`timescale 1ns / 1ps



module RAS
(
    input   wire        clk         ,
    input   wire        rst         ,
    input   wire        install     ,
    input   wire        data_ok     ,
    input   wire  [ 1:0]type        ,
    input   wire  [31:0]pc          ,
    output  wire  [31:0]data
);
    reg           [31:0]stack[7:0]  ;
    reg           [ 2:0]sp          ;
    reg           [ 2:0]button      ;
    reg           [ 2:0]top         ;
    wire          [ 2:0]spx         ;

    always @(posedge clk or posedge rst) 
    begin
        if(rst)
        begin
            sp     <= 0;
            button <= 0;
            top    <= 1;
        end
        else if(install)
        begin
            sp     <= sp;
            button <= button;
            top    <= top;
        end
        else
        begin//更新时间是在遇到data_ok的下一个周期，此时data已经使用了
            if((type == 2'b10)  && data_ok)
            begin
                if(top == button)
                begin
                    stack[sp] <= pc     + 3'b100;
                    sp        <= sp     + 1     ;
                    button    <= button + 1     ;
                    top       <= top    + 1     ;
                end
                else
                begin
                    stack[sp] <= pc     + 3'b100;
                    sp        <= sp     + 1     ;
                    top       <= top    + 1     ;
                end
            end
            else if(type == 2'b11 && data_ok)
            begin
                if(sp == button)
                begin
                    sp      <=  sp              ;
                    button  <=  button          ;
                    top     <=  top             ;
                end
                else
                begin
                    sp      <= sp - 1           ;
                    top     <= top - 1          ;
                end
            end 
        end
    end

    assign spx = sp - 1                         ;
    assign data = (type==2'b11)?(sp==button?data:stack[spx]):data;
endmodule

