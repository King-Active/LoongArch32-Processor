module datapath(
    input wire clk, rst,
    //inst
    output wire [31:0] pc,       
    input wire         inst_data_ok,
    input wire [31:0]  inst_rdata,
    output wire inst_req,

    //data    
    output wire         sram_data_en,            
    output wire  [3:0]  sram_data_wen,          
    output wire  [31:0] sram_data_addr,            
    output wire  [31:0] sram_data_wdata,          
    input  wire         sram_data_ok,
    input  wire         sram_addr_ok,     
    input  wire  [31:0] sram_data_rdata,
    
    output wire         noCache,
    
    //debug
    output wire [31:0]  debug_wb_pc,      
    output wire [3:0]   debug_wb_rf_wen,
    output wire [4:0]   debug_wb_rf_wnum, 
    output wire [31:0]  debug_wb_rf_wdata
    );
    
   
    
    //IF 取指阶段
    wire              StallF;
    wire              if_jump;         //是否跳转（ID）
	wire   [31:0]     pc_jump;   //跳转地址（ID）
	wire   [31:0]     instrF;    //流水线发出的指令   
	wire   [31:0]     pred_nxt_pc_F;
	wire   [31:0]     pcF;

	//ID 译码阶段
	wire              ertnD;
	wire   [31:0]     instrD;     
	wire   [31:0]     pcD;
	wire   [4:0]      RA1D;
	wire   [4:0]      RA2D;
    wire   [31:0]     RD1;            //寄存器读出数据1
    wire   [31:0]     RD2;            //寄存器读出数据2
    wire   [1:0]      ForwardD1;      //操作数1是否需要前推
    wire   [1:0]      ForwardD2;      //操作数2是否需要前推
	wire   [31:0]     RD1D_Ford;
	wire   [31:0]     RD2D_Ford;
	wire   [31:0]     ALU_immD;        
	wire   [31:0]     dummyD;
	wire   [31:0]     i20_sllD;
	wire   [4:0]      WAD;
    wire              WriteRegD;
    wire   [1:0]      WriteDataD;
    wire              RegWriteD;
    wire              SrcBD;
    wire   [18:0]     ALUCtrlD;
    wire              MemWriteD;
    wire              MemToRegD;
    wire   [1:0]      DataSizeD;
    wire              BranchD;
    
    wire   [1:0]      c_wayD; 
    wire              hitD;   
    //wire              BranchD;
    wire              call;   
    wire              return; 
    wire   [31:0]     pred_nxt_pc_D;
    wire              b_flushD;
    wire   [31:0]     csr_r_dataD;
    wire   [31:0]     EENTRY;
    wire              csrRegWriteD;
    wire              exceptionD;
    wire   [1:0]      ReadRdcntCsrD;
    wire   [31:0]     origin_pc_jump;
    wire   [13:0]     csr_r_addr;
    
    wire   testD;
    
    //EX 计算阶段
    wire   [31:0]  RD1E;
	wire   [31:0]  RD2E;
	wire   [31:0]  ALU_immE;        
	wire   [31:0]  dummyE;
	wire   [31:0]  i20_sllE;
	wire   [4:0]   RA1E;
	wire   [4:0]   RA2E;
	wire   [4:0]   WAE;
    wire           WriteRegE;
    wire   [1:0]   WriteDataE;
    wire           RegWriteE;
    wire           SrcBE;
    wire   [18:0]  ALUCtrlE;
    wire           MemWriteE;
    wire           MemToRegE;
    wire   [1:0]   DataSizeE;
    wire   [1:0]   ForwardE1;
    wire   [1:0]   ForwardE2;
    wire           mult_stall;
    wire           div_stall;
	wire   [31:0]  ALU_resultE;        
	wire   [4:0]   WAE_r;
	wire   [31:0]  pc_E;
    wire   [31:0]  instrE;
    wire           ertnE;
    wire           csrRegWriteE;
    wire   [31:0]  csrHcodeE;
    wire           exceptionE;
    wire   [13:0]     csr_w_addrE;
    wire   [5:0]      EcodeE;
    wire              EsubCodeE;
    wire   [31:0]     eraE;
    
    wire  testE;
    
    //MEM 访存阶段
    wire   [31:0]  RDM2;
	wire   [31:0]  ALU_resultM;       
	wire   [4:0]   WAM;
	wire   [31:0]  i20_sllM;
	wire   [31:0]  pcM;
	wire   [31:0]  dummyM;
	wire           MemWriteM;
	wire   [1:0]   DataSizeM;
	wire           MemToRegM;
    wire   [1:0]   WriteDataM;
    wire           RegWriteM;
    wire   [31:0]  instrM;
    wire   [31:0]  mem_rdataM;
    wire           ertnM;
    wire           csrRegWriteM;
    wire   [31:0]  csrHcodeM;
    wire           exceptionM;
    wire   [13:0]  csr_w_addrM;
    wire   [5:0]      EcodeM;
    wire              EsubCodeM;
    wire   [31:0]     eraM;

    wire             instr_mem_stall;  //指令访存阻塞
    wire             fifo_mem_stall;   //storeFIFO访存阻塞

    //WB 写回阶段
    wire   [31:0]   instrW;     
	wire   [31:0]   pcW;
	wire   [4:0]    WAW;        //写回阶段指令写寄存器号
	wire   [31:0]   i20_sllW;
	wire   [31:0]   dummyW;
	wire            MemToRegW;
 	wire   [1:0]    DataSizeW;
    wire   [1:0]    WriteDataW;
    wire            RegWriteW;      
	wire   [31:0]   mem_rdataW;   
	wire   [31:0]   ALU_resultW;  
	wire            reg_w_data_11;
    wire            ertnW;
    wire            csrRegWriteW;
    wire   [31:0]   csrHcodeW;
    wire            exceptionW;
    wire   [13:0]   csr_w_addrW;
    wire   [31:0]   csr_w_dataW;
    wire   [5:0]      EcodeW;
    wire              EsubCodeW;
    wire   [31:0]     eraW;

    
    wire   [31:0]     reg_w_dataW;    //写回阶段写数据
    wire   [31:0]     reg_w_data_00W;
    wire   [31:0]     reg_w_data_01W;
    wire   [31:0]     reg_w_data_10W;
    wire   [31:0]     reg_w_data_11W;
    wire   [31:0]     reg_w_dataM;    //访存阶段写数据
    wire   [31:0]     reg_w_data_00M;
    wire   [31:0]     reg_w_data_01M;
    wire   [31:0]     reg_w_data_10M;
    wire   [31:0]     reg_w_data_11M;
    
    wire int_ex;    // 中断类型例外
    wire ID_sys_ex;
    wire ID_brk_ex;
    wire ID_ine_ex;
    wire ID_adef_ex;
    wire EXE_ale_ex;
    
    wire ex_jump;  // 是否有例外
        
    wire [3:0]  ex_flush_pipe;       /* 清除流水信号 */
    wire [3:0]  ex_label_pipe;       /* 标记流水例外信号（即写CSR例外部分）*/
    wire [5:0]  Ecode;               /* ESTAT 一级例外类型字段 6位*/
    wire        EsubCode;            /* ESTAT 二级例外类型字段 9位，在此仅用到1位*/
    wire [31:0] era;                 /* 例外返回地址 */
    
    wire StallW,FlushW,StallM,FlushM,StallE,FlushE,StallD,hitF;
    wire [1:0]c_wayF;
    wire [1:0] csrForward;
    wire [1:0] csrForward_EENTRY;
    wire [31:0] pcE;
        
    //debug
    assign debug_wb_pc          = {8'b00011100, pcW[23:0]};                //访存阶段指令pc
    assign debug_wb_rf_wen      = RegWriteW;      
    assign debug_wb_rf_wnum     = WAW;            //访存阶段写寄存器
    assign debug_wb_rf_wdata    = reg_w_dataW;    //访存阶段写数据
    
    // Stages  包含各流水级没有交集的通路，regfile,hazard不在其中，若某一数据在一流水级中只是简单传递，也不会出现在对应的stage模块中
IF_stage u_IF_stage(
   .clk(clk),
   .rst(rst),
   .StallF(StallF),

   .if_jump(if_jump),        
   .pc_jump(pc_jump),  
   .pcD(pcD),
   .c_wayD(c_wayD),
   .hitD(hitD),
   .BranchD(BranchD),
   .call(call),
   .return(return),
   .pred_nxt_pc_D(pred_nxt_pc_D),
   .b_flushD(b_flushD),

   .inst_req(inst_req),     
   .inst_data_ok(inst_data_ok),
   .r_data(inst_rdata),

   .pc(pc),       
   .c_wayF(c_wayF),
   .hitF(hitF),
   .instrF(instrF),
   .pred_nxt_pc_F(pred_nxt_pc_F),
   .pcF(pcF)
    );
    
    assign ex_jump = |ex_label_pipe;  // 是否出现例外
    ID_stage u_ID_stage(
                       .clk(clk),
                       .rst(rst),
	                   .instrD(instrD),    
	                   .pcD(pcD),
	                   .RA1D(RA1D),
	                   .RA2D(RA2D),
                       .RD1(RD1),
                       .RD2(RD2),
                       .ForwardD1(ForwardD1),
                       .ForwardD2(ForwardD2),
                       .csrForward(csrForward),
                       .csrForward_EENTRY(csrForward_EENTRY),
                       .csr_w_dataE(RD2E),
                       .csr_w_dataM(RDM2),
                       .csr_w_dataW(csr_w_dataW),
                       .reg_w_dataM(reg_w_dataM),
                       .reg_w_dataW(reg_w_dataW),
	                   .if_jump(if_jump),     
	                   .pc_jump(pc_jump),  
                       .RD1D_Ford(RD1D_Ford),
                       .RD2D_Ford(RD2D_Ford),
                       .ALU_immD(ALU_immD),      
                       .dummyD(dummyD),
                       .i20_sllD(i20_sllD),
                       .WAD(WAD),
                       .WriteRegD(WriteRegD),
                       .WriteDataD(WriteDataD),
                       .RegWriteD(RegWriteD),
                       .SrcBD(SrcBD),
                       .ALUCtrlD(ALUCtrlD),
                       .MemWriteD(MemWriteD),
                       .MemToRegD(MemToRegD),
                       .DataSizeD(DataSizeD),
                       .BranchD(BranchD),
                       .call(call),
                       .return(return),
                       .ertn(ertnD),
                       .csr_r_dataD(csr_r_dataD),
                       .EENTRY(EENTRY),
                       .csrRegWriteD(csrRegWriteD),
                       .exceptionD(exceptionD),
                       .ReadRdcntCsrD(ReadRdcntCsrD),
                       
                       .ID_sys_ex(ID_sys_ex),
                       .ID_brk_ex(ID_brk_ex),
                       .ID_ine_ex(ID_ine_ex),
                       .ID_adef_ex(ID_adef_ex),
                       .ex_jump(ex_jump),
                       .origin_pc_jump(origin_pc_jump),
                       
                       .testD(testD)
    );
    
    assign csrHcodeE = RD1E;
    EX_stage u_EX_stage(
                     .clk(clk),
                     .rst(rst),
                     .stallE(StallE),
                     .flushE(FlushE),
                     .RD1E(RD1E),
                	 .RD2E(RD2E),
                	 .ALU_immE(ALU_immE),
                	 .i20_sllE(i20_sllE),
                	 .WAE(WAE),
                     .WriteRegE(WriteRegE),
                     .SrcBE(SrcBE),
                     .ALUCtrlE(ALUCtrlE),
                     .MemToRegE(MemToRegE),
                     .MemWriteE(MemWriteE),
                     .DataSizeE(DataSizeE),
                     .ForwardE1(ForwardE1),
                     .ForwardE2(ForwardE2),
                     .mult_stall(mult_stall),
                     .div_stall(div_stall),
                     .reg_w_dataM(reg_w_dataM),   
                     .reg_w_dataW(reg_w_dataW),
                	 .ALU_resultE(ALU_resultE),        
                	 .WAE_r(WAE_r),
                	 .EXE_ale_ex(EXE_ale_ex),
                	 .test(testE)
        );
        
        
     MEM_stage u_MEM_stage(
        .clk(clk),
	    .rst(rst),
    /*  来自流水级的访存请求  */
        .addr(ALU_resultM),
        .mem_r(MemToRegM),
        .mem_w(MemWriteM),
        .w_data(RDM2),
        .w_hcode(DataSizeM[1]?4'b1111 : (DataSizeM[0]?4'b0011 : 4'b0001)),
        .r_data(mem_rdataM),
    /*  与类sram接口的交互  */
        .sram_data_en(sram_data_en),
        .sram_data_wen(sram_data_wen),
        .sram_data_addr(sram_data_addr),
        .sram_data_wdata(sram_data_wdata), 
        .sram_data_ok(sram_data_ok),
        .sram_addr_ok(sram_addr_ok),
        .sram_data_rdata(sram_data_rdata),
    /*  流水阻塞  */
        .exe_mem_en(MemToRegE || MemWriteE), //执行阶段为访存指令
        .instr_mem_stall(instr_mem_stall),
        .fifo_mem_stall(fifo_mem_stall),
    
        .noCache(noCache)
	                 
    );
    
    WB_stage u_WB_stage(
                     .clk(clk),
                     .rst(rst),
	                 .MemToRegW(MemToRegW), 
	                 .DataSizeW(DataSizeW),        
	                 .mem_rdataW(mem_rdataW),   
	                 .ALU_resultW(ALU_resultW), 
	                 .instrW(instrW), 
	                 .reg_w_data_11(reg_w_data_11W)
    );
    
    //流水线寄存器：IF->ID, ID->EX, EX->MEM, MEM->WB
    IF2ID u_IF2ID(
                     .clk(clk),
                     .rst(rst),
                     .StallD(StallD),  //译码阶段阻塞
	                 .instrF(instrF),  //指令（IF）
	                 .pcF(pcF),        
	                 .c_wayF(c_wayF),
	                 .hitF(hitF),
	                 .instrD(instrD),
                     .pcD(pcD),
                     .c_wayD(c_wayD),
	                 .hitD(hitD),
	                 .pred_nxt_pc_F(pred_nxt_pc_F),
	                 .pred_nxt_pc_D(pred_nxt_pc_D),
	                 .b_flushD(b_flushD),
	                 .ex_flush_pipe_D(ex_flush_pipe[3]),
	                 .ex_label_pipe_D(ex_label_pipe[3]),
	                 .Ecode(Ecode),
	                 .EsubCode(EsubCode),
	                 .era(era)
    );
    
    ID2EX  u_ID2EX(  
                      .clk(clk),
                      .rst(rst),
                      .StallE(StallE),           //计算阶段阻塞
                      .FlushE(FlushE),           //计算阶段清空
                      .pcD(pcD),
    	              .RD1D_Ford(RD1D_Ford),
    	              .RD2D_Ford(RD2D_Ford),
    	              .ALU_immD(ALU_immD),        
    	              .dummyD(dummyD),
    	              .i20_sllD(i20_sllD),
    	              .RA1D(RA1D),
    	              .RA2D(RA2D),
    	              .WAD(WAD),
                      .WriteRegD(WriteRegD),
                      .WriteDataD(WriteDataD),
                      .RegWriteD(RegWriteD),
                      .SrcBD(SrcBD),
                      .ALUCtrlD(ALUCtrlD),
                      .MemWriteD(MemWriteD),
                      .MemToRegD(MemToRegD),
                      .DataSizeD(DataSizeD),
                      .instrD(instrD),
                      .ertnD(ertnD),
                      .csrRegWriteD(csrRegWriteD),
                      .exceptionD(exceptionD),
                      .pcE(pcE),
                      .RD1E(RD1E),
    	              .RD2E(RD2E),
    	              .ALU_immE(ALU_immE),        
    	              .dummyE(dummyE),
    	              .i20_sllE(i20_sllE),
    	              .RA1E(RA1E),
    	              .RA2E(RA2E),
    	              .WAE(WAE),
                      .WriteRegE(WriteRegE),
                      .WriteDataE(WriteDataE),
                      .RegWriteE(RegWriteE),
                      .SrcBE(SrcBE),
                      .ALUCtrlE(ALUCtrlE),
                      .MemWriteE(MemWriteE),
                      .MemToRegE(MemToRegE),
                      .DataSizeE(DataSizeE),
                      .instrE(instrE),
                      .ertnE(ertnE),
                      .csrRegWriteE(csrRegWriteE),
                      .exceptionE(exceptionE),
                      .ex_flush_pipe_E(ex_flush_pipe[2]),
	                  .ex_label_pipe_E(ex_label_pipe[2]),
	                  .Ecode(Ecode),
	                  .EsubCode(EsubCode),
	                  .era(era),
                      .EcodeE(EcodeE),
                      .EsubCodeE(EsubCodeE),
                      .eraE(eraE),
                      
                      .testD(testD),
                      .testE(testE)
        );
        
        EX2MEM  u_EX2MEM(
                      .clk(clk),
                      .rst(rst),
                      .StallM(StallM),           //访谈阶段阻塞
                      .FlushM(FlushM),           //访谈阶段清空
                      .RDE2(RD2E),
	                  .ALU_resultE(ALU_resultE),        
	                  .WAE_r(WAE_r),
	                  .i20_sllE(i20_sllE),
	                  .pcE(pcE),
	                  .dummyE(dummyE),
	                  .MemWriteE(MemWriteE),
	                  .DataSizeE(DataSizeE),
                      .MemToRegE(MemToRegE),
                      .WriteDataE(WriteDataE),
                      .RegWriteE(RegWriteE),
                      .instrE(instrE),
                      .ertnE(ertnE),
                      .csrRegWriteE(csrRegWriteE),
                      .csrHcodeE(csrHcodeE),
                      .exceptionE(exceptionE),
	                  .RDM2(RDM2),
	                  .ALU_resultM(ALU_resultM),        
	                  .WAM(WAM),
	                  .i20_sllM(i20_sllM),
	                  .pcM(pcM),
	                  .dummyM(dummyM),
	                  .MemWriteM(MemWriteM),
	                  .DataSizeM(DataSizeM),
                      .MemToRegM(MemToRegM),
                      .WriteDataM(WriteDataM),
                      .RegWriteM(RegWriteM),
                      .instrM(instrM),
                      .ertnM(ertnM),
                      .csrRegWriteM(csrRegWriteM),
                      .csrHcodeM(csrHcodeM),
                      .exceptionM(exceptionM),
                      .ex_flush_pipe_M(ex_flush_pipe[1]),
	                  .ex_label_pipe_M(ex_label_pipe[1]),
	                  .Ecode(Ecode),
	                  .EsubCode(EsubCode),
	                  .era(era),
	                  .EcodeE(EcodeE),
                      .EsubCodeE(EsubCodeE),
                      .eraE(eraE),
                      .EcodeM(EcodeM),
                      .EsubCodeM(EsubCodeM),
                      .eraM(eraM)
    );

    
    MEM2WB u_MEM2WB(
                      .clk(clk),
                      .rst(rst),
                      .StallW(StallW),           //写回阶段阻塞
                      .FlushW(FlushW),           //写回阶段清空
	                  .instrM(instrM),     
	                  .pcM(pcM),
	                  .WAM(WAM),
	                  .i20_sllM(i20_sllM),
	                  .dummyM(dummyM),
	                  .MemToRegM(MemToRegM),
 	                  .DataSizeM(DataSizeM),
                      .WriteDataM(WriteDataM),
                      .RegWriteM(RegWriteM),   
                      .mem_rdataM(mem_rdataM),    
                      .ertnM(ertnM),    
                      .csrRegWriteM(csrRegWriteM),
	                  .csrHcodeM(csrHcodeM),
	                  .exceptionM(exceptionM),
	                  .RDM2(RDM2),
	                  .instrW(instrW),     
	                  .pcW(pcW),
	                  .WAW(WAW),        //写回阶段指令写寄存器号
	                  .i20_sllW(i20_sllW),
	                  .dummyW(dummyW),
	                  .MemToRegW(MemToRegW),
 	                  .DataSizeW(DataSizeW),
                      .WriteDataW(WriteDataW),
                      .RegWriteW(RegWriteW),
                      .mem_rdataW(mem_rdataW),
                      .ALU_resultM(ALU_resultM),
                      .ALU_resultW(ALU_resultW),
                      .ertnW(ertnW),
                      .csrRegWriteW(csrRegWriteW),
                      .csrHcodeW(csrHcodeW),
                      .exceptionW(exceptionW),
                      .RDW2(csr_w_dataW),
                      .ex_flush_pipe_W(ex_flush_pipe[0]),
	                  .ex_label_pipe_W(ex_label_pipe[0]),
	                  .Ecode(Ecode),
	                  .EsubCode(EsubCode),
	                  .era(era),
	                  
	                  .EcodeM(EcodeM),   
                      .EsubCodeM(EsubCodeM),
                      .eraM(eraM),   
	                  
	                  .eraW(eraW),
	                  .EcodeW(EcodeW),
	                  .EsubCodeW(EsubCodeW)
    );
    
    

    //写回数据（写回阶段前推数据）
    assign reg_w_data_10W = i20_sllW;
    assign reg_w_data_01W = dummyW;
    assign reg_w_data_00W = pcW + 4;
    assign reg_w_dataW = WriteDataW[1] ? 
                        WriteDataW[0] ? reg_w_data_11W : reg_w_data_10W  :
                        WriteDataW[0] ? reg_w_data_01W : reg_w_data_00W;
    
    //访存阶段前推数据
    assign reg_w_data_11M = ALU_resultM;
    assign reg_w_data_10M = i20_sllM;                                 
    assign reg_w_data_01M = dummyM;                                   
    assign reg_w_data_00M = pcM + 4;                                      
    assign reg_w_dataM = WriteDataM[1] ?                              
                        WriteDataM[0] ? reg_w_data_11M : reg_w_data_10M  : 
                        WriteDataM[0] ? reg_w_data_01M : reg_w_data_00M;
                        
                        
    regfile u_regfile(
	                 .clk(clk),
	                 .rst(rst),
	                 .we3(RegWriteW),
	                 .ra1(RA1D),
	                 .ra2(RA2D),
	                 .wa3(WAW),
	                 .wd3(reg_w_dataW),
	                 .rd1(RD1),
	                 .rd2(RD2)
    );
    
    Hazard u_Hazard(
	.RA1D(RA1D),     //译码阶段源寄存器号
	.RA2D(RA2D),
	.RA1E(RA1E),     //计算阶段源寄存器号
	.RA2E(RA2E),
	.WAE(WAE),      //计算阶段阶段写寄存器号
	.WAM(WAM),      //访存阶段阶段写寄存器号
	.WAW(WAW),      //写回阶段阶段写寄存器号
	.RegWriteE(RegWriteE),      //计算阶段阶段寄存器写使能
	.RegWriteM(RegWriteM),      //访存阶段阶段寄存器写使能
	.RegWriteW(RegWriteW),      //写回阶段阶段寄存器写使能
	.MemToRegM(MemToRegM),      //访存阶段阶段寄存器是否写访存结果
	.mult_stall(mult_stall),
	.div_stall(div_stall),
	.ForwardD1(ForwardD1),
	.ForwardD2(ForwardD2),
	.ForwardE1(ForwardE1),
	.ForwardE2(ForwardE2),
	.instr_mem_stall(instr_mem_stall),     //指令访存阻塞
    .fifo_mem_stall(fifo_mem_stall),       //FIFO访存阻塞
	.stallF(StallF),
	.stallD(StallD),
	.stallE(StallE),
	.stallM(StallM),
	.stallW(StallW),
	.FlushE(FlushE),
	.FlushM(FlushM),
	.FlushW(FlushW),
	
	.csrForward(csrForward),
	.csrForward_EENTRY(csrForward_EENTRY),
	.csr_w_addrE(csr_w_addrE),
	.csr_w_addrM(csr_w_addrM),
	.csr_w_addrW(csr_w_addrW),
	.csr_r_addr(csr_r_addr),
	.csrRegWriteE(csrRegWriteE),
	.csrRegWriteM(csrRegWriteM),
	.csrRegWriteW(csrRegWriteW)
    );
    
    assign csr_w_addrE = instrE[23:10];
    assign csr_w_addrM = instrM[23:10];
    assign csr_w_addrW = instrW[23:10];
    assign csr_r_addr  = ertnD? 13'h6 : 
                            (ReadRdcntCsrD==2'b00)? instrD[23:10]:
                            (ReadRdcntCsrD==2'b01)? 14'h40:
                            (ReadRdcntCsrD==2'b10)? 14'h182:14'h183;
                             
    
    //控制状态寄存器
    csregfile u_csregfile(
                      .clk(clk),
                      .rst(rst),
                      .ertnD(ertnD),
                      .ertnW(ertnW),
	                  .wen(csrRegWriteW),
	                  .ex_jump(ex_jump),
	                  .exceptionW(exceptionW),
	                  .csr_w_addr(csr_w_addrW),
	                  .csr_r_addr(csr_r_addr),
	                  .w_data(csr_w_dataW),
	                  .Hcode(csrHcodeW),
	                  .instrW(instrW),
	                  .r_data(csr_r_dataD),
	                  .EENTRY(EENTRY),
	                  .HWI0(0),
	                  .HWI1(0),
	                  .HWI2(0),
	                  .HWI3(0),
	                  .HWI4(0),
	                  .HWI5(0),
	                  .HWI6(0),
	                  .HWI7(0),
	                  .IPI(0),
	                  .int_ex(int_ex),
	                  .eraW(eraW),
	                  .EcodeW(EcodeW),
	                  .EsubCodeW(EsubCodeW),
	                  .ALU_resultW(ALU_resultW)
    );
   

ex_controller ex_controller(
    .ID_sys_ex(ID_sys_ex),      /* 系统调用例外 */
    .ID_brk_ex(ID_brk_ex),      /* 断点例外 */
    .ID_int_ex(int_ex),         /* 中断例外 */
    .ID_ine_ex(ID_ine_ex),      /* 指令不存在例外 */
    .ID_adef_ex(ID_adef_ex),          /* 取指地址错误例外 */
    .EXE_ale_ex(EXE_ale_ex),          /* 访存地址错误例外 */
    .EXE_adem_ex(1'b0),
    
    .pcF(pcF),
    .pcD(pcD),
    .pcE(pcE),
    .pcM(pcM),                           /* 用于选出返回地址 */
    
    .exceptionD(exceptionD),
    .exceptionE(exceptionE),
    .exceptionM(exceptionM),
    .exceptionW(exceptionW),
    
    .ex_flush_pipe(ex_flush_pipe),       /* 清除流水信号 */
    .ex_label_pipe(ex_label_pipe),       /* 标记流水例外信号（即写CSR例外部分）*/
    
    .Ecode(Ecode),                       /* ESTAT 一级例外类型字段 6位*/
    .EsubCode(EsubCode),                 /* ESTAT 二级例外类型字段 9位，在此仅用到1位*/
    .era(era),                           /* 例外返回地址 */
    .origin_pc_jump(origin_pc_jump)
    );
endmodule
