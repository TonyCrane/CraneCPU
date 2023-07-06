`timescale 1ns / 1ps

module RegEXMEM (
    input               clk,
    input               rst,
    input               en,
    input       [63:0]  pc_EX,
    input       [1:0]   pc_src_EX,
    input       [4:0]   rd_EX,
    input       [63:0]  imm_EX,
    input       [63:0]  data2_EX,
    input       [63:0]  alu_result_EX,
    input       [2:0]   mem_to_reg_EX,
    input               reg_write_EX,
    input               branch_EX,
    input               b_type_EX,
    input               mem_write_EX,
    input               mem_read_EX,
    input       [2:0]   data_width_EX,
    input       [11:0]  csr_rd_EX,
    input               csr_write_EX,
    input               csr_write_src_EX,
    input       [63:0]  csr_write_data_EX,
    input       [63:0]  csr_read_data_EX,
    output  reg [63:0]  pc_MEM,
    output  reg [1:0]   pc_src_MEM,
    output  reg [4:0]   rd_MEM,
    output  reg [63:0]  imm_MEM,
    output  reg [63:0]  data2_MEM,
    output  reg [63:0]  alu_result_MEM,
    output  reg [2:0]   mem_to_reg_MEM,
    output  reg         reg_write_MEM,
    output  reg         branch_MEM,
    output  reg         b_type_MEM,
    output  reg         mem_write_MEM,
    output  reg         mem_read_MEM,
    output  reg [2:0]   data_width_MEM,
    output  reg [11:0]  csr_rd_MEM,
    output  reg         csr_write_MEM,
    output  reg         csr_write_src_MEM,
    output  reg [63:0]  csr_write_data_MEM,
    output  reg [63:0]  csr_read_data_MEM
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_MEM <= 63'h0;
            pc_src_MEM <= 2'h0;
            rd_MEM <= 5'h0;
            imm_MEM <= 63'h0;
            data2_MEM <= 63'h0;
            alu_result_MEM <= 63'h0;
            mem_to_reg_MEM <= 3'h0;
            reg_write_MEM <= 1'h0;
            branch_MEM <= 1'h0;
            b_type_MEM <= 1'h0;
            mem_write_MEM <= 1'h0;
            mem_read_MEM <= 1'h0;
            data_width_MEM <= 3'h0;
            csr_rd_MEM <= 12'h0;
            csr_write_MEM <= 1'h0;
            csr_write_src_MEM <= 1'h0;
            csr_write_data_MEM <= 63'h0;
            csr_read_data_MEM <= 63'h0;
        end else if (en) begin
            pc_MEM <= pc_EX;
            pc_src_MEM <= pc_src_EX;
            rd_MEM <= rd_EX;
            imm_MEM <= imm_EX;
            data2_MEM <= data2_EX;
            alu_result_MEM <= alu_result_EX;
            mem_to_reg_MEM <= mem_to_reg_EX;
            reg_write_MEM <= reg_write_EX;
            branch_MEM <= branch_EX;
            b_type_MEM <= b_type_EX;
            mem_write_MEM <= mem_write_EX;
            mem_read_MEM <= mem_read_EX;
            data_width_MEM <= data_width_EX;
            csr_rd_MEM <= csr_rd_EX;
            csr_write_MEM <= csr_write_EX;
            csr_write_src_MEM <= csr_write_src_EX;
            csr_write_data_MEM <= csr_write_data_EX;
            csr_read_data_MEM <= csr_read_data_EX;
        end
    end
endmodule