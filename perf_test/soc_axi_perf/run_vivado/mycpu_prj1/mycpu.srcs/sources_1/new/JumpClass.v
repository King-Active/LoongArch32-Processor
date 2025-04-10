`timescale 1ns / 1ps
module JumpClass(
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
    output wire   [1:0]   ReadRdcntCsr,       //  00->∆’Õ®“Î¬Î∂¡CSRºƒ¥Ê∆˜µÿ÷∑  01->∂¡∂® ±∆˜±‡∫≈  02£¨03-> ∂¡∫„∂®∆µ¬ º∆ ±∆˜µÕ£¨∏ﬂ32Œª
    output wire           WriteRj,           //  0->–¥rd   [4:0]  1->–¥rj   [9:5]
    output wire           ID_ine_ex
    );
    
    wire need_jump;
    assign need_jump  = ~instr[29] & ~instr[28] | ~instr[29] & ~instr[27];  
    
    assign exception   = 1'b0;
    assign ReadReg     = 1'b1;
    assign WriteReg    = instr[28];
    assign WriteData   = 2'b00;
    assign offst       = ~instr[29] & ~instr[27];
    assign Immd        = 1'b0;
    assign SignExt     = 1'b0;
    assign SrcB        = 1'b0;
    assign MemToReg    = 1'b0;
    assign Branch      = ~need_jump; 
    assign Jump        = need_jump;
    assign BKind       = {instr[29],instr[26]};
    assign Jirl        = instr[29] | instr[28];
    assign sft         = 1'b0;
    assign csrSrc      = 1'b1;  
    assign csrRegWrite = 1'b0;
    
    assign RegWrite = ~instr[29] & (~instr[28] | ~instr[27] & instr[26]) ;
    assign MemWrite = 1'b0;
    
    assign DataSize = 2'b00;
    
    assign ALUCtrl = {15'b0, instr[27], ~instr[27], 2'b0};
    
    assign csrHcode = 1'b0;
    
    assign ReadRdcntCsr = 2'b00;
    assign WriteRj      = 0;
    
    // BCEQZ ”Î BCNEZ ‘›»±
    assign ID_ine_ex = ~(instr[29]&~instr[28] | ~instr[29]&instr[28] | ~instr[29]&instr[27]&instr[26]);
    
endmodule
