module storeBuffer(
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
    
    //issue
    output wire FIFO_en,          //��Ҫ����
    output wire [31:0] FIFO_addr,  //����store��ַ
    output wire  [3:0] FIFO_wen,   //����store���루4'b1111��
    output wire [31:0] FIFO_wdata, //����storeд����
    input wire FIFO_data_ok //�������
);

wire [4:0]  out_index;   //��������table������   
wire        out_ok;      //����ɹ�           
wire [31:0] out_addr;    //�����ַ           
wire [31:0] out_data;    //��������           

StoreFIFO storefifo(
    .clk(clk),
    .rst(rst),
    
    //��ˮ��
    .isStore(isStore),
    .st_addr(st_addr),
    
    //storeTable
    .canEnter(canEnter),
    .out_index(out_index),   //��������table������
    .out_ok(out_ok),      //����ɹ�
    .out_addr(out_addr),  //�����ַ
    .out_data(out_data),   //��������
   
    //issue
    .FIFO_en(FIFO_en),
    .FIFO_addr(FIFO_addr),
    .FIFO_wen(FIFO_wen),    
    .FIFO_wdata(FIFO_wdata),
    .FIFO_data_ok(FIFO_data_ok)
    );

StoreTable storetable(
    .clk(clk),
    .rst(rst),

    .isStore(isStore),     //storeָ��
    .w_hcode(w_hcode),   //������
    .instr_nocache(instr_nocache),  //������
    .st_addr(st_addr),   //��ַ
    .st_wData(st_wData),  //д����
    .st_rData(st_rData), //������
    .buffer_hit(buffer_hit),    //��ַ����
    .canEnter(canEnter),      //�ɻ���store

    .out_index(out_index),   //��������table������
    .out_ok(out_ok),      //����ɹ�
    .out_addr(out_addr),  //�����ַ
    .out_data(out_data)   //��������
    );
endmodule