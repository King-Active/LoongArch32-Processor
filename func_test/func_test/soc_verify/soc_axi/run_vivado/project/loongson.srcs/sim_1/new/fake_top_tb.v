`timescale 1ns / 1ps
module fake_top_tb();
    wire [31:0] data_rdata   ;     
    wire data_addr_ok ;            
    wire data_data_ok ;             
    wire [31:0] inst_rdata   ;
    wire inst_addr_ok ;
    wire inst_data_ok ;
    reg    resetn; 
    reg    clk;

    reg noCache;     //外设信号     
    reg req2;        //第二通道请求   
                                         
    reg         instr_req     ;
    reg         instr_wr      ; 
    reg  [1 :0] instr_size   ; 
    reg  [31:0] instr_addr    ; 
    reg  [31:0] instr_wdata   ; 

    reg         data_req     ;  
    reg         data_wr      ;  
    reg  [1 :0] data_size    ;  
    reg  [31:0] data_addr    ;  
    reg  [31:0] data_wdata  ; 
    
    

fake_top ft
(     
     data_rdata   ,  
     data_addr_ok ,           
     data_data_ok ,  
    inst_rdata   ,
   inst_addr_ok ,
    inst_data_ok ,
       resetn, 
       clk,
   
    noCache,     //外设信号     
    req2,        //第二通道请求   
                                                 
            instr_req     , 
            instr_wr      , 
    instr_size    , 
    instr_addr    , 
    instr_wdata   , 
    
    data_req     ,  
    data_wr      ,  
    data_size    ,  
    data_addr    ,  
    data_wdata   
);

initial clk = 0;
always #4 clk = !clk;

initial begin
    resetn = 0;
    #500;
    resetn = 1;
    noCache = 0;
    req2 = 0;
    
    instr_req = 1; 
    instr_wr = 0;  
    instr_size = 0;
    instr_addr = 32'h0000_0000;
    instr_wdata = 0;
               
    data_req = 0;  
    data_wr = 0;   
    data_size = 0;
    data_addr = 0; 
    data_wdata = 0;
    #100;
end
endmodule
