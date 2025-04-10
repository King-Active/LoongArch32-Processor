module mmu (
    input wire  [31:0] inst_vaddr,
    output wire [31:0] inst_paddr,
    input wire  [31:0] data_vaddr,
    output wire [31:0] data_paddr 
);

    assign inst_paddr = inst_vaddr;
//    assign data_paddr = (data_vaddr == 32'h1fb00000)? data_paddr : data_vaddr;
    assign data_paddr = data_vaddr;

endmodule