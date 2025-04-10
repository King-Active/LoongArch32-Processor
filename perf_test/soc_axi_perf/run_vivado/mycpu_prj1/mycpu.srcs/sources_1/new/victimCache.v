`timescale 1ns / 1ps
module victimCache( 
    input    wire               clk, rst             ,
    input    wire               addDirtyReq          ,          
    input    wire [127:0]       DirtyBlock           ,   
    input    wire [31:0]        DirtyAddr            ,          
    
    output   wire               AcptDirty            ,              // 是否可以接收脏数据块
    
    /*  经过cache的访存交互  */
    input    wire               ram_data_req          ,
    input    wire               ram_data_wr           ,
    input    wire [1 :0]        ram_data_size         ,
    input    wire [31:0]        ram_data_addr         ,
    input    wire [31:0]        ram_data_wdata        ,
    output   wire [31:0]        vcm_ram_data_rdata    ,
    output   wire               vcm_ram_data_addr_ok  ,
    output   wire               vcm_ram_data_data_ok  ,             // vcm 命中反馈       

    
    /*  发送给 AXI总线的 写访存交互  */
    output  reg                 vcm_data_req          ,
    output  reg                 vcm_data_wr           ,
    output  reg  [1 :0]         vcm_data_size         ,
    output  reg  [31:0]         vcm_data_addr         ,
    output  reg  [31:0]         vcm_data_wdata        ,
    input   wire [31:0]         vcm_data_rdata        ,     // 忽略
    input   wire                vcm_data_addr_ok      ,     
    input   wire                vcm_data_data_ok      ,
    output  reg                 vcm_wlast             ,
    input   wire                vcm_wready                  // 表示对方是否接收请求
    );
    
    localparam vcmSize = 32; 
    localparam idxSize =  5; 
    
    reg [27:0]            vcmTag     [vcmSize-1:0]      ;   // 标记     
    reg [31:0]            vcmBlock   [vcmSize-1:0][3:0] ;   // 1个块： 4个字，每个字32位
    reg [vcmSize-1:0]     vcmValid                      ;   // 此块是否有效
    reg [idxSize-1:0]     out_p                         ;   // 指向即将写回内存的指针
    reg [idxSize-1:0]     in_p                          ;   // 指向可被写入的脏数据块
    reg [2:0]             vcm_s                         ;   // 状态机 
    
    wire                  full                          ;   // 是否已满，需要发起 vcm_data_req 写回请求
    wire [27:0]           tag                           ;   // 标记
    wire [1:0]            word                          ;   // 字偏移
    wire [1:0]            byte                          ;   // 字内字节偏移
    wire [idxSize-1:0]    hit_index                     ;   // vcm 命中下标
    wire [vcmSize-1:0]    vcm_cache_hit                 ;   // vcm 是否命中
    
    wire  [idxSize-1:0] nxt_p;
    assign nxt_p = in_p + 1'b1;
    assign full      =  (nxt_p == out_p);  
    assign AcptDirty = ~full;

    assign { tag, word, byte } = ram_data_addr;

    assign vcm_cache_hit = { vcmValid[31]  & (vcmTag[31] == tag) ,   
                             vcmValid[30]  & (vcmTag[30] == tag) ,   
                             vcmValid[29]  & (vcmTag[29] == tag) ,   
                             vcmValid[28]  & (vcmTag[28] == tag) ,   
                             vcmValid[27]  & (vcmTag[27] == tag) ,   
                             vcmValid[26]  & (vcmTag[26] == tag) ,   
                             vcmValid[25]  & (vcmTag[25]  == tag) ,   
                             vcmValid[24]  & (vcmTag[24]  == tag) ,   
                             vcmValid[23]  & (vcmTag[23]  == tag) ,   
                             vcmValid[22]  & (vcmTag[22]  == tag) ,   
                             vcmValid[21]  & (vcmTag[21]  == tag) ,   
                             vcmValid[20]  & (vcmTag[20]  == tag) ,   
                             vcmValid[19]  & (vcmTag[19]  == tag) ,   
                             vcmValid[18]  & (vcmTag[18]  == tag) ,  
                             vcmValid[17]  & (vcmTag[17]  == tag) ,  
                             vcmValid[16]  & (vcmTag[16]  == tag) ,
                             vcmValid[15]  & (vcmTag[15] == tag) ,   
                             vcmValid[14]  & (vcmTag[14] == tag) ,   
                             vcmValid[13]  & (vcmTag[13] == tag) ,   
                             vcmValid[12]  & (vcmTag[12] == tag) ,   
                             vcmValid[11]  & (vcmTag[11] == tag) ,   
                             vcmValid[10]  & (vcmTag[10] == tag) ,   
                             vcmValid[9]   & (vcmTag[9]  == tag) ,   
                             vcmValid[8]   & (vcmTag[8]  == tag) ,   
                             vcmValid[7]   & (vcmTag[7]  == tag) ,   
                             vcmValid[6]   & (vcmTag[6]  == tag) ,   
                             vcmValid[5]   & (vcmTag[5]  == tag) ,   
                             vcmValid[4]   & (vcmTag[4]  == tag) ,   
                             vcmValid[3]   & (vcmTag[3]  == tag) ,   
                             vcmValid[2]   & (vcmTag[2]  == tag) ,  
                             vcmValid[1]   & (vcmTag[1]  == tag) ,  
                             vcmValid[0]   & (vcmTag[0]  == tag) };
                             
    assign vcm_ram_data_data_ok =  ram_data_req? |vcm_cache_hit : 0;  
    assign vcm_ram_data_addr_ok =  ram_data_req? vcm_ram_data_data_ok : 0;
         
    assign vcm_ram_data_rdata   =   vcm_cache_hit[0]  ? vcmBlock[0] [word] :
                                    vcm_cache_hit[1]  ? vcmBlock[1] [word] :
                                    vcm_cache_hit[2]  ? vcmBlock[2] [word] :
                                    vcm_cache_hit[3]  ? vcmBlock[3] [word] :
                                    vcm_cache_hit[4]  ? vcmBlock[4] [word] :
                                    vcm_cache_hit[5]  ? vcmBlock[5] [word] :
                                    vcm_cache_hit[6]  ? vcmBlock[6] [word] :
                                    vcm_cache_hit[7]  ? vcmBlock[7] [word] :
                                    vcm_cache_hit[8]  ? vcmBlock[8] [word] :
                                    vcm_cache_hit[9]  ? vcmBlock[9] [word] :
                                    vcm_cache_hit[10] ? vcmBlock[10][word] :
                                    vcm_cache_hit[11] ? vcmBlock[11][word] :
                                    vcm_cache_hit[12] ? vcmBlock[12][word] :
                                    vcm_cache_hit[13] ? vcmBlock[13][word] :
                                    vcm_cache_hit[14] ? vcmBlock[14][word] :
                                    vcm_cache_hit[15] ? vcmBlock[15][word] :
                                    vcm_cache_hit[16] ? vcmBlock[16][word] :
                                    vcm_cache_hit[17] ? vcmBlock[17][word] :
                                    vcm_cache_hit[18] ? vcmBlock[18][word] :
                                    vcm_cache_hit[19] ? vcmBlock[19][word] :
                                    vcm_cache_hit[20] ? vcmBlock[20][word] :
                                    vcm_cache_hit[21] ? vcmBlock[21][word] :
                                    vcm_cache_hit[22] ? vcmBlock[22][word] :
                                    vcm_cache_hit[23] ? vcmBlock[23][word] :
                                    vcm_cache_hit[24] ? vcmBlock[24][word] :
                                    vcm_cache_hit[25] ? vcmBlock[25][word] :
                                    vcm_cache_hit[26] ? vcmBlock[26][word] :
                                    vcm_cache_hit[27] ? vcmBlock[27][word] :
                                    vcm_cache_hit[28] ? vcmBlock[28][word] :
                                    vcm_cache_hit[29] ? vcmBlock[29][word] :
                                    vcm_cache_hit[30] ? vcmBlock[30][word] :
                                    vcm_cache_hit[31] ? vcmBlock[31][word] : 32'b0;
                                    
    assign hit_index =  (vcm_cache_hit[0]) ? 0 :
                        (vcm_cache_hit[1]) ? 1 :
                        (vcm_cache_hit[2]) ? 2 :
                        (vcm_cache_hit[3]) ? 3 :
                        (vcm_cache_hit[4]) ? 4 :
                        (vcm_cache_hit[5]) ? 5 :
                        (vcm_cache_hit[6]) ? 6 :
                        (vcm_cache_hit[7]) ? 7 :
                        (vcm_cache_hit[8]) ? 8 :
                        (vcm_cache_hit[9]) ? 9 :
                        (vcm_cache_hit[10]) ? 10 :
                        (vcm_cache_hit[11]) ? 11 :
                        (vcm_cache_hit[12]) ? 12 :
                        (vcm_cache_hit[13]) ? 13 :
                        (vcm_cache_hit[14]) ? 14 :
                        (vcm_cache_hit[15]) ? 15 :
                        (vcm_cache_hit[16]) ? 16 : 
                        (vcm_cache_hit[17]) ? 17 : 
                        (vcm_cache_hit[18]) ? 18 : 
                        (vcm_cache_hit[19]) ? 19 : 
                        (vcm_cache_hit[20]) ? 20 : 
                        (vcm_cache_hit[21]) ? 21 : 
                        (vcm_cache_hit[22]) ? 22 : 
                        (vcm_cache_hit[23]) ? 23 : 
                        (vcm_cache_hit[24]) ? 24 : 
                        (vcm_cache_hit[25]) ? 25 : 
                        (vcm_cache_hit[26]) ? 26 :
                        (vcm_cache_hit[27]) ? 27 :
                        (vcm_cache_hit[28]) ? 28 :
                        (vcm_cache_hit[29]) ? 29 :
                        (vcm_cache_hit[30]) ? 30 :
                        (vcm_cache_hit[31]) ? 31 :
                         4'bx;
    

    wire [31:0] writeData;
    wire [31:0] hcode_;
    
    assign writeData    =  (ram_data_addr[1:0]==2'b00)? ram_data_wdata:
                           (ram_data_addr[1:0]==2'b01)? { ram_data_wdata[23:0],8'b0 } :
                           (ram_data_addr[1:0]==2'b10)? { ram_data_wdata[15:0],16'b0 }: { ram_data_wdata[7:0],24'b0 };
                      
    assign hcode_       =  ram_data_size[1] ? 32'hFFFFFFFF:
                           ram_data_size[0] ? 
                                 ram_data_addr[1] ? 32'hFFFF0000 : 32'h0000FFFF 
                                 :  
                                 (ram_data_addr[1:0]==2'b00)? 32'h000000FF:
                                 (ram_data_addr[1:0]==2'b01)? 32'h0000FF00:
                                 (ram_data_addr[1:0]==2'b10)? 32'h00FF0000:32'hFF000000;
                                 
    
    integer  i;
    always@(posedge clk)begin
        if(!rst) begin
            vcm_s           <= 3'b000;
            out_p           <= 0;
            in_p            <= 0;
            vcm_data_req    <= 0;
            vcm_data_wr     <= 1;       // 恒 1
            vcm_data_size   <= 2'b11;   // 恒 11
            vcm_wlast       <= 1'b0;
                            
            for(i=0;i<vcmSize;i=i+1)begin
                vcmValid[i] <= 1'b0;
            end
        end
        
        else begin
        // 访存命中，能保证 发生脏缺失的 dCache 不会发送脏请求
            if( ram_data_req & ram_data_wr & (|vcm_cache_hit) ) begin
                vcmBlock[hit_index][word]     <=   ((vcmBlock[hit_index][word] & ~hcode_)|(writeData & hcode_));
            end
            else begin
                case(vcm_s)
                3'b000: begin 
                            if (full) begin
                                // 满，发起写回请求
                                vcm_s             <= 3'b001;
                                vcm_data_req      <= 1;
                                vcm_data_addr     <= { vcmTag[out_p], 4'b0000 };        // 起始地址
                                vcm_data_wdata    <= vcmBlock[out_p][2'b00];            // 第一个字数据        
                                vcm_wlast         <= 1'b0;        
                            end
                            // 若 ram_data_req & vcm_cache_hit，则不接收脏数据块
                            // 因为 dCache 并非真的要替换
                            else if( ~(ram_data_req & vcm_cache_hit) & addDirtyReq) begin
                                // 接收脏数据块
                                vcm_s             <=  3'b000;
                                vcm_data_req      <=  0;
                                vcmBlock[in_p][0] <=  DirtyBlock[31:0];
                                vcmBlock[in_p][1] <=  DirtyBlock[63:32];
                                vcmBlock[in_p][2] <=  DirtyBlock[95:64];
                                vcmBlock[in_p][3] <=  DirtyBlock[127:96];
                                vcmTag[in_p]      <=  DirtyAddr[31:4];
                                vcmValid[in_p]    <=  1;
                                in_p              <=  in_p + 1;
                                vcm_wlast             <= 1'b0;
                            end
                            else begin
                                vcm_data_req      <=  0;
                                vcm_s             <=  3'b000;
                                vcm_wlast         <=  1'b0;
                            end
                        end
                    // 本次突发写请求通过，后续仅根据vcm_wready判断即可
                    3'b001: begin
                            if(vcm_data_addr_ok) begin
                                vcm_data_req      <=  1;
                                vcm_s             <= 3'b111;
                                vcm_wlast         <= 1'b0;
                            end
                            else begin
                                vcm_data_req      <=  1;
                                vcm_s             <= 3'b001;
                                vcm_wlast         <= 1'b0;
                            end
                        end 

                    3'b111: begin
                            if(~vcm_wready) begin
                           // 仍然请求第一个字
                                 vcm_data_req      <=  1;
                                 vcm_s             <= 3'b111;
                                 vcm_wlast         <= 1'b0;                           
                            end
                            else begin
                                vcm_s                 <= 3'b110;    
                                vcm_data_req          <= 1;
                                vcm_data_addr         <= { vcmTag[out_p], 4'b0000 };        // 起始地址
                                vcm_data_wdata        <= vcmBlock[out_p][2'b01];            // 第二个字数据       
                                vcm_wlast             <= 1'b0;                    
                            end
                        end
                        
                    3'b110: begin
                            if(~vcm_wready) begin
                                 vcm_data_req      <=  1;
                                 vcm_s             <= 3'b110;
                                 vcm_wlast         <= 1'b0;   
                            end
                            else begin
                                vcm_s                 <= 3'b010;   
                                vcm_data_req          <= 1;
                                vcm_data_addr         <= { vcmTag[out_p], 4'b0000 };        // 起始地址
                                vcm_data_wdata        <= vcmBlock[out_p][2'b10];            // 第三个字数据  
                                vcm_wlast             <= 1'b0;       
                            end
                        end        
                    3'b010: begin
                            if(~vcm_wready) begin
                                 vcm_data_req      <=  1;
                                 vcm_s             <= 3'b010;
                                 vcm_wlast         <= 1'b0;   
                            end
                            else begin
                                vcm_s                 <= 3'b100;            
                                vcm_data_req          <= 1;
                                vcm_data_addr         <= { vcmTag[out_p], 4'b0000 };        // 起始地址
                                vcm_data_wdata        <= vcmBlock[out_p][2'b11];            // 第四个字数据    
                                vcm_wlast             <= 1'b1;
                            end
                        end

                    3'b100: begin
                            // 等待数据写结束
                            if(~vcm_data_data_ok) begin
                                vcm_data_req      <=  0;
                                vcm_s             <= 3'b100;   
                                vcm_wlast         <= 1'b0;
                            end
                            else begin
                                vcm_s             <= 3'b000;
                                vcm_data_req      <=  0;
                                vcm_wlast         <= 1'b0;
                                // 写回数据的块剔除，变为无效
                                out_p                 <= out_p + 1;
                                vcmValid[out_p]       <= 1'b0;
                            end
                        end
                    default:begin
                        vcm_s           <= 3'b000;
                        out_p           <= 0;
                        in_p            <= 0;
                        vcm_data_req    <= 0;
                        vcm_data_wr     <= 1;       // 恒 1
                        vcm_data_size   <= 2'b11;   // 恒 11
                        vcm_wlast       <= 1'b0;
                                        
                        for(i=0;i<vcmSize;i=i+1)begin
                            vcmValid[i] <= 1'b0;
                        end
                     end
                endcase
            end
        end
    end
    
endmodule
