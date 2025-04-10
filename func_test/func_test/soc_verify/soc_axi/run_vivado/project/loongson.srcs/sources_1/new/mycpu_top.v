module mycpu_top(
    input wire [5:0] ext_int,  

    input wire aclk,    
    input wire aresetn,   

    //axi
    //ar 
    output wire[3:0] arid,
    output wire[31:0] araddr,
    output wire[7:0] arlen,
    output wire[2:0] arsize,
    output wire[1:0] arburst,
    output wire[1:0] arlock,
    output wire[3:0] arcache,
    output wire[2:0] arprot,
    output wire arvalid,
    input wire arready,
    //r           
    input wire[3:0] rid,
    input wire[31:0] rdata,
    input wire[1:0] rresp,
    input wire rlast,
    input wire rvalid,
    output wire rready, 
    //aw           
    output wire[3:0] awid,
    output wire[31:0] awaddr,
    output wire[7:0] awlen,
    output wire[2:0] awsize,
    output wire[1:0] awburst,
    output wire[1:0] awlock,
    output wire[3:0] awcache,
    output wire[2:0] awprot,
    output wire awvalid,
    input wire awready,
    //w 
    output wire[3:0] wid,
    output wire[31:0] wdata,
    output wire[3:0] wstrb,
    output wire wlast,
    output wire wvalid,
    input  wire wready,
    //b
    input wire[3:0] bid,
    input wire[1:0] bresp,
    input wire bvalid,
    output wire bready,

    //debug interface
    output wire[31:0] debug_wb_pc,
    output wire[3:0] debug_wb_rf_we,
    output wire[4:0] debug_wb_rf_wnum,
    output wire[31:0] debug_wb_rf_wdata
);
wire clk, rst;
assign clk = aclk;
assign rst = ~aresetn;

// ************************ 总线控制信号 *******************************
    wire noCache;           //是否为外设指令
    
    wire isReadRequring;    //AXI读通道繁忙(暂未使用)
    wire isWriteRequring;   //AXI写通道繁忙（暂未使用）
//**********************************************************************    
//cpu ->icache
wire        cpu_inst_req  ;
wire [31:0] cpu_inst_addr ;
wire        cpu_inst_wr   ;
wire [1:0]  cpu_inst_size ;
wire [31:0] cpu_inst_wdata;
wire [31:0] cpu_inst_rdata;
wire        cpu_inst_addr_ok;
wire        cpu_inst_data_ok;
//cpu -> sram_like -> 1x2
wire        cpu_sram_req  ;
wire [31:0] cpu_sram_addr ;
wire        cpu_sram_wr   ;
wire [1:0]  cpu_sram_size ;
wire [31:0] cpu_sram_wdata;
wire [31:0] cpu_sram_rdata;
wire        cpu_sram_addr_ok;
wire        cpu_sram_data_ok;
//1x2 -> dcache
wire        ram_data_req  ;
wire [31:0] ram_data_addr ;
wire        ram_data_wr   ;
wire [1:0]  ram_data_size ;
wire [31:0] ram_data_wdata;
wire [31:0] ram_data_rdata;
wire        ram_data_addr_ok;
wire        ram_data_data_ok;
//dcache -> 2x1
wire        cache_data_req;        
wire        cache_data_wr;        
wire [1 :0] cache_data_size;        
wire [31:0] cache_data_addr;        
wire [31:0] cache_data_wdata;        
wire [31:0] cache_data_rdata;        
wire        cache_data_addr_ok;        
wire        cache_data_data_ok;   
//1x2 -> 2x1  (confrg)
wire        conf_data_req  ;
wire [31:0] conf_data_addr ;
wire        conf_data_wr   ;
wire [1:0]  conf_data_size ;
wire [31:0] conf_data_wdata;
wire [31:0] conf_data_rdata;
wire        conf_data_addr_ok;
wire        conf_data_data_ok;
//2x1 -> cpu_axi_interface
wire        wrap_data_req  ;
wire [31:0] wrap_data_addr ;
wire        wrap_data_wr   ;
wire [1:0]  wrap_data_size ;
wire [31:0] wrap_data_wdata;
wire [31:0] wrap_data_rdata;
wire        wrap_data_addr_ok;
wire        wrap_data_data_ok;

//mmu ->1x2
wire [31:0] cpu_inst_paddr;
wire [31:0] cpu_sram_paddr;

wire         vcm_req    ;
wire         vcm_wr     ;
wire  [1 :0] vcm_size   ;
wire  [31:0] vcm_addr   ;
wire  [31:0] vcm_wdata  ;
wire  [31:0] vcm_rdata  ;
wire         vcm_addr_ok;
wire         vcm_data_ok;
wire         vcm_wlast  ;
wire         vcm_wready ;
 
wire instr_req     ;
wire instr_wr      ;
wire [1:0]instr_size    ;
wire [31:0]instr_addr    ;
wire [31:0]instr_wdata   ;
wire [31:0]instr_rdata   ;
wire instr_addr_ok ;
wire instr_data_ok ;

loong_core_p loong_core (
    .clk(clk),
    .rst(rst),
    //instr
    .inst_req(cpu_inst_req),
    .inst_wr(cpu_inst_wr),       //no
    .inst_size(cpu_inst_size),     //no
    .inst_addr(cpu_inst_addr),
    .inst_wdata(cpu_inst_wdata),    //no
    .inst_addr_ok(cpu_inst_addr_ok),  //no
    .inst_data_ok(cpu_inst_data_ok),
    .inst_rdata(cpu_inst_rdata),

    //data
    /*  与外部存储器的交互  */
    .cpu_sram_addr(cpu_sram_addr),               // 虚拟地址，传递给mmu
    .cpu_sram_req(cpu_sram_req),
    .cpu_sram_wr(cpu_sram_wr),                
    .cpu_sram_size(cpu_sram_size),               
    .cpu_sram_wdata(cpu_sram_wdata),
    .cpu_sram_rdata(cpu_sram_rdata),
    .cpu_sram_addr_ok(cpu_sram_addr_ok),
    .cpu_sram_data_ok(cpu_sram_data_ok),
    
    .noCache(noCache),
    
    //debug
    .debug_wb_pc(debug_wb_pc),      
    .debug_wb_rf_wen(debug_wb_rf_we),
    .debug_wb_rf_wnum(debug_wb_rf_wnum), 
    .debug_wb_rf_wdata(debug_wb_rf_wdata)
);

bridge1x2 b1x2(
    /*  来自总线的外设指令判断  */
    .noCache(noCache),
    
    /*  来自类sram接口的访存请求  */
    .cpu_sram_addr(cpu_sram_paddr),     
    .cpu_sram_req(cpu_sram_req),      
    .cpu_sram_wr(cpu_sram_wr),       
    .cpu_sram_size(cpu_sram_size),     
    .cpu_sram_wdata(cpu_sram_wdata),    
    .cpu_sram_rdata(cpu_sram_rdata),    
    .cpu_sram_addr_ok(cpu_sram_addr_ok),
    .cpu_sram_data_ok(cpu_sram_data_ok),
    
    /*  与cache的访存交互  */
    .ram_data_req(ram_data_req),
    .ram_data_wr(ram_data_wr),
    .ram_data_size(ram_data_size),
    .ram_data_addr(ram_data_addr),
    .ram_data_wdata(ram_data_wdata),
    .ram_data_rdata(ram_data_rdata),
    .ram_data_addr_ok(ram_data_addr_ok),
    .ram_data_data_ok(ram_data_data_ok),
    
    /*  与外设的访存交互  */
    .conf_data_req(conf_data_req),
    .conf_data_wr(conf_data_wr),
    .conf_data_size(conf_data_size),
    .conf_data_addr(conf_data_addr),
    .conf_data_wdata(conf_data_wdata),
    .conf_data_rdata(conf_data_rdata),
    .conf_data_addr_ok(conf_data_addr_ok),
    .conf_data_data_ok(conf_data_data_ok)
);

mmu mmu(
    .inst_vaddr(cpu_inst_addr ),
    .inst_paddr(cpu_inst_paddr),
    .data_vaddr(cpu_sram_addr ),
    .data_paddr(cpu_sram_paddr)
);

dCache dcache(
    .clk(clk),
    .rst(~rst),
    /*  经过cache的访存交互  */
    .ram_data_req(ram_data_req),
    .ram_data_wr(ram_data_wr),
    .ram_data_size(ram_data_size),
    .ram_data_addr(ram_data_addr),
    .ram_data_wdata(ram_data_wdata),
    .ram_data_rdata(ram_data_rdata),
    .ram_data_addr_ok(ram_data_addr_ok),
    .ram_data_data_ok(ram_data_data_ok),
    
    /*  来自 victimCache 的写访存交互  */
   .vcm_data_req     (vcm_req    ),
   .vcm_data_wr      (vcm_wr     ), 
   .vcm_data_size    (vcm_size   ), 
   .vcm_data_addr    (vcm_addr   ), 
   .vcm_data_wdata   (vcm_wdata  ), 
   .vcm_data_rdata   (vcm_rdata  ), 
   .vcm_data_addr_ok (vcm_addr_ok), 
   .vcm_data_data_ok (vcm_data_ok), 
   .vcm_wlast        (vcm_wlast  ),
   .vcm_wready       (vcm_wready ),
    
    /*  来自 主dCache 的读访存交互*/
    .cache_data_req(cache_data_req),        
    .cache_data_wr(cache_data_wr),        
    .cache_data_size(cache_data_size),        
    .cache_data_addr(cache_data_addr),        
    .cache_data_wdata(cache_data_wdata),        
    .cache_data_rdata(cache_data_rdata),        
    .cache_data_addr_ok(cache_data_addr_ok),        
    .cache_data_data_ok(cache_data_data_ok)
    );
    
bridge2x1 b2x1(
    .noCache(noCache),
    
    /*  dCache的读操作交互  */
    .cache_data_req(cache_data_req),        
    .cache_data_wr(cache_data_wr),        
    .cache_data_size(cache_data_size),        
    .cache_data_addr(cache_data_addr),        
    .cache_data_wdata(cache_data_wdata),        
    .cache_data_rdata(cache_data_rdata),        
    .cache_data_addr_ok(cache_data_addr_ok),        
    .cache_data_data_ok(cache_data_data_ok),   

    /*  外设的访存交互  */
    .conf_data_req(conf_data_req),
    .conf_data_wr(conf_data_wr),
    .conf_data_size(conf_data_size),
    .conf_data_addr(conf_data_addr),
    .conf_data_wdata(conf_data_wdata),
    .conf_data_rdata(conf_data_rdata),
    .conf_data_addr_ok(conf_data_addr_ok),
    .conf_data_data_ok(conf_data_data_ok),

    /*  与 AXI 接口的交互  */
    .wrap_data_req(wrap_data_req),
    .wrap_data_wr(wrap_data_wr),
    .wrap_data_size(wrap_data_size),
    .wrap_data_addr(wrap_data_addr),
    .wrap_data_wdata(wrap_data_wdata),
    .wrap_data_rdata(wrap_data_rdata),
    .wrap_data_addr_ok(wrap_data_addr_ok),
    .wrap_data_data_ok(wrap_data_data_ok)
);
    
    
iCache icache(
    .clk(clk),
    .rst(~rst),
    //cpu
    .instr_req    (cpu_inst_req  ),
    .instr_wr     (cpu_inst_wr   ),    
    .instr_size   (cpu_inst_size ),    
    .instr_addr   (cpu_inst_paddr),
    .instr_wdata  (cpu_inst_wdata),    
    .instr_rdata  (cpu_inst_rdata), 
    .instr_addr_ok(cpu_inst_addr_ok),
    .instr_data_ok(cpu_inst_data_ok),
    
    //axi
   .axi_req    (instr_req     ),
   .axi_wr     (instr_wr      ),
   .axi_size   (instr_size    ),
   .axi_addr   (instr_addr    ),
   .axi_wdata  (instr_wdata   ),
   .axi_rdata  (instr_rdata   ),
   .axi_addr_ok(instr_addr_ok ),
   .axi_data_ok(instr_data_ok )
    );
    
    cpu_axi_interface cx_interface(
    .isWriteRequring(isWriteRequring),
    .isReadRequring(isReadRequring),
    .noCache(noCache),     
    
    .clk(clk),
    .rst(~rst), 
    //inst sram-like 
    .instr_req   (instr_req     ),
    .instr_wr    (instr_wr      ),
    .instr_size  (instr_size    ),
    .instr_addr  (instr_addr    ),
    .instr_wdata (instr_wdata   ),
    .instr_rdata (instr_rdata   ),
    .instr_addr_ok(instr_addr_ok),
    .instr_data_ok(instr_data_ok), 
    
    //data sram-like 
    .data_req     (wrap_data_req    ),
    .data_wr      (wrap_data_wr     ),
    .data_size    (wrap_data_size   ),
    .data_addr    (wrap_data_addr   ),
    .data_wdata   (wrap_data_wdata  ),
    .data_rdata   (wrap_data_rdata  ),
    .data_addr_ok (wrap_data_addr_ok),
    .data_data_ok (wrap_data_data_ok),    //   读写

    //data victim_cache
   .vcm_req     (vcm_req    ),
   .vcm_wr      (vcm_wr     ), 
   .vcm_size    (vcm_size   ), 
   .vcm_addr    (vcm_addr   ), 
   .vcm_wdata   (vcm_wdata  ), 
   .vcm_rdata   (vcm_rdata  ), 
   .vcm_addr_ok (vcm_addr_ok), 
   .vcm_data_ok (vcm_data_ok), 
   .vcm_wlast   (vcm_wlast),
   .vcm_wready  (vcm_wready),
    
    //axi
   .arid    (arid    ) ,
   .araddr  (araddr  ) ,
   .arlen   (arlen   ) ,
   .arsize  (arsize  ) ,
   .arburst (arburst ) ,
   .arlock  (arlock  ) ,
   .arcache (arcache ) ,
   .arprot  (arprot  ) ,
   .arvalid (arvalid ) ,
   .arready (arready ) ,

   .rid     (rid     ) ,
   .rdata   (rdata   ) ,
   .rresp   (rresp   ) ,
   .rlast   (rlast   ) ,
   .rvalid  (rvalid  ) ,
   .rready  (rready  ) ,

   .awid    (awid    ) ,
   .awaddr  (awaddr  ) ,
   .awlen   (awlen   ) ,
   .awsize  (awsize  ) ,
   .awburst (awburst ) ,
   .awlock  (awlock  ) ,
   .awcache (awcache ) ,
   .awprot  (awprot  ) ,
   .awvalid (awvalid ) ,
   .awready (awready ) ,

   .wid     (wid     ) ,
   .wdata   (wdata   ) ,
   .wstrb   (wstrb   ) ,
   .wlast   (wlast   ) ,
   .wvalid  (wvalid  ) ,
   .wready  (wready  ) ,

   .bid     (bid     ) ,
   .bresp   (bresp   ) ,
   .bvalid  (bvalid  ) ,
   .bready  (bready  ) 
);

endmodule