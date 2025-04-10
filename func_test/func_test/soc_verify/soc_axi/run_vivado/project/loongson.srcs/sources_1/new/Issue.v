`timescale 1ns / 1ps

module Issue(
    //����storeFIFO��ֻ������ �������store ָ��
    input  wire         FIFO_en,     // ��ʾ�Ƿ���Ԫ����Ҫ���䣬����֤�ô���м��
    input  wire [31:0]  FIFO_addr,
    input  wire [3:0]   FIFO_wen,
    input  wire [31:0]  FIFO_wdata,
    output wire         FIFO_data_ok,
//    output wire         FIFO_addr_ok,     
    
    //������ˮ�������ȼ����
    input  wire         instr_en,
    input  wire [31:0]  instr_addr,
    input  wire [3:0]   instr_wen,
    input  wire [31:0]  instr_wdata,
    output wire         instr_data_ok,
//    output wire         instr_addr_ok,     
    output wire [31:0]  instr_rdata,
    input  wire         instr_nocache,
    
    //���͸���sram�ӿ�
    output wire         sram_data_en,
    output wire [31:0]  sram_data_addr,
    output wire  [3:0]  sram_data_wen,
    output wire [31:0]  sram_data_wdata,
    input  wire         sram_data_ok,   
    input  wire         sram_addr_ok,   
    input  wire [31:0]  sram_data_rdata,
    
    output wire         noCache
    );
    
    //��storeFIFO����ˮ�������ȼ����ӵ�data_sram_like
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
