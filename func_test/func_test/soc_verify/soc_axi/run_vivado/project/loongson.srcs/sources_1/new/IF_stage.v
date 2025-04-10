module IF_stage(
    input wire clk,
    input wire rst,
    input wire StallF,
    
    //ID
	input wire       if_jump,         //是否跳转（ID）
	input wire[31:0] pc_jump,        //跳转地址（ID）
	input wire[31:0] pcD,
	input wire[1:0]  c_wayD,
	input wire       hitD,
	input wire       BranchD,
	input wire       call,
	input wire       return,
	input wire[31:0] pred_nxt_pc_D,
	output wire      b_flushD,
	
	//icache
	output wire         inst_req,     
    input wire          inst_data_ok,
    input wire [31:0]   r_data,
	
	//IF2ID
    output wire[31:0]   pc,        //预测pc
	output wire[1:0]    c_wayF,
	output wire         hitF,
	output wire[31:0]   instrF,
	output wire[31:0]   pred_nxt_pc_F,
	output wire[31:0]   pcF
    );
    
   TOP_predict
    #(.PC_SIZE(32), .WIDTH(6), .TABLE_SIZE(32))
     u_TOP_predict (
           .clk             (clk), 
           .rst             (rst),
                           
           .branch          (BranchD),
           .branch_taken    (if_jump),
           .up_pc           (pcD),
           .j_pc            (pc_jump),
           .up_way          (c_wayD),
           .up_hit          (hitD),
           .call            (call),
           .return          (return),
           .StallF          (StallF),
           .pred_nxt_pc_D   (pred_nxt_pc_D),
           .b_flushD        (b_flushD),
                     
           .c_wayF          (c_wayF),
           .hitF            (hitF),
           .pcF             (pcF),             // ???
           .instrF          (instrF),
           .pred_nxt_pc_F   (pred_nxt_pc_F),  // ???
                       
           .pc              (pc),
           .r_data          (r_data),
           .instr_data_ok   (inst_data_ok),
           .req             (inst_req) 
    );

endmodule
