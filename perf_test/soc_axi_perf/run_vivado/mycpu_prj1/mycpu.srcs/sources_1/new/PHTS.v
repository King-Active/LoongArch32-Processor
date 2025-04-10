`timescale 1ns / 1ps

// ��ת����
module PHTS#(parameter WIDTH = 6)(
    input  wire            clk            ,
    input  wire            rst            ,
    input  wire            install        ,
    input  wire            branch         ,
    input  wire            branch_taken   ,
    input  wire [WIDTH-1:0]PHT_address    ,
    input  wire [WIDTH-1:0]up_PHT_address , 
    output wire            whetherJmp              //Ԥ���Ƿ���ת��� whether_jmp
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
        else if(branch) //����������תָ�����ñ��ͼ�����
        begin
            if     ( branch_taken && ~(&pht[up_PHT_address]) )  //�Ǳ��ͣ�ȫ1)
                pht[up_PHT_address] <= pht[up_PHT_address] + 1;
            else if(~branch_taken &&  (|pht[up_PHT_address]) )  //�Ǳ��ͣ�ȫ0)
                pht[up_PHT_address] <= pht[up_PHT_address] - 1; 
            else
                pht[up_PHT_address] <= pht[up_PHT_address]    ;
        end    
    end

    
endmodule
