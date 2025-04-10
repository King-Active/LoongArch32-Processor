`timescale 1ns / 1ps

module Issue(
    //来自storeFIFO，只可能是 非外设的store 指令
    input  wire         FIFO_en,     // 表示是否有元素需要发射，不保证访存空闲检查
    input  wire [31:0]  FIFO_addr,
    input  wire [3:0]   FIFO_wen,
    input  wire [31:0]  FIFO_wdata,
    output wire         FIFO_data_ok,
//    output wire         FIFO_addr_ok,     
    
    //来自流水级，优先级最高
    input  wire         instr_en,
    input  wire [31:0]  instr_addr,
    input  wire [3:0]   instr_wen,
    input  wire [31:0]  instr_wdata,
    output wire         instr_data_ok,
//    output wire         instr_addr_ok,     
    output wire [31:0]  instr_rdata,
    input  wire         instr_nocache,
    
    //发送给类sram接口
    output wire         sram_data_en,
    output wire [31:0]  sram_data_addr,
    output wire  [3:0]  sram_data_wen,
    output wire [31:0]  sram_data_wdata,
    input  wire         sram_data_ok,   
    input  wire         sram_addr_ok,   
    input  wire [31:0]  sram_data_rdata,
    
    output wire         noCache
    );
    
    //将storeFIFO与流水级按优先级连接到data_sram_like
    assign sram_data_en   =   (instr_en || FIFO_en);
   
    assign sram_data_addr =   (instr_en) ? instr_addr:
                                (FIFO_en)? FIFO_addr : 32'h1FB0_0000;
                                                                    
    assign sram_data_wen  =   (instr_en) ? instr_wen :
                                (FIFO_en) ? FIFO_addr : 4'b0000; 
                                
    assign sram_data_wdata =  (instr_en) ? instr_wdata :
                                (FIFO_en) ? FIFO_wdata : 32'b0;
                                
    assign FIFO_data_ok = ~instr_en & FIFO_en & sram_data_ok;
    
//    assign FIFO_addr_ok = ~instr_en & FIFO_en & sram_addr_ok;
    
    assign instr_data_ok = instr_en & sram_data_ok;
    
//    assign instr_addr_ok = instr_en & sram_addr_ok;
    
    assign instr_rdata = instr_en ? sram_data_rdata : 32'b00000000;
    
    assign noCache =  (instr_en) & instr_nocache ;          
    
endmodule
