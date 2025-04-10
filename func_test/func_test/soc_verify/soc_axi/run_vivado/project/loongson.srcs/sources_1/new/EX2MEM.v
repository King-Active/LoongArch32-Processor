module EX2MEM(
    input wire clk,
    input wire rst,
    input wire StallM,           //·ÃÌ¸½×¶Î×èÈû
    input wire FlushM,           //·ÃÌ¸½×¶ÎÇå¿Õ
    
    input wire   [31:0]  RDE2,
	input wire   [31:0]  ALU_resultE,        
	input wire   [4:0]   WAE_r,
	input wire   [31:0]  i20_sllE,
	input wire   [31:0]  pcE,
	input wire   [31:0]  dummyE,
	input wire           MemWriteE,
	input wire   [1:0]   DataSizeE,
    input wire           MemToRegE,
    input wire   [1:0]   WriteDataE,
    input wire           RegWriteE,
    input wire   [31:0]  instrE,
    input wire           ertnE,
    input wire           csrRegWriteE,
    input wire   [31:0]  csrHcodeE,
    input wire           exceptionE,    
	
	
	output reg   [31:0]  RDM2,
	output reg   [31:0]  ALU_resultM,        
	output reg   [4:0]   WAM,
	output reg   [31:0]  i20_sllM,
	output reg   [31:0]  pcM,
	output reg   [31:0]  dummyM,
	output reg           MemWriteM,
	output reg  [1:0]    DataSizeM,
    output reg           MemToRegM,
    output reg  [1:0]    WriteDataM,
    output reg           RegWriteM,
    output reg   [31:0]  instrM,
    output reg           ertnM,
    output reg           csrRegWriteM,
    output reg   [31:0]  csrHcodeM,
    output reg           exceptionM    ,
    
	input wire ex_flush_pipe_M,
	input wire ex_label_pipe_M,
	input wire [5:0] Ecode,
	input wire EsubCode,
	input wire [31:0] era,
	
	input wire [5:0] EcodeE,
    input wire       EsubCodeE,
    input wire [31:0]eraE,
    
    output reg [5:0] EcodeM,
    output reg       EsubCodeM,
    output reg [31:0]eraM     
    );
    
    always @(posedge clk) begin
        if(rst | FlushM | (ex_flush_pipe_M & ~StallM)) begin
            RDM2               <= 0    ;
            ALU_resultM        <= 0    ;
            WAM                <= 0    ;
            i20_sllM           <= 0    ;
            pcM                <= 32'h1c000000    ;
            dummyM             <= 0    ;
            MemWriteM          <= 0    ;
            DataSizeM          <= 0    ;
            MemToRegM          <= 0    ;
            WriteDataM         <= 0    ;
            RegWriteM          <= 0    ;
            instrM             <= 32'h02800000;
            ertnM              <= 0;
            csrRegWriteM       <= 0;
            csrHcodeM          <= 0;
            exceptionM         <= 0;
        end
        
        else if(~StallM) begin
        // 0010   ±ê¼Ç·Ã´æµØÖ·´íÎóÀýÍâ
            if(ex_label_pipe_M) begin
                RDM2               <= 0 ;
                ALU_resultM        <= ALU_resultE ;
                WAM                <= 0 ;
                i20_sllM           <= 0 ;
                pcM                <= 0 ;
                dummyM             <= 0 ;
                MemWriteM          <= 0 ;    
                DataSizeM          <= 0 ;    
                MemToRegM          <= 0 ; 
                WriteDataM         <= 0 ;
                RegWriteM          <= 0 ;
                instrM             <= 0 ; 
                ertnM              <= 0 ;
                csrRegWriteM       <= 0 ;
                csrHcodeM          <= 0 ;
                exceptionM         <= 1 ;
                EcodeM             <= Ecode;
                EsubCodeM          <= EsubCode;
                eraM               <= era;
            end
            else begin
                RDM2               <= RDE2      ;
                ALU_resultM        <= ALU_resultE  ;
                WAM                <= WAE_r        ;
                i20_sllM           <= i20_sllE     ;
                pcM                <= pcE          ;
                dummyM             <= dummyE       ;
                MemWriteM          <= MemWriteE    ;    
                DataSizeM          <= DataSizeE    ;    
                MemToRegM          <= MemToRegE    ; 
                WriteDataM         <= WriteDataE   ;
                RegWriteM          <= RegWriteE    ;
                instrM             <= instrE       ; 
                ertnM              <= ertnE        ;
                csrRegWriteM       <= csrRegWriteE ;
                csrHcodeM          <= csrHcodeE    ;
                exceptionM         <= exceptionE   ;
                EcodeM             <= EcodeE;
                EsubCodeM          <= EsubCodeE;
                eraM               <= eraE;
            end
        end
        
        else begin
                RDM2               <= RDM2;        
                ALU_resultM        <= ALU_resultM;
                WAM                <= WAM;         
                i20_sllM           <= i20_sllM;    
                pcM                <= pcM;         
                dummyM             <= dummyM;      
                MemWriteM          <= MemWriteM;       
                DataSizeM          <= DataSizeM;       
                MemToRegM          <= MemToRegM;    
                WriteDataM         <= WriteDataM;  
                RegWriteM          <= RegWriteM;   
                instrM             <= instrM;       
                ertnM              <= ertnM;       
                csrRegWriteM       <= csrRegWriteM;
                csrHcodeM          <= csrHcodeM;   
                exceptionM         <= exceptionM;  
                EcodeM             <= EcodeM;      
                EsubCodeM          <= EsubCodeM;   
                eraM               <= eraM;        
        end
    end
    
endmodule
