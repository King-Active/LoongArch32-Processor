`timescale 1ns / 1ps

// 跳转方向
module PHTS#(parameter WIDTH = 6)(
    input  wire            clk            ,
    input  wire            rst            ,
    input  wire            install        ,
    input  wire            branch         ,
    input  wire            branch_taken   ,
    input  wire [WIDTH-1:0]PHT_address    ,
    input  wire [WIDTH-1:0]up_PHT_address , 
    output wire            whetherJmp              //预测是否跳转结果 whether_jmp
    );

    reg             [1:0]pht[63:0]      ;

    assign whetherJmp = pht[PHT_address][1]?1:0;   

    integer i;
    always @(posedge clk or posedge rst) 
    begin
        if(rst)
        begin
            for(i = 0;i < 64;i = i + 1)
                pht[i] <= 2'b01;    
        end
        else if(install)
            pht[up_PHT_address] <= pht[up_PHT_address]    ;   
        else if(branch) //仅对条件跳转指令运用饱和计数器
        begin
            if     ( branch_taken && ~(&pht[up_PHT_address]) )  //非饱和（全1)
                pht[up_PHT_address] <= pht[up_PHT_address] + 1;
            else if(~branch_taken &&  (|pht[up_PHT_address]) )  //非饱和（全0)
                pht[up_PHT_address] <= pht[up_PHT_address] - 1; 
            else
                pht[up_PHT_address] <= pht[up_PHT_address]    ;
        end    
    end

    
endmodule
