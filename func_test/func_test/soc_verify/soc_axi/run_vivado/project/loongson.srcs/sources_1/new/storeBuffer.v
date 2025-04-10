module storeBuffer(
    input wire clk,
    input wire rst,
    
    //流水级
    input wire isStore,     //store指令
    input wire [3:0]  w_hcode,   //有掩码
    input wire instr_nocache,  //访外设
    input wire [31:0] st_addr,   //地址
    input wire [31:0] st_wData,  //写数据
    output wire [31:0] st_rData, //读数据
    output wire buffer_hit,    //地址命中
    output wire canEnter,      //可缓存store
    
    //issue
    output wire FIFO_en,          //需要发射
    output wire [31:0] FIFO_addr,  //发射store地址
    output wire  [3:0] FIFO_wen,   //发射store掩码（4'b1111）
    output wire [31:0] FIFO_wdata, //发射store写数据
    input wire FIFO_data_ok //发射完成
);

wire [4:0]  out_index;   //发射项在table的索引   
wire        out_ok;      //发射成功           
wire [31:0] out_addr;    //发射地址           
wire [31:0] out_data;    //发射数据           

StoreFIFO storefifo(
    .clk(clk),
    .rst(rst),
    
    //流水级
    .isStore(isStore),
    .st_addr(st_addr),
    
    //storeTable
    .canEnter(canEnter),
    .out_index(out_index),   //发射项在table的索引
    .out_ok(out_ok),      //发射成功
    .out_addr(out_addr),  //发射地址
    .out_data(out_data),   //发射数据
   
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

    .isStore(isStore),     //store指令
    .w_hcode(w_hcode),   //有掩码
    .instr_nocache(instr_nocache),  //访外设
    .st_addr(st_addr),   //地址
    .st_wData(st_wData),  //写数据
    .st_rData(st_rData), //读数据
    .buffer_hit(buffer_hit),    //地址命中
    .canEnter(canEnter),      //可缓存store

    .out_index(out_index),   //发射项在table的索引
    .out_ok(out_ok),      //发射成功
    .out_addr(out_addr),  //发射地址
    .out_data(out_data)   //发射数据
    );
endmodule