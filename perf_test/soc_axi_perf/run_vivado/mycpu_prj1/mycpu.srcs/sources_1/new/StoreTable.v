`define indexBits 6    //��������
`define indexBits1 5    //��������-1
`define indexBits2 7    //��������+1  ��������λ
`define indexBits3 8    //��������+2  ��ǿ�ʼλ  
`define tagsize1 23    //��־����-1
`define stSize    64   //�����С����λ���֣�
`define stSize1   63   //�����С-1����λ���֣�

module StoreTable(
    input wire clk,
    input wire rst,
    
    //��ˮ��
    input wire isStore,     //storeָ��
    input wire [3:0]  w_hcode,   //������
    input wire instr_nocache,  //������
    input wire [31:0] st_addr,   //��ַ
    input wire [31:0] st_wData,  //д����
    output wire [31:0] st_rData, //������
    
    output wire buffer_hit,    //��ַ����
    output wire canEnter,      //�ɻ���store
    
    //storeFIFO
    input wire [`indexBits1:0] out_index,   //��������table������
    input wire       out_ok,      //����ɹ�
    output wire [31:0] out_addr,  //�����ַ
    output wire [31:0] out_data   //��������
    );
    
    reg stValid   [`stSize1:0];
    reg stInFIFO  [`stSize1:0];
    reg [31:0] stData  [`stSize1:0];      
    reg [`tagsize1:0] stTag [`stSize1:0];      //��[`indexBits2:2]Ϊ�������� ��[indexBits3:7]Ϊ���
    
    wire [31:0] st_wData_silled;
    wire [3:0]  w_hcode_silled;
    wire [31:0] total_hcode;
    assign st_wData_silled = (w_hcode==4'b1111) ? st_wData :
                                (w_hcode==4'b0011) ? (st_addr[1]?{st_wData[15:0],16'b0}:{16'b0,st_wData[15:0]}) : 
                                (st_addr[1]? (st_addr[0]?{st_wData[7:0],24'b0}:{5'b0,st_wData[7:0],16'b0}) : (st_addr[0]?{16'b0,st_wData[7:0],8'b0}:{24'b0,st_wData[7:0]}));
    assign w_hcode_silled = (w_hcode==4'b1111) ? w_hcode :
                            (w_hcode==4'b0011) ? (st_addr[1]?4'b1100:4'b0011) : (w_hcode << st_addr[1:0]);
    assign total_hcode = {(w_hcode_silled[3]? 8'hFF:8'h00),(w_hcode_silled[2]? 8'hFF:8'h00),(w_hcode_silled[1]? 8'hFF:8'h00),(w_hcode_silled[0]? 8'hFF:8'h00)};

    assign st_rData = stData[st_addr[`indexBits2:2]];
    assign buffer_hit  = ((stTag[st_addr[`indexBits2:2]])==st_addr[31:`indexBits3]) && stValid[st_addr[`indexBits2:2]];
    assign canEnter = instr_nocache ? 1'b0 :  //���費��
                        //дȫ�� -> (�� | ����λ�� | ���ڶ���) ����
                        (w_hcode==4'b1111) ? (~stValid[st_addr[`indexBits2:2]] || ((stTag[st_addr[`indexBits2:2]])==st_addr[31:`indexBits3]) || ~stInFIFO[st_addr[`indexBits2:2]]) :  
                        //д����/�ֽ� -> ���п���
                         (stValid[st_addr[`indexBits2:2]] && ((stTag[st_addr[`indexBits2:2]])==st_addr[31:`indexBits3]));
  // ������ & ������ & (��/����/��ռ��(���ڶ���))
    
    assign out_addr = {stTag[out_index],out_index,2'b00};
    assign out_data = stData[out_index];
                        
    integer i;
// ʱ���߼� - �����У�������Ԫ�� �� �滻��Ԫ��
    always@(posedge clk)begin
        if(rst) begin
        //������ݺͶ��У�αɾ����
            for(i = 0; i<`stSize; i=i+1)begin
                stValid[i]  <= 0;
                stInFIFO[i] <= 0; 
            end
        end
        else begin
        //ָ����� & ����-> inqueue     cache���� & data_ok -> outFIFO
            stInFIFO [out_index] <= out_ok ? 1'b0 : stInFIFO [out_index];
            
            stValid [st_addr[`indexBits2:2]] <= (isStore & canEnter) ? 1'b1 : stValid [st_addr[`indexBits2:2]];
            stInFIFO [st_addr[`indexBits2:2]] <= (isStore & canEnter) ? 1'b1 : stInFIFO [st_addr[`indexBits2:2]];
            stTag [st_addr[`indexBits2:2]] <= (isStore & canEnter) ? st_addr[31:`indexBits3] : stTag [st_addr[`indexBits2:2]];
            stData [st_addr[`indexBits2:2]] <= (isStore & canEnter) ? ((st_wData_silled & total_hcode)|(stData [st_addr[`indexBits2:2]] & (~total_hcode))) : stData [st_addr[`indexBits2:2]];
        end
    end

endmodule
