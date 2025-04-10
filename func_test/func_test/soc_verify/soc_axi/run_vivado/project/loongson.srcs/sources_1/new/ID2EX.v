module ID2EX(
    input wire            clk,
    input wire            rst,
        input wire        StallE,           //计算阶段阻塞
    input wire            FlushE,           //计算阶段清空
    
    input wire   [31:0]   pcD,
	input wire   [31:0]   RD1D_Ford,
	input wire   [31:0]   RD2D_Ford,
	input wire   [31:0]   ALU_immD,        
	input wire   [31:0]   dummyD,
	input wire   [31:0]   i20_sllD,
	input wire   [4:0]    RA1D,
	input wire   [4:0]    RA2D,
	input wire   [4:0]    WAD,
    input wire            WriteRegD,
    input wire   [1:0]    WriteDataD,
    input wire            RegWriteD,
    input wire            SrcBD,
    input wire   [18:0]   ALUCtrlD,
    input wire            MemWriteD,
    input wire            MemToRegD,
    input wire   [1:0]    DataSizeD,
    input wire   [31:0]   instrD,
    input wire            ertnD,
    input wire            csrRegWriteD,
    input wire            exceptionD,
    
    output reg   [31:0]   pcE,
    output reg   [31:0]   RD1E,
	output reg   [31:0]   RD2E,
	output reg   [31:0]   ALU_immE,        
	output reg   [31:0]   dummyE,
	output reg   [31:0]   i20_sllE,
	output reg   [4:0]    RA1E,
	output reg   [4:0]    RA2E,
	output reg   [4:0]    WAE,
    output reg            WriteRegE,
    output reg   [1:0]    WriteDataE,
    output reg            RegWriteE,
    output reg            SrcBE,
    output reg   [18:0]   ALUCtrlE,
    output reg            MemWriteE,
    output reg            MemToRegE,
    output reg   [1:0]    DataSizeE,
    output reg   [31:0]   instrE,
    output reg            ertnE,
    output reg            csrRegWriteE,
    output reg            exceptionE,
    
	input wire            ex_flush_pipe_E,
	input wire            ex_label_pipe_E,
	input wire   [5:0]    Ecode,
	input wire            EsubCode,
	input wire   [31:0]   era,
	
    output reg [5:0]      EcodeE,
    output reg            EsubCodeE,
    output reg [31:0]     eraE     ,
    
    input wire       testD,
    output reg          testE
    );
    
    always @(posedge clk) begin
        if(rst | FlushE | (ex_flush_pipe_E & ~StallE)) begin
           RD1E            <=     32'b0;    
           RD2E            <=     32'b0;      
           ALU_immE        <=     32'b0;     
           dummyE          <=     32'b0;         
           i20_sllE        <=     32'b0;
           RA1E            <=     0;
           RA2E            <=     0;
           WAE             <=     0;
           WriteRegE       <=     0;
           WriteDataE      <=     0;
           RegWriteE       <=     0;
           SrcBE           <=     0;
           ALUCtrlE        <=     1;
           MemWriteE       <=     0;
           MemToRegE       <=     0;
           DataSizeE       <=     0; 
           instrE          <=     32'b0000001010_000000000000_00000_00000;
           pcE             <=     32'h1c000000;
           ertnE           <=     0;    
           csrRegWriteE    <=     0;
           exceptionE      <=     0;
           EcodeE          <=     6'h1A;
           EsubCodeE       <=     0;
           eraE            <=     32'b0;
           testE           <= 0;
        end
            
        else if(~StallE) begin
        //  非分支地址错误类型例外
            if(ex_label_pipe_E==1'b1 & ~(Ecode == 6'b00_1000 && EsubCode==0)) begin
               RD1E            <=     32'b0;    
               RD2E            <=     32'b0;      
               ALU_immE        <=     32'b0;     
               dummyE          <=     32'b0;         
               i20_sllE        <=     32'b0;
               RA1E            <=     0;
               RA2E            <=     0;
               WAE             <=     0;
               WriteRegE       <=     0;
               WriteDataE      <=     0;
               RegWriteE       <=     0;
               SrcBE           <=     0;
               ALUCtrlE        <=     1;
               MemWriteE       <=     0;
               MemToRegE       <=     0;
               DataSizeE       <=     0;
               instrE          <=     32'b0;             
               pcE             <=     32'b0;      
               ertnE           <=     0;    
               csrRegWriteE    <=     1;
               exceptionE      <=     1;

               EcodeE          <=     Ecode;
               EsubCodeE       <=     EsubCode;
               eraE            <=     era;
               testE <= 0;
            end
            
            // 分支类型地址例外，需写寄存器
            else if(ex_label_pipe_E==1'b1) begin
               RD1E            <=     RD1D_Ford;   
               RD2E            <=     RD2D_Ford;   
               ALU_immE        <=     ALU_immD;    
               dummyE          <=     dummyD;      
               i20_sllE        <=     i20_sllD;    
               RA1E            <=     RA1D;        
               RA2E            <=     RA2D;        
               WAE             <=     WAD;         
               WriteRegE       <=     WriteRegD;   
               WriteDataE      <=     WriteDataD;  
               RegWriteE       <=     RegWriteD;   
               SrcBE           <=     SrcBD;       
               ALUCtrlE        <=     ALUCtrlD;    
               MemWriteE       <=     MemWriteD;   
               MemToRegE       <=     MemToRegD;   
               DataSizeE       <=     DataSizeD;         
               instrE          <=     instrD;       
               pcE             <=     pcD;         
               ertnE           <=     ertnD;       
               csrRegWriteE    <=     csrRegWriteD;
               exceptionE      <=     1;  
               
               EcodeE          <=     Ecode;
               EsubCodeE       <=     EsubCode;
               eraE            <=     era;
               testE <= testD;
            end
            
            else begin
               RD1E            <=     RD1D_Ford;    
               RD2E            <=     RD2D_Ford;
               ALU_immE        <=     ALU_immD; 
               dummyE          <=     dummyD;    
               i20_sllE        <=     i20_sllD; 
               RA1E            <=     RA1D;     
               RA2E            <=     RA2D;     
               WAE             <=     WAD;      
               WriteRegE       <=     WriteRegD;
               WriteDataE      <=     WriteDataD;
               RegWriteE       <=     RegWriteD;
               SrcBE           <=     SrcBD; 
               ALUCtrlE        <=     ALUCtrlD;
               MemWriteE       <=     MemWriteD;
               MemToRegE       <=     MemToRegD;
               DataSizeE       <=     DataSizeD;
               instrE          <=     instrD;
               pcE             <=     pcD;
               ertnE           <=     ertnD;    
               csrRegWriteE    <=     csrRegWriteD;
               exceptionE      <=     exceptionD;
               EcodeE          <=     6'h1A;
               EsubCodeE       <=     0;
               eraE            <=     32'b0;
               testE <= testD;
           end
      end
  
        else begin
               RD1E            <=     RD1E;        
               RD2E            <=     RD2E;        
               ALU_immE        <=     ALU_immE;    
               dummyE          <=     dummyE;      
               i20_sllE        <=     i20_sllE;    
               RA1E            <=     RA1E;        
               RA2E            <=     RA2E;        
               WAE             <=     WAE;         
               WriteRegE       <=     WriteRegE;   
               WriteDataE      <=     WriteDataE;  
               RegWriteE       <=     RegWriteE;   
               SrcBE           <=     SrcBE;       
               ALUCtrlE        <=     ALUCtrlE;    
               MemWriteE       <=     MemWriteE;   
               MemToRegE       <=     MemToRegE;   
               DataSizeE       <=     DataSizeE;         
               instrE          <=     instrE;       
               pcE             <=     pcE;         
               ertnE           <=     ertnE;       
               csrRegWriteE    <=     csrRegWriteE;
               exceptionE      <=     exceptionE;  
               
               EcodeE          <=     EcodeE;      
               EsubCodeE       <=     EsubCodeE;   
               eraE            <=     eraE;     
               testE <= testE;   
        end
  
    end
    
endmodule
