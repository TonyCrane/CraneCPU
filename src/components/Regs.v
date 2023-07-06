`timescale 1ns / 1ps

module Regs (
    input           clk,
    input           rst,
    input           we,
    input   [4:0]   read_addr_1,
    input   [4:0]   read_addr_2,
    input   [4:0]   write_addr,
    input   [63:0]  write_data,
    input   [4:0]   debug_reg_addr,
    output  [63:0]  read_data_1,
    output  [63:0]  read_data_2,
    output  [63:0]  debug_reg
);
    integer i;
    reg [63:0] register [1:31]; // x1 - x31, x0 keeps zero

    // genvar idx;
    // for (idx = 1; idx < 32; idx = idx + 1) begin
    //     initial $dumpvars(0, register[idx]);
    // end

    integer dump_file_descriptor;

    // initial begin
    //     dump_file_descriptor = $fopen("dut_changes.txt", "w");
    // end

    assign read_data_1 = (read_addr_1 == 0) ? 0 : register[read_addr_1]; // read
    assign read_data_2 = (read_addr_2 == 0) ? 0 : register[read_addr_2]; // read
    assign debug_reg = (debug_reg_addr == 0) ? 0 : register[debug_reg_addr];

    always @(negedge clk or posedge rst) begin
        if (rst == 1) for (i = 1; i < 32; i = i + 1) register[i] <= 0; // reset
        else if (we == 1 && write_addr != 0) begin
            // if (register[write_addr] != write_data) begin
            //     $fwrite(dump_file_descriptor, "[%h] x%d 0x%h\n", CoreSim.core.cpu.MEM_WB_pc, write_addr, write_data);
            // end
            register[write_addr] <= write_data;
        end
    end
endmodule