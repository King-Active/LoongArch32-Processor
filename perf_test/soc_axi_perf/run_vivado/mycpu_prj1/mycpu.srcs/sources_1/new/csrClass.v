`timescale 1ns / 1ps
module csrClass(
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
    output wire   [1:0]   ReadRdcntCsr,       //  00->ÆÕÍ¨ÒëÂë¶ÁCSR¼Ä´æÆ÷µØÖ·  01->¶Á¶¨Ê±Æ÷±àºÅ  02£¬03-> ¶Áºã¶¨ÆµÂÊ¼ÆÊ±Æ÷µÍ£¬¸ß32Î»
    output wire           WriteRj ,           //  0->Ð´rd   [4:0]  1->Ð´rj   [9:5]
    output wire           ID_ine_ex
    );
    
    assign exception   = 1'b0;
    assign ReadReg     = 1'b1;
    assign WriteReg    = 1'b0;
    assign WriteData   = 2'b01;
    assign offst       = 1'b0;
    assign Immd        = 1'b0;
    assign SignExt     = 1'b0;
    assign SrcB        = 1'b0;
    assign MemToReg    = 1'b0;
    assign Branch      = 1'b0;
    assign Jump        = 1'b0;
    assign BKind       = 2'b00;
    assign Jirl        = 1'b0;
    assign sft         = 1'b0;
    assign csrSrc      = 1'b0;
    assign csrRegWrite = ~(instr[9:5] == 5'b0);
    
    assign ALUCtrl = 19'b0;
    
    assign RegWrite = 1'b1;
    assign MemWrite = 1'b0;
   
    assign DataSize = 2'b00;
   
    assign csrHcode = ~(instr[9:5] == 1);
    
    assign ReadRdcntCsr = 2'b00;
    assign WriteRj      = 0;
   
    assign ID_ine_ex = 0; 
endmodule
