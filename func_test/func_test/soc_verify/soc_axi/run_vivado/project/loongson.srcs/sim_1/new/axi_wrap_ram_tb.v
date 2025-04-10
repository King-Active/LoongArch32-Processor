`timescale 1ns / 1ps  
  
module axi_wrap_ram_tb;  
  
// Inputs  
reg aclk;  
reg aresetn;  
reg [3:0] axi_arid;  
reg [31:0] axi_araddr;  
reg [7:0] axi_arlen;  // Length in bytes - 1, so 15 for 16 bytes  
reg [2:0] axi_arsize; // 2'b10 for 32-bit words  
reg [1:0] axi_arburst;  
reg [1:0] axi_arlock;  
reg [3:0] axi_arcache;  
reg [2:0] axi_arprot;  
reg axi_arvalid;  

reg [3:0]  axi_awid;  
reg [31:0] axi_awaddr;  
reg [7:0]  axi_awlen;  
reg [2:0]  axi_awsize;  
reg [1:0]  axi_awburst;  
reg [1:0]  axi_awlock;  
reg [3:0]  axi_awcache;  
reg [2:0]  axi_awprot;  
reg        axi_awvalid;  
reg [3:0]  axi_wid;  
reg [31:0] axi_wdata;  
reg [3:0]  axi_wstrb;  
reg        axi_wlast;  
reg        axi_wvalid;  
reg        axi_rready;  
reg       axi_bready;  
reg [4:0] ram_random_mask;  
  
// Outputs  
wire       axi_arready;  
wire [3:0] axi_rid;  
wire [31:0]axi_rdata;  
wire [1:0] axi_rresp;  
wire       axi_rlast;  
wire       axi_rvalid;  
wire       axi_awready;  
wire       axi_wready;  
wire [3:0] axi_bid;  
wire [1:0] axi_bresp;  
wire       axi_bvalid;  
  
// Instantiate the Unit Under Test (UUT)  
axi_wrap_ram uut (  
    .aclk(aclk),  
    .aresetn(aresetn),  
    // AR channel  
    .axi_arid(axi_arid),  
    .axi_araddr(axi_araddr),  
    .axi_arlen(axi_arlen),  
    .axi_arsize(axi_arsize),  
    .axi_arburst(axi_arburst),  
    .axi_arlock(axi_arlock),  
    .axi_arcache(axi_arcache),  
    .axi_arprot(axi_arprot),  
    .axi_arvalid(axi_arvalid),  
    .axi_arready(axi_arready),  
    // R channel  
    .axi_rid(axi_rid),  
    .axi_rdata(axi_rdata),  
    .axi_rresp(axi_rresp),  
    .axi_rlast(axi_rlast),  
    .axi_rvalid(axi_rvalid),  
    .axi_rready(axi_rready),  
    // AW, W, B channels (not used in this test)  
    .axi_awid(axi_awid),  
    .axi_awaddr(axi_awaddr),  
    .axi_awlen(axi_awlen),  
    .axi_awsize(axi_awsize),  
    .axi_awburst(axi_awburst),  
    .axi_awlock(axi_awlock),  
    .axi_awcache(axi_awcache),  
    .axi_awprot(axi_awprot),  
    .axi_awvalid(axi_awvalid),  
    .axi_awready(axi_awready),  
    .axi_wid(axi_wid),  
    .axi_wdata(axi_wdata),
    .axi_wstrb(axi_wstrb),  
    .axi_wlast(axi_wlast),  
    .axi_wvalid(axi_wvalid),  
    .axi_wready(axi_wready),  
    .axi_bid(axi_bid),  
    .axi_bresp(axi_bresp),  
    .axi_bvalid(axi_bvalid),  
    .axi_bready(axi_bready),  
    // From confreg  
    .ram_random_mask(ram_random_mask)  
);  
  
// Clock generation  
initial begin  
    aclk = 0;  
    forever #5 aclk = ~aclk;  
end  
  
// Reset generation  
initial begin  
    aresetn = 0;  
    #500; // Assert reset for 20ns  
    aresetn = 1;  
    #5000; // Run simulation for 1000ns  
    $finish;  
end  
  
// Test sequence  
initial begin  
//    // Initialize signals  
    axi_arid = 0;  
    axi_araddr = 32'h00000000; // Assuming RAM starts at address 0  
    axi_arlen = 3; // 
    axi_arsize = 3'b010; // 32-bit word  
    axi_arburst = 2'b01; // INCR burst  
    axi_arlock = 2'b00; // No lock  
    axi_arcache = 4'h0; // Default cacheable  
    axi_arprot = 3'h0; // Unprivileged, non-secure, data access  
    axi_arvalid = 0;  
    axi_rready = 1;    //准备好接收数据
    ram_random_mask = 5'b11111;

    axi_awid = 0;    
    axi_awaddr=0;     
    axi_awlen=3;      
    axi_awsize = 3'b010;     
    axi_awburst= 2'b01;    
    axi_awlock = 2'b00;     
    axi_awcache = 4'b0000;    
    axi_awprot = 2'b00;     
    axi_awvalid = 0;   
     
    axi_wid = 0;        
    axi_wdata = 32'hffffffff;      
    axi_wstrb=4'b0;      
    axi_wlast = 0;
    axi_wvalid = 0; 
    axi_bready = 1;         
                  
    #555;  
    axi_awid = 1;    
    axi_awaddr=32'h001d_0000;          
    axi_awsize = 3'b010;     
    axi_awburst= 2'b01;    
    axi_awlock = 2'b00;     
    axi_awcache = 4'b0000;    
    axi_awprot = 2'b00;     
    axi_awvalid = 1;   
    
    
    axi_wid = 1;        
    axi_wdata = 32'h1111_1114;      
    axi_wstrb=4'b1111;      
    axi_wlast = 0;
    axi_wvalid = 1;     
    axi_bready = 1;      
    #10;
    axi_awvalid = 0;  
    axi_wid = 2;        
    axi_wdata = 32'h2222_2223;      
    axi_wstrb=4'b1111;      
    axi_wlast = 0;
    axi_wvalid = 1;     
    axi_bready = 1;      

    #10;
  
    axi_wid = 3;        
    axi_wdata = 32'h3333_3332;      
    axi_wstrb=4'b1111;      
    axi_wlast = 0;
    axi_wvalid = 1;     
    axi_bready = 1;      

    
    #10;
    axi_wid = 4;        
    axi_wdata = 32'h4444_4441;      
    axi_wstrb=4'b1111;      
    axi_wlast = 0;
    axi_wvalid = 1;     
    axi_bready = 1;      
    #10;
    axi_wdata = 32'h5555_5551;
    axi_wvalid = 1;  
    #10;
    axi_wdata = 32'h6666_6661;
    axi_wvalid = 1;  
    #10;
    axi_wdata = 32'h7777_7771;
    axi_wvalid = 0;  
    #10;
    
    #1000;
    
    axi_arvalid = 1; 
    axi_arid = 1;    
    axi_araddr = 32'h001d_0000;
    axi_rready = 0;
    #20;
    axi_araddr = 32'h00FF_FFFF;
    #10;
    axi_rready = 1;
    #1000;
    $stop;
end
endmodule