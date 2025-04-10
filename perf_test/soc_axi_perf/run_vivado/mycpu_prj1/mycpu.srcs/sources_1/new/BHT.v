`timescale 1ns / 1ps

// 寄存器条件依赖型分支历史记录
    module BHT#(parameter WIDTH = 6, parameter PC_SIZE = 32)
    (
    input   wire              clk            ,
    input   wire              rst            ,//高电平重置
    input   wire              install        ,
    input   wire [PC_SIZE-1:0]pc             ,
    input   wire [PC_SIZE-1:0]up_pc          ,
    input   wire              branch         ,//branch仅仅只针对条件跳转,才会修改BHT和PHT
    input   wire              branch_taken   ,
    output  wire [5:0]        up_history     ,
    output  wire [5:0]        history         //六位tag的PHT
    );

    wire             [3:0]address        ;
    wire             [3:0]up_address     ;
    reg        [WIDTH-1:0]bhr[1023:0]    ;//设定BHR深度为1024，宽度为6

    assign address    = pc   [14:5]      ;
    assign up_address = up_pc[14:5]      ;

//读取BHT中所保存的局部历史
    assign history    = {bhr[address]}   ;
    assign up_history = {bhr[up_address]};

    integer i;
//BHT，初始化，修改等
    always @(posedge clk or posedge rst) 
    begin
        if(rst)
        begin
            for(i = 0; i < 1024; i = i + 1)
                bhr[i] <= 6'b000000;
        end
        else if(install)
            bhr[address] <= bhr[address];   
        else
        begin
            if(branch)
                bhr[up_address] <= {bhr[up_address][WIDTH-2:0],branch_taken};   
        end
    end                                    

endmodule
