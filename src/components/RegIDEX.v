`timescale 1ns / 1ps

module RegIDEX (
    input               clk,
    input               rst,
    input               en,
    input               flush,
    input       [63:0]  pc_ID,
    input       [1:0]   pc_src_ID,
    input       [4:0]   rs1_ID,
    input       [4:0]   rs2_ID,
    input       [4:0]   rd_ID,
    input       [63:0]  data1_ID,
    input       [63:0]  data2_ID,
    input       [63:0]  imm_ID,
    input       [3:0]   alu_op_ID,
    input               alu_src_ID,
    input               alu_work_on_word_ID,
    input               reg_write_ID,
    input               branch_ID,
    input               b_type_ID,
    input               auipc_ID,
    input               mem_write_ID,
    input               mem_read_ID,
    input       [2:0]   mem_to_reg_ID,
    input       [2:0]   data_width_ID,
    input               csr_write_ID,
    input               csr_write_src_ID,
    input       [11:0]  csr_rd_ID,
    input       [63:0]  csr_write_data_ID,
    input       [63:0]  csr_read_data_ID,
    output  reg [63:0]  pc_EX,
    output  reg [1:0]   pc_src_EX,
    output  reg [4:0]   rs1_EX,
    output  reg [4:0]   rs2_EX,
    output  reg [4:0]   rd_EX,
    output  reg [63:0]  data1_EX,
    output  reg [63:0]  data2_EX,
    output  reg [63:0]  imm_EX,
    output  reg [3:0]   alu_op_EX,
    output  reg         alu_src_EX,
    output  reg         alu_work_on_word_EX,
    output  reg         reg_write_EX,
    output  reg         branch_EX,
    output  reg         b_type_EX,
    output  reg         auipc_EX,
    output  reg         mem_write_EX,
    output  reg         mem_read_EX,
    output  reg [2:0]   mem_to_reg_EX,
    output  reg [2:0]   data_width_EX,
    output  reg         csr_write_EX,
    output  reg         csr_write_src_EX,
    output  reg [11:0]  csr_rd_EX,
    output  reg [63:0]  csr_write_data_EX,
    output  reg [63:0]  csr_read_data_EX
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_EX <= 63'h0;
            pc_src_EX <= 2'h0;
            rs1_EX <= 5'h0;
            rs2_EX <= 5'h0;
            rd_EX <= 5'h0;
            data1_EX <= 64'h0;
            data2_EX <= 64'h0;
            imm_EX <= 64'h0;
            alu_op_EX <= 2'h0;
            alu_src_EX <= 2'h0;
            alu_work_on_word_EX <= 1'h0;
            reg_write_EX <= 1'h0;
            branch_EX <= 1'h0;
            b_type_EX <= 1'h0;
            auipc_EX <= 1'h0;
            mem_write_EX <= 1'h0;
            mem_read_EX <= 1'h0;
            mem_to_reg_EX <= 3'h0;
            data_width_EX <= 3'h0;
            csr_write_EX <= 1'h0;
            csr_write_src_EX <= 1'h0;
            csr_rd_EX <= 12'h0;
            csr_write_data_EX <= 64'h0;
            csr_read_data_EX <= 64'h0;
        end else if (en) begin
            if (flush) begin
                pc_src_EX <= 2'h0;
                rd_EX <= 5'h0;
                reg_write_EX <= 1'h0;
                mem_write_EX <= 1'h0;
                mem_read_EX <= 1'h0;
                data_width_EX <= 3'h0;
                csr_write_EX <= 1'h0;
                csr_write_src_EX <= 1'h0;
                csr_rd_EX <= 12'h0;
                pc_EX <= pc_ID;
                data1_EX <= data1_ID;
                data2_EX <= data2_ID;
                imm_EX <= imm_ID;
                rd_EX <= rd_ID;
                rs1_EX <= rs1_ID;
                rs2_EX <= rs2_ID;
                csr_write_data_EX <= csr_write_data_ID;
                csr_read_data_EX <= csr_read_data_ID;
            end else begin
                pc_EX <= pc_ID;
                pc_src_EX <= pc_src_ID;
                rs1_EX <= rs1_ID;
                rs2_EX <= rs2_ID;
                rd_EX <= rd_ID;
                data1_EX <= data1_ID;
                data2_EX <= data2_ID;
                imm_EX <= imm_ID;
                alu_op_EX <= alu_op_ID;
                alu_src_EX <= alu_src_ID;
                alu_work_on_word_EX <= alu_work_on_word_ID;
                reg_write_EX <= reg_write_ID;
                branch_EX <= branch_ID;
                b_type_EX <= b_type_ID;
                auipc_EX <= auipc_ID;
                mem_write_EX <= mem_write_ID;
                mem_read_EX <= mem_read_ID;
                mem_to_reg_EX <= mem_to_reg_ID;
                data_width_EX <= data_width_ID;
                csr_write_EX <= csr_write_ID;
                csr_write_src_EX <= csr_write_src_ID;
                csr_rd_EX <= csr_rd_ID;
                csr_write_data_EX <= csr_write_data_ID;
                csr_read_data_EX <= csr_read_data_ID;
            end
        end
    end
endmodule