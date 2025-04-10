`timescale 1ns / 1ps

module TOP_predict#(parameter PC_SIZE = 32, parameter WIDTH = 6, parameter TABLE_SIZE = 32)//���еļĴ���������������
(
    input wire                 clk                  ,
    input wire                 rst                  ,
        
    input wire                 branch               ,// <- D �Ƿ�Ϊ������תָ��
    input wire                 branch_taken         ,// <- D ��֤��ķ�֧���
    input wire [PC_SIZE-1:0]   up_pc                ,// <- D �����µ�pc
    input wire [PC_SIZE-1:0]   j_pc                 ,// <- D ��֤���Ŀ���ַ
    input wire [1:0]           up_way               ,// <- D ��λ��Ϣ������ = ����
    input wire                 up_hit               ,// <- D Ԥ����Ϣ������ = ����
    input wire                 call                 ,// <- D ��תָ������
    input wire                 return               ,// <- D ��תָ������
    input wire                 StallF               ,
    input wire [31:0]          pred_nxt_pc_D        ,// <- D  
    output wire                b_flushD             ,// -> D
     
    output wire[1:0]           c_wayF               ,// -> F ��λ��Ϣ
    output wire                hitF                 ,// -> F Ԥ����Ϣ
    output reg [PC_SIZE-1:0]   pcF                  ,// -> F
    output reg [31:0]          instrF               ,// -> F
    output reg [31:0]          pred_nxt_pc_F        ,// -> F
   
    output reg [31:0]          pc                   ,// -> icache
    output reg                 req                  ,
    input wire [PC_SIZE-1:0]   r_data               ,// <- icache
    input wire                 instr_data_ok         // <- icache
);
    wire                       data_ok           ;
    wire [PC_SIZE-1:0]         predict_address   ;               
    localparam                 nop = 32'h02800000 ;
    localparam                 nul = 32'h1c000000 ;

    wire b_err;
    assign b_err = (branch || call || return || branch_taken) && (pred_nxt_pc_D != j_pc);
    assign b_flushD = b_err;
    reg [1:0] s;
    
    reg [31:0]  saved_j_pc;
    
    always@( posedge clk ) begin
        if(rst) begin
            s <= 2'b00;
            saved_j_pc <= nul;
            req <= 0 ; pcF <= nul ; instrF <= nop; pred_nxt_pc_F <= nul ; pc <= nul;
        end
        else if(!StallF) begin
            case(s)
            
               2'b00: begin
                    s <= 2'b01;
                    saved_j_pc <= nul;
                    req <= 1 ; pcF <= pcF ; instrF <= nop; pred_nxt_pc_F <= nul ; pc <= nul; 
               end
               
               2'b01: begin
                    if(!b_err && !instr_data_ok) begin
                        s <= 2'b01;
                        saved_j_pc <= nul;
                        req <= 1 ; pcF <= pcF ; instrF <= nop; pred_nxt_pc_F <= nul ; pc <= pc; 
                    end
                    else if(!b_err && instr_data_ok) begin
                        s <= 2'b01;
                        saved_j_pc <= nul;
                        req <= 1 ; pcF <= pc ;  instrF <= r_data; pred_nxt_pc_F <= predict_address ; pc <= predict_address;
                    end
                    else if(b_err && !instr_data_ok) begin
                        s <= 2'b10;
                        saved_j_pc  <= j_pc;
                        req <= 1 ; pcF <= pcF ; instrF <= nop; pred_nxt_pc_F <= nul ; pc <= pc;
                    end
                    else begin   // b_err & instr_data_ok
                        s <= 2'b01;
                        saved_j_pc <= nul;
                        req <= 1 ; pcF <= pcF ; instrF <= nop; pred_nxt_pc_F <= nul ; pc <= j_pc;
                    end
               end
               
               2'b10: begin
                   if(!instr_data_ok) begin
                       s <= 2'b10;
                       saved_j_pc <= saved_j_pc ; 
                       req <= 1 ; pcF <= pcF ; instrF <= nop; pred_nxt_pc_F <= nul ; pc <= pc; 
                   end
                   else begin
                       s <= 2'b01;
                       saved_j_pc <= nul;
                       req <= 1 ; pcF <= pcF ; instrF <= nop; pred_nxt_pc_F <= nul ; pc <= saved_j_pc; 
                   end
               end
               
               default: begin
                   s <= 2'b00;
                   saved_j_pc <= nul;
                   req <= 0 ; pcF <= pcF ; instrF <= nop; pred_nxt_pc_F <= nul ; pc <= nul; 
               end
          endcase
        end
        else begin
            s <= s;
            saved_j_pc <= saved_j_pc;
            req <= 1 ; pcF <= pcF; instrF <= instrF ; pred_nxt_pc_F <= pred_nxt_pc_F ; pc <= pc ;
        end
    end

    wire                        whetherJmp  ;      
    wire     [WIDTH-1:0]        BHR         ;
    wire     [WIDTH-1:0]        up_BHR      ;
    wire     [WIDTH-1:0]        PHT         ;
    wire     [WIDTH-1:0]        up_PHT      ;
    wire     [PC_SIZE-1:0]      pc_btb      ;
    wire     [PC_SIZE-1:0]      pc_ras      ;
//quick_decoder
    wire                        I26        ;
    wire                        I16        ;
    wire                        reglike    ;
    wire      [PC_SIZE-1:0]     pc_I26     ;
    wire      [PC_SIZE-1:0]     pc_I16     ;
    wire      [PC_SIZE-1:0]     pc_next    ;
    
//��¼����ָ����ʷ��֧���
    BHT #(WIDTH, PC_SIZE)bht
    (
        .clk               (clk            ),
        .rst               (rst            ),
        .install           (StallF         ),
        .pc                (pc             ),
        .up_pc             (up_pc          ),
        .branch            (branch         ),
        .branch_taken      (branch_taken   ),
        .up_history        (up_BHR         ),
        .history           (BHR            )
    );

    assign PHT    = BHR    ^ pc[10:5]       ;
    assign up_PHT = up_BHR ^ up_pc[10:5]    ;
    
    //Ԥ������ָ�����ת����
    PHTS #(WIDTH)pht
    (
        .clk               (clk            ),
        .rst               (rst            ),
        .install           (StallF         ),
        .branch            (branch         ),
        .branch_taken      (branch_taken   ),
        .PHT_address       (PHT            ),
        .up_PHT_address    (up_PHT         ),
        .whetherJmp        (whetherJmp     )
    );

    wire               [1:0]type            ;
    //��¼ָ��ķ�֧��ת��ַ
    BTB btb
    (
        .clk                (clk           ),
        .rst                (rst           ),
        .install            (StallF        ),
        .pc                 (pc            ),
        .up_pc              (up_pc         ),
        .j_pc               (j_pc          ),
        .call               (call          ),
        .return             (return        ),
        .up_way             (up_way        ),
        .up_hit             (up_hit        ),
        .data_ok            (data_ok       ),
        .data               (pc_btb        ),
        .type               (type          ),
        .hit                (hitF          ),
        .c_way              (c_wayF        )
    );
// ��ջ�ṹ����¼ call �� return �ĵ�ַ
    RAS ras
    (
        .clk                (clk           ),
        .rst                (rst           ),
        .install            (StallF        ),
        .data_ok            (data_ok       ),    
        .type               (type          ),
        .pc                 (pc            ),
        .data               (pc_ras        )
    );

    quick_decoder qd
    (
        .pc                 (pc            ),
        .instr              (r_data         ),
        .I26                (I26           ),
        .I16                (I16           ),    
        .reglike            (reglike       ),
        .pc_I26             (pc_I26        ),
        .pc_I16             (pc_I16        ),
        .pc_next            (pc_next       )
    ); 

    MUX_pre mux_pre
    (
        .rst                (rst           ),
        .whetherJmp         (whetherJmp    ),
        .hit                (hitF          ),
        .I26                (I26           ),
        .I16                (I16           ),    
        .reglike            (reglike       ),
        .type               (type          ),
        .pc_I26             (pc_I26        ),
        .pc_I16             (pc_I16        ),
        .pc_next            (pc_next       ),
        .pc_btb             (pc_btb        ),
        .pc_ras             (pc_ras        ),
        .predict_address    (predict_address),
        .cur_pc             (pc             ),
        .up_pc              (up_pc)         ,
        .j_pc               (j_pc)          ,
        .branch_taken       (branch_taken   )
    );
    
   
    
endmodule
