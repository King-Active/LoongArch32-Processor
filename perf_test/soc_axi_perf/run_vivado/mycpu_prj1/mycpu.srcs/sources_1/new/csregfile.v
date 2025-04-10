module csregfile(
    input wire  clk,
    input wire  rst,
    
    //指令读写
    input wire  wen,
    input wire  ex_jump,
    input wire  exceptionW,
    input wire  ertnD,
    input wire  ertnW,
    input wire[13:0]  csr_r_addr,
    input wire[13:0]  csr_w_addr,
    input wire[31:0]  w_data,
    input wire[31:0]  Hcode,
    input wire[31:0]  instrW,
    output wire[31:0] r_data,
    output wire[31:0] EENTRY,
    
    //中断控制
    // SWI0, SWI1 由软件写入
    input wire HWI0,
    input wire HWI1,
    input wire HWI2,
    input wire HWI3,
    input wire HWI4,
    input wire HWI5,
    input wire HWI6,
    input wire HWI7,    // 硬中断
    //input wire TI      //定时器中断，这里定时器合并在csr中，不需要传入
    input wire IPI,     // 核间中断
    
    output wire int_ex,    // 中断例外
    
    input wire [31:0] eraW,
    input wire [5:0]  EcodeW,
    input wire        EsubCodeW,
    
    input wire [31:0] ALU_resultW   // 访存地址不对齐例外 对应的 错误虚地址
    );
    
    // 0~385 架构定义控制状态寄存器  5为例外状态ESTATE  66为定时器数值  386、387分别为低32位、高32位恒定频率计时器
    reg [31:0] rf[387:0]; 
       
    
    assign EENTRY = {rf[14'hc][31:6],6'b000000};
    
    wire if_hcode;
    assign if_hcode = !(instrW[9:6] == 4'b0000);
    
    /************************* csr读写掩码 *************************/
    wire [31:0] addr_r_hcode;     // 实现恒读为零的bit位，根据地址得到掩码，掩码为1读出为原值，为0读出为0
    assign addr_r_hcode = (csr_r_addr == 14'h44)? 32'h0000_0000 :    // 定时器中断清除位读 恒为0 
                          (csr_r_addr == 14'hc)? 32'hFFFF_FFC0 :     // EENTRY例外入口地址[5:0] 读恒为0
                          (csr_r_addr == 14'h20) ? 32'h0000_01FF:    // CPUID处理器编号仅前9位可读 --> CoreID
                           32'hFFFF_FFFF;
    
    wire [31:0] addr_w_hcode;     // 阻止软件指令不合理的写操作
    assign addr_w_hcode = (csr_w_addr == 14'h5)? 32'h0000_0003 :     // ESTAT 软件中断控制位可写[1:0]
                          (csr_w_addr == 14'hc)? 32'hFFFF_FFC0 :     // EENTRY例外入口地址仅[31:6]可写
                          (csr_w_addr == 14'h20) ? 32'h0000_0000:    // CPUID处理器编号不可写
                           32'hFFFF_FFFF;
    /************************* csr读写掩码 *************************/
                           
    /************************* 中断定时器 BEGIN *************************/
    // rf[14'h41] TCFG   定时器配置      [0] 定时器使能    [1] 循环控制   [31:2] 未补零的自减计数初始值
    // rf[14'h42] TVAL   定时器值        
    // rf[14'h44] TICLR  定时中断清除    读恒为0
    
    reg [1:0] ti_ex_state;
    wire ti_ex_en, periodic;
    reg TI;   // 定时中断脉冲信号，传送至中断控制器
    
    assign ti_ex_en = rf[14'h41][0];
    assign periodic = rf[14'h41][1];
    /************************* 中断定时器 BEGIN *************************/
    
    /************************* 中断控制器 BEGIN *************************/
   wire [11:0] int_vet;
   wire ti_clr;
   assign int_vet = { rf[14'h5][12:11], rf[14'h5][9:0] } & { rf[14'h4][12:11],rf[14'h4][9:0] };
   assign ti_clr = wen & ~exceptionW & (csr_w_addr == 32'h44) & (if_hcode ? (w_data[0] & Hcode[0]):(w_data[0]));
   // 全局使能 + 优先级过滤
   assign int_ex = (rf[14'h0][2] == 1'b0)? 0:
                         (|int_vet == 1'b0)? 0:1;       // int_vet 已然经过局部使能过滤
   /************************* 中断控制器 BEGIN *************************/
    
    integer i;
    always @(negedge clk,posedge rst) begin
        /************************* csr指令 + 例外标记 + ertn *************************/
        if(rst) begin
//            rf[14'h0][8:0] <= 9'b000001000;       // CRMD(1:0 PLV=0，2 IE=0，3 DA=1，4 PG=0，6:5 DATF=0，8:7 DATM=0, //31:9 0)
//            rf[14'h2][0] <= 1'b0;                 // EUEN(0 FPUen=0, //31:1 0)
//            rf[14'h4][9:0] <= 10'b0;              // ECFG(9:0 LIE=0)
//            rf[14'h41][0] <= 1'b0;                // TCFG(0 En=0)
//            rf[14'h60][2] <= 1'b0;                // LLBCTL(2 KLO=0)
//            rf[14'h5][10] <= 1'b0;
//            rf[14'h5][15:13] <= 3'b0;
//            rf[14'h5][31:22] <= 10'b0;            // Estat 保留域
//            rf[14'h5][1:0] <= 2'b00;              // 软中断
//            rf[14'h181][0] <= 1'b0;  
//            rf[14'h181][3] <= 1'b0;   
//            rf[14'h180][0] <= 1'b0;
//            rf[14'h180][3] <= 1'b0;              // DMW0~DMW1(0 PLV0=0, 3 PLV3=0)
//            rf[14'h44]     <= 32'b0;             // for func tesr
//            rf[14'h20]     <= 32'b0;    // 处理器编号（不可写）
//            rf[14'h40]     <= 32'b0;    // 定时器编号
            //备注：官方要求除了上述指定的内容外，复位撤销后，处理器中其它软件可见的寄存器的值都是不确定的，这里实现的并没有保证是不定态
            for(i=0;i<388;i=i+1)begin
                rf[i]     <= 32'b0;
            end            
            rf[14'h0][8:0] <= 9'b000001000;       // CRMD(1:0 PLV=0，2 IE=0，3 DA=1，4 PG=0，6:5 DATF=0，8:7 DATM=0, //31:9 0)
           
        end
    else begin
            if(csr_w_addr < 385 & wen & ~exceptionW & csr_w_addr != 14'h42  & csr_w_addr != 14'h182  & csr_w_addr != 14'h183) begin    // 地址有效的特权访问写指令     
                    rf[csr_w_addr] <= ((if_hcode ? (rf[csr_w_addr] & ~Hcode)|(w_data & Hcode) : w_data) & addr_w_hcode) |
                                      (rf[csr_w_addr]& ~addr_w_hcode) ;
            end
            
            if(exceptionW) begin                        // 来自 例外控制器
               rf[14'h0][2:0] <= 3'b0;                  // CRMD（PLV，IE） ←（0，0）
               
               rf[14'h1][2:0] <= rf[14'h0][2:0];        // PRMD（PPLV，PIE）← CRMD（PLV，IE）
    
               rf[14'h5][21:16] <=  EcodeW;            // Ecode
               rf[14'h5][30:22] <=  EsubCodeW;          // EsubCode
               
               //状态应该是与指令挂钩与estate不一样此处来自read_ram
               rf[14'h6] <= eraW;                   // ERA ← 触发例外指令的PC值
               
               // 若为 ADEF 或 ALE 例外，需要在 BADV 7号 CSR 寄存器 填写错误地址PC值
               if((EcodeW == 6'h8 && EsubCodeW == 0) || EcodeW == 6'h9) begin
                    rf[14'h7] <= ((EcodeW==6'h8)? eraW : ALU_resultW);
               end
            end
            
            else if(ertnW) begin
                rf[14'h0][2:0] <= rf[14'h1][2:0];           // CRMD（PLV，IE）← PRMD（PPLV，PIE）
                rf[14'h60] <= (rf[14'h60][2] != 1)? 32'b0:rf[14'h60];   
            end
            
        end
        /************************* csr指令 + 例外标记 + ertn *************************/
        
        
        /************************* 恒定频率计时器 Stable Counter *************************/
        if(rst) begin
                rf[14'h182]    <= 32'hFFFFFFF1;    // 低32位计时器
                rf[14'h183]    <= 32'h0;    // 高32位计时器
        end
        else begin
                {rf[14'h183],rf[14'h182]} <= {rf[14'h183],rf[14'h182]} + 1;
        end
        /************************* 恒定频率计时器 Stable Counter *************************/
        
        
        /************************* 中断定时器 BEGIN *************************/
        if(rst || !ti_ex_en) begin
            ti_ex_state <= 2'b00;
            TI <= 0;
            rf[14'h42] <= 32'b0;
        end
        
            else if(ti_ex_state == 2'b00)begin
            ti_ex_state <= 2'b01;
            rf[14'h42] <= {rf[14'h41][31:2],2'b00};
        end
        
        else if(ti_ex_state == 2'b01)begin
            if(rf[14'h42] == 32'b0) begin
                ti_ex_state <= 2'b10;
                TI <= 1'b1;
                rf[14'h42] <= {rf[14'h41][31:2],2'b00};
            end
            else begin
                rf[14'h42] <= rf[14'h42] - 1; 
            end
        end
        
        else if(ti_ex_state == 2'b10) begin
            if(!periodic) begin
                TI <= 0;
                rf[14'h42] <= 32'b0;
            end
            else begin
                ti_ex_state <= 2'b01;
                TI <= 0;
                rf[14'h42] <= rf[14'h42] - 1;
            end
        end
        /************************* 中断定时器 END *************************/
        
        /************************* 中断控制器 BEGIN *************************/
        // 采样中断信号，写 estate;  定时中断清除
        if(rst) rf[14'h5][11] <= 1'b0;  
        else if(ti_clr) rf[14'h5][11] <= 1'b0;
        else if(TI) rf[14'h5][11] <= 1'b1;
        
        if(rst) rf[14'h5][2] <= 1'b0;  
        else if (HWI0) rf[14'h5][2] <= 1'b1;
        
        if(rst) rf[14'h5][3] <= 1'b0;  
        else if (HWI1) rf[14'h5][3] <= 1'b1; 
        
        if(rst) rf[14'h5][4] <= 1'b0;  
        else if (HWI2) rf[14'h5][4] <= 1'b1;
        
        if(rst) rf[14'h5][5] <= 1'b0;  
        else if (HWI3) rf[14'h5][5] <= 1'b1;
        
        if(rst) rf[14'h5][6] <= 1'b0;  
        else if (HWI4) rf[14'h5][6] <= 1'b1;
        
        if(rst) rf[14'h5][7] <= 1'b0;  
        else if (HWI5) rf[14'h5][7] <= 1'b1; 
        
        if(rst) rf[14'h5][8] <= 1'b0;  
        else if (HWI6) rf[14'h5][8] <= 1'b1;  
        
        if(rst) rf[14'h5][9] <= 1'b0;  
        else if (HWI7) rf[14'h5][9] <= 1'b1;   
        
        if(rst) rf[14'h5][12] <= 1'b0;  
        else if (IPI) rf[14'h5][12] <= 1'b1;
        /************************* 中断控制器 END *************************/
        
       end
    
    assign r_data =  ( ertnD ? rf[14'h6] :
                       (csr_r_addr > 387 || csr_r_addr == 32'h44) ? 32'b0 : rf[csr_r_addr] ) //地址有效的特权访问指令： 读出对应旧值
                     & addr_r_hcode;    //控制读恒为零的bit位
    //还要再添加一个选择，选择etrn返回，
    //并且在etrn返回时还需要修改译码，得直接增添一位辨识位，其他差不多。
   

endmodule