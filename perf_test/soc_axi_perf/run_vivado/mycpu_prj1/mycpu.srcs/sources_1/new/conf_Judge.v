module conf_Judge(
    input wire  [31:0] data_vaddr,
    output wire no_cache    
    );
    
    wire ram_tag;
    assign ram_tag = ((data_vaddr[31:24] == 8'b0001_1100) || 
                      (data_vaddr[31:30] == 2'b01)        || 
                      (data_vaddr[31:30] == 2'b11)        || 
                      (data_vaddr[31:29] == 3'b100)       || 
                      (data_vaddr[31:28] == 4'b0000))      
                      ? 1:0;
//     assign no_cache = (data_vaddr == 32'h1fb00000)? no_cache:!ram_tag;
    assign no_cache = !ram_tag;
endmodule
