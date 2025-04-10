module Hazard(
	input  wire  [4:0]    RA1D,     //ÒëÂë½×¶ÎÔ´¼Ä´æÆ÷ºÅ
	input  wire  [4:0]    RA2D,
	
	input  wire  [4:0]    RA1E,     //¼ÆËã½×¶ÎÔ´¼Ä´æÆ÷ºÅ
	input  wire  [4:0]    RA2E,
	
	input  wire  [4:0]    WAE,      //¼ÆËã½×¶Î½×¶ÎÐ´¼Ä´æÆ÷ºÅ
	input  wire  [4:0]    WAM,      //·Ã´æ½×¶Î½×¶ÎÐ´¼Ä´æÆ÷ºÅ
	input  wire  [4:0]    WAW,      //Ð´»Ø½×¶Î½×¶ÎÐ´¼Ä´æÆ÷ºÅ
	
	input  wire           RegWriteE,      //¼ÆËã½×¶Î½×¶Î¼Ä´æÆ÷Ð´Ê¹ÄÜ
	input  wire           RegWriteM,      //·Ã´æ½×¶Î½×¶Î¼Ä´æÆ÷Ð´Ê¹ÄÜ
	input  wire           RegWriteW,      //Ð´»Ø½×¶Î½×¶Î¼Ä´æÆ÷Ð´Ê¹ÄÜ
	
	input  wire           MemToRegM,      //·Ã´æ½×¶Î½×¶Î¼Ä´æÆ÷ÊÇ·ñÐ´·Ã´æ½á¹û

	input  wire           mult_stall,     //³Ë·¨×èÈû
	input  wire           div_stall,      //³ý·¨×èÈû
	
	input wire           instr_mem_stall,  //Ö¸Áî·Ã´æ×èÈû
    input wire           fifo_mem_stall,   //storeFIFO·Ã´æ×èÈû
	
	output wire  [1:0]    ForwardD1,
	output wire  [1:0]    ForwardD2,
	output wire  [1:0]    ForwardE1,
	output wire  [1:0]    ForwardE2,
	
	output wire           stallF,
	output wire           stallD,
	output wire           stallE,
	output wire           stallM,
	output wire           stallW,
	
	output wire           FlushE,
	output wire           FlushM,
	output wire           FlushW,
	
	//ÔøÖ¾ÎÄÐÂÔö£ºcsrÇ°ÍÆ
	output reg [1:0]      csrForward,
	output reg [1:0]      csrForward_EENTRY,
	
	input wire [13:0]     csr_w_addrE,
	input wire [13:0]     csr_w_addrM,
	input wire [13:0]     csr_w_addrW,
	input wire [13:0]     csr_r_addr,
	
	input wire            csrRegWriteE,
	input wire            csrRegWriteM,
	input wire            csrRegWriteW
    );
    
    assign ForwardD1 = RA1D != 0 && RegWriteM && (RA1D == WAM) ? 2'b10 :
                       RA1D != 0 && RegWriteW && (RA1D == WAW) ? 2'b01 :
                       2'b00;
    assign ForwardD2 = RA2D != 0 && RegWriteM && (RA2D == WAM) ? 2'b10 :
                       RA2D != 0 && RegWriteW && (RA2D == WAW) ? 2'b01 :
                       2'b00;
    assign ForwardE1 = RA1E != 0 && RegWriteM && (RA1E == WAM) ? 2'b10 :
                       RA1E != 0 && RegWriteW && (RA1E == WAW) ? 2'b01 :
                       2'b00;
    assign ForwardE2 = RA2E != 0 && RegWriteM && (RA2E == WAM) ? 2'b10 :
                       RA2E != 0 && RegWriteW && (RA2E == WAW) ? 2'b01 :
                       2'b00;
          
    
    wire Stall_forward_E2D;     //¼ÆËã½×¶ÎÇ°ÍÆµ½ÒëÂë½×¶Î -> ×èÈûIF,ID,Ë¢ÐÂEX
    wire Stall_forward_MR;      //·Ã´æ½×¶ÎÇ°ÍÆ·Ã´æ½á¹û -> ×èÈûIF,ID,EX,Ë¢ÐÂMEM
    
    assign Stall_forward_E2D =  (RA1D != 0 && RegWriteE && (RA1D == WAE)) ||
                                (RA2D != 0 && RegWriteE && (RA2D == WAE));
    assign Stall_forward_MR  = MemToRegM && 
                               ((RA1D != 0 && RegWriteM && (RA1D == WAM)) ||
                                (RA2D != 0 && RegWriteM && (RA2D == WAM)) ||
                                (RA1E != 0 && RegWriteM && (RA1E == WAM)) ||
                                (RA2E != 0 && RegWriteM && (RA2E == WAM))
                               );
     
    assign stallF = mult_stall  | div_stall | Stall_forward_E2D | Stall_forward_MR | instr_mem_stall | fifo_mem_stall;
    assign stallD = mult_stall  | div_stall | Stall_forward_E2D | Stall_forward_MR | instr_mem_stall | fifo_mem_stall;
    assign stallE = mult_stall  | div_stall | Stall_forward_MR  | instr_mem_stall | fifo_mem_stall;
    assign stallM = instr_mem_stall;
    assign stallW = 0; 

    assign FlushE = Stall_forward_E2D && !stallE; 
    assign FlushM = (mult_stall | div_stall | Stall_forward_MR | fifo_mem_stall)  && !stallM; 
    assign FlushW = instr_mem_stall; 
    
    always@(*)begin
        if((csr_r_addr == csr_w_addrE) & csrRegWriteE )
            csrForward = 2'b01;
        else if((csr_r_addr == csr_w_addrM) & csrRegWriteM)
            csrForward = 2'b10;
        else if((csr_r_addr == csr_w_addrW) & csrRegWriteW)
            csrForward = 2'b11;
        else
            csrForward = 2'b00;         
    end
    
    always@(*)begin
        if((14'hc == csr_w_addrE) & csrRegWriteE )
            csrForward_EENTRY = 2'b01;
        else if((14'hc == csr_w_addrM) & csrRegWriteM)
            csrForward_EENTRY = 2'b10;
        else if((14'hc == csr_w_addrW) & csrRegWriteW)
            csrForward_EENTRY = 2'b11;
        else
            csrForward_EENTRY = 2'b00;         
    end
    
    
endmodule
