`timescale 1ns / 1ps

module MMU (
    input           clk,
    input           rst,
    input   [63:0]  inst_addr,
    input   [63:0]  data_addr,
    input   [63:0]  write_data,
    input           mem_write,
    input           mem_read,
    input   [2:0]   width,
    input   [63:0]  satp,
    output  [31:0]  inst_out,
    output  [63:0]  read_data,
    output          stall_pipeline,
    output  [7:0]   sim_uart_char_out,
    output          sim_uart_char_valid
);
    localparam SIM_UART_ADDR = 64'h10000000;

    wire            finish_translation;
    wire    [63:0]  addr1;
    wire    [63:0]  addr2;
    wire    [63:0]  data1;
    wire    [63:0]  data2;
    wire            ram_we, need_trans1, need_trans2, need_trans;

    assign need_trans1 = (satp[63:60] != 0);
    assign need_trans2 = (mem_read || mem_write) && (satp[63:60] != 0) && (data_addr != SIM_UART_ADDR);
    assign need_trans = need_trans1 || need_trans2;

    assign ram_we = mem_write && (!need_trans || finish_translation);

    AddressTranslator addr_trans (
        .clk(clk),
        .rst(rst),
        .ram_en((mem_read || mem_write) && need_trans2),
        .satp(satp),
        .inst_addr(inst_addr),
        .data_addr(data_addr),
        .memory_data1(data1),
        .memory_data2(data2),
        .finish(finish_translation),
        .memory_addr1(addr1),
        .memory_addr2(addr2)
    );

    Memory memory (
        .clk(~clk),
        .address1(addr1),
        .width1(stall_pipeline ? 3'b011 : 3'b010),
        .read_data1(data1),
        .we2(ram_we),
        .address2(need_trans ? addr2 : data_addr),
        .width2(stall_pipeline ? 3'b011 : width),
        .write_data2(write_data),
        .read_data2(data2),
        .sim_uart_char_out(sim_uart_char_out),
        .sim_uart_char_valid(sim_uart_char_valid)
    );

    assign inst_out = data1[31:0];
    assign read_data = data2;
    assign stall_pipeline = need_trans && !finish_translation;

endmodule