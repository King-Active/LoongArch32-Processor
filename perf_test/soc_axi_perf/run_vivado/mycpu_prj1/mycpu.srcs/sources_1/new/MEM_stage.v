module MEM_stage(
    input      wire clk,
	input      wire rst,
    
    /*  ������ˮ���ķô�����  */
    input      wire [31:0]       addr,
    input      wire              mem_r,
    input      wire              mem_w,
    input      wire [31:0]       w_data,
    input      wire [3:0]        w_hcode,
    output     wire [31:0]       r_data,
    
    /*  ����sram�ӿڵĽ���  */
    output     wire             sram_data_en,
    output     wire  [3:0]      sram_data_wen,
    output     wire  [31:0]     sram_data_addr,
    output     wire  [31:0]     sram_data_wdata, 
    input      wire             sram_data_ok,
    input      wire             sram_addr_ok,
    input      wire  [31:0]     sram_data_rdata,
    
    //��ˮ����
    input      wire             exe_mem_en, //ִ�н׶�Ϊ�ô�ָ��
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
    
    wire  [31:0] st_wData;      //д����
    wire  [31:0] st_rData;      //������
    wire         buffer_hit;    //��ַ����
    wire         canEnter;      //�ɻ���store
    //issue
    wire         FIFO_en;       //��Ҫ����
    wire  [31:0] FIFO_addr;     //����store��ַ
    wire   [3:0] FIFO_wen;      //����store���루4'b1111��
    wire  [31:0] FIFO_wdata;    //����storeд����
    wire         FIFO_data_ok;  //�������
    
    assign instr_en = ((mem_r & ~buffer_hit) || (mem_w & ~canEnter));
    assign instr_wen = mem_w ? w_hcode : 4'b0000 ;
    
    assign instr_mem_stall = instr_en && ~instr_data_ok;
    assign fifo_mem_stall = ~instr_en && FIFO_en && ~FIFO_data_ok && exe_mem_en;
    
    assign r_data = instr_en ? instr_rdata :
                      buffer_hit ? st_rData : 32'b00000000;
    
/************** ����ָ���ж� **************/
conf_Judge u_conf_Judge(
            .data_vaddr(addr),
            .no_cache(instr_nocache)
    );
/******************************************/

storeBuffer u_storeBuffer(
    .clk(clk),
    .rst(rst),
    
    //��ˮ��
    .isStore(mem_w),     //storeָ��
    .w_hcode(w_hcode),   //������
    .instr_nocache(instr_nocache),  //������
    .st_addr(addr),   //��ַ
    .st_wData(w_data),  //д����
    .st_rData(st_rData), //������
    .buffer_hit(buffer_hit),    //��ַ����
    .canEnter(canEnter),      //�ɻ���store
    
    //issue
    .FIFO_en(FIFO_en),          //��Ҫ����
    .FIFO_addr(FIFO_addr),  //����store��ַ
    .FIFO_wen(FIFO_wen),   //����store���루4'b1111��
    .FIFO_wdata(FIFO_wdata), //����storeд����
    .FIFO_data_ok(FIFO_data_ok) //�������
);
    
Issue u_Issue(
    //����storeFIFO��ֻ������ �������store ָ��
    .FIFO_en(FIFO_en),     // ��ʾ�Ƿ���Ԫ����Ҫ���䣬����֤�ô���м��
    .FIFO_addr(FIFO_addr),
    .FIFO_wen(FIFO_wen),
    .FIFO_wdata(FIFO_wdata),
    .FIFO_data_ok(FIFO_data_ok),  
    
    //������ˮ�������ȼ����
    .instr_en(instr_en),
    .instr_addr(addr),
    .instr_wen(instr_wen),
    .instr_wdata(w_data),
    .instr_data_ok(instr_data_ok),     
    .instr_rdata(instr_rdata),
    .instr_nocache(instr_nocache),
    
    //���͸���sram�ӿ�
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
