module StoreFIFO(
    input wire clk,
    input wire rst,
    
    //流水级
    input wire isStore,
    input wire [31:0] st_addr,
    
    //storeTable
    input wire canEnter,
    output wire [4:0] out_index,   //发射项在table的索引
    output wire       out_ok,      //发射成功
    input wire [31:0] out_addr,  //发射地址
    input wire [31:0] out_data,   //发射数据
   
    //issue
    output wire FIFO_en,
    output wire [31:0] FIFO_addr,
    output wire [3:0]  FIFO_wen,    
    output wire [31:0] FIFO_wdata,
    input  wire FIFO_data_ok   
    );
    
    reg  [4:0] W_index;
    reg  [4:0] R_index;
    reg  [4:0] stFIFO [31:0];
    reg  [5:0] content;    //队列有效元素个数
    assign out_ok = FIFO_data_ok;
    
    integer i;
    always@(posedge clk) begin
        if(rst)begin
            content <= 0;
            W_index <= 0;
            R_index <= 0;
        end
        else begin
             R_index <= out_ok ? (R_index + 1) : R_index;
             content <= (out_ok & ~(isStore & canEnter)) ? (content - 1) : 
                        (~out_ok & (isStore & canEnter)) ? (content + 1) :content;
             stFIFO[W_index] <= (isStore & canEnter) ? {st_addr[6:2]} : stFIFO[W_index];
             W_index <= (isStore & canEnter) ? (W_index + 1) : W_index;      
        end
    end
    
    assign out_index = stFIFO[R_index];
    assign FIFO_en = content>0 ? 1:0;
    assign FIFO_addr = FIFO_en ? out_addr:32'h1FB0_0000;
    assign FIFO_wen  = FIFO_en ? 4'b1111:4'b0000;
    assign FIFO_wdata = FIFO_en ? out_data : 32'b0;
   
endmodule
