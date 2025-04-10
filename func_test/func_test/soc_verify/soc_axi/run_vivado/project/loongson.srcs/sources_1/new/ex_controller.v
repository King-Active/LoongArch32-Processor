`timescale 1ns / 1ps
/*   
  --- ���⴦��ģ�� ---
    ��������ÿһ�������ⴥ���źţ��Լ������жϴ���������ж������ź�
    �ж����ȼ���ߣ���ˮ��Խ�������ȼ�Խ��
   ��1����Ϊ�����ж����⣬��ѡ�� "����׶�" ��Ϊ������ˮ�������ִ�У�2��
   ��2����ָ��ת��ΪдCSR���ⲿ��ָ���Ҫ��������ǰ��
   ��3��������ˮ֮���ָ������ִ�У�֮ǰ��ָ����գ������ת���⴦�����
   
   �� ���ж���������д ESTAT �Ĵ����������Ӻ�д
   �� �������޸ĵ�CSR���ݣ�
       �� ESTATE��IS��Ecode��EsubCode��
       �� CRMD��PLV��IE��
       �� PRMD��PPLV��PIE��
       �� ERA
*/
module ex_controller(
    input  wire        ID_sys_ex,           /* ϵͳ�������� */
    input  wire        ID_brk_ex,           /* �ϵ����� */
    input  wire        ID_int_ex,           /* �ж����� */
    input  wire        ID_ine_ex,           /* ָ��������� */
    input  wire        ID_adef_ex,          /* ȡָ��ַ�������� */
    input  wire        EXE_ale_ex,          /* ��ַ�Ƕ������� */
    input  wire        EXE_adem_ex,         /* �ô��ַ�������� */
    
    input  wire [31:0] pcF,
    input  wire [31:0] pcD,
    input  wire [31:0] pcE,
    input  wire [31:0] pcM,                 /* ����ѡ�����ص�ַ */
    
    input wire exceptionD,
    input wire exceptionE,
    input wire exceptionM,
    input wire exceptionW,
    
    output wire [3:0]  ex_flush_pipe,       /* �����ˮ�ź� */
    output wire [3:0]  ex_label_pipe,       /* �����ˮ�����źţ���дCSR���ⲿ�֣�*/
    
    output wire [5:0]  Ecode,               /* ESTAT һ�����������ֶ� 6λ*/
    output wire        EsubCode,            /* ESTAT �������������ֶ� 9λ���ڴ˽��õ�1λ*/
    output wire [31:0] era,                 /* ���ⷵ�ص�ַ */
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
                           6'b01_1010;   // ������
                             
    assign EsubCode      = (EXE_adem_ex==1)? 1'b1: 1'b0;
    
    assign era           = (ID_int_ex==1)  ? pcD:
                           (EXE_ale_ex==1) ? pcE:
                           (ID_sys_ex==1 || ID_brk_ex==1 || ID_ine_ex==1)? pcD:
                           (ID_adef_ex==1) ? origin_pc_jump: 32'b0;  
endmodule
