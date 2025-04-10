module cpu_axi_interface
(   
//是否处于有空处理的请求状态: 从开始请求 -> 最后一个数据操作完成
    output reg isWriteRequring,
    output reg isReadRequring,
    input wire noCache,     //外设信号

    input wire         clk,
    input wire         rst, 
    //inst sram-like 
    input wire         instr_req     ,
    input wire         instr_wr      ,
    input wire  [1 :0] instr_size    ,
    input wire  [31:0] instr_addr    ,
    input wire  [31:0] instr_wdata   ,
    output wire [31:0] instr_rdata   ,
    output wire        instr_addr_ok ,
    output wire        instr_data_ok ,   //只读
    
    //data sram-like 
    input wire         data_req     ,
    input wire         data_wr      ,
    input wire  [1 :0] data_size    ,
    input wire  [31:0] data_addr    ,
    input wire  [31:0] data_wdata   ,
    output wire [31:0] data_rdata   ,
    output wire        data_addr_ok ,
    output wire        data_data_ok ,    //   读写

    //data victim_cache
    input wire         vcm_req     ,
    input wire         vcm_wr      ,  //恒为1
    input wire  [1 :0] vcm_size    ,  
    input wire  [31:0] vcm_addr    ,  //脏数据地址
    input wire  [31:0] vcm_wdata   ,  //脏数据
    output wire [31:0] vcm_rdata   ,  //无效
    output reg         vcm_addr_ok ,  
    output wire        vcm_data_ok ,    //只写
    input  wire        vcm_wlast   ,
    output wire        vcm_wready  ,
    
    //axi
    //ar
    output wire [3 :0] arid         ,
    output wire [31:0] araddr       ,
    output wire [7 :0] arlen        ,
    output wire [2 :0] arsize       ,
    output wire [1 :0] arburst      ,
    output wire [1 :0] arlock        ,
    output wire [3 :0] arcache      ,
    output wire [2 :0] arprot       ,
    output wire        arvalid      ,
    input wire         arready      ,
    //r           
    input wire  [3 :0] rid          ,
    input wire  [31:0] rdata        ,
    input wire  [1 :0] rresp        ,
    input wire         rlast        ,
    input wire         rvalid       ,
    output wire        rready       ,
    //aw         
    output wire [3 :0] awid         ,
    output wire [31:0] awaddr       ,
    output wire [7 :0] awlen        ,
    output wire [2 :0] awsize       ,
    output wire [1 :0] awburst      ,
    output wire [1 :0] awlock       ,
    output wire [3 :0] awcache      ,
    output wire [2 :0] awprot       ,
    output wire        awvalid      ,
    input wire         awready      ,
    //w          
    output wire [3 :0] wid          ,
    output wire [31:0] wdata        ,
    output wire [3 :0] wstrb        ,
    output wire        wlast        ,
    output wire        wvalid       ,
    input wire         wready       ,
    //b           
    input wire  [3 :0] bid          ,
    input wire  [1 :0] bresp        ,
    input wire         bvalid       ,
    output wire        bready       
);

//是否为数据类型的请求，则其优先级更高； 在本次请求结束后置零
reg isDataWriteReq;
reg isDataReadReq;
//是否为victimcache的请求，则其优先级在写操作中最高； 在本次请求结束后置零
reg isVcmWriteReq;
//表示当前请求 读数据正在接受中 或 写操作已完成（最后一个数据已写入）
wire final_Write_responding;
wire final_Read_responding;
// 与axi地址握手成功 -> 最后一个数据操作完成
reg addr_Write_handed;
reg addr_Read_handed;
//  与axi写数据握手成功 ->  最后一个数据传输完成
reg data_handed;
//通过isWriteRequring 和 isReadRequring 判断读写通道是否有工作
reg [31:0] req_Write_addr;       
reg [31:0] req_Read_addr;       


always@(posedge clk) begin
    if(!rst)
        isWriteRequring <= 1'b0;
    else if(((data_req && data_wr)||(vcm_req && vcm_wr))&&!isWriteRequring) 
        isWriteRequring <= 1'b1;         //一次事务完成后 空闲一拍
    else if(final_Write_responding && bvalid)
        isWriteRequring <= 1'b0;        //最后响应阶段，且到最终点，下一拍空闲
    else
        isWriteRequring <= isWriteRequring;
end

always@(posedge clk) begin
    if(!rst)
        isReadRequring <= 1'b0;
    else if(((data_req && !data_wr)||(instr_req && !instr_wr))&&!isReadRequring) 
        isReadRequring <= 1'b1;         //一次事务完成后 空闲一拍
    else if(final_Read_responding && rvalid)
        isReadRequring <= 1'b0;        //最后响应阶段，且到最终点，下一拍空闲
    else
        isReadRequring <= isReadRequring;
end

always@(posedge clk) begin
    if(!rst)
        isDataWriteReq <= 1'b0;
    else if((!isWriteRequring || bvalid) && !vcm_req)
        isDataWriteReq <= (data_req && data_wr) ;  //非请求中，若vcm未请求，则写通道留给data
    else
        isDataWriteReq <= isDataWriteReq; //请求中，保持请求类型不变
end

always@(posedge clk) begin
    if(!rst)
        isDataReadReq <= 1'b0;
    else if((!isReadRequring || rlast))
        isDataReadReq <= (data_req && !data_wr);  //非请求中，则读通道优先留给data
    else
        isDataReadReq <= isDataReadReq; //请求中，保持请求类型不变
end

always@(posedge clk) begin
    if(!rst)
        isVcmWriteReq <= 1'b0;
    else if(!isWriteRequring || bvalid)
        isVcmWriteReq <= (vcm_req && vcm_wr);  //非请求中，写通道优先留给victimcache
    else
        isVcmWriteReq <= isVcmWriteReq; //请求中，保持请求类型不变
end

assign final_Write_responding = isWriteRequring && ( bvalid && bready );  
assign final_Read_responding  = isReadRequring  && ( rlast && rvalid && rready);  

always@(posedge clk) begin
    if(!rst)
        addr_Write_handed <= 1'b0;
    else if(awvalid && awready)
        addr_Write_handed <= 1'b1;             
    else if(final_Write_responding && bvalid)
        addr_Write_handed <= 1'b0;
    else
        addr_Write_handed <= addr_Write_handed;    
end

always@(posedge clk) begin
    if(!rst)
        addr_Read_handed <= 1'b0;
    else if(arvalid && arready)
        addr_Read_handed <= 1'b1;             
    else if(final_Read_responding && rvalid)
        addr_Read_handed <= 1'b0;
    else
        addr_Read_handed <= addr_Read_handed;    
end

//在与data竞争中，写操作的优先级最高
always@(posedge clk) begin 
    vcm_addr_ok <= vcm_req && !isWriteRequring;    //在空闲下，首选vcm进行写操作
end
//优先级次高：读地址 或 写地址 握手成功
assign data_addr_ok =  (data_wr && (vcm_req && data_req ? 0:data_req)) ||
                       (data_req && !data_wr);       //只有当vcm和data共同请求写时，data失败
//优先级最低
assign instr_addr_ok = (instr_req && data_req && !data_wr ? 0:instr_req);   //当data进行读请求时失败


always@(posedge clk) begin
    if(!rst)
        data_handed <= 1'b0;
    else if(wvalid && wready)
        data_handed <= 1'b1;             
    else if(final_Write_responding && wlast)   
        data_handed <= 1'b0;
    else
        data_handed <= data_handed;    
end

always @(posedge clk) begin
    if(!rst) begin
        req_Write_addr   <=  32'h1fb00000;
        req_Read_addr    <=  32'h1fb00000;
    end
    else begin 
        req_Write_addr   <=  vcm_req && vcm_wr && vcm_addr_ok ? vcm_addr :
                            data_req && data_wr && data_addr_ok ? data_addr : 32'h1fb00000; 
        req_Read_addr    <=  data_req && !data_wr && data_addr_ok ? data_addr :
                            instr_req && !instr_wr && instr_addr_ok ? instr_addr : 32'h1fb00000;                          
    end
end

//instr的数据正在返回中，将持续 4 拍
assign instr_data_ok = isReadRequring && !isDataReadReq && rvalid;
//victimCache的写数据信号
assign vcm_data_ok   = isWriteRequring && isVcmWriteReq && final_Write_responding;
//Data的数据正在返回中，将持续 4 拍 或 1 拍
assign data_data_ok  = (isReadRequring && isDataReadReq && rvalid) ||
                       (isWriteRequring && !isVcmWriteReq && isDataWriteReq && final_Write_responding);

assign instr_rdata   = rdata;
assign data_rdata   = rdata;

//读地址通道
assign arid    = 4'd0;
assign araddr  = req_Read_addr;
assign arlen   = (isReadRequring && (~noCache || instr_req))? 3:0;           //若为外设请求，则arlen = 0, 否则arlen = 3
assign arsize  = 3'b010;                           //每次都读一个字（4bytes）
assign arburst = 2'b01;  
assign arlock  = 2'd0;
assign arcache = 4'd0;
assign arprot  = 3'd0;
assign arvalid = isReadRequring && !addr_Read_handed;
//读数据通道-准备好接收数据
assign rready  = 1'b1;

//写地址通道
assign awid    = 4'd0;
assign awaddr  = req_Write_addr;          
assign awlen   = isDataWriteReq ? 0:3;             //若为外设写请求，则arlen = 0, 否则arlen = 3
assign awsize  = 3'b010;                          //每次都写一个字（4bytes）
assign awburst = 2'b01;
assign awlock  = 2'd0;
assign awcache = 4'd0;
assign awprot  = 3'd0;
assign awvalid = (isWriteRequring && !addr_Write_handed);     //写地址有效 仅握手一次
//写数据通道
assign wid    = 4'd0;
assign wdata  = isVcmWriteReq ? vcm_wdata : data_wdata;
assign wstrb  = 4'b1111;                          //写一个字
assign wlast  = isVcmWriteReq ? vcm_wlast : 
                noCache? 1:
                (data_req && data_wr ? 0:1);        //要求cpu在发送数据期间保持请求状态 和 写数据状态，发射数据完成后可恢复
assign wvalid = (!data_handed) ? isWriteRequring: 
                isVcmWriteReq ? vcm_req:
                wlast? 1:0;                //在写数据传输过程中要求全程为高电平
//写响应通道
assign bready  = 1'b1;

assign vcm_wready = wready;


//ila_0 u_debug(
//    .clk(clk),
//    .probe0(data_wr),
//    .probe1(data_req),
//    .probe2(data_addr),
//    .probe3(data_wdata),
//    .probe4(awvalid),
//    .probe5(awready),
//    .probe6(wvalid),
//    .probe7(wready),
//    .probe8(bvalid),
//    .probe9(wdata)
//);

endmodule