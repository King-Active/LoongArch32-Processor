module data_sram_like(
    input wire                 clk,
    input wire                 rst,
    
    /*  来自issue的访存请求发射  */
    input  wire                sram_data_en,            
    input  wire  [3:0]         sram_data_wen,          
    input  wire  [31:0]        sram_data_addr,            
    input  wire  [31:0]        sram_data_wdata,          
    output wire  [31:0]        sram_data_ok,
    output wire                sram_addr_ok,     
    output wire  [31:0]        sram_data_rdata,
    
    /*  与外部存储器的交互  */
    output wire  [31:0]        cpu_sram_addr,               // 虚拟地址，传递给mmu
    output wire                cpu_sram_req,
    output wire                cpu_sram_wr,                
    output wire  [1:0]         cpu_sram_size,               
    output wire  [31:0]        cpu_sram_wdata,
    input  wire  [31:0]        cpu_sram_rdata,
    input  wire                cpu_sram_addr_ok,
    input  wire                cpu_sram_data_ok
);
    /*  发送给访存设备  */
    assign cpu_sram_req        =    sram_data_en;
    assign cpu_sram_wr         =    (sram_data_wen != 4'b0000);      
    assign cpu_sram_size       =    (sram_data_wen) == 4'b0001 ? 2'b00:             //ST.B，写rd[7:0]
                                    (sram_data_wen) == 4'b0011 ? 2'b01:             //ST.H，写rd[15:0]
                                    (sram_data_wen) == 4'b1111 ? 2'b10 : 2'b10;     //ST.W，写rd[31:0] ， 默认全写          
    assign cpu_sram_addr       =    sram_data_addr;
    assign cpu_sram_wdata      =    sram_data_wdata;
    
    /*  返回给内核  */
    assign sram_data_rdata     =    cpu_sram_data_ok? cpu_sram_rdata : 32'b0;
    assign sram_addr_ok        =    sram_data_en & cpu_sram_addr_ok;
    assign sram_data_ok        =    sram_data_en & cpu_sram_data_ok;
    
endmodule