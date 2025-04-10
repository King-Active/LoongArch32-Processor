`define TAG_WIDTH 23   
`define INDEX_WIDTH 5
`define INDEX_DEPTH 32

`timescale 1ns / 1ps

module cache(
    input wire clk, rst,
    /*  ����cache�ķô潻��  */
    input   wire                ram_data_req          ,
    input   wire                ram_data_wr           ,
    input   wire [1 :0]         ram_data_size         ,
    input   wire [31:0]         ram_data_addr         ,
    input   wire [31:0]         ram_data_wdata        ,
    output  wire [31:0]         cache_ram_data_rdata        ,
    output  wire                cache_ram_data_addr_ok      ,
    output  reg                 cache_ram_data_data_ok      ,
    
    /*  ���͸� AXI���ߵ� д�ô潻�� */
    output  wire                cache_data_req          ,
    output  wire                cache_data_wr           ,
    output  wire [1 :0]         cache_data_size         ,
    output  wire [31:0]         cache_data_addr         ,
    output  wire [31:0]         cache_data_wdata        ,
    input   wire [31:0]         cache_data_rdata        ,
    input   wire                cache_data_addr_ok      ,
    input   wire                cache_data_data_ok      ,
    
    output  wire                addDirtyReq             ,
    output  wire [127:0]        DirtyBlock              ,
    output  wire [31:0]         DirtyAddr               ,
    input   wire                AcptDirty               ,
    
    input   wire                vcm_ram_data_data_ok
    );
    
    reg [3:0]    s;
    
    wire [`TAG_WIDTH-1:0]   tag_;       // ��ǰ����ı��
    wire [`INDEX_WIDTH-1:0] idx_;       // ��ǰ���������
    wire [1:0]              word_;      // ��ǰ�������ƫ�ƣ�����ƫ�ƣ�
    wire [1:0]              byte_;
    
    reg [`TAG_WIDTH-1:0]    tag_way0    [`INDEX_DEPTH-1:0]; 
    reg [`TAG_WIDTH-1:0]    tag_way1    [`INDEX_DEPTH-1:0];
    reg [`TAG_WIDTH-1:0]    tag_way2    [`INDEX_DEPTH-1:0];
    reg [`TAG_WIDTH-1:0]    tag_way3    [`INDEX_DEPTH-1:0];
   
    reg [`INDEX_DEPTH-1:0]  valid_way0                    ; 
    reg [`INDEX_DEPTH-1:0]  valid_way1                    ;
    reg [`INDEX_DEPTH-1:0]  valid_way2                    ;
    reg [`INDEX_DEPTH-1:0]  valid_way3                    ;
    
    reg [`INDEX_DEPTH-1:0]  dirty_way0                    ; 
    reg [`INDEX_DEPTH-1:0]  dirty_way1                    ;
    reg [`INDEX_DEPTH-1:0]  dirty_way2                    ;
    reg [`INDEX_DEPTH-1:0]  dirty_way3                    ;
    
    reg [2:0]               lru         [`INDEX_DEPTH-1:0];
    
    assign { tag_, idx_, word_, byte_ } = ram_data_addr;
    
    reg   [15:0]  wen_           ; // д��·�ĸ���cache��ʹ���ź�
    reg   [31:0]  w_data_        ; // дĳ·��ĳ�������
    reg   [1:0]   wHcode_        ; // дĳ·��ĳ�������
    reg   [1:0]   ofst_          ; // дĳ·��ĳ����ֽ�ƫ��
    
    wire  [31:0]  rdata_way0_mem0, rdata_way0_mem1, rdata_way0_mem2, rdata_way0_mem3;
    wire  [31:0]  rdata_way1_mem0, rdata_way1_mem1, rdata_way1_mem2, rdata_way1_mem3;
    wire  [31:0]  rdata_way2_mem0, rdata_way2_mem1, rdata_way2_mem2, rdata_way2_mem3;
    wire  [31:0]  rdata_way3_mem0, rdata_way3_mem1, rdata_way3_mem2, rdata_way3_mem3;
    
    cache_way way0_mem0 ( clk, idx_, w_data_, wen_[15], wHcode_, ofst_, rdata_way0_mem0 );
    cache_way way0_mem1 ( clk, idx_, w_data_, wen_[14], wHcode_, ofst_, rdata_way0_mem1 );
    cache_way way0_mem2 ( clk, idx_, w_data_, wen_[13], wHcode_, ofst_, rdata_way0_mem2 );
    cache_way way0_mem3 ( clk, idx_, w_data_, wen_[12], wHcode_, ofst_, rdata_way0_mem3 );
    
    cache_way way1_mem0 ( clk, idx_, w_data_, wen_[11], wHcode_, ofst_, rdata_way1_mem0 );
    cache_way way1_mem1 ( clk, idx_, w_data_, wen_[10], wHcode_, ofst_, rdata_way1_mem1 );
    cache_way way1_mem2 ( clk, idx_, w_data_, wen_[9 ], wHcode_, ofst_, rdata_way1_mem2 );
    cache_way way1_mem3 ( clk, idx_, w_data_, wen_[8 ], wHcode_, ofst_, rdata_way1_mem3 );
    
    cache_way way2_mem0 ( clk, idx_, w_data_, wen_[7 ], wHcode_, ofst_, rdata_way2_mem0 );
    cache_way way2_mem1 ( clk, idx_, w_data_, wen_[6 ], wHcode_, ofst_, rdata_way2_mem1 );
    cache_way way2_mem2 ( clk, idx_, w_data_, wen_[5 ], wHcode_, ofst_, rdata_way2_mem2 );
    cache_way way2_mem3 ( clk, idx_, w_data_, wen_[4 ], wHcode_, ofst_, rdata_way2_mem3 );
    
    cache_way way3_mem0 ( clk, idx_, w_data_, wen_[3 ], wHcode_, ofst_, rdata_way3_mem0 );
    cache_way way3_mem1 ( clk, idx_, w_data_, wen_[2 ], wHcode_, ofst_, rdata_way3_mem1 );
    cache_way way3_mem2 ( clk, idx_, w_data_, wen_[1 ], wHcode_, ofst_, rdata_way3_mem2 );
    cache_way way3_mem3 ( clk, idx_, w_data_, wen_[0 ], wHcode_, ofst_, rdata_way3_mem3 );
    
    wire  hit_way0, hit_way1, hit_way2, hit_way3, miss;
    
    assign  hit_way0  =  valid_way0[idx_] & (tag_ == tag_way0[idx_]);       // ���Ƿ�����������ж� --����--> ����dCache
    assign  hit_way1  =  valid_way1[idx_] & (tag_ == tag_way1[idx_]);
    assign  hit_way2  =  valid_way2[idx_] & (tag_ == tag_way2[idx_]);
    assign  hit_way3  =  valid_way3[idx_] & (tag_ == tag_way3[idx_]);
    assign  miss      =  ~(hit_way0 | hit_way1 | hit_way2 | hit_way3);
    
    assign  cache_ram_data_addr_ok = ram_data_req;
        
    assign  cache_ram_data_rdata   = (s==4'b1110 & ~ram_data_wr & word_==2'b11)? cache_data_rdata:
                                     hit_way0? 
                                        (word_==2'b00)? rdata_way0_mem0:
                                        (word_==2'b01)? rdata_way0_mem1:
                                        (word_==2'b10)? rdata_way0_mem2:rdata_way0_mem3
                                     :
                                     hit_way1? 
                                        (word_==2'b00)? rdata_way1_mem0:
                                        (word_==2'b01)? rdata_way1_mem1:
                                        (word_==2'b10)? rdata_way1_mem2:rdata_way1_mem3
                                     :
                                     hit_way2? 
                                        (word_==2'b00)? rdata_way2_mem0:
                                        (word_==2'b01)? rdata_way2_mem1:
                                        (word_==2'b10)? rdata_way2_mem2:rdata_way2_mem3
                                     :
                                     hit_way3? 
                                        (word_==2'b00)? rdata_way3_mem0:
                                        (word_==2'b01)? rdata_way3_mem1:
                                        (word_==2'b10)? rdata_way3_mem2:rdata_way3_mem3
                                     : 32'b0;
   
   
/******************** lru�����㷨 ********************/
    wire [1:0]   old_way;
    
    integer i;                         
    always@(posedge clk) begin
        if(!rst) begin
            for (i = 0; i < `INDEX_DEPTH; i = i + 1) begin
                lru[i] <= 3'b000;  
            end
        end
        // ����ʱ��ֱ���޸�
        // ȱʧʱ�������ݴӴ洢��ȡ�غ󷽲��޸�
        else if(ram_data_req & ~miss & (s != 3'b001 & s != 3'b011 & s != 3'b111 & s != 3'b110)) begin
            if(hit_way0) begin
                lru[idx_] <= {2'b11, lru[idx_][2]};
            end
            else if(hit_way1) begin
                lru[idx_] <= {2'b10, lru[idx_][2]};
            end
            else if(hit_way2) begin
                lru[idx_] <= {1'b0, lru[idx_][1], 1'b1};
            end
            else if(hit_way3) begin
                lru[idx_] <= {1'b0, lru[idx_][1], 1'b0};
            end
            else begin
                lru[idx_] <= lru[idx_];
            end
        end
        else begin
            lru[idx_] <= lru[idx_];
        end
    end
    
    assign old_way = lru[idx_][0]? 
                        lru[idx_][2]? 2'b11:2'b10
                        :
                        lru[idx_][1]? 2'b01:2'b00;
/*****************************************************/ 



/********************  AXI������  ********************/

   // ����AXI����������cpu�зô����� �� �ô�ȱʧ �� ��λ������ �� ����д��vcm������ʹ��Ч
   assign cache_data_req     =      ram_data_req & miss & ( (old_way==2'b00 & ~dirty_way0[idx_]) |
                                                            (old_way==2'b01 & ~dirty_way1[idx_]) |
                                                            (old_way==2'b10 & ~dirty_way2[idx_]) | 
                                                            (old_way==2'b11 & ~dirty_way3[idx_]) );
   assign cache_data_wr      =      1'b0;
   assign cache_data_size    =      2'b11;
   assign cache_data_addr    =      { ram_data_addr[31:4], 4'b0 };
   assign cache_data_wdata   =      32'b0;  // ��Ч
   
/*****************************************************/    
   
   
/********************  ������д��vcm����  ********************/

   // ����������������cpu�зô����� �� �ô�ȱʧ �� ��λ��Ч����δ��vcm��
   assign addDirtyReq        =      ~vcm_ram_data_data_ok & ram_data_req & miss & ( (old_way==2'b00 & valid_way0[idx_] & dirty_way0[idx_]) |
                                                            (old_way==2'b01 & valid_way1[idx_] & dirty_way1[idx_]) |
                                                            (old_way==2'b10 & valid_way2[idx_] & dirty_way2[idx_]) | 
                                                            (old_way==2'b11 & valid_way3[idx_] & dirty_way3[idx_]) );
                                                            
   assign DirtyBlock         =      (old_way==2'b00)? { rdata_way0_mem3, rdata_way0_mem2, rdata_way0_mem1, rdata_way0_mem0} :
                                    (old_way==2'b01)? { rdata_way1_mem3, rdata_way1_mem2, rdata_way1_mem1, rdata_way1_mem0} :
                                    (old_way==2'b10)? { rdata_way2_mem3, rdata_way2_mem2, rdata_way2_mem1, rdata_way2_mem0} :
                                    (old_way==2'b11)? { rdata_way3_mem3, rdata_way3_mem2, rdata_way3_mem1, rdata_way3_mem0} : 127'b0;
                                    
   assign DirtyAddr          =      (old_way==2'b00)? { tag_way0[idx_], idx_, 4'b0000 } :
                                    (old_way==2'b01)? { tag_way1[idx_], idx_, 4'b0000 } :
                                    (old_way==2'b10)? { tag_way2[idx_], idx_, 4'b0000 } :
                                    (old_way==2'b11)? { tag_way3[idx_], idx_, 4'b0000 } : 32'b0;
/*****************************************************/    

   always@(posedge clk) begin
        if(!rst) begin
            valid_way0 <=  `INDEX_DEPTH'b0 ;  
            valid_way1 <=  `INDEX_DEPTH'b0 ;
            valid_way2 <=  `INDEX_DEPTH'b0 ;
            valid_way3 <=  `INDEX_DEPTH'b0 ;
            dirty_way0 <=  `INDEX_DEPTH'b0 ;
            dirty_way1 <=  `INDEX_DEPTH'b0 ;
            dirty_way2 <=  `INDEX_DEPTH'b0 ;
            dirty_way3 <=  `INDEX_DEPTH'b0 ;
            for(i=0; i<`INDEX_DEPTH; i=i+1) begin
                tag_way0[i] <= `TAG_WIDTH'b0;
                tag_way1[i] <= `TAG_WIDTH'b0;
                tag_way2[i] <= `TAG_WIDTH'b0;
                tag_way3[i] <= `TAG_WIDTH'b0;
            end
        end
        else begin
            // �����ݿ�д��, vcm����ʱ��׼д������Ч
            if(addDirtyReq & AcptDirty & ~vcm_ram_data_data_ok) begin
                case(old_way)
                    2'b00: begin
                              valid_way0[idx_] <= 1'b0;
                              dirty_way0[idx_] <= 1'b0;
                           end
                    2'b01: begin
                              valid_way1[idx_] <= 1'b0;    
                              dirty_way1[idx_] <= 1'b0;
                           end
                    2'b10: begin
                              valid_way2[idx_] <= 1'b0;
                              dirty_way2[idx_] <= 1'b0;
                           end
                    2'b11: begin
                              valid_way3[idx_] <= 1'b0;
                              dirty_way3[idx_] <= 1'b0;
                           end
                    default: begin
                              valid_way0[idx_] <= valid_way0[idx_];
                              valid_way1[idx_] <= valid_way1[idx_];
                              valid_way2[idx_] <= valid_way2[idx_];
                              valid_way3[idx_] <= valid_way3[idx_]; 
                              dirty_way0[idx_] <= dirty_way0[idx_];
                              dirty_way1[idx_] <= dirty_way1[idx_];
                              dirty_way2[idx_] <= dirty_way2[idx_];
                              dirty_way3[idx_] <= dirty_way3[idx_]; 
                             end
                 endcase
            end
            // ȱʧʱ�������ݼ��ؽ���
            else if(ram_data_req & cache_data_data_ok) begin
                case(old_way)
                    2'b00: begin
                              valid_way0[idx_] <= 1'b1;
                              dirty_way0[idx_] <= 1'b0;
                              tag_way0[idx_]   <= tag_;
                           end
                    2'b01: begin
                              valid_way1[idx_] <= 1'b1;    
                              dirty_way1[idx_] <= 1'b0;
                              tag_way1[idx_]   <= tag_;
                           end
                    2'b10: begin
                              valid_way2[idx_] <= 1'b1;
                              dirty_way2[idx_] <= 1'b0;
                              tag_way2[idx_]   <= tag_;
                           end
                    2'b11: begin
                              valid_way3[idx_] <= 1'b1;
                              dirty_way3[idx_] <= 1'b0;
                              tag_way3[idx_]   <= tag_;
                           end
                    default: begin
                              valid_way0[idx_] <= valid_way0[idx_];
                              valid_way1[idx_] <= valid_way1[idx_];
                              valid_way2[idx_] <= valid_way2[idx_];
                              valid_way3[idx_] <= valid_way3[idx_]; 
                              dirty_way0[idx_] <= dirty_way0[idx_];
                              dirty_way1[idx_] <= dirty_way1[idx_];
                              dirty_way2[idx_] <= dirty_way2[idx_];
                              dirty_way3[idx_] <= dirty_way3[idx_];
                              tag_way0[idx_]   <= tag_way0[idx_];
                              tag_way1[idx_]   <= tag_way1[idx_];
                              tag_way2[idx_]   <= tag_way2[idx_];
                              tag_way3[idx_]   <= tag_way3[idx_];
                             end
                 endcase
            end
            
            // ȡ��ȱʧ��ִ��store
            else if(s == 4'b1110 & ram_data_wr) begin
                case(old_way)
                    2'b00: begin
                              dirty_way0[idx_] <= 1'b1;
                           end
                    2'b01: begin
                              dirty_way1[idx_] <= 1'b1;    
                           end
                    2'b10: begin
                              dirty_way2[idx_] <= 1'b1;
                           end
                    2'b11: begin
                              dirty_way3[idx_] <= 1'b1;
                           end
                    default: begin
                              dirty_way0[idx_] <= dirty_way0[idx_];
                              dirty_way1[idx_] <= dirty_way1[idx_];
                              dirty_way2[idx_] <= dirty_way2[idx_];
                              dirty_way3[idx_] <= dirty_way3[idx_]; 
                             end
                    endcase
            end
            // ֱ������
            else if(s == 4'b0000 & ram_data_req & ~miss & ram_data_wr) begin
                if(hit_way0)        dirty_way0[idx_] <= 1'b1;
                else if(hit_way1)   dirty_way1[idx_] <= 1'b1; 
                else if(hit_way2)   dirty_way2[idx_] <= 1'b1;
                else                dirty_way3[idx_] <= 1'b1;
            end
            
            else begin
                valid_way0[idx_] <= valid_way0[idx_];
                valid_way1[idx_] <= valid_way1[idx_];
                valid_way2[idx_] <= valid_way2[idx_];
                valid_way3[idx_] <= valid_way3[idx_]; 
                dirty_way0[idx_] <= dirty_way0[idx_];
                dirty_way1[idx_] <= dirty_way1[idx_];
                dirty_way2[idx_] <= dirty_way2[idx_];
                dirty_way3[idx_] <= dirty_way3[idx_];
                tag_way0[idx_]   <= tag_way0[idx_];
                tag_way1[idx_]   <= tag_way1[idx_];
                tag_way2[idx_]   <= tag_way2[idx_];
                tag_way3[idx_]   <= tag_way3[idx_];
            end 
        end
   end
   
   wire [15:0]  _wen_;  // ������һ·���ĸ���
   assign _wen_ =  ~ram_data_wr? 0:
                   (word_ == 2'b00) ? 
                        (hit_way0 ? 16'b1000_0000_0000_0000 : 
                         hit_way1 ? 16'b0000_1000_0000_0000 : 
                         hit_way2 ? 16'b0000_0000_1000_0000 : 
                         hit_way3 ? 16'b0000_0000_0000_1000 : 16'b0) :
                   (word_ == 2'b01) ? 
                        (hit_way0 ? 16'b0100_0000_0000_0000 : 
                         hit_way1 ? 16'b0000_0100_0000_0000 : 
                         hit_way2 ? 16'b0000_0000_0100_0000 : 
                         hit_way3 ? 16'b0000_0000_0000_0100 : 16'b0) :
                   (word_ == 2'b10) ? 
                        (hit_way0 ? 16'b0010_0000_0000_0000 : 
                         hit_way1 ? 16'b0000_0010_0000_0000 : 
                         hit_way2 ? 16'b0000_0000_0010_0000 : 
                         hit_way3 ? 16'b0000_0000_0000_0010 : 16'b0) :
                   (word_ == 2'b11) ? 
                        (hit_way0 ? 16'b0001_0000_0000_0000 : 
                         hit_way1 ? 16'b0000_0001_0000_0000 : 
                         hit_way2 ? 16'b0000_0000_0001_0000 : 
                         hit_way3 ? 16'b0000_0000_0000_0001 : 16'b0) :
                    16'b0;
                    
/********************  дcache  ********************/
   
   always@(posedge clk) begin
        if(!rst) begin
            s           <=  4'b0000;
            wen_        <=  16'b0;
            wHcode_     <=  2'b11;
            ofst_       <=  2'b00;
            w_data_     <=  32'b0;
            cache_ram_data_data_ok  <= 1'b0;
        end
        else begin
            case(s)
                4'b0000: begin
                    // ������ �� д����
                    if( ram_data_req & ~miss ) begin
                        s           <=  4'b0100;
                        wen_        <=  _wen_;
                        ofst_       <=  byte_;
                        wHcode_     <=  ram_data_size;
                        w_data_     <=  ram_data_wdata;
                        cache_ram_data_data_ok      <=  1'b1; 
                    end
                    // ȱʧ��
                    else if( ram_data_req & miss & ~addDirtyReq & ~vcm_ram_data_data_ok) begin
                        s           <=  4'b0001;
                        wen_        <=  16'b0;
                        ofst_       <=  2'b00;
                        wHcode_     <=  2'b11;
                        w_data_     <=  32'b0;
                        cache_ram_data_data_ok      <=  1'b0; 
                    end
                    else begin
                        s           <=  4'b0000;
                        wen_        <=  16'b0;
                        ofst_       <=  2'b00;
                        wHcode_     <=  2'b11;
                        w_data_     <=  32'b0;
                        cache_ram_data_data_ok  <= 1'b0;
                    end
                end
                
                4'b0001: begin
                    if( ~cache_data_data_ok ) begin
                         s           <=  4'b0001;
                         wen_        <=  16'b0;
                         ofst_       <=  2'b00;
                         wHcode_     <=  2'b11;
                         w_data_     <=  32'b0;
                         cache_ram_data_data_ok  <= 1'b0;                   
                    end
                    else begin
                         s           <=  4'b0011;
                         wen_        <= (old_way==2'b00)? 16'b1000_0000_0000_0000:
                                        (old_way==2'b01)? 16'b0000_1000_0000_0000:
                                        (old_way==2'b10)? 16'b0000_0000_1000_0000: 16'b0000_0000_0000_1000;
                         ofst_       <=  2'b00;
                         wHcode_     <=  2'b11;
                         w_data_     <=  cache_data_rdata;
                         cache_ram_data_data_ok  <= 1'b0;
                    end
                end
                
                4'b0011: begin
                    if( ~cache_data_data_ok ) begin
                         s           <=  4'b0011;
                         wen_        <=  16'b0;
                         ofst_       <=  2'b00;
                         wHcode_     <=  2'b11;
                         w_data_     <=  32'b0;
                         cache_ram_data_data_ok  <= 1'b0;                   
                    end
                    else begin
                         s          <=  4'b0111;
                         wen_ <= (old_way==2'b00)? 16'b0100_0000_0000_0000:
                                        (old_way==2'b01)? 16'b0000_0100_0000_0000:
                                        (old_way==2'b10)? 16'b0000_0000_0100_0000: 16'b0000_0000_0000_0100;
                         wHcode_     <=  2'b11;
                         ofst_       <=  2'b00;
                         w_data_     <=  cache_data_rdata;
                         cache_ram_data_data_ok  <= 1'b0;
                    end
                         
                end
                
                4'b0111: begin
                    if( ~cache_data_data_ok ) begin
                         s           <=  4'b0111;
                         wen_        <=  16'b0;
                         ofst_       <=  2'b00;
                         wHcode_     <=  2'b11;
                         w_data_     <=  32'b0;
                         cache_ram_data_data_ok  <= 1'b0;                   
                    end
                    else begin
                        s      <=  4'b0110;
                        wen_   <= (old_way==2'b00)? 16'b0010_0000_0000_0000:
                                        (old_way==2'b01)? 16'b0000_0010_0000_0000:
                                        (old_way==2'b10)? 16'b0000_0000_0010_0000: 16'b0000_0000_0000_0010;
                        wHcode_ <= 2'b10;
                        ofst_   <=  2'b00;
                        w_data_ <= cache_data_rdata;
                        cache_ram_data_data_ok  <= 1'b0;
                    end
                         
                end
                
                4'b0110: begin
                    if( ~cache_data_data_ok ) begin
                         s           <=  4'b0110;
                         wen_        <=  16'b0;
                         ofst_       <=  2'b00;
                         wHcode_     <=  2'b11;
                         w_data_     <=  32'b0;
                         cache_ram_data_data_ok  <= 1'b0;                   
                    end
                    else begin
                        s       <=  4'b1110;
                        wen_    <=  (old_way==2'b00)? 16'b0001_0000_0000_0000:
                                        (old_way==2'b01)? 16'b0000_0001_0000_0000:
                                        (old_way==2'b10)? 16'b0000_0000_0001_0000: 16'b0000_0000_0000_0001;
                        wHcode_ <=  2'b10;
                        ofst_   <=  2'b00;
                        w_data_ <=  cache_data_rdata;
                        cache_ram_data_data_ok  <= ~ram_data_wr;
                    end
                        
                end
                
                4'b1110: begin
                        s       <=  ~ram_data_wr ? 4'b0000 : 4'b1111;
                        wen_    <=  _wen_;     
                        ofst_   <=  byte_;
                        wHcode_ <=  ram_data_size;
                        w_data_ <=  ram_data_wdata;        
                        cache_ram_data_data_ok  <= ram_data_wr;    
                end
                
                4'b1111: begin
                    s           <=  4'b0000;
                    wen_        <=  16'b0;
                    ofst_       <=  2'b00;
                    wHcode_     <=  2'b11;
                    w_data_     <=  32'b0;
                    cache_ram_data_data_ok  <= 1'b0;
                end
                
                default: begin
                    s           <=  4'b0000;
                    wen_        <=  16'b0;
                    ofst_       <=  2'b00;
                    wHcode_     <=  2'b11;
                    w_data_     <=  32'b0;
                    cache_ram_data_data_ok  <= 1'b0;
                 end
            endcase
        end
   end
   
/***************************************************/
endmodule
