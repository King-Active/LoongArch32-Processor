module bridge2x1 (

    /*  来自总线的外设指令判断  */
    input  wire                 noCache              ,
    
    /*  dCache的读操作交互  */
    input  wire                 cache_data_req       ,        
    input  wire                 cache_data_wr        ,        
    input  wire [1 :0]          cache_data_size      ,        
    input  wire [31:0]          cache_data_addr      ,        
    input  wire [31:0]          cache_data_wdata     ,        
    output wire [31:0]          cache_data_rdata     ,        
    output wire                 cache_data_addr_ok   ,        
    output wire                 cache_data_data_ok   ,   

    /*  外设的访存交互  */
    input   wire                conf_data_req        ,
    input   wire                conf_data_wr         ,
    input   wire [1 :0]         conf_data_size       ,
    input   wire [31:0]         conf_data_addr       ,
    input   wire [31:0]         conf_data_wdata      ,
    output  wire [31:0]         conf_data_rdata      ,
    output  wire                conf_data_addr_ok    ,
    output  wire                conf_data_data_ok    ,

    /*  与 AXI 接口的交互  */
    output wire                 wrap_data_req     ,
    output wire                 wrap_data_wr      ,
    output wire [1 :0]          wrap_data_size    ,
    output wire [31:0]          wrap_data_addr    ,
    output wire [31:0]          wrap_data_wdata   ,
    input  wire [31:0]          wrap_data_rdata   ,
    input  wire                 wrap_data_addr_ok ,
    input  wire                 wrap_data_data_ok
);

    assign wrap_data_req                =    noCache  ?  conf_data_req   : cache_data_req  ;
    assign wrap_data_wr                 =    noCache  ?  conf_data_wr    : cache_data_wr   ;
    assign wrap_data_size               =    noCache  ?  conf_data_size  : cache_data_size ;
    assign wrap_data_addr               =    noCache  ?  conf_data_addr  : cache_data_addr ;
    assign wrap_data_wdata              =    noCache  ?  conf_data_wdata : cache_data_wdata;
    

    assign cache_data_rdata             =    noCache  ?  0 : wrap_data_rdata  ;
    assign cache_data_addr_ok           =    noCache  ?  0 : wrap_data_addr_ok;
    assign cache_data_data_ok           =    noCache  ?  0 : wrap_data_data_ok;

    assign conf_data_rdata              =    noCache  ?  wrap_data_rdata   : 0;
    assign conf_data_addr_ok            =    noCache  ?  wrap_data_addr_ok : 0;
    assign conf_data_data_ok            =    noCache  ?  wrap_data_data_ok : 0;
                                      
endmodule                                 
                                          
