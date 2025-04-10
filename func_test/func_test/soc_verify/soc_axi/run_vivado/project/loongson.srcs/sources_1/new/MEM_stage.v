module MEM_stage(
    input      wire clk,
	input      wire rst,
    
    /*  来自流水级的访存请求  */
    input      wire [31:0]       addr,
    input      wire              mem_r,
    input      wire              mem_w,
    input      wire [31:0]       w_data,
    input      wire [3:0]        w_hcode,
    output     wire [31:0]       r_data,
    
    /*  与类sram接口的交互  */
    output     wire             sram_data_en,
    output     wire  [3:0]      sram_data_wen,
    output     wire  [31:0]     sram_data_addr,
    output     wire  [31:0]     sram_data_wdata, 
    input      wire             sram_data_ok,
    input      wire             sram_addr_ok,
    input      wire  [31:0]     sram_data_rdata,
    
    //流水阻塞
    input      wire             exe_mem_en, //执行阶段为访存指令
    output     wire             instr_mem_stall,
    output     wire             fifo_mem_stall,
    
    //
    output     wire             noCache
    );
    
    //instr
    wire         instr_en;
    wire  [3:0]  instr_wen;
    wire         instr_nocache;
    wire         instr_data_ok;
    wire  [31:0] instr_rdata;
    //buffer
    
    wire  [31:0] st_wData;      //写数据
    wire  [31:0] st_rData;      //读数据
    wire         buffer_hit;    //地址命中
    wire         canEnter;      //可缓存store
    //issue
    wire         FIFO_en;       //需要发射
    wire  [31:0] FIFO_addr;     //发射store地址
    wire   [3:0] FIFO_wen;      //发射store掩码（4'b1111）
    wire  [31:0] FIFO_wdata;    //发射store写数据
    wire         FIFO_data_ok;  //发射完成
    
    assign instr_en = ((mem_r & ~buffer_hit) || (mem_w & ~canEnter));
    assign instr_wen = mem_w ? w_hcode : 4'b0000 ;
    
    assign instr_mem_stall = instr_en && ~instr_data_ok;
    assign fifo_mem_stall = ~instr_en && FIFO_en && ~FIFO_data_ok && exe_mem_en;
    
    assign r_data = instr_en ? instr_rdata :
                      buffer_hit ? st_rData : 32'b00000000;
    
/************** 外设指令判断 **************/
conf_Judge u_conf_Judge(
            .data_vaddr(addr),
            .no_cache(instr_nocache)
    );
/******************************************/

storeBuffer u_storeBuffer(
    .clk(clk),
    .rst(rst),
    
    //流水级
    .isStore(mem_w),     //store指令
    .w_hcode(w_hcode),   //有掩码
    .instr_nocache(instr_nocache),  //访外设
    .st_addr(addr),   //地址
    .st_wData(w_data),  //写数据
    .st_rData(st_rData), //读数据
    .buffer_hit(buffer_hit),    //地址命中
    .canEnter(canEnter),      //可缓存store
    
    //issue
    .FIFO_en(FIFO_en),          //需要发射
    .FIFO_addr(FIFO_addr),  //发射store地址
    .FIFO_wen(FIFO_wen),   //发射store掩码（4'b1111）
    .FIFO_wdata(FIFO_wdata), //发射store写数据
    .FIFO_data_ok(FIFO_data_ok) //发射完成
);
    
Issue u_Issue(
    //来自storeFIFO，只可能是 非外设的store 指令
    .FIFO_en(FIFO_en),     // 表示是否有元素需要发射，不保证访存空闲检查
    .FIFO_addr(FIFO_addr),
    .FIFO_wen(FIFO_wen),
    .FIFO_wdata(FIFO_wdata),
    .FIFO_data_ok(FIFO_data_ok),  
    
    //来自流水级，优先级最高
    .instr_en(instr_en),
    .instr_addr(addr),
    .instr_wen(instr_wen),
    .instr_wdata(w_data),
    .instr_data_ok(instr_data_ok),     
    .instr_rdata(instr_rdata),
    .instr_nocache(instr_nocache),
    
    //发送给类sram接口
    .sram_data_en(sram_data_en),
    .sram_data_addr(sram_data_addr),
    .sram_data_wen(sram_data_wen),
    .sram_data_wdata(sram_data_wdata),
    .sram_data_ok(sram_data_ok),   
    .sram_addr_ok(sram_addr_ok),   
    .sram_data_rdata(sram_data_rdata),
    
    .noCache(noCache)
    );
    
endmodule
