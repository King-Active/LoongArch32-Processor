module WB_stage(
    input wire clk,
    input wire rst,
	input wire MemToRegW, 
	input wire[1:0]  DataSizeW,        
	input wire[31:0] mem_rdataW,   
	input wire[31:0] ALU_resultW, 
	input wire[31:0] instrW, 
	output wire [31:0]reg_w_data_11
    );
    
    //右移保留最低几位有效位
    wire [4:0]  ld_offst;   
    assign ld_offst = {3'b0, ALU_resultW[1:0]};
    wire [31:0] ofst_res;   
    assign ofst_res = mem_rdataW >> (ld_offst << 3);  
    wire [31:0] ldb,ldh; 
    assign ldb = {{24{ofst_res[7]}}, ofst_res[7:0]};
    assign ldh = {{16{ofst_res[15]}}, ofst_res[15:0]};

    //写回阶段重点在寄存器，这里只有reg_w_data_11的赋值逻辑
    assign reg_w_data_11 = ~MemToRegW ? ALU_resultW :
                            DataSizeW[1] ? mem_rdataW :
                            DataSizeW[0] ? (instrW[25]? ldh & 32'h0000ffff:ldh) : (instrW[25]? ldb & 32'h000000ff:ldb);
endmodule
