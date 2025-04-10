`timescale 1ns / 1ps
module oneTotwo_tb();

reg         cpu_wrap_aclk   ;
reg         cpu_wrap_aresetn;
reg  [3 :0] cpu_wrap_arid   ;
reg  [31:0] cpu_wrap_araddr ;
reg  [7 :0] cpu_wrap_arlen  ;
reg  [2 :0] cpu_wrap_arsize ;
reg  [1 :0] cpu_wrap_arburst;
reg  [1 :0] cpu_wrap_arlock ;
reg  [3 :0] cpu_wrap_arcache;
reg  [2 :0] cpu_wrap_arprot ;
reg         cpu_wrap_arvalid;
wire        cpu_wrap_arready;

wire [3 :0] cpu_wrap_rid    ;
wire [31:0] cpu_wrap_rdata  ;
wire [1 :0] cpu_wrap_rresp  ;
wire        cpu_wrap_rlast  ;
wire        cpu_wrap_rvalid ;
reg         cpu_wrap_rready ;

wire [3 :0] cpu_wrap_awid   ;
wire [31:0] cpu_wrap_awaddr ;
wire [7 :0] cpu_wrap_awlen  ;
wire [2 :0] cpu_wrap_awsize ;
wire [1 :0] cpu_wrap_awburst;
wire [1 :0] cpu_wrap_awlock ;
wire [3 :0] cpu_wrap_awcache;
wire [2 :0] cpu_wrap_awprot ;
wire        cpu_wrap_awvalid;
wire        cpu_wrap_awready;
wire [3 :0] cpu_wrap_wid    ;
wire [31:0] cpu_wrap_wdata  ;
wire [3 :0] cpu_wrap_wstrb  ;
wire        cpu_wrap_wlast  ;
wire        cpu_wrap_wvalid ;
wire        cpu_wrap_wready ;
wire [3 :0] cpu_wrap_bid    ;
wire [1 :0] cpu_wrap_bresp  ;
wire        cpu_wrap_bvalid ;
wire        cpu_wrap_bready ;
//axi ram
wire [3 :0] ram_arid   ;
wire [31:0] ram_araddr ;
wire [3 :0] ram_arlen  ;
wire [2 :0] ram_arsize ;
wire [1 :0] ram_arburst;
wire [1 :0] ram_arlock ;
wire [3 :0] ram_arcache;
wire [2 :0] ram_arprot ;
wire        ram_arvalid;
wire        ram_arready;
wire [3 :0] ram_rid    ;
wire [31:0] ram_rdata  ;
wire [1 :0] ram_rresp  ;
wire        ram_rlast  ;
wire        ram_rvalid ;
wire        ram_rready ;
wire [3 :0] ram_awid   ;
wire [31:0] ram_awaddr ;
wire [3 :0] ram_awlen  ;
wire [2 :0] ram_awsize ;
wire [1 :0] ram_awburst;
wire [1 :0] ram_awlock ;
wire [3 :0] ram_awcache;
wire [2 :0] ram_awprot ;
wire        ram_awvalid;
wire        ram_awready;
wire [3 :0] ram_wid    ;
wire [31:0] ram_wdata  ;
wire [3 :0] ram_wstrb  ;
wire        ram_wlast  ;
wire        ram_wvalid ;
wire        ram_wready ;
wire [3 :0] ram_bid    ;
wire [1 :0] ram_bresp  ;
wire        ram_bvalid ;
wire        ram_bready ;
//conf
wire [3 :0] conf_arid   ;
wire [31:0] conf_araddr ;
wire [3 :0] conf_arlen  ;
wire [2 :0] conf_arsize ;
wire [1 :0] conf_arburst;
wire [1 :0] conf_arlock ;
wire [3 :0] conf_arcache;
wire [2 :0] conf_arprot ;
wire        conf_arvalid;
wire        conf_arready;
wire [3 :0] conf_rid    ;
wire [31:0] conf_rdata  ;
wire [1 :0] conf_rresp  ;
wire        conf_rlast  ;
wire        conf_rvalid ;
wire        conf_rready ;
wire [3 :0] conf_awid   ;
wire [31:0] conf_awaddr ;
wire [3 :0] conf_awlen  ;
wire [2 :0] conf_awsize ;
wire [1 :0] conf_awburst;
wire [1 :0] conf_awlock ;
wire [3 :0] conf_awcache;
wire [2 :0] conf_awprot ;
wire        conf_awvalid;
wire        conf_awready;
wire [3 :0] conf_wid    ;
wire [31:0] conf_wdata  ;
wire [3 :0] conf_wstrb  ;
wire        conf_wlast  ;
wire        conf_wvalid ;
wire        conf_wready ;
wire [3 :0] conf_bid    ;
wire [1 :0] conf_bresp  ;
wire        conf_bvalid ;
wire        conf_bready ;


axi_crossbar_1x2 u_axi_crossbar_1x2(
    .aclk             ( cpu_wrap_aclk        ), // i, 1                 
    .aresetn          ( cpu_wrap_aresetn     ), // i, 1                 

    .s_axi_arid       ( cpu_wrap_arid        ),
    .s_axi_araddr     ( cpu_wrap_araddr      ),
    .s_axi_arlen      ( cpu_wrap_arlen[3:0]  ),
    .s_axi_arsize     ( cpu_wrap_arsize      ),
    .s_axi_arburst    ( cpu_wrap_arburst     ),
    .s_axi_arlock     ( cpu_wrap_arlock      ),
    .s_axi_arcache    ( cpu_wrap_arcache     ),
    .s_axi_arprot     ( cpu_wrap_arprot      ),
    .s_axi_arqos      ( 4'd0                 ),
    .s_axi_arvalid    ( cpu_wrap_arvalid     ),
    .s_axi_arready    ( cpu_wrap_arready     ),
    .s_axi_rid        ( cpu_wrap_rid         ),
    .s_axi_rdata      ( cpu_wrap_rdata       ),
    .s_axi_rresp      ( cpu_wrap_rresp       ),
    .s_axi_rlast      ( cpu_wrap_rlast       ),
    .s_axi_rvalid     ( cpu_wrap_rvalid      ),
    .s_axi_rready     ( cpu_wrap_rready      ),
    .s_axi_awid       ( cpu_wrap_awid        ),
    .s_axi_awaddr     ( cpu_wrap_awaddr      ),
    .s_axi_awlen      ( cpu_wrap_awlen[3:0]  ),
    .s_axi_awsize     ( cpu_wrap_awsize      ),
    .s_axi_awburst    ( cpu_wrap_awburst     ),
    .s_axi_awlock     ( cpu_wrap_awlock      ),
    .s_axi_awcache    ( cpu_wrap_awcache     ),
    .s_axi_awprot     ( cpu_wrap_awprot      ),
    .s_axi_awqos      ( 4'd0                 ),
    .s_axi_awvalid    ( cpu_wrap_awvalid     ),
    .s_axi_awready    ( cpu_wrap_awready     ),
    .s_axi_wid        ( cpu_wrap_wid         ),
    .s_axi_wdata      ( cpu_wrap_wdata       ),
    .s_axi_wstrb      ( cpu_wrap_wstrb       ),
    .s_axi_wlast      ( cpu_wrap_wlast       ),
    .s_axi_wvalid     ( cpu_wrap_wvalid      ),
    .s_axi_wready     ( cpu_wrap_wready      ),
    .s_axi_bid        ( cpu_wrap_bid         ),
    .s_axi_bresp      ( cpu_wrap_bresp       ),
    .s_axi_bvalid     ( cpu_wrap_bvalid      ),
    .s_axi_bready     ( cpu_wrap_bready      ),

    .m_axi_arid       ( {ram_arid   ,conf_arid   } ),
    .m_axi_araddr     ( {ram_araddr ,conf_araddr } ),
    .m_axi_arlen      ( {ram_arlen  ,conf_arlen  } ),
    .m_axi_arsize     ( {ram_arsize ,conf_arsize } ),
    .m_axi_arburst    ( {ram_arburst,conf_arburst} ),
    .m_axi_arlock     ( {ram_arlock ,conf_arlock } ),
    .m_axi_arcache    ( {ram_arcache,conf_arcache} ),
    .m_axi_arprot     ( {ram_arprot ,conf_arprot } ),
    .m_axi_arqos      (                            ),
    .m_axi_arvalid    ( {ram_arvalid,conf_arvalid} ),
    .m_axi_arready    ( {ram_arready,conf_arready} ),
    .m_axi_rid        ( {ram_rid    ,conf_rid    } ),
    .m_axi_rdata      ( {ram_rdata  ,conf_rdata  } ),
    .m_axi_rresp      ( {ram_rresp  ,conf_rresp  } ),
    .m_axi_rlast      ( {ram_rlast  ,conf_rlast  } ),
    .m_axi_rvalid     ( {ram_rvalid ,conf_rvalid } ),
    .m_axi_rready     ( {ram_rready ,conf_rready } ),
    .m_axi_awid       ( {ram_awid   ,conf_awid   } ),
    .m_axi_awaddr     ( {ram_awaddr ,conf_awaddr } ),
    .m_axi_awlen      ( {ram_awlen  ,conf_awlen  } ),
    .m_axi_awsize     ( {ram_awsize ,conf_awsize } ),
    .m_axi_awburst    ( {ram_awburst,conf_awburst} ),
    .m_axi_awlock     ( {ram_awlock ,conf_awlock } ),
    .m_axi_awcache    ( {ram_awcache,conf_awcache} ),
    .m_axi_awprot     ( {ram_awprot ,conf_awprot } ),
    .m_axi_awqos      (                            ),
    .m_axi_awvalid    ( {ram_awvalid,conf_awvalid} ),
    .m_axi_awready    ( {ram_awready,conf_awready} ),
    .m_axi_wid        ( {ram_wid    ,conf_wid    } ),
    .m_axi_wdata      ( {ram_wdata  ,conf_wdata  } ),
    .m_axi_wstrb      ( {ram_wstrb  ,conf_wstrb  } ),
    .m_axi_wlast      ( {ram_wlast  ,conf_wlast  } ),
    .m_axi_wvalid     ( {ram_wvalid ,conf_wvalid } ),
    .m_axi_wready     ( {ram_wready ,conf_wready } ),
    .m_axi_bid        ( {ram_bid    ,conf_bid    } ),
    .m_axi_bresp      ( {ram_bresp  ,conf_bresp  } ),
    .m_axi_bvalid     ( {ram_bvalid ,conf_bvalid } ),
    .m_axi_bready     ( {ram_bready ,conf_bready } )

 );
 
 initial cpu_wrap_aclk = 1; 
 always #5 cpu_wrap_aclk = ~cpu_wrap_aclk;
 
 initial begin
    cpu_wrap_aresetn = 1;
    cpu_wrap_arid=5;
    cpu_wrap_araddr=32'h1b000018;
    cpu_wrap_arlen=0;
    cpu_wrap_arsize=3'b010; 
    cpu_wrap_arburst=2'b01;
    cpu_wrap_arlock= 2'b00;
    cpu_wrap_arcache=4'b0000;
    cpu_wrap_arprot=3'b000; 
    cpu_wrap_arvalid =1;
    #1000;
    $stop;
 end
 endmodule