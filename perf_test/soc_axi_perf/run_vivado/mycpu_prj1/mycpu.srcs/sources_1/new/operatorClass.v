`timescale 1ns / 1ps
module operatorClass(
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
    output wire           WriteRj,           //  0->Ğ´rd   [4:0]  1->Ğ´rj   [9:5]
    output wire           ID_ine_ex
    );
    
    assign exception   = 1'b0;
    assign ReadReg     = 1'b0;
    assign WriteReg    = 1'b0;
    assign WriteData   = 2'b11;
    assign RegWrite    = 1'b1; 
    assign offst       = 1'b0;
    assign Immd        = 1'b0;
    assign SignExt     = 1'b0;
    assign SrcB        = 1'b0;
    assign MemWrite    = 1'b0;
    assign MemToReg    = 1'b0;
    assign Branch      = 1'b0;
    assign Jump        = 1'b0;
    assign BKind       = 2'b00;
    assign Jirl        = 1'b0;
    assign DataSize    = 2'b0;
    assign sft         = 1'b0;
    assign csrSrc      = 1'b0;
    assign csrRegWrite = 1'b0;
        
    assign ALUCtrl ={      instr[21]&~instr[20]&~instr[19]&~instr[18]&~instr[17]& instr[16]& instr[15],
                           instr[21]&~instr[20]&~instr[19]&~instr[18]&~instr[17]&~instr[16]& instr[15], 
                           instr[21]&~instr[20]&~instr[19]&~instr[18]&~instr[17]& instr[16]&~instr[15], 
                           instr[21]&~instr[20]&~instr[19]&~instr[18]&~instr[17]&~instr[16]&~instr[15], 
                          ~instr[21]& instr[20]& instr[19]& instr[18]&~instr[17]& instr[16]&~instr[15], 
                          ~instr[21]& instr[20]& instr[19]& instr[18]&~instr[17]&~instr[16]& instr[15], 
                          ~instr[21]& instr[20]& instr[19]& instr[18]&~instr[17]&~instr[16]&~instr[15], 
                           1'b0,
                          ~instr[21]& instr[20]& instr[19]&~instr[18]&~instr[17]&~instr[16]&~instr[15], 
                          ~instr[21]& instr[20]&~instr[19]& instr[18]& instr[17]& instr[16]& instr[15], 
                          ~instr[21]& instr[20]&~instr[19]& instr[18]& instr[17]& instr[16]&~instr[15], 
                          ~instr[21]& instr[20]&~instr[19]& instr[18]&~instr[17]& instr[16]& instr[15], 
                          ~instr[21]& instr[20]&~instr[19]& instr[18]&~instr[17]& instr[16]&~instr[15], 
                          ~instr[21]& instr[20]&~instr[19]& instr[18]&~instr[17]&~instr[16]&~instr[15], 
                          ~instr[21]& instr[20]&~instr[19]& instr[18]&~instr[17]&~instr[16]& instr[15],
                          ~instr[21]& instr[20]&~instr[19]&~instr[18]& instr[17]&~instr[16]& instr[15], 
                          ~instr[21]& instr[20]&~instr[19]&~instr[18]& instr[17]&~instr[16]&~instr[15],
                          ~instr[21]& instr[20]&~instr[19]&~instr[18]&~instr[17]& instr[16]&~instr[15], 
                          ~instr[21]& instr[20]&~instr[19]&~instr[18]&~instr[17]&~instr[16]&~instr[15] 
                         };
        
    assign csrHcode = 1'b0; 
    
    integer i;
    reg [4:0] count;  
    reg is_one_hot;
    
    always @(*) begin
        is_one_hot = 0;
        count = 0;
        for (i = 0; i <= 18; i = i + 1) begin
            if (ALUCtrl[i]) count = count + 1;
        end
        is_one_hot = (count == 1'b1);
    end
    
    assign ReadRdcntCsr = 2'b00;
    assign WriteRj      = 0;

    assign ID_ine_ex = ~is_one_hot;
    
endmodule
