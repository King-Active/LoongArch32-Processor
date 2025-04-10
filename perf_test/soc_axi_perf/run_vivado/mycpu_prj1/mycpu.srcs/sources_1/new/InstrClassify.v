`timescale 1ns / 1ps
module InstrClassify(
    input wire [31:0] instr,
    output reg [3:0] instr_op
    );
    
    always @(*) begin
        casez(instr)  
            32'b001010??????????????????????????:  instr_op <= 4'b0000;
            32'b01??????????????????????????????:  instr_op <= 4'b0001;
            32'b0000001?????????????????????????:  instr_op <= 4'b0010;
            32'b000000000100????????????????????:  instr_op <= 4'b0011;
            32'b00000000001010??????????????????:  instr_op <= 4'b0111; 
            
            32'b000000000001????????????????????:  instr_op <= 4'b0100;
            32'b000000000010????????????????????:  instr_op <= 4'b0100; 

            32'b0001?10?????????????????????????:  instr_op <= 4'b0101;
            32'b00000100????????????????????????:  instr_op <= 4'b0110;  
            32'b0000011?????????????????????????:  instr_op <= 4'b1000;        
            32'b000000000000000001100???????????:  instr_op <= 4'b1001;
            default:  
                instr_op <= 4'b1111; // ine例外（指令不存在例外），指令编码在架构中未定义  
        endcase  
    end
endmodule

//0000 0010 1000 0000 0000 0100 1010 0000
