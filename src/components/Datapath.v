`timescale 1ns / 1ps

module Datapath(
    input           clk,
    input           rst,
    input   [1:0]   pc_src,     // 00 -> from pc+4, 01 -> from JALR, 10 -> from JAL
    input           reg_write,  // write register or not
    input           alu_src_b,  // ALUsrc
    input           branch,     // whether branch or not
    input           b_type,     // 0 -> bne, 1 -> beq
    input           auipc,      // whether auipc or not
    input   [3:0]   alu_op,     // ALU operation
    input   [2:0]   mem_to_reg, // 00 -> from ALU, 01 -> from imm, 10 -> from pc+4, 11 -> from RAM
    input   [31:0]  inst_in,    // now instruction
    input   [31:0]  data_in,    // data from data memory
    output  [31:0]  addr_out,   // data memory address
    output  [31:0]  data_out,   // data to data memory
    output  [31:0]  pc_out,     // connect to instruction memory
    input   [4:0]   debug_reg_addr,
    output  [31:0]  debug_reg,
    input   [1:0]   trap,
    input   [11:0]  csr_read_addr,
    input   [11:0]  csr_write_addr,
    input           csr_write,
    input           csr_write_src,
    input           rev_imm
);
    reg     [31:0]  pc;
    wire    [31:0]  pc_next;
    wire    [31:0]  write_data, read_data_1, read_data_2;
    wire    [31:0]  alu_data_1, alu_data_2, alu_result;
    wire            alu_zero;
    wire    [31:0]  imm;
    wire    [31:0]  jal_addr, jalr_addr;
    wire    [31:0]  csr_read_data, csr_write_data;

    assign pc_out   = pc;
    assign addr_out = alu_result;
    assign data_out = read_data_2;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 32'b0;
        end
        else begin
            pc <= pc_next;
        end
    end

    Regs regs (
        .clk(clk),
        .rst(rst),
        .we(reg_write),
        .read_addr_1(inst_in[19:15]),
        .read_addr_2(inst_in[24:20]),
        .write_addr(inst_in[11:7]),
        .write_data(write_data),
        .read_data_1(read_data_1),
        .read_data_2(read_data_2),
        .debug_reg_addr(debug_reg_addr),
        .debug_reg(debug_reg)
    );

    CSRs csr (
        .clk(clk),
        .rst(rst),
        .we(csr_write),
        .trap(trap),
        .pc(pc),
        .csr_read_addr(csr_read_addr),
        .csr_write_addr(csr_write_addr),
        .csr_write_data(read_data_1),
        .csr_read_data(csr_read_data)
    );

    ImmGen immgen (
        .inst(inst_in),
        .imm(imm)
    );

    Mux2x32 mux2x32_1 (
        .I0(read_data_1),
        .I1(pc),
        .s(auipc),
        .o(alu_data_1)
    );

    Mux2x32 mux2x32_2 (
        .I0(read_data_2),
        .I1(imm),
        .s(alu_src_b),
        .o(alu_data_2)
    );

    ALU alu (
        .a(alu_data_1),
        .b(alu_data_2),
        .alu_op(alu_op),
        .res(alu_result),
        .zero(alu_zero)
    );

    Mux8x32 mux8x32 (
        .I0(alu_result),
        .I1(imm),
        .I2(pc + 4),
        .I3(data_in),
        .I4(csr_read_data),
        .I5(0),
        .I6(0),
        .I7(0),
        .s(mem_to_reg),
        .o(write_data)
    );

    assign jal_addr  = pc + imm;
    assign jalr_addr = alu_result;

    MuxPC mux_pc (
        .I0(pc + 4),
        .I1(jalr_addr),
        .I2(jal_addr),
        .I3(csr_read_data),
        .s(pc_src),
        .branch(branch),
        .b_type(b_type),
        .alu_res(alu_result),
        .o(pc_next)
    );
endmodule