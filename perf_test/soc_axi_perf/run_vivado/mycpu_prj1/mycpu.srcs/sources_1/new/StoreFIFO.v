`define indexBits 6    //��������
`define indexBits1 5    //��������-1
`define indexBits2 7    //��������+1  ��������λ
`define indexBits3 8    //��������+2  ��ǿ�ʼλ  
`define tagsize1 23    //��־����-1
`define stSize    64   //�����С����λ���֣�
`define stSize1   63   //�����С-1����λ���֣�
module StoreFIFO(
    input wire clk,
    input wire rst,
    
    //��ˮ��
    input wire isStore,
    input wire [31:0] st_addr,
    
    //storeTable
    input wire canEnter,
    output wire [`indexBits1:0] out_index,   //��������table������
    output wire       out_ok,      //����ɹ�
    input wire [31:0] out_addr,  //�����ַ
    input wire [31:0] out_data,   //��������
   
    //issue
    output wire FIFO_en,
    output wire [31:0] FIFO_addr,
    output wire [3:0]  FIFO_wen,    
    output wire [31:0] FIFO_wdata,
    input  wire FIFO_data_ok   
    );
    
    reg  [`indexBits1:0] W_index;
    reg  [`indexBits1:0] R_index;
    reg  [`indexBits1:0] stFIFO [`stSize1:0];
    reg  [`indexBits:0] content;    //������ЧԪ�ظ���
    assign out_ok = FIFO_data_ok;
    
    integer i;
    always@(posedge clk) begin
        if(rst)begin
            content <= 0;
            W_index <= 0;
            R_index <= 0;
        end
        else begin
             R_index <= out_ok ? (R_index + 1) : R_index;
             content <= (out_ok & ~(isStore & canEnter)) ? (content - 1) : 
                        (~out_ok & (isStore & canEnter)) ? (content + 1) :content;
             stFIFO[W_index] <= (isStore & canEnter) ? {st_addr[`indexBits2:2]} : stFIFO[W_index];
             W_index <= (isStore & canEnter) ? (W_index + 1) : W_index;      
        end
    end
    
    assign out_index = stFIFO[R_index];
    assign FIFO_en = content>0 ? 1:0;
    assign FIFO_addr = FIFO_en ? out_addr:32'h1FB0_0000;
    assign FIFO_wen  = FIFO_en ? 4'b1111:4'b0000;
    assign FIFO_wdata = FIFO_en ? out_data : 32'b0;
   
endmodule
