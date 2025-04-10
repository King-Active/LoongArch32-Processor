module ALU(
  input  wire clk,
  input  wire rst,
  input  wire stallE,
  input  wire flushE,
  input  wire [18:0] alu_op,
  input  wire [31:0] alu_src1,
  input  wire [31:0] alu_src2,
  output wire zero,
  output wire slt,
  output wire mult_stall,
  output wire div_stall,
  output wire [31:0] alu_result,
    
  input  wire  test
);

wire op_add;   //add operation
wire op_sub;   //sub operation
wire op_slt;   //signed compared and set less than
wire op_sltu;  //unsigned compared and set less than
wire op_and;   //bitwise and
wire op_nor;   //bitwise nor
wire op_or;    //bitwise or
wire op_xor;   //bitwise xor
wire op_sll;   //logic left shift
wire op_srl;   //logic right shift
wire op_sra;   //arithmetic right shift

wire op_lui;   //Load Upper Immediate

wire op_mul;   //有符号乘，低位结果    
wire op_mulh;   //有符号乘，高位结果
wire op_mulhu;   //无符号乘，高位结果
wire op_div;   //有符号除
wire op_divu;   //无符号除
wire op_mod;   //有符号取模
wire op_modu;   //无符号取模

// control code decomposition
assign op_add  = alu_op[ 0];
assign op_sub  = alu_op[ 1];
assign op_slt  = alu_op[ 2];
assign op_sltu = alu_op[ 3];
assign op_and  = alu_op[ 4];
assign op_nor  = alu_op[ 5];
assign op_or   = alu_op[ 6];
assign op_xor  = alu_op[ 7];
assign op_sll  = alu_op[ 8];
assign op_srl  = alu_op[ 9];
assign op_sra  = alu_op[10];
assign op_lui  = alu_op[11];

assign op_mul  = alu_op[12]; 
assign op_mulh  = alu_op[13]; 
assign op_mulhu  = alu_op[14]; 
assign op_div  = alu_op[15]; 
assign op_divu  = alu_op[16];
assign op_mod   = alu_op[17];
assign op_modu  = alu_op[18]; 

wire [31:0] add_sub_result;
wire [31:0] slt_result;
wire [31:0] sltu_result;
wire [31:0] and_result;
wire [31:0] nor_result;
wire [31:0] or_result;
wire [31:0] xor_result;
wire [31:0] lui_result;
wire [31:0] sll_result;
wire [63:0] sr64_result;
wire [31:0] sr_result;

wire [31:0] mul_result; 
wire [31:0] mulh_result; 
wire [31:0] mulhu_result; 
wire [31:0] div_result; 
wire [31:0] divu_result; 
wire [31:0] mod_result; 
wire [31:0] modu_result; 

wire        mult_ready;        //乘法是否执行完毕
wire        mult_sign;         //是否正在执行有符号乘
wire        mult_unsign;       //是否正在执行无符号乘
wire        mult_valid;        //是否正在执行乘法
wire        signed_mult_ce;    //有符号乘法器时钟使能
wire        unsigned_mult_ce;  //无符号乘法器时钟使能

reg  [2:0]  cnt;               //乘法计数器（乘法模块为流水线设计，需要对齐周期才能正常使用）

assign mult_valid       =    mult_sign | mult_unsign;
assign mult_sign        =    op_mul | op_mulh;
assign mult_unsign      =    op_mulhu;
assign mult_ready       =   (cnt == 3'b101);     // 5级流水线 5个周期出结果
assign mult_stall       =   mult_valid && cnt != 3'b101;

always@(posedge clk) begin
    if(rst || flushE || ~mult_valid) cnt <= 3'b0;
    else if(mult_valid) cnt <= cnt + 1;
end
    
wire     signed_div;
wire     unsigned_div;    
wire     div_valid_sign;
wire     div_valid_unsign;


assign   signed_div = op_div | op_mod;
assign   unsigned_div = op_divu |op_modu;
assign   div_stall = (signed_div & ~div_valid_sign) | (unsigned_div & ~div_valid_unsign);

//乘除法结果    
wire [63:0] mul_s_result;  //有符号乘
wire [63:0] mul_u_result;  //无符号乘
wire [63:0] div_s_result;  //有符号除{商，余}
wire [63:0] div_u_result;  //无符号除{商，余}


//实例化乘除法器
mult_signed u_mult_signed(
        .CLK(clk),  
        .A(alu_src1),      // input wire [31 : 0] A
        .B(alu_src2),      // input wire [31 : 0] B
        .CE(1),    // input wire CE
        .SCLR(flushE),
        .P(mul_s_result)      // output wire [63 : 0] P
);

mult_unsigned u_mult_unsigned(
        .CLK(clk), 
        .A(alu_src1),      // input wire [31 : 0] A
        .B(alu_src2),      // input wire [31 : 0] B
        .CE(1),    // 时钟使能
        .SCLR(flushE),
        .P(mul_u_result)      // output wire [63 : 0] P
);
reg  [1:0] s;
wire sign_div_hide;
wire unsigned_div_hide;

always@(posedge clk)begin
    if(rst) s <= 2'b00;
    else if(s == 2'b00 && (signed_div || unsigned_div)) s <= 2'b01;
    else if(s == 2'b01) s <= 2'b10;
    else if(s == 2'b10 && !signed_div && !unsigned_div) s <= 2'b00;
end
assign sign_div_hide = signed_div & (s != 2'b10);
assign unsigned_div_hide = unsigned_div & (s != 2'b10);

div_signed u_div_signed(
      .aclk(clk),
      .s_axis_divisor_tvalid(sign_div_hide),
      .s_axis_divisor_tdata(alu_src2),
      .s_axis_dividend_tvalid(sign_div_hide),
      .s_axis_dividend_tdata(alu_src1),
      .m_axis_dout_tvalid(div_valid_sign),
      .m_axis_dout_tdata(div_s_result)
);

div_unsigned u_div_unsigned(
      .aclk(clk),
      .s_axis_divisor_tvalid(unsigned_div_hide),
      .s_axis_divisor_tdata(alu_src2),
      .s_axis_dividend_tvalid(unsigned_div_hide),
      .s_axis_dividend_tdata(alu_src1),
      .m_axis_dout_tvalid(div_valid_unsign),
      .m_axis_dout_tdata(div_u_result)
);


// 32-bit adder
wire [31:0] adder_a;
wire [31:0] adder_b;
wire        adder_cin;
wire [31:0] adder_result;
wire        adder_cout;

assign adder_a   = alu_src1;
assign adder_b   = (op_sub | op_slt | op_sltu) ? ~alu_src2 : alu_src2;  //src1 - src2 rj-rk
assign adder_cin = (op_sub | op_slt | op_sltu) ? 1'b1      : 1'b0;
assign {adder_cout, adder_result} = adder_a + adder_b + adder_cin;

// ADD, SUB result
assign add_sub_result = adder_result;

// SLT result
assign slt_result[31:1] = 31'b0;   //rj < rk 1
assign slt_result[0]    = (alu_src1[31] & ~alu_src2[31])
                        | ((alu_src1[31] ~^ alu_src2[31]) & adder_result[31]);

// SLTU result
assign sltu_result[31:1] = 31'b0;
assign sltu_result[0]    = ~adder_cout;

// bitwise operation
assign and_result = alu_src1 & alu_src2;
assign or_result  = alu_src1 | alu_src2;
assign nor_result = ~or_result;
assign xor_result = alu_src1 ^ alu_src2;
assign lui_result = alu_src2;

// SLL result
assign sll_result = alu_src1 << alu_src2[4:0];   //rj << i5

// SRL, SRA result
assign sr64_result = {{32{op_sra & alu_src1[31]}}, alu_src1[31:0]} >> alu_src2[4:0]; //rj >> i5

assign sr_result   = sr64_result[31:0];

// MUL_s result
assign mul_result = mul_s_result[31:0];
assign mulh_result = mul_s_result[63:32];

// MUL_u result
assign mulhu_result = mul_u_result[63:32];

// DIV_s,MOD_s result
assign div_result = div_s_result[63:32];
assign mod_result = div_s_result[31:0];

// DIV_u,MOD_u result
assign divu_result = div_u_result[63:32];
assign modu_result = div_u_result[31:0];

wire [31:0] test_result;
assign test_result = (alu_src1 >> alu_src2) | (alu_src1 << (32-alu_src2));
// final result mux
assign alu_result = test? test_result:(
                  ({32{op_add|op_sub}} & add_sub_result)
                  | ({32{op_slt       }} & slt_result)
                  | ({32{op_sltu      }} & sltu_result)
                  | ({32{op_and       }} & and_result)
                  | ({32{op_nor       }} & nor_result)
                  | ({32{op_or        }} & or_result)
                  | ({32{op_xor       }} & xor_result)
                  | ({32{op_lui       }} & lui_result)
                  | ({32{op_sll       }} & sll_result)
                  | ({32{op_srl|op_sra}} & sr_result)
                  | ({32{op_mul       }} & mul_result)
                  | ({32{op_mulh      }} & mulh_result)
                  | ({32{op_mulhu     }} & mulhu_result)
                  | ({32{op_div       }} & div_result)
                  | ({32{op_divu      }} & divu_result)
                  | ({32{op_mod       }} & mod_result)
                  | ({32{op_modu      }} & modu_result));

assign zero = alu_src1 == alu_src2;
assign slt = (op_slt & slt_result[0])
            |(op_sltu & sltu_result[0]);

endmodule