module ID_stage(
    input wire clk,
    input wire rst,
    
    //IF  ->  ID
	input wire[31:0] instrD,     
	input wire[31:0] pcD,
	
	//regfile
	output wire[4:0]  RA1D,
	output wire[4:0]  RA2D,
    input  wire[31:0] RD1,
    input  wire[31:0] RD2,
    
    //Hazard
    input wire[1:0] ForwardD1,
    input wire[1:0] ForwardD2,
    input wire[1:0] csrForward,
    input wire[1:0] csrForward_EENTRY,
    
    // Ex_stage
    input wire[31:0] csr_w_dataE,
    input wire[31:0] csr_w_dataM,
    input wire[31:0] csr_w_dataW,
    
    //MEM_stage
    input wire[31:0] reg_w_dataM,
    
    //WB_stage
    input wire[31:0] reg_w_dataW,
						
	//IF_stage
	output wire           if_jump,   //是否跳转
	output wire   [31:0]  pc_jump,   //跳转地址
	
	//ID2IF
	output wire   [31:0]  RD1D_Ford,
	output wire   [31:0]  RD2D_Ford,
	output wire   [31:0]  ALU_immD,        
	output wire   [31:0]  dummyD,
	output wire   [31:0]  i20_sllD,
	output wire   [4:0]   WAD,
	
    output wire           WriteRegD,
    output wire   [1:0]   WriteDataD,
    output wire           RegWriteD,
    output wire           SrcBD,
    output wire   [18:0]  ALUCtrlD,
    output wire           MemWriteD,
    output wire           MemToRegD,
    output wire   [1:0]   DataSizeD,
    output wire           BranchD,
    output wire           call,
    output wire           return,
    output wire           ertn,
    input  wire   [31:0]  csr_r_dataD,
    input  wire   [31:0]  EENTRY,
    output wire           csrRegWriteD,
    output wire           exceptionD,
    output wire   [1:0]   ReadRdcntCsrD,
    
    /* 例外相关 */
    output wire ID_sys_ex,
    output wire ID_brk_ex,
    output wire ID_ine_ex,
    output wire ID_adef_ex,
    input wire ex_jump,
    output wire [31:0]  origin_pc_jump  ,
    
    output wire testD 
    );
    
    //Controller
    wire           ReadRegD;
    wire           offstD;
    wire           ImmdD;
    wire           SignExtD;
    wire           JumpD;
    wire  [1:0]    BKindD;
    wire           JirlD;
    wire           sftD;
    wire           csrSrcD;
    wire           csrHcodeD;
//    wire  [1:0]    ReadRdcntCsrD;
    wire           WriteRjD;
    
    //译码
    wire [4:0]   rk,rj,rd;  //操作数地址
    wire [4:0]   i5;        //五位立即数
    wire [11:0]  i12;       //十二位立即数
    wire [19:0]  i20;       //二十位立即数  
    wire [13:0]  csr;       //控制状态寄存器地址
    wire [15:0]  offs_16;    //十六位跳转地址偏移
    wire [25:0]  offs_26;    //二十六位跳转地址偏移
    
    //立即数处理
    wire [31:0]  i5_extend;
    wire [31:0]  i12_extend;
    //output wire [31:0]  i20_sllD;
    wire [31:0]  offs_16_extend;    //十六位跳转地址偏移
    wire [31:0]  offs_26_extend;    //二十六位跳转地址偏移
    wire [31:0]  offs_sll;
    //output wire [31:0]  ALU_immD;      //ALU运算立即数
    wire [31:0]  jump_offs;    //跳转地址偏移
    
    //分支判断
    wire          Bcondt;
    wire          if_Branch;
    //output wire if_jump;
    reg [31:0]   csr_r_dataD_forward;
    always@(*)begin
        if(csrForward == 2'b00)
            csr_r_dataD_forward = csr_r_dataD;
        else if(csrForward == 2'b01)
            csr_r_dataD_forward = csr_w_dataE;
        else if(csrForward == 2'b10)
            csr_r_dataD_forward = csr_w_dataM;    
        else
            csr_r_dataD_forward = csr_w_dataW;    
    end
    
    reg [31:0]   EENTRY_forward;
    always@(*)begin
        if(csrForward_EENTRY == 2'b00)
            EENTRY_forward = EENTRY;
        else if(csrForward_EENTRY == 2'b01)
            EENTRY_forward = csr_w_dataE;
        else if(csrForward_EENTRY == 2'b10)
            EENTRY_forward = csr_w_dataM;    
        else
            EENTRY_forward = csr_w_dataW;    
    end
    
    assign call   = (instrD[31:26] == 6'b010011 || instrD[31:19] == 13'b0000000000101)?1:0;
    assign return = (instrD[31:11] == 21'b000001100100100000111)||(instrD[31:26] == 6'b010101)?1:0;
    assign ertn   = (instrD[31:11] == 21'b000001100100100000111)?1:0;
    
    Controller con(
    .instr(instrD),
    .ReadReg(ReadRegD),
    .WriteReg(WriteRegD),
    .WriteData(WriteDataD),
    .RegWrite(RegWriteD),
    .offst(offstD),
    .Immd(ImmdD),
    .SignExt(SignExtD),
    .SrcB(SrcBD),
    .ALUCtrl(ALUCtrlD),
    .MemWrite(MemWriteD),
    .MemToReg(MemToRegD),
    .Branch(BranchD),
    .Jump(JumpD),
    .BKind(BKindD),
    .Jirl(JirlD),
    .DataSize(DataSizeD),
    .sft(sftD),
    .csrSrc(csrSrcD),
    .csrRegWrite(csrRegWriteD),
    .csrHcode(csrHcodeD),
    .exception(exceptionD),
    .ReadRdcntCsr(ReadRdcntCsrD),
    .WriteRj(WriteRjD),
    .ID_ine_ex(ID_ine_ex),
    .TEST(testD)
    );
    
    //译码    
    assign rk = rst?0:instrD[14:10];      
    assign rj = rst?0:instrD[9:5];        
    assign rd = rst?0:instrD[4:0];      
            
    assign i5 = instrD[14:10];       
    assign i12 = instrD[21:10];    
    assign i20 = instrD[24:5];    
    assign offs_16 = instrD[25:10];
    assign offs_26 = {instrD[9:0],instrD[25:10]}; 
    
    //立即数处理
    assign i5_extend = {27'b0,i5};               
    assign i12_extend = (SignExtD==0) ? {20'b0,i12}:
                        i12[11] ? {20'hfffff,i12}:
                        {20'h00000,i12};
    assign i20_sllD = {i20,12'b0};  
    assign offs_16_extend = offs_16[15] ? {16'hffff,offs_16} : {16'b0,offs_16};
    assign offs_26_extend = offs_26[25] ? {6'h3f,offs_26} : {6'b0,offs_26};
    assign ALU_immD = ImmdD ? i12_extend : i5_extend;
    assign jump_offs = offstD ? offs_26_extend : offs_16_extend;
    assign offs_sll = jump_offs << 2'b10;
    wire [31:0] imm_add_src1;
    wire [31:0] imm_add_src2;
    wire [31:0] imm_add_result;
    assign imm_add_src1 = JirlD ? pcD : RD1D_Ford;
    assign imm_add_src2 = sftD ? i20_sllD : offs_sll;
    assign imm_add_result = imm_add_src1 + imm_add_src2;

    assign origin_pc_jump = (csrSrcD) ? imm_add_result : csr_r_dataD_forward;
    assign dummyD = ex_jump ? EENTRY_forward : origin_pc_jump; //前推*********
    
    wire if_branch;
    
    //分支判断
    wire [31:0] alusrc1,alusrc2,alures;
    wire isu,alucout,less,lessu;
    assign isu = instrD[27];
    assign alusrc1 =  RD1D_Ford;
    assign alusrc2 = ~RD2D_Ford + 1'b1;
    assign {alucout, alures} = alusrc1 + alusrc2;
    assign less  = (RD1D_Ford[31] & ~RD2D_Ford[31]) | ((RD1D_Ford[31] ~^ RD2D_Ford[31]) & alures[31]);
    assign lessu = RD1D_Ford < RD2D_Ford;
    
    assign Bcondt = BKindD[1] ? 
                    BKindD[0] ? ~(isu? lessu : less) : (isu? lessu : less) :
                    BKindD[0] ? ~(RD1D_Ford  ==  RD2D_Ford) : (RD1D_Ford  ==  RD2D_Ford);
    assign if_branch = Bcondt & BranchD;
    assign if_jump = if_branch | JumpD | ex_jump;
    assign pc_jump = if_jump? dummyD:pcD+4;
    
    //寄存器堆
    assign RA1D = rj;
    assign RA2D = ReadRegD ? rd : rk ;
//    assign WAD  = WriteRegD ? 5'b1 : rd;
    assign WAD  = WriteRjD ? rj : rd;
    
    //数据前推
    assign RD1D_Ford = ForwardD1[1] ? 
                       ForwardD1[0] ? 32'bz : reg_w_dataM  :
                       ForwardD1[0] ? reg_w_dataW : RD1;
                       
    assign RD2D_Ford = ForwardD2[1] ? 
                       ForwardD2[0] ? 32'bz : reg_w_dataM  :
                       ForwardD2[0] ? reg_w_dataW : RD2;                     
    
    assign ID_sys_ex = exceptionD & instrD[16];
    assign ID_brk_ex = exceptionD & ~instrD[16]; 
    assign ID_adef_ex = (if_branch | JumpD) & (origin_pc_jump[1:0] != 2'b0);
    //ID_ine_ex 由controller得出
    
endmodule
