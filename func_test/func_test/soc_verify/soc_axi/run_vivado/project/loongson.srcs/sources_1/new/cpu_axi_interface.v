module cpu_axi_interface
(   
//�Ƿ����пմ��������״̬: �ӿ�ʼ���� -> ���һ�����ݲ������
    output reg isWriteRequring,
    output reg isReadRequring,
    input wire noCache,     //�����ź�

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
    output wire        instr_data_ok ,   //ֻ��
    
    //data sram-like 
    input wire         data_req     ,
    input wire         data_wr      ,
    input wire  [1 :0] data_size    ,
    input wire  [31:0] data_addr    ,
    input wire  [31:0] data_wdata   ,
    output wire [31:0] data_rdata   ,
    output wire        data_addr_ok ,
    output wire        data_data_ok ,    //   ��д

    //data victim_cache
    input wire         vcm_req     ,
    input wire         vcm_wr      ,  //��Ϊ1
    input wire  [1 :0] vcm_size    ,  
    input wire  [31:0] vcm_addr    ,  //�����ݵ�ַ
    input wire  [31:0] vcm_wdata   ,  //������
    output wire [31:0] vcm_rdata   ,  //��Ч
    output reg         vcm_addr_ok ,  
    output wire        vcm_data_ok ,    //ֻд
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

//�Ƿ�Ϊ�������͵������������ȼ����ߣ� �ڱ����������������
reg isDataWriteReq;
reg isDataReadReq;
//�Ƿ�Ϊvictimcache�������������ȼ���д��������ߣ� �ڱ����������������
reg isVcmWriteReq;
//��ʾ��ǰ���� ���������ڽ����� �� д��������ɣ����һ��������д�룩
wire final_Write_responding;
wire final_Read_responding;
// ��axi��ַ���ֳɹ� -> ���һ�����ݲ������
reg addr_Write_handed;
reg addr_Read_handed;
//  ��axiд�������ֳɹ� ->  ���һ�����ݴ������
reg data_handed;
//ͨ��isWriteRequring �� isReadRequring �ж϶�дͨ���Ƿ��й���
reg [31:0] req_Write_addr;       
reg [31:0] req_Read_addr;       


always@(posedge clk) begin
    if(!rst)
        isWriteRequring <= 1'b0;
    else if(((data_req && data_wr)||(vcm_req && vcm_wr))&&!isWriteRequring) 
        isWriteRequring <= 1'b1;         //һ��������ɺ� ����һ��
    else if(final_Write_responding && bvalid)
        isWriteRequring <= 1'b0;        //�����Ӧ�׶Σ��ҵ����յ㣬��һ�Ŀ���
    else
        isWriteRequring <= isWriteRequring;
end

always@(posedge clk) begin
    if(!rst)
        isReadRequring <= 1'b0;
    else if(((data_req && !data_wr)||(instr_req && !instr_wr))&&!isReadRequring) 
        isReadRequring <= 1'b1;         //һ��������ɺ� ����һ��
    else if(final_Read_responding && rvalid)
        isReadRequring <= 1'b0;        //�����Ӧ�׶Σ��ҵ����յ㣬��һ�Ŀ���
    else
        isReadRequring <= isReadRequring;
end

always@(posedge clk) begin
    if(!rst)
        isDataWriteReq <= 1'b0;
    else if((!isWriteRequring || bvalid) && !vcm_req)
        isDataWriteReq <= (data_req && data_wr) ;  //�������У���vcmδ������дͨ������data
    else
        isDataWriteReq <= isDataWriteReq; //�����У������������Ͳ���
end

always@(posedge clk) begin
    if(!rst)
        isDataReadReq <= 1'b0;
    else if((!isReadRequring || rlast))
        isDataReadReq <= (data_req && !data_wr);  //�������У����ͨ����������data
    else
        isDataReadReq <= isDataReadReq; //�����У������������Ͳ���
end

always@(posedge clk) begin
    if(!rst)
        isVcmWriteReq <= 1'b0;
    else if(!isWriteRequring || bvalid)
        isVcmWriteReq <= (vcm_req && vcm_wr);  //�������У�дͨ����������victimcache
    else
        isVcmWriteReq <= isVcmWriteReq; //�����У������������Ͳ���
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

//����data�����У�д���������ȼ����
always@(posedge clk) begin 
    vcm_addr_ok <= vcm_req && !isWriteRequring;    //�ڿ����£���ѡvcm����д����
end
//���ȼ��θߣ�����ַ �� д��ַ ���ֳɹ�
assign data_addr_ok =  (data_wr && (vcm_req && data_req ? 0:data_req)) ||
                       (data_req && !data_wr);       //ֻ�е�vcm��data��ͬ����дʱ��dataʧ��
//���ȼ����
assign instr_addr_ok = (instr_req && data_req && !data_wr ? 0:instr_req);   //��data���ж�����ʱʧ��


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

//instr���������ڷ����У������� 4 ��
assign instr_data_ok = isReadRequring && !isDataReadReq && rvalid;
//victimCache��д�����ź�
assign vcm_data_ok   = isWriteRequring && isVcmWriteReq && final_Write_responding;
//Data���������ڷ����У������� 4 �� �� 1 ��
assign data_data_ok  = (isReadRequring && isDataReadReq && rvalid) ||
                       (isWriteRequring && !isVcmWriteReq && isDataWriteReq && final_Write_responding);

assign instr_rdata   = rdata;
assign data_rdata   = rdata;

//����ַͨ��
assign arid    = 4'd0;
assign araddr  = req_Read_addr;
assign arlen   = (isReadRequring && (~noCache || instr_req))? 3:0;           //��Ϊ����������arlen = 0, ����arlen = 3
assign arsize  = 3'b010;                           //ÿ�ζ���һ���֣�4bytes��
assign arburst = 2'b01;  
assign arlock  = 2'd0;
assign arcache = 4'd0;
assign arprot  = 3'd0;
assign arvalid = isReadRequring && !addr_Read_handed;
//������ͨ��-׼���ý�������
assign rready  = 1'b1;

//д��ַͨ��
assign awid    = 4'd0;
assign awaddr  = req_Write_addr;          
assign awlen   = isDataWriteReq ? 0:3;             //��Ϊ����д������arlen = 0, ����arlen = 3
assign awsize  = 3'b010;                          //ÿ�ζ�дһ���֣�4bytes��
assign awburst = 2'b01;
assign awlock  = 2'd0;
assign awcache = 4'd0;
assign awprot  = 3'd0;
assign awvalid = (isWriteRequring && !addr_Write_handed);     //д��ַ��Ч ������һ��
//д����ͨ��
assign wid    = 4'd0;
assign wdata  = isVcmWriteReq ? vcm_wdata : data_wdata;
assign wstrb  = 4'b1111;                          //дһ����
assign wlast  = isVcmWriteReq ? vcm_wlast : 
                noCache? 1:
                (data_req && data_wr ? 0:1);        //Ҫ��cpu�ڷ��������ڼ䱣������״̬ �� д����״̬������������ɺ�ɻָ�
assign wvalid = (!data_handed) ? isWriteRequring: 
                isVcmWriteReq ? vcm_req:
                wlast? 1:0;                //��д���ݴ��������Ҫ��ȫ��Ϊ�ߵ�ƽ
//д��Ӧͨ��
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