`timescale 1ns / 1ps

module dCache(
    input wire clk, rst,
    /*  经过cache的访存交互  */
    input   wire                ram_data_req          ,
    input   wire                ram_data_wr           ,
    input   wire [1 :0]         ram_data_size         ,
    input   wire [31:0]         ram_data_addr         ,
    input   wire [31:0]         ram_data_wdata        ,
    output  wire [31:0]         ram_data_rdata        ,
    output  wire                ram_data_addr_ok      ,
    output  wire                ram_data_data_ok      ,
    
    /*  来自 victimCache 的写访存交互  */
    output  wire                vcm_data_req          ,
    output  wire                vcm_data_wr           ,
    output  wire [1 :0]         vcm_data_size         ,
    output  wire [31:0]         vcm_data_addr         ,
    output  wire [31:0]         vcm_data_wdata        ,
    input   wire [31:0]         vcm_data_rdata        ,
    input   wire                vcm_data_addr_ok      ,
    input   wire                vcm_data_data_ok      ,
    output  wire                vcm_wlast             ,
    input   wire                vcm_wready            ,
    
    /*  来自 主dCache 的读访存交互*/
    output  wire                cache_data_req        ,
    output  wire                cache_data_wr         ,
    output  wire [1 :0]         cache_data_size       ,
    output  wire [31:0]         cache_data_addr       ,
    output  wire [31:0]         cache_data_wdata      ,
    input   wire [31:0]         cache_data_rdata      ,
    input   wire                cache_data_addr_ok    ,
    input   wire                cache_data_data_ok    
    );
    
    wire                addDirtyReq;
    wire [127:0]        DirtyBlock ;
    wire [31:0]         DirtyAddr;
    
    wire                AcptDirty;
    
    wire [31:0]         vcm_ram_data_rdata;
    wire                vcm_ram_data_addr_ok;
    wire                vcm_ram_data_data_ok;
    
    wire [31:0]         cache_ram_data_rdata;
    wire                cache_ram_data_addr_ok;
    wire                cache_ram_data_data_ok;
    
    assign ram_data_rdata     = cache_ram_data_data_ok? cache_ram_data_rdata : vcm_ram_data_rdata;
    assign ram_data_data_ok   = ~ram_data_req? 0:
                                               cache_ram_data_data_ok? 1: vcm_ram_data_data_ok;
    assign ram_data_addr_ok   = ~ram_data_req? 0:
                                               cache_ram_data_addr_ok? 1: vcm_ram_data_addr_ok;
    
    
    victimCache u_victim_cache( 
        .clk                    (clk)                   , 
        .rst                    (rst)                   ,
        .addDirtyReq            (addDirtyReq)           ,          
        .DirtyBlock             (DirtyBlock)            ,   
        .DirtyAddr              (DirtyAddr)             ,          
        
        .AcptDirty              (AcptDirty)             ,              // 是否可以接收脏数据块
        
        .ram_data_req           (ram_data_req)          ,
        .ram_data_wr            (ram_data_wr)           ,
        .ram_data_size          (ram_data_size)         ,
        .ram_data_addr          (ram_data_addr)         ,
        .ram_data_wdata         (ram_data_wdata)        ,
        .vcm_ram_data_rdata     (vcm_ram_data_rdata)    ,
        .vcm_ram_data_addr_ok   (vcm_ram_data_addr_ok)  ,
        .vcm_ram_data_data_ok   (vcm_ram_data_data_ok)  ,             // vcm 命中反馈       
    
        .vcm_data_req           (vcm_data_req)          ,
        .vcm_data_wr            (vcm_data_wr)           ,
        .vcm_data_size          (vcm_data_size)         ,
        .vcm_data_addr          (vcm_data_addr)         ,
        .vcm_data_wdata         (vcm_data_wdata)        ,
        .vcm_data_rdata         (vcm_data_rdata)        ,     // 忽略
        .vcm_data_addr_ok       (vcm_data_addr_ok)      ,     
        .vcm_data_data_ok       (vcm_data_data_ok)      ,
        .vcm_wlast              (vcm_wlast)             ,
        .vcm_wready             (vcm_wready)
    );
    
    cache u_cache(
     .clk                        (clk                   ),
     .rst                        (rst                   ),                    
     .ram_data_req               (ram_data_req          ),
     .ram_data_wr                (ram_data_wr           ),
     .ram_data_size              (ram_data_size         ),
     .ram_data_addr              (ram_data_addr         ),
     .ram_data_wdata             (ram_data_wdata        ),
     .cache_ram_data_rdata       (cache_ram_data_rdata  ),
     .cache_ram_data_addr_ok     (cache_ram_data_addr_ok),
     .cache_ram_data_data_ok     (cache_ram_data_data_ok),
    
    /*  发送给 AXI总线的 写访存交互 */
    .cache_data_req              (cache_data_req    ),
    .cache_data_wr               (cache_data_wr     ),
    .cache_data_size             (cache_data_size   ),
    .cache_data_addr             (cache_data_addr   ),
    .cache_data_wdata            (cache_data_wdata  ),
    .cache_data_rdata            (cache_data_rdata  ),
    .cache_data_addr_ok          (cache_data_addr_ok),
    .cache_data_data_ok          (cache_data_data_ok),
    
    .addDirtyReq                 (addDirtyReq),
    .DirtyBlock                  (DirtyBlock),
    .DirtyAddr                   (DirtyAddr),
    .AcptDirty                   (AcptDirty),
    .vcm_ram_data_data_ok        (vcm_ram_data_data_ok)
    );
    
    
endmodule
