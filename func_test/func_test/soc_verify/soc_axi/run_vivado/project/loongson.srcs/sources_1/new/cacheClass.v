`timescale 1ns / 1ps
module cacheClass(
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
    output wire           WriteRj ,           //  0->写rd   [4:0]  1->写rj   [9:5]
    output wire           ID_ine_ex,
    output wire           TEST
    );
    assign TEST = 1'b0;
    
    assign exception   = 1'b0;
    assign ReadReg     = 1'b0;
    assign WriteReg    = 1'b0;
    assign WriteData   = 32'b0;
    assign RegWrite    = 1'b0; 
    assign offst       = 1'b0;
    assign Immd        = 1'b0;
    assign SignExt     = 1'b0;
    assign SrcB        = 1'b0;
    assign MemWrite    = 1'b0;
    assign MemToReg    = 1'b0;
    assign Branch      = 1'b0;
    assign Jump        = 1'b1;
    assign BKind       = 2'b00;
    assign Jirl        = 1'b1;
    assign DataSize    = 2'b10;
    assign sft         = 1'b0;
    assign csrSrc      = 1'b0;
    assign csrHcode    = 1'b0;
    assign csrRegWrite = 1'b1;
    assign ALUCtrl     = 19'b0;
    
    assign ReadRdcntCsr = 2'b00;
    assign WriteRj      = 0;
    
    //   本分支共匹配以下指令 ：CACOP  TLBSRCH  TLBRD  TLBWE  TLBFILL  ERTN  IDLE  INVTLB
    //   当前仅实现 ERTN  
    assign ID_ine_ex = (instr != 32'b0000_0110_0100_1000_0011_1000_0000_0000);
    
endmodule
