`timescale 1ns / 1ps

module MUX_pre
    (
        input  wire          rst              ,
        input  wire          whetherJmp       ,
        input  wire          hit              ,
        input  wire          I26              ,
        input  wire          I16              ,
        input  wire          reglike          ,
        input  wire  [1:0]   type             ,
        input  wire  [31:0]  pc_I26           ,
        input  wire  [31:0]  pc_I16           ,
        input  wire  [31:0]  pc_next          ,
        input  wire  [31:0]  pc_btb           ,
        input  wire  [31:0]  pc_ras           ,
        output wire  [31:0]  predict_address  ,
        input  wire  [31:0]  cur_pc           ,
        input  wire  [31:0]  up_pc            ,
        input  wire  [31:0]  j_pc             ,
        input  wire          branch_taken
    );

    wire [31:0]reg_address;
    wire [31:0]jud_address;

    assign reg_address    =    ~hit? pc_next:
                                (type==2'b10)? pc_btb : pc_ras;      //call return 
    assign jud_address    =     whetherJmp? pc_I16:pc_next;

    assign predict_address = rst?32'h00000000:
                             I26?pc_I26:                //直接跳转
                         reglike?reg_address:           //地址依赖
                             I16?jud_address:pc_next;   //条件依赖
endmodule   
