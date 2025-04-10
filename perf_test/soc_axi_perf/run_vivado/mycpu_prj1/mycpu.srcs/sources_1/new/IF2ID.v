module IF2ID(
    input wire clk,
    input wire rst,
    input wire StallD,           //ÒëÂë½×¶Î×èÈû
    
	input wire[31:0]   instrF,     //Ö¸Áî£¨IF£©
	input wire[31:0]   pcF,        //Ìø×ªµØÖ·£¨IF£©
	input wire[1:0]    c_wayF,
	input wire         hitF,
	
	output reg [31:0]  instrD,
    output reg [31:0]  pcD,
    output reg [1:0]   c_wayD,
	output reg         hitD,
	output reg  [31:0] pred_nxt_pc_D,
	input  wire [31:0] pred_nxt_pc_F,
	input  wire        b_flushD,
	
	input wire ex_flush_pipe_D,
	input wire ex_label_pipe_D,
	input wire [5:0] Ecode,
	input wire EsubCode,
	input wire [31:0] era
    );
    
    always @(posedge clk) begin
        if(rst | (b_flushD & ~StallD) | (ex_flush_pipe_D & ~StallD)) begin
            pcD                 <= 32'h1c000000;
            instrD              <= 32'b0000001010_000000000000_00000_00000;
            c_wayD              <= 0    ;
            hitD                <= 0    ;
            pred_nxt_pc_D       <= 32'b0;
        end      
        else if(~StallD) begin
            pcD                 <= pcF    ;
            instrD              <= instrF ;
            c_wayD              <= c_wayF ;
            hitD                <= hitF   ;
            pred_nxt_pc_D       <= pred_nxt_pc_F;
        end
        else begin
            pcD                 <= pcD    ;
            instrD              <= instrD ;
            c_wayD              <= c_wayD ;
            hitD                <= hitD   ;
            pred_nxt_pc_D       <= pred_nxt_pc_D;
        end
    end
    
    
    
endmodule
