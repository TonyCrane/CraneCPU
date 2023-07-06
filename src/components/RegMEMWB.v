`timescale 1ns / 1ps

module RegMEMWB (
    input               clk,
    input               rst,
    input               en,
    input       [63:0]  pc_MEM,
    input       [63:0]  imm_MEM,
    input       [63:0]  data_in_MEM,
    input       [63:0]  alu_result_MEM,
    input       [4:0]   rd_MEM,
    input               reg_write_MEM,
    input       [2:0]   mem_to_reg_MEM,
    input               csr_write_MEM,
    input               csr_write_src_MEM,
    input       [11:0]  csr_rd_MEM,
    input       [63:0]  csr_write_data_MEM,
    input       [63:0]  csr_read_data_MEM,
    output  reg [63:0]  pc_WB,
    output  reg [63:0]  imm_WB,
    output  reg [63:0]  data_in_WB,
    output  reg [63:0]  alu_result_WB,
    output  reg [4:0]   rd_WB,
    output  reg         reg_write_WB,
    output  reg [2:0]   mem_to_reg_WB,
    output  reg         csr_write_WB,
    output  reg         csr_write_src_WB,
    output  reg [11:0]  csr_rd_WB,
    output  reg [63:0]  csr_write_data_WB,
    output  reg [63:0]  csr_read_data_WB
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_WB <= 63'h0;
            imm_WB <= 63'h0;
            data_in_WB <= 63'h0;
            alu_result_WB <= 63'h0;
            rd_WB <= 5'h0;
            reg_write_WB <= 1'h0;
            mem_to_reg_WB <= 3'h0;
            csr_write_WB <= 1'h0;
            csr_write_src_WB <= 1'h0;
            csr_rd_WB <= 12'h0;
            csr_write_data_WB <= 63'h0;
            csr_read_data_WB <= 63'h0;
        end else if (en) begin
            pc_WB <= pc_MEM;
            imm_WB <= imm_MEM;
            data_in_WB <= data_in_MEM;
            alu_result_WB <= alu_result_MEM;
            rd_WB <= rd_MEM;
            reg_write_WB <= reg_write_MEM;
            mem_to_reg_WB <= mem_to_reg_MEM;
            csr_write_WB <= csr_write_MEM;
            csr_write_src_WB <= csr_write_src_MEM;
            csr_rd_WB <= csr_rd_MEM;
            csr_write_data_WB <= csr_write_data_MEM;
            csr_read_data_WB <= csr_read_data_MEM;
        end
    end
endmodule