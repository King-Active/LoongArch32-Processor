module bridge1x2 (
    /*  来自总线的外设指令判断  */
    input   wire                noCache,
    
    /*  来自类sram接口的访存请求  */
    input   wire  [31:0]        cpu_sram_addr         ,     
    input   wire                cpu_sram_req          ,      
    input   wire                cpu_sram_wr           ,       
    input   wire  [1:0]         cpu_sram_size         ,     
    input   wire  [31:0]        cpu_sram_wdata        ,    
    output  wire  [31:0]        cpu_sram_rdata        ,    
    output  wire                cpu_sram_addr_ok      ,  
    output  wire                cpu_sram_data_ok      ,
    
    /*  与cache的访存交互  */
    output  wire                ram_data_req          ,
    output  wire                ram_data_wr           ,
    output  wire [1 :0]         ram_data_size         ,
    output  wire [31:0]         ram_data_addr         ,
    output  wire [31:0]         ram_data_wdata        ,
    input   wire [31:0]         ram_data_rdata        ,
    input   wire                ram_data_addr_ok      ,
    input   wire                ram_data_data_ok      ,
    
    /*  与外设的访存交互  */
    output  wire                conf_data_req        ,
    output  wire                conf_data_wr         ,
    output  wire [1 :0]         conf_data_size       ,
    output  wire [31:0]         conf_data_addr       ,
    output  wire [31:0]         conf_data_wdata      ,
    input   wire [31:0]         conf_data_rdata      ,
    input   wire                conf_data_addr_ok    ,
    input   wire                conf_data_data_ok 
);

    assign cpu_sram_rdata        =    noCache ? conf_data_rdata   : ram_data_rdata  ;
    assign cpu_sram_addr_ok      =    noCache ? conf_data_addr_ok : ram_data_addr_ok;
    assign cpu_sram_data_ok      =    noCache ? conf_data_data_ok : ram_data_data_ok;

    assign ram_data_req          =    noCache ? 0 : cpu_sram_req       ;
    assign ram_data_wr           =    noCache ? 0 : cpu_sram_wr        ;
    assign ram_data_size         =    noCache ? 0 : cpu_sram_size      ;
    assign ram_data_addr         =    noCache ? 0 : cpu_sram_addr      ;
    assign ram_data_wdata        =    noCache ? 0 : cpu_sram_wdata     ;

    assign conf_data_req         =    noCache ? cpu_sram_req  : 0     ;
    assign conf_data_wr          =    noCache ? cpu_sram_wr   : 0     ;
    assign conf_data_size        =    noCache ? cpu_sram_size : 0     ;
    assign conf_data_addr        =    noCache ? cpu_sram_addr : 0     ;
    assign conf_data_wdata       =    noCache ? cpu_sram_wdata: 0     ;

endmodule