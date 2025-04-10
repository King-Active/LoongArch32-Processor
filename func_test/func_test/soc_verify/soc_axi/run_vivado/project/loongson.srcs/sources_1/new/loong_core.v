module loong_core_p (
    input wire clk, rst,

    //instr
    output wire         inst_req,
    output wire         inst_wr,       //no
    output wire [1:0]   inst_size,     //no
    output wire [31:0]  inst_addr,
    output wire [31:0]  inst_wdata,    //no
    input wire          inst_addr_ok,  //no
    input wire          inst_data_ok,
    input wire [31:0]   inst_rdata,

    //data
    /*  与外部存储器的交互  */
    output wire  [31:0] cpu_sram_addr,               // 虚拟地址，传递给mmu
    output wire         cpu_sram_req,
    output wire         cpu_sram_wr,                
    output wire  [1:0]  cpu_sram_size,               
    output wire  [31:0] cpu_sram_wdata,
    input  wire  [31:0] cpu_sram_rdata,
    input  wire         cpu_sram_addr_ok,
    input  wire         cpu_sram_data_ok,
    
    output wire         noCache,
    
    //debug
    output wire [31:0]  debug_wb_pc,      
    output wire [3:0]   debug_wb_rf_wen,
    output wire [4:0]   debug_wb_rf_wnum, 
    output wire [31:0]  debug_wb_rf_wdata
);

    assign inst_wr    = 1'b0;
    assign inst_size  = 2'b10;
    assign inst_wdata = 32'b0;
    
    wire           sram_data_en;            
    wire  [3:0]    sram_data_wen;          
    wire  [31:0]   sram_data_addr;            
    wire  [31:0]   sram_data_wdata;          
    wire           sram_data_ok;
    wire           sram_addr_ok;     
    wire  [31:0]   sram_data_rdata;
   
    datapath datapath(
        .clk(clk), .rst(rst),

        //inst
        .pc(inst_addr),       
        .inst_data_ok(inst_data_ok),
        .inst_rdata(inst_rdata),
        .inst_req(inst_req),
        
        //data
        .sram_data_en(sram_data_en),            
        .sram_data_wen(sram_data_wen),          
        .sram_data_addr(sram_data_addr),            
        .sram_data_wdata(sram_data_wdata),          
        .sram_data_ok(sram_data_ok),
        .sram_addr_ok(sram_addr_ok),     
        .sram_data_rdata(sram_data_rdata),
        
        .noCache(noCache),

        //debug
        .debug_wb_pc       (debug_wb_pc       ),  
        .debug_wb_rf_wen   (debug_wb_rf_wen   ),  
        .debug_wb_rf_wnum  (debug_wb_rf_wnum  ),  
        .debug_wb_rf_wdata (debug_wb_rf_wdata )  
    );

    //data sram to sram-like
data_sram_like u_data_sram_like(
    .clk(clk),
    .rst(rst),
    
    /*  来自issue的访存请求发射  */
    .sram_data_en(sram_data_en),            
    .sram_data_wen(sram_data_wen),          
    .sram_data_addr(sram_data_addr),            
    .sram_data_wdata(sram_data_wdata),          
    .sram_data_ok(sram_data_ok),
    .sram_addr_ok(sram_addr_ok),     
    .sram_data_rdata(sram_data_rdata),
    
    /*  与外部存储器的交互  */
    .cpu_sram_addr(cpu_sram_addr),               // 虚拟地址，传递给mmu
    .cpu_sram_req(cpu_sram_req),
    .cpu_sram_wr(cpu_sram_wr),                
    .cpu_sram_size(cpu_sram_size),               
    .cpu_sram_wdata(cpu_sram_wdata),
    .cpu_sram_rdata(cpu_sram_rdata),
    .cpu_sram_addr_ok(cpu_sram_addr_ok),
    .cpu_sram_data_ok(cpu_sram_data_ok)
);
    
    
endmodule