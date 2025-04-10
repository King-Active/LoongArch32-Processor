`timescale 1ns / 1ps
module iCache(
    input   wire clk,rst,
    //cpu   
    input   wire             instr_req     ,
    input   wire             instr_wr      ,   //废弃接口
    input   wire [1 :0]      instr_size    ,   //废弃接口
    input   wire [31:0]      instr_addr    ,
    input   wire [31:0]      instr_wdata   ,   //废弃接口
    output  wire  [31:0]     instr_rdata   ,
    output  wire             instr_addr_ok , 
    output  wire             instr_data_ok ,
    
    //axi
    output  wire             axi_req     ,  
    output  wire             axi_wr      ,      // 恒定
    output  wire [1 :0]      axi_size    ,      // 恒定
    output  wire  [31:0]     axi_addr    ,
    output  wire [31:0]      axi_wdata   ,      // 恒定
    input   wire [31:0]      axi_rdata   ,
    input   wire             axi_addr_ok ,
    input   wire             axi_data_ok 
    );
    
    wire hit;
    wire [31:0] addr;
    reg  [2:0] s;
    
    assign axi_wr    = 0;
    assign axi_size  = 2'b10;
    assign axi_wdata = 32'b0;
    assign instr_addr_ok = 1'b1;
    assign axi_req   = instr_req & ~hit;
    assign axi_addr  = { instr_addr[31:4], 4'b0000};
    assign instr_data_ok = hit & ~axi_data_ok;

    always@(posedge clk) begin
        if(!rst) begin
            s <= 3'b000;
        end
        else begin
            case(s)
                3'b000: begin
                    if (hit) begin
                        s <= 3'b000;
                    end
                    else begin
                        s <= 3'b010;
                    end
                end
                
                3'b010: begin
                    if(~axi_data_ok) begin
                        s <= 3'b010;
                    end
                    else begin
                        s <= 3'b110;
                    end
                end
                
                3'b110: begin
                    if(~axi_data_ok) begin
                        s <= 3'b110;
                    end
                    else begin
                        s <= 3'b100;
                    end
                end
                
                3'b100: begin
                    if(~axi_data_ok) begin
                        s <= 3'b100;
                    end
                    else begin
                        s <= 3'b101;
                    end
                end
                
                3'b101: begin
                    if(~axi_data_ok) begin
                        s <= 3'b101;
                    end
                    else begin
                        s <= 3'b111;
                    end
                end

                3'b111: begin
                    s <= 3'b000;
                end
                
                default: begin
                    s <= 3'b000;
                end
            endcase
        end
    end
    
    localparam blockSize = 4;      // 每个块包含4个字  
    localparam wordSize = 32;      // 1个字32位
    localparam setSize = 2;        // 组相联度
    localparam cacheSize = 8;    // 组数
    localparam tag_length = 25;    //标志位长度
    localparam idx_length = 3;    // 索引长度
    
    reg [wordSize-1:0] cache_memory [cacheSize-1:0][setSize-1:0][blockSize-1:0];  
    reg [0:0] cache_valid [cacheSize-1:0][setSize-1:0]; 
    reg [1:0] cache_last_find [cacheSize-1:0]; 
    reg [tag_length-1:0]cache_tag   [cacheSize-1:0][setSize-1:0];
       
    wire valid_1,valid_2;
    wire [1:0] last_find;
    wire [tag_length-1:0] tag_1;
    wire [tag_length-1:0] tag_2;
    wire [wordSize-1:0] instr_1 [blockSize-1:0];
    wire [wordSize-1:0] instr_2 [blockSize-1:0];
    wire rightway;
    wire replaceway;
    
    assign addr = instr_addr;
    
    assign valid_1    = cache_valid[addr[idx_length+3:4]][0];
    assign valid_2    = cache_valid[addr[idx_length+3:4]][1];
    assign last_find  = cache_last_find[addr[idx_length+3:4]];
    assign tag_1      = cache_tag[addr[idx_length+3:4]][0];
    assign tag_2      = cache_tag[addr[idx_length+3:4]][1];
    assign instr_1[0] = cache_memory[addr[idx_length+3:4]][0][0];
    assign instr_1[1] = cache_memory[addr[idx_length+3:4]][0][1];
    assign instr_1[2] = cache_memory[addr[idx_length+3:4]][0][2];
    assign instr_1[3] = cache_memory[addr[idx_length+3:4]][0][3];
    assign instr_2[0] = cache_memory[addr[idx_length+3:4]][1][0];
    assign instr_2[1] = cache_memory[addr[idx_length+3:4]][1][1];
    assign instr_2[2] = cache_memory[addr[idx_length+3:4]][1][2];
    assign instr_2[3] = cache_memory[addr[idx_length+3:4]][1][3];
    
    assign hit         = (valid_1 && (tag_1  == addr[31:idx_length+4])) || (valid_2 && (tag_2 == addr[31:idx_length+4]));
    assign rightway    = (tag_1 == addr[31:idx_length+4])? 0:1;
    assign replaceway  = (last_find == 2'b01)? 0:
                         (last_find == 2'b10)? 1:0;
    assign instr_rdata = hit?  
                            rightway? instr_2[addr[3:2]] : instr_1[addr[3:2]]
                            : 32'b0;
                        
    integer x,y;
    always@(posedge clk) begin
        if(!rst)begin
            for (x=0;x<cacheSize;x=x+1)begin
                for(y=0;y<setSize;y=y+1)begin
                    cache_valid[x][y] <= 1'b0;
                    cache_last_find[x] <= 2'b00;
                    cache_tag[x][y] <= 25'b0;
                end
            end       
        end
        else begin
            if(s == 3'b000 & hit)begin
                cache_last_find[addr[idx_length+3:4]] <= rightway? 2'b01: 2'b10;  
            end     
            else if(s == 3'b010 && axi_data_ok)begin
                cache_memory[addr[idx_length+3:4]][replaceway][0] <= axi_rdata;
            end   
            else if(s == 3'b110 && axi_data_ok)begin
                cache_memory[addr[idx_length+3:4]][replaceway][1] <= axi_rdata;
            end  
            else if(s == 3'b100 && axi_data_ok)begin
                cache_memory[addr[idx_length+3:4]][replaceway][2] <= axi_rdata;
            end   
            // 最后一个数据取回成功
            else if(s == 3'b101 && axi_data_ok)begin
                cache_memory[addr[idx_length+3:4]][replaceway][3] <= axi_rdata;
                cache_valid[addr[idx_length+3:4]][replaceway] <= 1;
                cache_last_find[addr[idx_length+3:4]] <= replaceway? 2'b01:2'b10;
                cache_tag[addr[idx_length+3:4]][replaceway] <= addr[31:idx_length+4];
            end            
            else begin
                cache_valid[addr[idx_length+3:4]][replaceway] <= cache_valid[addr[idx_length+3:4]][replaceway];
                cache_last_find[addr[idx_length+3:4]] <= cache_last_find[addr[idx_length+3:4]];
                cache_tag[addr[idx_length+3:4]][replaceway] <= cache_tag[addr[idx_length+3:4]][replaceway];
            end
        end    
    end
   
    
endmodule
