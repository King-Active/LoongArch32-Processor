module MEM2WB(
    input wire clk,
    input wire rst,
    input wire StallW,           //Ð´»Ø½×¶Î×èÈû
    input wire FlushW,           //Ð´»Ø½×¶ÎÇå¿Õ
    
	input wire   [31:0]   instrM,     
	input wire   [31:0]   pcM,
	input wire   [4:0]    WAM,
	input wire   [31:0]   i20_sllM,
	input wire   [31:0]   dummyM,
	input wire            MemToRegM,
 	input wire   [1:0]    DataSizeM,
    input wire   [1:0]    WriteDataM,
    input wire            RegWriteM,
    input wire   [31:0]   mem_rdataM,      
    input wire            ertnM,
    input wire            csrRegWriteM,
    input wire   [31:0]   csrHcodeM,
    input wire            exceptionM,
    input wire   [31:0]   RDM2,     
	
	output reg   [31:0]   instrW,     
	output reg   [31:0]   pcW,
	output reg   [4:0]    WAW,        //Ð´»Ø½×¶ÎÖ¸ÁîÐ´¼Ä´æÆ÷ºÅ
	output reg   [31:0]   i20_sllW,
	output reg   [31:0]   dummyW,
	output reg            MemToRegW,
 	output reg   [1:0]    DataSizeW,
    output reg   [1:0]    WriteDataW,
    output reg            RegWriteW,
    output reg   [31:0]   mem_rdataW,
    input  wire  [31:0]   ALU_resultM,
    output reg   [31:0]   ALU_resultW,
    output reg            ertnW,
    output reg            csrRegWriteW,
    output reg   [31:0]   csrHcodeW,
    output reg            exceptionW,
    output reg   [31:0]   RDW2,
    
	input wire ex_flush_pipe_W,
	input wire ex_label_pipe_W,
	input wire [5:0] Ecode,
	input wire EsubCode,
	input wire [31:0] era,
	
    input wire [5:0]        EcodeM,
    input wire              EsubCodeM,
    input wire [31:0]       eraM  ,
    
    output reg [5:0]        EcodeW,
    output reg              EsubCodeW,
    output reg [31:0]       eraW   
    );
    
    always @(posedge clk) begin
        if(rst | FlushW | (ex_flush_pipe_W & ~StallW)) begin
            instrW            <= 0    ;
            pcW               <= 32'h1c000000;
            WAW               <= 0    ;
            i20_sllW          <= 0    ;
            dummyW            <= 0    ;
            MemToRegW         <= 0    ;
            DataSizeW         <= 0    ;
            WriteDataW        <= 0    ;
            RegWriteW         <= 0    ;
            mem_rdataW        <= mem_rdataM    ;
            ALU_resultW       <= 32'b0;
            ertnW             <= 0;      
            csrRegWriteW      <= 0;
            csrHcodeW         <= 0;
            exceptionW        <= 0;       
            RDW2              <= 0;
        end
        else if(~StallW) begin        
            if(ex_label_pipe_W == 1) begin
                instrW            <= 0;
                pcW               <= 0;
                WAW               <= 0;
                i20_sllW          <= 0;
                dummyW            <= 0;
                MemToRegW         <= 0;
                DataSizeW         <= 0;
                WriteDataW        <= 0;
                RegWriteW         <= 0;
                mem_rdataW        <= 0;
                ALU_resultW       <= 0;
                ertnW             <= 0;      
                csrRegWriteW      <= 0;
                csrHcodeW         <= 0;
                exceptionW        <= 0;           
                RDW2              <= 0;
                
                EcodeW            <= Ecode     ;
                EsubCodeW         <= EsubCode  ;          
                eraW              <= era       ;
            end
            
            else begin
                instrW            <= instrM        ;
                pcW               <= pcM           ;
                WAW               <= WAM           ;
                i20_sllW          <= i20_sllM      ;
                dummyW            <= dummyM        ;
                MemToRegW         <= MemToRegM     ;
                DataSizeW         <= DataSizeM     ;
                WriteDataW        <= WriteDataM    ;
                RegWriteW         <= RegWriteM     ;
                mem_rdataW        <= mem_rdataM    ;
                ALU_resultW       <= ALU_resultM   ;
                ertnW             <= ertnM         ;      
                csrRegWriteW      <= csrRegWriteM  ;
                csrHcodeW         <= csrHcodeM     ;
                exceptionW        <= exceptionM    ;           
                RDW2              <= RDM2          ;
                
                EcodeW            <= EcodeM        ;
                EsubCodeW         <= EsubCodeM     ;          
                eraW              <= eraM;
            end
        end
        
        else begin
            instrW            <= instrW;      
            pcW               <= pcW;         
            WAW               <= WAW;         
            i20_sllW          <= i20_sllW;    
            dummyW            <= dummyW;      
            MemToRegW         <= MemToRegW;   
            DataSizeW         <= DataSizeW;   
            WriteDataW        <= WriteDataW;  
            RegWriteW         <= RegWriteW;   
            mem_rdataW        <= mem_rdataW;  
            ALU_resultW       <= ALU_resultW; 
            ertnW             <= ertnW;       
            csrRegWriteW      <= csrRegWriteW;
            csrHcodeW         <= csrHcodeW;   
            exceptionW        <= exceptionW;  
            RDW2              <= RDW2;        
        end
    end
    
    
endmodule
