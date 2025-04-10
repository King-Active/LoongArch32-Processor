module EX_stage(
    input wire clk,
    input wire rst,
    input  wire stallE,
    input  wire flushE,
    
    //ID2EX
    input wire   [31:0]   RD1E,
	input wire   [31:0]   RD2E,
	input wire   [31:0]   ALU_immE,        
	input wire   [31:0]   i20_sllE,
	input wire   [4:0]    WAE,
    input wire            WriteRegE,
    input wire            MemWriteE,
    input wire   [1:0]    DataSizeE,
    input wire            SrcBE,
    input wire   [18:0]   ALUCtrlE,
    input wire            MemToRegE,
    input wire    [1:0]   ForwardE1,
    input wire    [1:0]   ForwardE2,
    output wire           mult_stall,
    output wire           div_stall,
    
    //MEM_stage    
    input wire    [31:0]  reg_w_dataM,
    
    //WB_stage    
    input wire    [31:0]  reg_w_dataW,
    
    //EX2MEM
	output wire   [31:0]  ALU_resultE,        
	output wire   [4:0]   WAE_r,
	
	output wire   EXE_ale_ex,    // 访存地址非 4字对齐 例外
	
	input wire  test
    );
    
    wire    [31:0]    alu_src1,alu_src2;
    wire    [31:0]    alu_src1_Ford,alu_src2_Ford; 
    wire              slt,zero;       //分支判断移到译码阶段了，这里已经用不到zero和slt
       
    //数据前推   
    assign alu_src1_Ford = ForwardE1[1] ? 
                           ForwardE1[0] ? 1'bz : reg_w_dataM  :
                           ForwardE1[0] ? reg_w_dataW : RD1E;
                       
    assign alu_src2_Ford = ForwardE2[1] ? 
                           ForwardE2[0] ? 1'bz : reg_w_dataM  :
                           ForwardE2[0] ? reg_w_dataW : RD2E; 
    
    //ALU
    assign alu_src1 = alu_src1_Ford;
    assign alu_src2 = SrcBE ? ALU_immE : alu_src2_Ford;
    ALU alu(
    .clk(clk),
    .rst(rst),
    .stallE(stallE),
    .flushE(flushE),
    .alu_op(ALUCtrlE),
    .alu_src1(alu_src1),
    .alu_src2(alu_src2),
    .zero(zero),
    .slt(slt),
    .mult_stall(mult_stall),
    .div_stall(div_stall),
    .alu_result(ALU_resultE),
    .test(test)
    );
    
    //写寄存器号
    assign WAE_r = WriteRegE ? 5'b1 : WAE;
    
    assign EXE_ale_ex = (MemToRegE || MemWriteE) && ((DataSizeE==2'b10 && ALU_resultE[1:0]!=2'b00) ||
                                                     (DataSizeE==2'b01 && ALU_resultE[0]!=1'b0));
    
endmodule
