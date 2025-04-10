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
    
   
    
    //IF ȡָ�׶�
    wire              StallF;
    wire              if_jump;         //�Ƿ���ת��ID��
	wire   [31:0]     pc_jump;   //��ת��ַ��ID��
	wire   [31:0]     instrF;    //��ˮ�߷�����ָ��   
	wire   [31:0]     pred_nxt_pc_F;
	wire   [31:0]     pcF;

	//ID ����׶�
	wire              ertnD;
	wire   [31:0]     instrD;     
	wire   [31:0]     pcD;
	wire   [4:0]      RA1D;
	wire   [4:0]      RA2D;
    wire   [31:0]     RD1;            //�Ĵ�����������1
    wire   [31:0]     RD2;            //�Ĵ�����������2
    wire   [1:0]      ForwardD1;      //������1�Ƿ���Ҫǰ��
    wire   [1:0]      ForwardD2;      //������2�Ƿ���Ҫǰ��
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
    
    //EX ����׶�
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
    
    //MEM �ô�׶�
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

    wire             instr_mem_stall;  //ָ��ô�����
    wire             fifo_mem_stall;   //storeFIFO�ô�����

    //WB д�ؽ׶�
    wire   [31:0]   instrW;     
	wire   [31:0]   pcW;
	wire   [4:0]    WAW;        //д�ؽ׶�ָ��д�Ĵ�����
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

    
    wire   [31:0]     reg_w_dataW;    //д�ؽ׶�д����
    wire   [31:0]     reg_w_data_00W;
    wire   [31:0]     reg_w_data_01W;
    wire   [31:0]     reg_w_data_10W;
    wire   [31:0]     reg_w_data_11W;
    wire   [31:0]     reg_w_dataM;    //�ô�׶�д����
    wire   [31:0]     reg_w_data_00M;
    wire   [31:0]     reg_w_data_01M;
    wire   [31:0]     reg_w_data_10M;
    wire   [31:0]     reg_w_data_11M;
    
    wire int_ex;    // �ж���������
    wire ID_sys_ex;
    wire ID_brk_ex;
    wire ID_ine_ex;
    wire ID_adef_ex;
    wire EXE_ale_ex;
    
    wire ex_jump;  // �Ƿ�������
        
    wire [3:0]  ex_flush_pipe;       /* �����ˮ�ź� */
    wire [3:0]  ex_label_pipe;       /* �����ˮ�����źţ���дCSR���ⲿ�֣�*/
    wire [5:0]  Ecode;               /* ESTAT һ�����������ֶ� 6λ*/
    wire        EsubCode;            /* ESTAT �������������ֶ� 9λ���ڴ˽��õ�1λ*/
    wire [31:0] era;                 /* ���ⷵ�ص�ַ */
    
    wire StallW,FlushW,StallM,FlushM,StallE,FlushE,StallD,hitF;
    wire [1:0]c_wayF;
    wire [1:0] csrForward;
    wire [1:0] csrForward_EENTRY;
    wire [31:0] pcE;
        
    //debug
    assign debug_wb_pc          = {8'b00011100, pcW[23:0]};                //�ô�׶�ָ��pc
    assign debug_wb_rf_wen      = RegWriteW;      
    assign debug_wb_rf_wnum     = WAW;            //�ô�׶�д�Ĵ���
    assign debug_wb_rf_wdata    = reg_w_dataW;    //�ô�׶�д����
    
    // Stages  ��������ˮ��û�н�����ͨ·��regfile,hazard�������У���ĳһ������һ��ˮ����ֻ�Ǽ򵥴��ݣ�Ҳ��������ڶ�Ӧ��stageģ����
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
    
    assign ex_jump = |ex_label_pipe;  // �Ƿ��������
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
    /*  ������ˮ���ķô�����  */
        .addr(ALU_resultM),
        .mem_r(MemToRegM),
        .mem_w(MemWriteM),
        .w_data(RDM2),
        .w_hcode(DataSizeM[1]?4'b1111 : (DataSizeM[0]?4'b0011 : 4'b0001)),
        .r_data(mem_rdataM),
    /*  ����sram�ӿڵĽ���  */
        .sram_data_en(sram_data_en),
        .sram_data_wen(sram_data_wen),
        .sram_data_addr(sram_data_addr),
        .sram_data_wdata(sram_data_wdata), 
        .sram_data_ok(sram_data_ok),
        .sram_addr_ok(sram_addr_ok),
        .sram_data_rdata(sram_data_rdata),
    /*  ��ˮ����  */
        .exe_mem_en(MemToRegE || MemWriteE), //ִ�н׶�Ϊ�ô�ָ��
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
    
    //��ˮ�߼Ĵ�����IF->ID, ID->EX, EX->MEM, MEM->WB
    IF2ID u_IF2ID(
                     .clk(clk),
                     .rst(rst),
                     .StallD(StallD),  //����׶�����
	                 .instrF(instrF),  //ָ�IF��
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
                      .StallE(StallE),           //����׶�����
                      .FlushE(FlushE),           //����׶����
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
                      .StallM(StallM),           //��̸�׶�����
                      .FlushM(FlushM),           //��̸�׶����
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
                      .StallW(StallW),           //д�ؽ׶�����
                      .FlushW(FlushW),           //д�ؽ׶����
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
	                  .WAW(WAW),        //д�ؽ׶�ָ��д�Ĵ�����
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
    
    

    //д�����ݣ�д�ؽ׶�ǰ�����ݣ�
    assign reg_w_data_10W = i20_sllW;
    assign reg_w_data_01W = dummyW;
    assign reg_w_data_00W = pcW + 4;
    assign reg_w_dataW = WriteDataW[1] ? 
                        WriteDataW[0] ? reg_w_data_11W : reg_w_data_10W  :
                        WriteDataW[0] ? reg_w_data_01W : reg_w_data_00W;
    
    //�ô�׶�ǰ������
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
	.RA1D(RA1D),     //����׶�Դ�Ĵ�����
	.RA2D(RA2D),
	.RA1E(RA1E),     //����׶�Դ�Ĵ�����
	.RA2E(RA2E),
	.WAE(WAE),      //����׶ν׶�д�Ĵ�����
	.WAM(WAM),      //�ô�׶ν׶�д�Ĵ�����
	.WAW(WAW),      //д�ؽ׶ν׶�д�Ĵ�����
	.RegWriteE(RegWriteE),      //����׶ν׶μĴ���дʹ��
	.RegWriteM(RegWriteM),      //�ô�׶ν׶μĴ���дʹ��
	.RegWriteW(RegWriteW),      //д�ؽ׶ν׶μĴ���дʹ��
	.MemToRegM(MemToRegM),      //�ô�׶ν׶μĴ����Ƿ�д�ô���
	.mult_stall(mult_stall),
	.div_stall(div_stall),
	.ForwardD1(ForwardD1),
	.ForwardD2(ForwardD2),
	.ForwardE1(ForwardE1),
	.ForwardE2(ForwardE2),
	.instr_mem_stall(instr_mem_stall),     //ָ��ô�����
    .fifo_mem_stall(fifo_mem_stall),       //FIFO�ô�����
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
                             
    
    //����״̬�Ĵ���
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
    .ID_sys_ex(ID_sys_ex),      /* ϵͳ�������� */
    .ID_brk_ex(ID_brk_ex),      /* �ϵ����� */
    .ID_int_ex(int_ex),         /* �ж����� */
    .ID_ine_ex(ID_ine_ex),      /* ָ��������� */
    .ID_adef_ex(ID_adef_ex),          /* ȡָ��ַ�������� */
    .EXE_ale_ex(EXE_ale_ex),          /* �ô��ַ�������� */
    .EXE_adem_ex(1'b0),
    
    .pcF(pcF),
    .pcD(pcD),
    .pcE(pcE),
    .pcM(pcM),                           /* ����ѡ�����ص�ַ */
    
    .exceptionD(exceptionD),
    .exceptionE(exceptionE),
    .exceptionM(exceptionM),
    .exceptionW(exceptionW),
    
    .ex_flush_pipe(ex_flush_pipe),       /* �����ˮ�ź� */
    .ex_label_pipe(ex_label_pipe),       /* �����ˮ�����źţ���дCSR���ⲿ�֣�*/
    
    .Ecode(Ecode),                       /* ESTAT һ�����������ֶ� 6λ*/
    .EsubCode(EsubCode),                 /* ESTAT �������������ֶ� 9λ���ڴ˽��õ�1λ*/
    .era(era),                           /* ���ⷵ�ص�ַ */
    .origin_pc_jump(origin_pc_jump)
    );
endmodule
