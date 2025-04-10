module csregfile(
    input wire  clk,
    input wire  rst,
    
    //ָ���д
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
    
    //�жϿ���
    // SWI0, SWI1 �����д��
    input wire HWI0,
    input wire HWI1,
    input wire HWI2,
    input wire HWI3,
    input wire HWI4,
    input wire HWI5,
    input wire HWI6,
    input wire HWI7,    // Ӳ�ж�
    //input wire TI      //��ʱ���жϣ����ﶨʱ���ϲ���csr�У�����Ҫ����
    input wire IPI,     // �˼��ж�
    
    output wire int_ex,    // �ж�����
    
    input wire [31:0] eraW,
    input wire [5:0]  EcodeW,
    input wire        EsubCodeW,
    
    input wire [31:0] ALU_resultW   // �ô��ַ���������� ��Ӧ�� �������ַ
    );
    
    // 0~385 �ܹ��������״̬�Ĵ���  5Ϊ����״̬ESTATE  66Ϊ��ʱ����ֵ  386��387�ֱ�Ϊ��32λ����32λ�㶨Ƶ�ʼ�ʱ��
    reg [31:0] rf[387:0]; 
       
    
    assign EENTRY = {rf[14'hc][31:6],6'b000000};
    
    wire if_hcode;
    assign if_hcode = !(instrW[9:6] == 4'b0000);
    
    /************************* csr��д���� *************************/
    wire [31:0] addr_r_hcode;     // ʵ�ֺ��Ϊ���bitλ�����ݵ�ַ�õ����룬����Ϊ1����Ϊԭֵ��Ϊ0����Ϊ0
    assign addr_r_hcode = (csr_r_addr == 14'h44)? 32'h0000_0000 :    // ��ʱ���ж����λ�� ��Ϊ0 
                          (csr_r_addr == 14'hc)? 32'hFFFF_FFC0 :     // EENTRY������ڵ�ַ[5:0] ����Ϊ0
                          (csr_r_addr == 14'h20) ? 32'h0000_01FF:    // CPUID��������Ž�ǰ9λ�ɶ� --> CoreID
                           32'hFFFF_FFFF;
    
    wire [31:0] addr_w_hcode;     // ��ֹ���ָ������д����
    assign addr_w_hcode = (csr_w_addr == 14'h5)? 32'h0000_0003 :     // ESTAT ����жϿ���λ��д[1:0]
                          (csr_w_addr == 14'hc)? 32'hFFFF_FFC0 :     // EENTRY������ڵ�ַ��[31:6]��д
                          (csr_w_addr == 14'h20) ? 32'h0000_0000:    // CPUID��������Ų���д
                           32'hFFFF_FFFF;
    /************************* csr��д���� *************************/
                           
    /************************* �ж϶�ʱ�� BEGIN *************************/
    // rf[14'h41] TCFG   ��ʱ������      [0] ��ʱ��ʹ��    [1] ѭ������   [31:2] δ������Լ�������ʼֵ
    // rf[14'h42] TVAL   ��ʱ��ֵ        
    // rf[14'h44] TICLR  ��ʱ�ж����    ����Ϊ0
    
    reg [1:0] ti_ex_state;
    wire ti_ex_en, periodic;
    reg TI;   // ��ʱ�ж������źţ��������жϿ�����
    
    assign ti_ex_en = rf[14'h41][0];
    assign periodic = rf[14'h41][1];
    /************************* �ж϶�ʱ�� BEGIN *************************/
    
    /************************* �жϿ����� BEGIN *************************/
   wire [11:0] int_vet;
   wire ti_clr;
   assign int_vet = { rf[14'h5][12:11], rf[14'h5][9:0] } & { rf[14'h4][12:11],rf[14'h4][9:0] };
   assign ti_clr = wen & ~exceptionW & (csr_w_addr == 32'h44) & (if_hcode ? (w_data[0] & Hcode[0]):(w_data[0]));
   // ȫ��ʹ�� + ���ȼ�����
   assign int_ex = (rf[14'h0][2] == 1'b0)? 0:
                         (|int_vet == 1'b0)? 0:1;       // int_vet ��Ȼ�����ֲ�ʹ�ܹ���
   /************************* �жϿ����� BEGIN *************************/
    
    integer i;
    always @(negedge clk,posedge rst) begin
        /************************* csrָ�� + ������ + ertn *************************/
        if(rst) begin
//            rf[14'h0][8:0] <= 9'b000001000;       // CRMD(1:0 PLV=0��2 IE=0��3 DA=1��4 PG=0��6:5 DATF=0��8:7 DATM=0, //31:9 0)
//            rf[14'h2][0] <= 1'b0;                 // EUEN(0 FPUen=0, //31:1 0)
//            rf[14'h4][9:0] <= 10'b0;              // ECFG(9:0 LIE=0)
//            rf[14'h41][0] <= 1'b0;                // TCFG(0 En=0)
//            rf[14'h60][2] <= 1'b0;                // LLBCTL(2 KLO=0)
//            rf[14'h5][10] <= 1'b0;
//            rf[14'h5][15:13] <= 3'b0;
//            rf[14'h5][31:22] <= 10'b0;            // Estat ������
//            rf[14'h5][1:0] <= 2'b00;              // ���ж�
//            rf[14'h181][0] <= 1'b0;  
//            rf[14'h181][3] <= 1'b0;   
//            rf[14'h180][0] <= 1'b0;
//            rf[14'h180][3] <= 1'b0;              // DMW0~DMW1(0 PLV0=0, 3 PLV3=0)
//            rf[14'h44]     <= 32'b0;             // for func tesr
//            rf[14'h20]     <= 32'b0;    // ��������ţ�����д��
//            rf[14'h40]     <= 32'b0;    // ��ʱ�����
            //��ע���ٷ�Ҫ���������ָ���������⣬��λ�����󣬴���������������ɼ��ļĴ�����ֵ���ǲ�ȷ���ģ�����ʵ�ֵĲ�û�б�֤�ǲ���̬
            for(i=0;i<388;i=i+1)begin
                rf[i]     <= 32'b0;
            end            
            rf[14'h0][8:0] <= 9'b000001000;       // CRMD(1:0 PLV=0��2 IE=0��3 DA=1��4 PG=0��6:5 DATF=0��8:7 DATM=0, //31:9 0)
           
        end
    else begin
            if(csr_w_addr < 385 & wen & ~exceptionW & csr_w_addr != 14'h42  & csr_w_addr != 14'h182  & csr_w_addr != 14'h183) begin    // ��ַ��Ч����Ȩ����дָ��     
                    rf[csr_w_addr] <= ((if_hcode ? (rf[csr_w_addr] & ~Hcode)|(w_data & Hcode) : w_data) & addr_w_hcode) |
                                      (rf[csr_w_addr]& ~addr_w_hcode) ;
            end
            
            if(exceptionW) begin                        // ���� ���������
               rf[14'h0][2:0] <= 3'b0;                  // CRMD��PLV��IE�� ����0��0��
               
               rf[14'h1][2:0] <= rf[14'h0][2:0];        // PRMD��PPLV��PIE���� CRMD��PLV��IE��
    
               rf[14'h5][21:16] <=  EcodeW;            // Ecode
               rf[14'h5][30:22] <=  EsubCodeW;          // EsubCode
               
               //״̬Ӧ������ָ��ҹ���estate��һ���˴�����read_ram
               rf[14'h6] <= eraW;                   // ERA �� ��������ָ���PCֵ
               
               // ��Ϊ ADEF �� ALE ���⣬��Ҫ�� BADV 7�� CSR �Ĵ��� ��д�����ַPCֵ
               if((EcodeW == 6'h8 && EsubCodeW == 0) || EcodeW == 6'h9) begin
                    rf[14'h7] <= ((EcodeW==6'h8)? eraW : ALU_resultW);
               end
            end
            
            else if(ertnW) begin
                rf[14'h0][2:0] <= rf[14'h1][2:0];           // CRMD��PLV��IE���� PRMD��PPLV��PIE��
                rf[14'h60] <= (rf[14'h60][2] != 1)? 32'b0:rf[14'h60];   
            end
            
        end
        /************************* csrָ�� + ������ + ertn *************************/
        
        
        /************************* �㶨Ƶ�ʼ�ʱ�� Stable Counter *************************/
        if(rst) begin
                rf[14'h182]    <= 32'hFFFFFFF1;    // ��32λ��ʱ��
                rf[14'h183]    <= 32'h0;    // ��32λ��ʱ��
        end
        else begin
                {rf[14'h183],rf[14'h182]} <= {rf[14'h183],rf[14'h182]} + 1;
        end
        /************************* �㶨Ƶ�ʼ�ʱ�� Stable Counter *************************/
        
        
        /************************* �ж϶�ʱ�� BEGIN *************************/
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
        /************************* �ж϶�ʱ�� END *************************/
        
        /************************* �жϿ����� BEGIN *************************/
        // �����ж��źţ�д estate;  ��ʱ�ж����
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
        /************************* �жϿ����� END *************************/
        
       end
    
    assign r_data =  ( ertnD ? rf[14'h6] :
                       (csr_r_addr > 387 || csr_r_addr == 32'h44) ? 32'b0 : rf[csr_r_addr] ) //��ַ��Ч����Ȩ����ָ� ������Ӧ��ֵ
                     & addr_r_hcode;    //���ƶ���Ϊ���bitλ
    //��Ҫ�����һ��ѡ��ѡ��etrn���أ�
    //������etrn����ʱ����Ҫ�޸����룬��ֱ������һλ��ʶλ��������ࡣ
   

endmodule