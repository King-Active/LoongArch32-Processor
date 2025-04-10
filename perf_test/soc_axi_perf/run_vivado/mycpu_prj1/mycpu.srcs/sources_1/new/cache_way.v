`define TAG_WIDTH 23   
`define INDEX_WIDTH 5
`define INDEX_SIZE 32

`timescale 1ns / 1ps

module cache_way(
     input  wire            clk,    
     input  wire  [4:0]     index,      // 需要读取的行索引
     input  wire  [31:0]    wdata,      // 需要写入的数据
     input  wire            wen,        // 写使能
     input  wire  [1:0]     wHcode,     // 需要写入的掩码
     input  wire  [1:0]     ofst,       // 字节偏移
     output wire  [31:0]    rdata       // 读出的数据
);

    reg [31:0]  way_mem   [`INDEX_DEPTH-1:0];    
    
    wire [31:0] data_;
    wire [31:0] hcode_;
    wire [31:0] writeData;
    
    assign data_    =  (ofst==2'b00)?   wdata:
                       (ofst==2'b01)? { wdata[23:0], 8'b0}:
                       (ofst==2'b10)? { wdata[15:0], 16'b0 }: { wdata[7:0], 24'b0 };
                      
    assign hcode_   =  wHcode[1] ? 32'hFFFFFFFF:
                       wHcode[0] ? (ofst[1] ? 32'hFFFF0000 : 32'h0000FFFF) : 
                                   (ofst==2'b00)? 32'h000000FF: 
                                   (ofst==2'b01)? 32'h0000FF00:
                                   (ofst==2'b10)? 32'h00FF0000: 32'hFF000000;
                
    assign rdata = way_mem[index];

    assign writeData = wen ? ((way_mem[index] & ~hcode_)|(data_ & hcode_)) : way_mem[index];
                            
    always@(posedge clk) begin
       way_mem[index] <=  writeData;
    end
endmodule
