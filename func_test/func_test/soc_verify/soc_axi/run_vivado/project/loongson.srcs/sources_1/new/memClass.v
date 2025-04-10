`timescale 1ns / 1ps
module memClass(
    input  wire   [31:0]  instr,
    output wire           ReadReg,
    output wire           WriteReg,
    output wire   [1:0]   WriteData,
    output wire           RegWrite,
    output wire           offst,
    output wire           Immd,
    output wire           SignExt,
    output wire           SrcB,
    output wire   [18:0]  ALUCtrl,
    output wire           MemWrite,
    output wire           MemToReg,
    output wire           Branch,
    output wire           Jump,
    output wire   [1:0]   BKind,
    output wire           Jirl,
    output wire   [1:0]   DataSize,
    output wire           sft,
    output wire           csrSrc,
    output wire           csrRegWrite,
    output wire           csrHcode,
    output wire           exception,
    output wire   [1:0]   ReadRdcntCsr,       //  00->普通译码读CSR寄存器地址  01->读定时器编号  02，03-> 读恒定频率计时器低，高32位
    output wire           WriteRj,           //  0->写rd   [4:0]  1->写rj   [9:5]
    output wire           ID_ine_ex,
    output wire           TEST
    );
    assign TEST = 1'b0;
    
    assign exception   = 1'b0;
    assign ReadReg     = instr[24];
    assign WriteReg    = 1'b0;
    assign WriteData   = 2'b11;
    assign offst       = 1'bx;
    assign Immd        = 1'b1;
    assign SignExt     = 1'b1;
    assign SrcB        = 1'b1;
    assign MemToReg    = ~MemWrite;
    assign Branch      = 1'b0; 
    assign Jump        = 1'b0;
    assign BKind       = 2'bxx;
    assign Jirl        = 1'bx;
    assign sft         = 1'bx;
    assign csrSrc      = 1'bx;  
    assign csrRegWrite = 1'b0;
    
    assign ALUCtrl = 19'b1;
    
    assign RegWrite = ~instr[24];
    assign MemWrite =  instr[24];
    
    assign DataSize = instr[23:22];
    
    assign csrHcode = 1'bx;
    
    assign ReadRdcntCsr = 2'b00;
    assign WriteRj      = 0;
    
    // 在LoongArch32精简指令集中，前缀为001010的情况下，不存在未定义指令
    // 但本项目 PRELD，FLD.S，FST.S，FLD.D，FST.D 尚未实现，但不将其视为未定义指令
    assign ID_ine_ex = 0;    
    
    
endmodule
