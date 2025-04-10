`timescale 1ns / 1ps
/*   
  --- 例外处理模块 ---
    接收来自每一级的例外触发信号，以及来自中断处理机构的中断例外信号
    中断优先级最高，流水级越靠后，优先级越高
   （1）若为触发中断例外，则选择 "译码阶段" 作为例外流水级，随后执行（2）
   （2）本指令转换为写CSR例外部分指令，需要考虑数据前推
   （3）本级流水之后的指令正常执行，之前的指令清空，随后跳转例外处理程序
   
   · 仅中断例外马上写 ESTAT 寄存器，其他延后写
   · 例外需修改的CSR内容：
       · ESTATE（IS，Ecode，EsubCode）
       · CRMD（PLV，IE）
       · PRMD（PPLV，PIE）
       · ERA
*/
module ex_controller(
    input  wire        ID_sys_ex,           /* 系统调用例外 */
    input  wire        ID_brk_ex,           /* 断点例外 */
    input  wire        ID_int_ex,           /* 中断例外 */
    input  wire        ID_ine_ex,           /* 指令不存在例外 */
    input  wire        ID_adef_ex,          /* 取指地址错误例外 */
    input  wire        EXE_ale_ex,          /* 地址非对齐例外 */
    input  wire        EXE_adem_ex,         /* 访存地址错误例外 */
    
    input  wire [31:0] pcF,
    input  wire [31:0] pcD,
    input  wire [31:0] pcE,
    input  wire [31:0] pcM,                 /* 用于选出返回地址 */
    
    input wire exceptionD,
    input wire exceptionE,
    input wire exceptionM,
    input wire exceptionW,
    
    output wire [3:0]  ex_flush_pipe,       /* 清除流水信号 */
    output wire [3:0]  ex_label_pipe,       /* 标记流水例外信号（即写CSR例外部分）*/
    
    output wire [5:0]  Ecode,               /* ESTAT 一级例外类型字段 6位*/
    output wire        EsubCode,            /* ESTAT 二级例外类型字段 9位，在此仅用到1位*/
    output wire [31:0] era,                 /* 例外返回地址 */
    input wire [31:0]  origin_pc_jump   
    );
    
    assign ex_flush_pipe = (ID_int_ex==1 && ~exceptionE && ~exceptionM && ~exceptionW)  ? 4'b1000:
                           (EXE_ale_ex==1 || EXE_adem_ex==1) ? 4'b1100:
                           (ID_sys_ex==1 || ID_brk_ex==1 || ID_ine_ex==1 || ID_adef_ex==1)? 4'b1000:4'b0000;
                           
    assign ex_label_pipe = (ID_int_ex==1 && ~exceptionE && ~exceptionM && ~exceptionW)  ? 4'b0100:
                           (EXE_ale_ex==1 || EXE_adem_ex==1) ? 4'b0010:
                           (ID_sys_ex==1 || ID_brk_ex==1 || ID_ine_ex==1 || ID_adef_ex==1)? 4'b0100:
                           4'b0000;
                           
    assign Ecode         = (ID_int_ex==1)  ? 6'b00_0000:
                           (EXE_ale_ex==1) ? 6'b00_1001:
                           (ID_sys_ex==1)  ? 6'b00_1011:
                           (ID_brk_ex==1)  ? 6'b00_1100:
                           (ID_ine_ex==1)  ? 6'b00_1101:
                           (ID_adef_ex==1 || EXE_adem_ex==1) ? 6'b00_1000: 
                           6'b01_1010;   // 保留域
                             
    assign EsubCode      = (EXE_adem_ex==1)? 1'b1: 1'b0;
    
    assign era           = (ID_int_ex==1)  ? pcD:
                           (EXE_ale_ex==1) ? pcE:
                           (ID_sys_ex==1 || ID_brk_ex==1 || ID_ine_ex==1)? pcD:
                           (ID_adef_ex==1) ? origin_pc_jump: 32'b0;  
endmodule
