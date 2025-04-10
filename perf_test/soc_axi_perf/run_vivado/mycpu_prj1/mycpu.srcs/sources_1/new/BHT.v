`timescale 1ns / 1ps

// �Ĵ������������ͷ�֧��ʷ��¼
    module BHT#(parameter WIDTH = 6, parameter PC_SIZE = 32)
    (
    input   wire              clk            ,
    input   wire              rst            ,//�ߵ�ƽ����
    input   wire              install        ,
    input   wire [PC_SIZE-1:0]pc             ,
    input   wire [PC_SIZE-1:0]up_pc          ,
    input   wire              branch         ,//branch����ֻ���������ת,�Ż��޸�BHT��PHT
    input   wire              branch_taken   ,
    output  wire [5:0]        up_history     ,
    output  wire [5:0]        history         //��λtag��PHT
    );

    wire             [3:0]address        ;
    wire             [3:0]up_address     ;
    reg        [WIDTH-1:0]bhr[1023:0]    ;//�趨BHR���Ϊ1024�����Ϊ6

    assign address    = pc   [14:5]      ;
    assign up_address = up_pc[14:5]      ;

//��ȡBHT��������ľֲ���ʷ
    assign history    = {bhr[address]}   ;
    assign up_history = {bhr[up_address]};

    integer i;
//BHT����ʼ�����޸ĵ�
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
