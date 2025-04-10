`timescale 1ns / 1ps
module Controller(
    input  wire  [31:0]  instr,
    output reg           ReadReg,
    output reg           WriteReg,
    output reg   [1:0]   WriteData,
    output reg           RegWrite,
    output reg           offst,
    output reg           Immd,
    output reg           SignExt,
    output reg           SrcB,
    output reg   [18:0]  ALUCtrl,
    output reg           MemWrite,
    output reg           MemToReg,
    output reg           Branch,
    output reg           Jump,
    output reg   [1:0]   BKind,
    output reg           Jirl,
    output reg   [1:0]   DataSize,
    output reg           sft,
    output reg           csrSrc,
    output reg           csrRegWrite,
    output reg           csrHcode,
    output reg           exception,
    output reg   [1:0]   ReadRdcntCsr,       //  00->ÆÕÍ¨ÒëÂë¶ÁCSR¼Ä´æÆ÷µØÖ·  01->¶Á¶¨Ê±Æ÷±àºÅ  02£¬03-> ¶Áºã¶¨ÆµÂÊ¼ÆÊ±Æ÷µÍ£¬¸ß32Î»
    output reg           WriteRj,            //  0->Ð´rd   [4:0]  1->Ð´rj   [9:5]
    
    output reg           ID_ine_ex
    );
    
    wire  ReadReg_jump;
    wire  WriteReg_jump;
    wire [1:0] WriteData_jump;
    wire  RegWrite_jump;
    wire  offst_jump;
    wire  Immd_jump;
    wire  SignExt_jump;
    wire  SrcB_jump;
    wire [18:0] ALUCtrl_jump;
    wire  MemWrite_jump;
    wire  MemToReg_jump;
    wire  Branch_jump;
    wire  Jump_jump;
    wire [1:0] BKind_jump;
    wire  Jirl_jump;
    wire [1:0] DataSize_jump;
    wire  sft_jump;
    wire  csrSrc_jump;
    wire  csrRegWrite_jump;
    wire  csrHcode_jump;
    wire  exception_jump;
    wire [1:0] ReadRdcntCsr_jump;    
    wire  WriteRj_jump;        
    wire ID_ine_ex_jump;

    wire  ReadReg_mem;
    wire  WriteReg_mem;
    wire [1:0] WriteData_mem;
    wire  RegWrite_mem;
    wire  offst_mem;
    wire  Immd_mem;
    wire  SignExt_mem;
    wire  SrcB_mem;
    wire [18:0] ALUCtrl_mem;
    wire  MemWrite_mem;
    wire  MemToReg_mem;
    wire  Branch_mem;
    wire  Jump_mem;
    wire [1:0] BKind_mem;
    wire  Jirl_mem;
    wire [1:0] DataSize_mem;
    wire  sft_mem;
    wire  csrSrc_mem;
    wire  csrRegWrite_mem;
    wire  csrHcode_mem;
    wire  exception_mem;
    wire ID_ine_ex_mem;
    wire [1:0] ReadRdcntCsr_mem;    
    wire  WriteRj_mem; 

    wire  ReadReg_opr;
    wire  WriteReg_opr;
    wire [1:0] WriteData_opr;
    wire  RegWrite_opr;
    wire  offst_opr;
    wire  Immd_opr;
    wire  SignExt_opr;
    wire  SrcB_opr;
    wire [18:0] ALUCtrl_opr;
    wire  MemWrite_opr;
    wire  MemToReg_opr;
    wire  Branch_opr;
    wire  Jump_opr;
    wire [1:0] BKind_opr;
    wire  Jirl_opr;
    wire [1:0] DataSize_opr;
    wire  sft_opr;
    wire  csrSrc_opr;
    wire  csrRegWrite_opr;
    wire  csrHcode_opr;
    wire  exception_opr;
    wire ID_ine_ex_opr;
    wire [1:0] ReadRdcntCsr_opr;    
    wire  WriteRj_opr; 

    wire  ReadReg_usft;
    wire  WriteReg_usft;
    wire [1:0] WriteData_usft;
    wire  RegWrite_usft;
    wire  offst_usft;
    wire  Immd_usft;
    wire  SignExt_usft;
    wire  SrcB_usft;
    wire [18:0] ALUCtrl_usft;
    wire  MemWrite_usft;
    wire  MemToReg_usft;
    wire  Branch_usft;
    wire  Jump_usft;
    wire [1:0] BKind_usft;
    wire  Jirl_usft;
    wire [1:0] DataSize_usft;
    wire  sft_usft;
    wire  csrSrc_usft;
    wire  csrRegWrite_usft;
    wire  csrHcode_usft;
    wire  exception_usft;
    wire ID_ine_ex_usft;
    wire [1:0] ReadRdcntCsr_usft;    
    wire  WriteRj_usft; 
    

    wire  ReadReg_oprI;
    wire  WriteReg_oprI;
    wire [1:0] WriteData_oprI;
    wire  RegWrite_oprI;
    wire  offst_oprI;
    wire  Immd_oprI;
    wire  SignExt_oprI;
    wire  SrcB_oprI;
    wire [18:0] ALUCtrl_oprI;
    wire  MemWrite_oprI;
    wire  MemToReg_oprI;
    wire  Branch_oprI;
    wire  Jump_oprI;
    wire [1:0] BKind_oprI;
    wire  Jirl_oprI;
    wire [1:0] DataSize_oprI;
    wire  sft_oprI;
    wire  csrSrc_oprI;
    wire  csrRegWrite_oprI;
    wire  csrHcode_oprI;
    wire  exception_oprI;
    wire ID_ine_ex_oprI;
    wire [1:0] ReadRdcntCsr_oprI;    
    wire  WriteRj_oprI; 

    wire  ReadReg_I20;
    wire  WriteReg_I20;
    wire [1:0] WriteData_I20;
    wire  RegWrite_I20;
    wire  offst_I20;
    wire  Immd_I20;
    wire  SignExt_I20;
    wire  SrcB_I20;
    wire [18:0] ALUCtrl_I20;
    wire  MemWrite_I20;
    wire  MemToReg_I20;
    wire  Branch_I20;
    wire  Jump_I20;
    wire [1:0] BKind_I20;
    wire  Jirl_I20;
    wire [1:0] DataSize_I20;
    wire  sft_I20;
    wire  csrSrc_I20;
    wire  csrRegWrite_I20;
    wire  csrHcode_I20;
    wire  exception_I20;
    wire ID_ine_ex_I20;
    wire [1:0] ReadRdcntCsr_I20;    
    wire  WriteRj_I20; 

    wire  ReadReg_csr;
    wire  WriteReg_csr;
    wire [1:0] WriteData_csr;
    wire  RegWrite_csr;
    wire  offst_csr;
    wire  Immd_csr;
    wire  SignExt_csr;
    wire  SrcB_csr;
    wire [18:0] ALUCtrl_csr;
    wire  MemWrite_csr;
    wire  MemToReg_csr;
    wire  Branch_csr;
    wire  Jump_csr;
    wire [1:0] BKind_csr;
    wire  Jirl_csr;
    wire [1:0] DataSize_csr;
    wire  sft_csr;
    wire  csrSrc_csr;
    wire  csrRegWrite_csr;
    wire  csrHcode_csr;
    wire  exception_csr;
    wire ID_ine_ex_csr;
    wire [1:0] ReadRdcntCsr_csr;    
    wire  WriteRj_csr; 
    
    wire  ReadReg_exc;
    wire  WriteReg_exc;
    wire [1:0] WriteData_exc;
    wire  RegWrite_exc;
    wire  offst_exc;
    wire  Immd_exc;
    wire  SignExt_exc;
    wire  SrcB_exc;
    wire [18:0] ALUCtrl_exc;
    wire  MemWrite_exc;
    wire  MemToReg_exc;
    wire  Branch_exc;
    wire  Jump_exc;
    wire [1:0] BKind_exc;
    wire  Jirl_exc;
    wire [1:0] DataSize_exc;
    wire  sft_exc;
    wire  csrSrc_exc;
    wire  csrRegWrite_exc;
    wire  csrHcode_exc;
    wire  exception_exc;
    wire ID_ine_ex_exc;
    wire [1:0] ReadRdcntCsr_exc;    
    wire  WriteRj_exc; 
    
    wire  ReadReg_cache;
    wire  WriteReg_cache;
    wire [1:0] WriteData_cache;
    wire  RegWrite_cache;
    wire  offst_cache;
    wire  Immd_cache;
    wire  SignExt_cache;
    wire  SrcB_cache;
    wire [18:0] ALUCtrl_cache;
    wire  MemWrite_cache;
    wire  MemToReg_cache;
    wire  Branch_cache;
    wire  Jump_cache;
    wire [1:0] BKind_cache;
    wire  Jirl_cache;
    wire [1:0] DataSize_cache;
    wire  sft_cache;
    wire  csrSrc_cache;
    wire  csrRegWrite_cache;
    wire  csrHcode_cache;
    wire  exception_cache; 
    wire ID_ine_ex_cache;
    wire [1:0] ReadRdcntCsr_cache;    
    wire  WriteRj_cache; 
    
    wire  ReadReg_rdcnt;
    wire  WriteReg_rdcnt;
    wire [1:0] WriteData_rdcnt;
    wire  RegWrite_rdcnt;
    wire  offst_rdcnt;
    wire  Immd_rdcnt;
    wire  SignExt_rdcnt;
    wire  SrcB_rdcnt;
    wire [18:0] ALUCtrl_rdcnt;
    wire  MemWrite_rdcnt;
    wire  MemToReg_rdcnt;
    wire  Branch_rdcnt;
    wire  Jump_rdcnt;
    wire [1:0] BKind_rdcnt;
    wire  Jirl_rdcnt;
    wire [1:0] DataSize_rdcnt;
    wire  sft_rdcnt;
    wire  csrSrc_rdcnt;
    wire  csrRegWrite_rdcnt;
    wire  csrHcode_rdcnt;
    wire  exception_rdcnt; 
    wire ID_ine_ex_rdcnt;
    wire [1:0] ReadRdcntCsr_rdcnt;    
    wire  WriteRj_rdcnt; 
    
    I20Class i20(
    .instr(instr),
    .ReadReg(ReadReg_I20),
    .WriteReg(WriteReg_I20),
    .WriteData(WriteData_I20),
    .RegWrite(RegWrite_I20),
    .offst(offst_I20),
    .Immd(Immd_I20),
    .SignExt(SignExt_I20),
    .SrcB(SrcB_I20),
    .ALUCtrl(ALUCtrl_I20),
    .MemWrite(MemWrite_I20),
    .MemToReg(MemToReg_I20),
    .Branch(Branch_I20),
    .Jump(Jump_I20),
    .BKind(BKind_I20),
    .Jirl(Jirl_I20),
    .DataSize(DataSize_I20),
    .sft(sft_I20),
    .csrSrc(csrSrc_I20),
    .csrRegWrite(csrRegWrite_I20),
    .csrHcode(csrHcode_I20),
    .exception(exception_I20),
    .ReadRdcntCsr(ReadRdcntCsr_I20),
    .WriteRj(WriteRj_I20), 
    .ID_ine_ex(ID_ine_ex_I20)
    );
    
    JumpClass jump(
    .instr(instr),
    .ReadReg(ReadReg_jump),
    .WriteReg(WriteReg_jump),
    .WriteData(WriteData_jump),
    .RegWrite(RegWrite_jump),
    .offst(offst_jump),
    .Immd(Immd_jump),
    .SignExt(SignExt_jump),
    .SrcB(SrcB_jump),
    .ALUCtrl(ALUCtrl_jump),
    .MemWrite(MemWrite_jump),
    .MemToReg(MemToReg_jump),
    .Branch(Branch_jump),
    .Jump(Jump_jump),
    .BKind(BKind_jump),
    .Jirl(Jirl_jump),
    .DataSize(DataSize_jump),
    .sft(sft_jump),
    .csrSrc(csrSrc_jump),
    .csrRegWrite(csrRegWrite_jump),
    .csrHcode(csrHcode_jump),
    .exception(exception_jump),
    .ReadRdcntCsr(ReadRdcntCsr_jump),
    .WriteRj(WriteRj_jump),  
    .ID_ine_ex(ID_ine_ex_jump)
    );
    
    csrClass csr(
    .instr(instr),
    .ReadReg(ReadReg_csr),
    .WriteReg(WriteReg_csr),
    .WriteData(WriteData_csr),
    .RegWrite(RegWrite_csr),
    .offst(offst_csr),
    .Immd(Immd_csr),
    .SignExt(SignExt_csr),
    .SrcB(SrcB_csr),
    .ALUCtrl(ALUCtrl_csr),
    .MemWrite(MemWrite_csr),
    .MemToReg(MemToReg_csr),
    .Branch(Branch_csr),
    .Jump(Jump_csr),
    .BKind(BKind_csr),
    .Jirl(Jirl_csr),
    .DataSize(DataSize_csr),
    .sft(sft_csr),
    .csrSrc(csrSrc_csr),
    .csrRegWrite(csrRegWrite_csr),
    .csrHcode(csrHcode_csr),
    .exception(exception_csr),
    .ReadRdcntCsr(ReadRdcntCsr_csr),
    .WriteRj(WriteRj_csr),  
    .ID_ine_ex(ID_ine_ex_csr)
    );
    
    memClass mem(
    .instr(instr),
    .ReadReg(ReadReg_mem),
    .WriteReg(WriteReg_mem),
    .WriteData(WriteData_mem),
    .RegWrite(RegWrite_mem),
    .offst(offst_mem),
    .Immd(Immd_mem),
    .SignExt(SignExt_mem),
    .SrcB(SrcB_mem),
    .ALUCtrl(ALUCtrl_mem),
    .MemWrite(MemWrite_mem),
    .MemToReg(MemToReg_mem),
    .Branch(Branch_mem),
    .Jump(Jump_mem),
    .BKind(BKind_mem),
    .Jirl(Jirl_mem),
    .DataSize(DataSize_mem),
    .sft(sft_mem),
    .csrSrc(csrSrc_mem),
    .csrRegWrite(csrRegWrite_mem),
    .csrHcode(csrHcode_mem),
    .exception(exception_mem),
    .ReadRdcntCsr(ReadRdcntCsr_mem),
    .WriteRj(WriteRj_mem),  
    .ID_ine_ex(ID_ine_ex_mem)
    );
    
     ushiftClass ushif(
    .instr(instr),
    .ReadReg(ReadReg_usft),
    .WriteReg(WriteReg_usft),
    .WriteData(WriteData_usft),
    .RegWrite(RegWrite_usft),
    .offst(offst_usft),
    .Immd(Immd_usft),
    .SignExt(SignExt_usft),
    .SrcB(SrcB_usft),
    .ALUCtrl(ALUCtrl_usft),
    .MemWrite(MemWrite_usft),
    .MemToReg(MemToReg_usft),
    .Branch(Branch_usft),
    .Jump(Jump_usft),
    .BKind(BKind_usft),
    .Jirl(Jirl_usft),
    .DataSize(DataSize_usft),
    .sft(sft_usft),
    .csrSrc(csrSrc_usft),
    .csrRegWrite(csrRegWrite_usft),
    .csrHcode(csrHcode_usft),
    .exception(exception_usft),
    .ReadRdcntCsr(ReadRdcntCsr_usft),
    .WriteRj(WriteRj_usft),  
    .ID_ine_ex(ID_ine_ex_usft)
    );
    
     operatorClass operator(
    .instr(instr),
    .ReadReg(ReadReg_opr),
    .WriteReg(WriteReg_opr),
    .WriteData(WriteData_opr),
    .RegWrite(RegWrite_opr),
    .offst(offst_opr),
    .Immd(Immd_opr),
    .SignExt(SignExt_opr),
    .SrcB(SrcB_opr),
    .ALUCtrl(ALUCtrl_opr),
    .MemWrite(MemWrite_opr),
    .MemToReg(MemToReg_opr),
    .Branch(Branch_opr),
    .Jump(Jump_opr),
    .BKind(BKind_opr),
    .Jirl(Jirl_opr),
    .DataSize(DataSize_opr),
    .sft(sft_opr),
    .csrSrc(csrSrc_opr),
    .csrRegWrite(csrRegWrite_opr),
    .csrHcode(csrHcode_opr),
    .exception(exception_opr),
    .ReadRdcntCsr(ReadRdcntCsr_opr),
    .WriteRj(WriteRj_opr),  
    .ID_ine_ex(ID_ine_ex_opr)
    );

    IOperatorClass ioperator(
    .instr(instr),
    .ReadReg(ReadReg_oprI),
    .WriteReg(WriteReg_oprI),
    .WriteData(WriteData_oprI),
    .RegWrite(RegWrite_oprI),
    .offst(offst_oprI),
    .Immd(Immd_oprI),
    .SignExt(SignExt_oprI),
    .SrcB(SrcB_oprI),
    .ALUCtrl(ALUCtrl_oprI),
    .MemWrite(MemWrite_oprI),
    .MemToReg(MemToReg_oprI),
    .Branch(Branch_oprI),
    .Jump(Jump_oprI),
    .BKind(BKind_oprI),
    .Jirl(Jirl_oprI),
    .DataSize(DataSize_oprI),
    .sft(sft_oprI),
    .csrSrc(csrSrc_oprI),
    .csrRegWrite(csrRegWrite_oprI),
    .csrHcode(csrHcode_oprI),
    .exception(exception_oprI),
    .ReadRdcntCsr(ReadRdcntCsr_oprI),
    .WriteRj(WriteRj_oprI),  
    .ID_ine_ex(ID_ine_ex_oprI)
    );
        
        exceptionClass excep(
        .instr(instr),
        .ReadReg(ReadReg_exc),
        .WriteReg(WriteReg_exc),
        .WriteData(WriteData_exc),
        .RegWrite(RegWrite_exc),
        .offst(offst_exc),
        .Immd(Immd_exc),
        .SignExt(SignExt_exc),
        .SrcB(SrcB_exc),
        .ALUCtrl(ALUCtrl_exc),
        .MemWrite(MemWrite_exc),
        .MemToReg(MemToReg_exc),
        .Branch(Branch_exc),
        .Jump(Jump_exc),
        .BKind(BKind_exc),
        .Jirl(Jirl_exc),
        .DataSize(DataSize_exc),
        .sft(sft_exc),
        .csrSrc(csrSrc_exc),
        .csrRegWrite(csrRegWrite_exc),
        .csrHcode(csrHcode_exc),
        .exception(exception_exc),
        .ReadRdcntCsr(ReadRdcntCsr_exc),
        .WriteRj(WriteRj_exc),  
        .ID_ine_ex(ID_ine_ex_exc)
    );

        cacheClass cacheclass(
        .instr(instr),
        .ReadReg(ReadReg_cache),
        .WriteReg(WriteReg_cache),
        .WriteData(WriteData_cache),
        .RegWrite(RegWrite_cache),
        .offst(offst_cache),
        .Immd(Immd_cache),
        .SignExt(SignExt_cache),
        .SrcB(SrcB_cache),
        .ALUCtrl(ALUCtrl_cache),
        .MemWrite(MemWrite_cache),
        .MemToReg(MemToReg_cache),
        .Branch(Branch_cache),
        .Jump(Jump_cache),
        .BKind(BKind_cache),
        .Jirl(Jirl_cache),
        .DataSize(DataSize_cache),
        .sft(sft_cache),
        .csrSrc(csrSrc_cache),
        .csrRegWrite(csrRegWrite_cache),
        .csrHcode(csrHcode_cache),
        .exception(exception_cache),
        .ReadRdcntCsr(ReadRdcntCsr_cache),
        .WriteRj(WriteRj_cache),  
        .ID_ine_ex(ID_ine_ex_cache)
    );
    
    rdcntClass rdcntclass(
        .instr(instr),
        .ReadReg(ReadReg_rdcnt),
        .WriteReg(WriteReg_rdcnt),
        .WriteData(WriteData_rdcnt),
        .RegWrite(RegWrite_rdcnt),
        .offst(offst_rdcnt),
        .Immd(Immd_rdcnt),
        .SignExt(SignExt_rdcnt),
        .SrcB(SrcB_rdcnt),
        .ALUCtrl(ALUCtrl_rdcnt),
        .MemWrite(MemWrite_rdcnt),
        .MemToReg(MemToReg_rdcnt),
        .Branch(Branch_rdcnt),
        .Jump(Jump_rdcnt),
        .BKind(BKind_rdcnt),
        .Jirl(Jirl_rdcnt),
        .DataSize(DataSize_rdcnt),
        .sft(sft_rdcnt),
        .csrSrc(csrSrc_rdcnt),
        .csrRegWrite(csrRegWrite_rdcnt),
        .csrHcode(csrHcode_rdcnt),
        .exception(exception_rdcnt),
        .ReadRdcntCsr(ReadRdcntCsr_rdcnt),
        .WriteRj(WriteRj_rdcnt),  
        .ID_ine_ex(ID_ine_ex_rdcnt)
    );
        
    wire [3:0] instr_op;
    InstrClassify u(instr, instr_op);
    
    always@(*)begin
        ID_ine_ex <= 1'b0;
        case(instr_op)
            4'b0000: 
            begin
                ReadReg <= ReadReg_mem;
                WriteReg <= WriteReg_mem;
                WriteData <= WriteData_mem;
                RegWrite <= RegWrite_mem;
                offst <= offst_mem;
                Immd <= Immd_mem;
                SignExt <= SignExt_mem;
                SrcB <= SrcB_mem;
                ALUCtrl <= ALUCtrl_mem;
                MemWrite <= MemWrite_mem;
                MemToReg <= MemToReg_mem;
                Branch <= Branch_mem;
                Jump <= Jump_mem;
                BKind <= BKind_mem;
                Jirl <= Jirl_mem;
                DataSize <= DataSize_mem;
                sft <= sft_mem;
                csrSrc <= csrSrc_mem;
                csrRegWrite <= csrRegWrite_mem;
                csrHcode <= csrHcode_mem;
                exception <= exception_mem;
                ReadRdcntCsr  <= ReadRdcntCsr_mem;
                WriteRj  <= WriteRj_mem;
                ID_ine_ex <= ID_ine_ex_mem;
            end
    
            4'b0001: 
            begin
                ReadReg <= ReadReg_jump;
                WriteReg <= WriteReg_jump;
                WriteData <= WriteData_jump;
                RegWrite <= RegWrite_jump;
                offst <= offst_jump;
                Immd <= Immd_jump;
                SignExt <= SignExt_jump;
                SrcB <= SrcB_jump;
                ALUCtrl <= ALUCtrl_jump;
                MemWrite <= MemWrite_jump;
                MemToReg <= MemToReg_jump;
                Branch <= Branch_jump;
                Jump <= Jump_jump;
                BKind <= BKind_jump;
                Jirl <= Jirl_jump;
                DataSize <= DataSize_jump;
                sft <= sft_jump;
                csrSrc <= csrSrc_jump;
                csrRegWrite <= csrRegWrite_jump;
                csrHcode <= csrHcode_jump;
                exception <= exception_jump;
                ReadRdcntCsr  <= ReadRdcntCsr_jump;
                WriteRj  <= WriteRj_jump;
                ID_ine_ex <= ID_ine_ex_jump;
            end
            
            4'b0010: 
            begin
                ReadReg <= ReadReg_oprI;
                WriteReg <= WriteReg_oprI;
                WriteData <= WriteData_oprI;
                RegWrite <= RegWrite_oprI;
                offst <= offst_oprI;
                Immd <= Immd_oprI;
                SignExt <= SignExt_oprI;
                SrcB <= SrcB_oprI;
                ALUCtrl <= ALUCtrl_oprI;
                MemWrite <= MemWrite_oprI;
                MemToReg <= MemToReg_oprI;
                Branch <= Branch_oprI;
                Jump <= Jump_oprI;
                BKind <= BKind_oprI;
                Jirl <= Jirl_oprI;
                DataSize <= DataSize_oprI;
                sft <= sft_oprI;
                csrSrc <= csrSrc_oprI;
                csrRegWrite <= csrRegWrite_oprI;
                csrHcode <= csrHcode_oprI;
                exception <= exception_oprI;
                ReadRdcntCsr  <= ReadRdcntCsr_oprI;
                WriteRj  <= WriteRj_oprI;
                ID_ine_ex <= ID_ine_ex_oprI;
            end 
            
            4'b0011: 
            begin
                ReadReg <= ReadReg_usft;
                WriteReg <= WriteReg_usft;
                WriteData <= WriteData_usft;
                RegWrite <= RegWrite_usft;
                offst <= offst_usft;
                Immd <= Immd_usft;
                SignExt <= SignExt_usft;
                SrcB <= SrcB_usft;
                ALUCtrl <= ALUCtrl_usft;
                MemWrite <= MemWrite_usft;
                MemToReg <= MemToReg_usft;
                Branch <= Branch_usft;
                Jump <= Jump_usft;
                BKind <= BKind_usft;
                Jirl <= Jirl_usft;
                DataSize <= DataSize_usft;
                sft <= sft_usft;
                csrSrc <= csrSrc_usft;
                csrRegWrite <= csrRegWrite_usft;
                csrHcode <= csrHcode_usft;
                exception <= exception_usft;
                ReadRdcntCsr  <= ReadRdcntCsr_usft;
                WriteRj  <= WriteRj_usft;
                ID_ine_ex <= ID_ine_ex_usft;
            end 
            
            4'b0100: 
            begin
                ReadReg <= ReadReg_opr;
                WriteReg <= WriteReg_opr;
                WriteData <= WriteData_opr;
                RegWrite <= RegWrite_opr;
                offst <= offst_opr;
                Immd <= Immd_opr;
                SignExt <= SignExt_opr;
                SrcB <= SrcB_opr;
                ALUCtrl <= ALUCtrl_opr;
                MemWrite <= MemWrite_opr;
                MemToReg <= MemToReg_opr;
                Branch <= Branch_opr;
                Jump <= Jump_opr;
                BKind <= BKind_opr;
                Jirl <= Jirl_opr;
                DataSize <= DataSize_opr;
                sft <= sft_opr;
                csrSrc <= csrSrc_opr;
                csrRegWrite <= csrRegWrite_opr;
                csrHcode <= csrHcode_opr;
                exception <= exception_opr;
                ReadRdcntCsr  <= ReadRdcntCsr_opr;
                WriteRj  <= WriteRj_opr;
                ID_ine_ex <= ID_ine_ex_opr;
            end 
            
            4'b0101: 
            begin
                ReadReg <= ReadReg_I20;
                WriteReg <= WriteReg_I20;
                WriteData <= WriteData_I20;
                RegWrite <= RegWrite_I20;
                offst <= offst_I20;
                Immd <= Immd_I20;
                SignExt <= SignExt_I20;
                SrcB <= SrcB_I20;
                ALUCtrl <= ALUCtrl_I20;
                MemWrite <= MemWrite_I20;
                MemToReg <= MemToReg_I20;
                Branch <= Branch_I20;
                Jump <= Jump_I20;
                BKind <= BKind_I20;
                Jirl <= Jirl_I20;
                DataSize <= DataSize_I20;
                sft <= sft_I20;
                csrSrc <= csrSrc_I20;
                csrRegWrite <= csrRegWrite_I20;
                csrHcode <= csrHcode_I20;
                exception <= exception_I20;
                ReadRdcntCsr  <= ReadRdcntCsr_I20;
                WriteRj  <= WriteRj_I20;
                ID_ine_ex <= ID_ine_ex_I20;
            end 
            
            4'b0110: 
            begin
                ReadReg <= ReadReg_csr;
                WriteReg <= WriteReg_csr;
                WriteData <= WriteData_csr;
                RegWrite <= RegWrite_csr;
                offst <= offst_csr;
                Immd <= Immd_csr;
                SignExt <= SignExt_csr;
                SrcB <= SrcB_csr;
                ALUCtrl <= ALUCtrl_csr;
                MemWrite <= MemWrite_csr;
                MemToReg <= MemToReg_csr;
                Branch <= Branch_csr;
                Jump <= Jump_csr;
                BKind <= BKind_csr;
                Jirl <= Jirl_csr;
                DataSize <= DataSize_csr;
                sft <= sft_csr;
                csrSrc <= csrSrc_csr;
                csrRegWrite <= csrRegWrite_csr;
                csrHcode <= csrHcode_csr;
                exception <= exception_csr;
                ReadRdcntCsr  <= ReadRdcntCsr_csr;
                WriteRj  <= WriteRj_csr;
                ID_ine_ex <= ID_ine_ex_csr;
            end 
            
            4'b0111: 
            begin
                ReadReg <= ReadReg_exc;
                WriteReg <= WriteReg_exc;
                WriteData <= WriteData_exc;
                RegWrite <= RegWrite_exc;
                offst <= offst_exc;
                Immd <= Immd_exc;
                SignExt <= SignExt_exc;
                SrcB <= SrcB_exc;
                ALUCtrl <= ALUCtrl_exc;
                MemWrite <= MemWrite_exc;
                MemToReg <= MemToReg_exc;
                Branch <= Branch_exc;
                Jump <= Jump_exc;
                BKind <= BKind_exc;
                Jirl <= Jirl_exc;
                DataSize <= DataSize_exc;
                sft <= sft_exc;
                csrSrc <= csrSrc_exc;
                csrRegWrite <= csrRegWrite_exc;
                csrHcode <= csrHcode_exc;
                exception <= exception_exc;
                ReadRdcntCsr  <= ReadRdcntCsr_exc;
                WriteRj  <= WriteRj_exc;
                ID_ine_ex <= ID_ine_ex_exc;
            end 

            4'b1000: 
            begin
                ReadReg <= ReadReg_cache;
                WriteReg <= WriteReg_cache;
                WriteData <= WriteData_cache;
                RegWrite <= RegWrite_cache;
                offst <= offst_cache;
                Immd <= Immd_cache;
                SignExt <= SignExt_cache;
                SrcB <= SrcB_cache;
                ALUCtrl <= ALUCtrl_cache;
                MemWrite <= MemWrite_cache;
                MemToReg <= MemToReg_cache;
                Branch <= Branch_cache;
                Jump <= Jump_cache;
                BKind <= BKind_cache;
                Jirl <= Jirl_cache;
                DataSize <= DataSize_cache;
                sft <= sft_cache;
                
                csrSrc <= csrSrc_cache;
                csrRegWrite <= csrRegWrite_cache;
                csrHcode <= csrHcode_cache;
                exception <= exception_cache;
                ReadRdcntCsr  <= ReadRdcntCsr_cache;
                WriteRj  <= WriteRj_cache;
                ID_ine_ex <= ID_ine_ex_cache;
            end 
            
            4'b1001: 
            begin
                ReadReg <= ReadReg_rdcnt;
                WriteReg <= WriteReg_rdcnt;
                WriteData <= WriteData_rdcnt;
                RegWrite <= RegWrite_rdcnt;
                offst <= offst_rdcnt;
                Immd <= Immd_rdcnt;
                SignExt <= SignExt_rdcnt;
                SrcB <= SrcB_rdcnt;
                ALUCtrl <= ALUCtrl_rdcnt;
                MemWrite <= MemWrite_rdcnt;
                MemToReg <= MemToReg_rdcnt;
                Branch <= Branch_rdcnt;
                Jump <= Jump_rdcnt;
                BKind <= BKind_rdcnt;
                Jirl <= Jirl_rdcnt;
                DataSize <= DataSize_rdcnt;
                sft <= sft_rdcnt;
                
                csrSrc <= csrSrc_rdcnt;
                csrRegWrite <= csrRegWrite_rdcnt;
                csrHcode <= csrHcode_rdcnt;
                exception <= exception_rdcnt;
                ReadRdcntCsr  <= ReadRdcntCsr_rdcnt;
                WriteRj  <= WriteRj_rdcnt;
                ID_ine_ex <= ID_ine_ex_rdcnt;
            end 

            default:begin
                    ReadReg <= 1'bz;
                    WriteReg <= 1'bz;
                    WriteData <= 2'bz;
                    RegWrite <= 1'bz;
                    offst <= 1'bz;
                    Immd <= 1'bz;
                    SignExt <= 1'bz;
                    SrcB <= 1'bz;
                    ALUCtrl <= 13'bz;
                    MemWrite <= 1'bz;
                    MemToReg <= 1'bz;
                    Branch <= 1'bz;
                    Jump <= 1'bz;
                    BKind <= 2'bz;
                    Jirl <= 1'bz;
                    DataSize <= 2'bz;
                    sft <= 1'bz;
                    csrSrc <= 1'bz;
                    csrRegWrite <= 1'bz;
                    csrHcode <= 1'bz;
                    exception <= 1'b0;
                    
                    ReadRdcntCsr  <= 2'b00;
                    WriteRj  <= 1'b0;
                    
                    ID_ine_ex <= 1'b1;
                end
            endcase
    end
endmodule
