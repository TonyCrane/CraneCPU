`timescale 1ns / 1ps

module Core (
    input  wire        clk,
    input  wire        aresetn,
    input  wire        step,
    input  wire        debug_mode,
    input  wire [4:0]  debug_reg_addr, // register address
    output wire [63:0] chip_debug_out0,
    output wire [63:0] chip_debug_out1,
    output wire [63:0] chip_debug_out2,
    output wire [63:0] chip_debug_out3,
    output wire [7:0]  sim_uart_char_out,
    output wire        sim_uart_char_valid
);
    wire rst, mem_write, mem_clk, cpu_clk;
    wire [31:0] inst;
    wire [63:0] core_data_in, addr_out, core_data_out, pc_out;
    reg  [31:0] clk_div;
    wire [63:0] debug_reg;
    wire [63:0] satp;
    wire stall, mem_read;
    wire [2:0]  width;
    
    assign rst = ~aresetn;

    CPU cpu (
        .clk(cpu_clk),
        .rst(rst),
        .inst(inst),
        .data_in(core_data_in),      // data from data memory
        .addr_out(addr_out),         // data memory address
        .data_out(core_data_out),    // data to data memory
        .pc_out(pc_out),             // connect to instruction memory
        .mem_write(mem_write),
        .mem_read(mem_read),
        .debug_reg_addr(debug_reg_addr),
        .debug_reg(debug_reg),
        .satp(satp),
        .data_width(width),
        .stall(stall)
    );
    
    always @(posedge clk) begin
        if(rst) clk_div <= 0;
        else clk_div <= clk_div + 1;
    end
    assign mem_clk = ~clk_div[0];
    assign cpu_clk = debug_mode ? clk_div[0] : step;
    
    MMU mmu (
        .clk(mem_clk), .rst(rst),
        .inst_addr(pc_out),
        .data_addr(addr_out),
        .write_data(core_data_out),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .width(width),
        .satp(satp),
        .inst_out(inst),
        .read_data(core_data_in),
        .stall_pipeline(stall),
        .sim_uart_char_out(sim_uart_char_out),
        .sim_uart_char_valid(sim_uart_char_valid)
    );
    
    assign chip_debug_out0 = pc_out;
    assign chip_debug_out1 = addr_out;
    assign chip_debug_out2 = {32'b0, inst};
    assign chip_debug_out3 = debug_reg;
endmodule
