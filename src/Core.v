`timescale 1ns / 1ps

module Core (
    input  wire        clk,
    input  wire        aresetn,
    input  wire        step,
    input  wire        debug_mode,
    input  wire [4:0]  debug_reg_addr, // register address
    output wire [31:0] chip_debug_out0,
    output wire [31:0] chip_debug_out1,
    output wire [31:0] chip_debug_out2,
    output wire [31:0] chip_debug_out3
);
    wire rst, mem_write, mem_clk, cpu_clk;
    wire [31:0] inst, core_data_in, addr_out, core_data_out, pc_out;
    reg  [31:0] clk_div;
    wire [31:0] debug_reg;
    
    assign rst = ~aresetn;

    CPU cpu(
        .clk(cpu_clk),
        .rst(rst),
        .inst(inst),
        .data_in(core_data_in),      // data from data memory
        .addr_out(addr_out),         // data memory address
        .data_out(core_data_out),    // data to data memory
        .pc_out(pc_out),             // connect to instruction memory
        .mem_write(mem_write),
        .debug_reg_addr(debug_reg_addr),
        .debug_reg(debug_reg)
    );
    
    always @(posedge clk) begin
        if(rst) clk_div <= 0;
        else clk_div <= clk_div + 1;
    end
    assign mem_clk = ~clk_div[0];
    assign cpu_clk = debug_mode ? clk_div[0] : step;
    
    ROM rom_unit (
        .address(pc_out / 4),
        .out(inst)
    );
    
    RAM ram_unit (
        .clk(mem_clk),
        .we(mem_write),
        .address(addr_out / 4),
        .write_data(core_data_out),
        .read_data(core_data_in)
    );
    
    assign chip_debug_out0 = pc_out;
    assign chip_debug_out1 = addr_out;
    assign chip_debug_out2 = inst;
    assign chip_debug_out3 = debug_reg;
endmodule
