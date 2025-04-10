`timescale 1ns / 1ps


//跳转地址
module BTB
(
    input    wire         clk     ,        
    input    wire         rst     ,
    input    wire         install ,
    input    wire  [31:0] pc      ,
    input    wire  [31:0] up_pc   ,
    input    wire  [31:0] j_pc    ,
    input    wire         call    ,
    input    wire         return  ,
    input    wire  [ 1:0] up_way  ,
    input    wire         up_hit  ,
    output   wire         data_ok ,
    output   wire  [31:0] data    ,
    output   wire  [ 1:0] type    ,
    output   wire         hit     ,
    output   wire  [1:0]  c_way   
);
    wire          [21:0]tag                     ;
    wire          [1: 0]index                   ;
    wire          [21:0]up_tag                  ;
    wire          [1 :0]up_index                ; 
    wire                    miss                ;       

    reg           [31:0]cache_block[3:0][3:0]   ;
    reg           [21:0]cache_tag  [3:0][3:0]   ;                  
    reg                 cache_valid[3:0][3:0]   ;  
    reg           [1 :0]cache_type [3:0][3:0]   ;//00      ?  10  call  ?  11  return  ?
    reg           [2 :0]tree_table [3:0]        ;  


    assign tag      = pc    [27:6]              ;
    assign index    = pc    [5: 4]              ;         
    assign up_tag   = up_pc [27:6]              ;
    assign up_index = up_pc [5: 4]              ; 


    wire                c_valid[3:0]            ;
    wire                c_type [3:0]            ; //  ?  ?? 
    wire         [21:0] c_tag  [3:0]            ;
    wire         [31:0] c_block[3:0]            ;
    wire         [2 :0] tree                    ;

    assign c_valid[0] = cache_valid[index][0]   ;
    assign c_valid[1] = cache_valid[index][1]   ;
    assign c_valid[2] = cache_valid[index][2]   ;
    assign c_valid[3] = cache_valid[index][3]   ;
    assign c_type [0]  = cache_type[index][0]   ;
    assign c_type [1]  = cache_type[index][1]   ;
    assign c_type [2]  = cache_type[index][2]   ;
    assign c_type [3]  = cache_type[index][3]   ;
    assign c_tag  [0]  = cache_tag  [index][0]   ;
    assign c_tag  [1]  = cache_tag  [index][1]   ;
    assign c_tag  [2]  = cache_tag  [index][2]   ;
    assign c_tag  [3]  = cache_tag  [index][3]   ;
    assign c_block[0]  = cache_block[index][0]   ;
    assign c_block[1]  = cache_block[index][1]   ;
    assign c_block[2]  = cache_block[index][2]   ;
    assign c_block[3]  = cache_block[index][3]   ;
    assign tree        = tree_table [index]      ;

    assign hit = c_valid[0] & (c_tag[0] == tag) | 
                 c_valid[1] & (c_tag[1] == tag) |
                 c_valid[2] & (c_tag[2] == tag) |
                 c_valid[3] & (c_tag[3] == tag) ;  //* cache line??· е validλ?1    tag   ?  tag   
    assign miss = ~hit                          ;

    assign data_ok = hit;
    assign c_way = hit ? (c_valid[0] & (c_tag[0] == tag) ? 2'b00 :
                          c_valid[1] & (c_tag[1] == tag) ? 2'b01 :
                          c_valid[2] & (c_tag[2] == tag) ? 2'b10 :
                          2'b11) : 
                   tree[2] ? {tree[2], tree[0]} : //*           
                             {tree[2], tree[1]} ;  //*            
    assign data = hit ? c_block[c_way] : data   ;
    assign type = hit ? c_type [c_way] : type   ;

    integer i,t                                 ;
    always @(posedge clk) 
    begin
        if(rst)
        begin
            for(i=0; i<4; i=i+1)
            begin
                for(t=0; t<4; t=t+1)
                begin
                    cache_valid[i][t] <= 0;
                    cache_type [i][t] <= 2'b0;
                end
            end    
        end
        else if(install)
        begin
            cache_valid[index][c_way] <= cache_valid[index][c_way];
            cache_type [index][c_way] <= cache_type [index][c_way];
            cache_tag  [index][c_way] <= cache_tag  [index][c_way];
            cache_block[index][c_way] <= cache_block[index][c_way];
        end
        else if(call || return)
        begin
            //
            if (up_way[1] == 1'b0)
                {tree_table[up_index][2], tree_table[up_index][1]} <= ~up_way;
            else
                {tree_table[up_index][2], tree_table[up_index][0]} <= ~up_way;
            //    cache
            if (~up_hit)    //预测错误,更新正确分支地址
            begin
                cache_valid[up_index][up_way] <= 1;
                cache_block[up_index][up_way] <= j_pc;
                cache_tag  [up_index][up_way] <= up_tag;
                cache_type [up_index][up_way] <= call ?2'b10:2'b11;     
            end
        end
    end

endmodule
