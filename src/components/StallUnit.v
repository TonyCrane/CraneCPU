`timescale 1ns / 1ps

module StallUnit(
    input           ID_EX_mem_read,
    input   [4:0]   ID_EX_rd,
    input   [4:0]   IF_ID_rs1,
    input   [4:0]   IF_ID_rs2,
    input           jump,
    input           ID_EX_reg_write,
    output          bubble_stop
);
    assign bubble_stop = (ID_EX_mem_read && (ID_EX_rd == IF_ID_rs1 || ID_EX_rd == IF_ID_rs2)) || (jump && ID_EX_reg_write && ID_EX_rd != 0 && (ID_EX_rd == IF_ID_rs1 || ID_EX_rd == IF_ID_rs2));
endmodule
