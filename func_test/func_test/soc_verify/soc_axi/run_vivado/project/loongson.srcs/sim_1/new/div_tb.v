`timescale 1ns / 1ps
module div_tb();
    reg [31:0] alu_src2;
    reg [31:0] alu_src1;
    reg signed_div;
    reg alu_clk;
    reg rst;
    
    wire div_valid_sign;
    wire [63:0]div_s_result;
    
    div_signed u_div_signed(
      .aclk(alu_clk),
      .s_axis_divisor_tvalid(signed_div),
      .s_axis_divisor_tdata(alu_src2),
      .s_axis_dividend_tvalid(signed_div),
      .s_axis_dividend_tdata(alu_src1),
      .m_axis_dout_tvalid(div_valid_sign),
      .m_axis_dout_tdata(div_s_result),
      .aresetn(1    )
);

initial alu_clk = 0;
always #5 alu_clk = ~alu_clk;

initial begin
    rst = 0;
    signed_div = 0;
    #1000;
    rst = 1;
    #50;
    signed_div = 1;
    alu_src2 = 1;
    alu_src1 = 1;
    #10;
    rst = 0;
    signed_div = 0;
    #100;
    rst = 1;
    #1000;
    $stop;
    
end
endmodule
