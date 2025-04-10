`define indexBits 6    //索引长度
`define indexBits1 5    //索引长度-1
`define indexBits2 7    //索引长度+1  索引结束位
`define indexBits3 8    //索引长度+2  标记开始位  
`define tagsize1 23    //标志长度-1
`define stSize    64   //缓存大小（单位：字）
`define stSize1   63   //缓存大小-1（单位：字）

module StoreTable(
    input wire clk,
    input wire rst,
    
    //流水级
    input wire isStore,     //store指令
    input wire [3:0]  w_hcode,   //有掩码
    input wire instr_nocache,  //访外设
    input wire [31:0] st_addr,   //地址
    input wire [31:0] st_wData,  //写数据
    output wire [31:0] st_rData, //读数据
    
    output wire buffer_hit,    //地址命中
    output wire canEnter,      //可缓存store
    
    //storeFIFO
    input wire [`indexBits1:0] out_index,   //发射项在table的索引
    input wire       out_ok,      //发射成功
    output wire [31:0] out_addr,  //发射地址
    output wire [31:0] out_data   //发射数据
    );
    
    reg stValid   [`stSize1:0];
    reg stInFIFO  [`stSize1:0];
    reg [31:0] stData  [`stSize1:0];      
    reg [`tagsize1:0] stTag [`stSize1:0];      //以[`indexBits2:2]为字索引； 以[indexBits3:7]为标记
    
    wire [31:0] st_wData_silled;
    wire [3:0]  w_hcode_silled;
    wire [31:0] total_hcode;
    assign st_wData_silled = (w_hcode==4'b1111) ? st_wData :
                                (w_hcode==4'b0011) ? (st_addr[1]?{st_wData[15:0],16'b0}:{16'b0,st_wData[15:0]}) : 
                                (st_addr[1]? (st_addr[0]?{st_wData[7:0],24'b0}:{5'b0,st_wData[7:0],16'b0}) : (st_addr[0]?{16'b0,st_wData[7:0],8'b0}:{24'b0,st_wData[7:0]}));
    assign w_hcode_silled = (w_hcode==4'b1111) ? w_hcode :
                            (w_hcode==4'b0011) ? (st_addr[1]?4'b1100:4'b0011) : (w_hcode << st_addr[1:0]);
    assign total_hcode = {(w_hcode_silled[3]? 8'hFF:8'h00),(w_hcode_silled[2]? 8'hFF:8'h00),(w_hcode_silled[1]? 8'hFF:8'h00),(w_hcode_silled[0]? 8'hFF:8'h00)};

    assign st_rData = stData[st_addr[`indexBits2:2]];
    assign buffer_hit  = ((stTag[st_addr[`indexBits2:2]])==st_addr[31:`indexBits3]) && stValid[st_addr[`indexBits2:2]];
    assign canEnter = instr_nocache ? 1'b0 :  //外设不入
                        //写全字 -> (空 | 命中位置 | 不在队列) 可入
                        (w_hcode==4'b1111) ? (~stValid[st_addr[`indexBits2:2]] || ((stTag[st_addr[`indexBits2:2]])==st_addr[31:`indexBits3]) || ~stInFIFO[st_addr[`indexBits2:2]]) :  
                        //写半字/字节 -> 命中可入
                         (stValid[st_addr[`indexBits2:2]] && ((stTag[st_addr[`indexBits2:2]])==st_addr[31:`indexBits3]));
  // 非外设 & 无掩码 & (空/命中/可占据(不在队列))
    
    assign out_addr = {stTag[out_index],out_index,2'b00};
    assign out_data = stData[out_index];
                        
    integer i;
// 时序逻辑 - 出队列；新增表元素 ； 替换表元素
    always@(posedge clk)begin
        if(rst) begin
        //清空数据和队列（伪删除）
            for(i = 0; i<`stSize; i=i+1)begin
                stValid[i]  <= 0;
                stInFIFO[i] <= 0; 
            end
        end
        else begin
        //指令访问 & 可入-> inqueue     cache空闲 & data_ok -> outFIFO
            stInFIFO [out_index] <= out_ok ? 1'b0 : stInFIFO [out_index];
            
            stValid [st_addr[`indexBits2:2]] <= (isStore & canEnter) ? 1'b1 : stValid [st_addr[`indexBits2:2]];
            stInFIFO [st_addr[`indexBits2:2]] <= (isStore & canEnter) ? 1'b1 : stInFIFO [st_addr[`indexBits2:2]];
            stTag [st_addr[`indexBits2:2]] <= (isStore & canEnter) ? st_addr[31:`indexBits3] : stTag [st_addr[`indexBits2:2]];
            stData [st_addr[`indexBits2:2]] <= (isStore & canEnter) ? ((st_wData_silled & total_hcode)|(stData [st_addr[`indexBits2:2]] & (~total_hcode))) : stData [st_addr[`indexBits2:2]];
        end
    end

endmodule
