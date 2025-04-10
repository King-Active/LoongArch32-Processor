`timescale 1ns / 1ps


module quick_decoder
    (       
    input  wire  [31:0]pc         ,
    input  wire  [31:0]instr      ,
    output wire        I26        ,
    output wire        I16        ,
    output wire        reglike    ,
    output wire  [31:0]pc_I26     ,
    output wire  [31:0]pc_I16     ,
    output wire  [31:0]pc_next
    );

    assign pc_I26  = pc + {{4{instr[9]}},instr[9:0],instr[25:10],2'b00};
    assign pc_I16  = pc + {{14{instr[25]}},instr[25:10],2'b00};
    assign pc_next = pc + 4;

    assign I26     = (instr[31:26] == 6'b010100 || instr[31:26] == 6'b010101)?1:0;
    //B BL 直接跳转类型（目标地址可直接得出）
    assign I16     = (instr[31:30] == 2'b01 && ~(instr[29:26] == 4'b0011 || instr[29:26] == 4'b0100 || instr[29:26] == 4'b0101))?1:0;
    // 依赖于寄存器值的比较结果（目标地址可直接得出）
    assign reglike = (instr[31:26] == 6'b010011 || instr[31:19] == 13'b0000000000101 || instr[31:11] == 21'b00000_11001_00100000_111)?1:0;
    //JIRL BREAK  SYSCALL ERTN (返回地址为依赖于寄存器的值)
endmodule
