`timescale 1ns / 1ps


module ForwardingUnit(
    input       [4:0]   EX_MEM_rd,
    input       [4:0]   MEM_WB_rd,
    input       [4:0]   ID_EX_rs1,
    input       [4:0]   ID_EX_rs2,
    input               EX_MEM_reg_write,
    input               MEM_WB_reg_write,
    input       [1:0]   EX_MEM_mem_to_reg,
    input       [1:0]   MEM_WB_mem_to_reg,
    input               auipc,
    input               alu_src_b,
    output reg  [2:0]   ForwardA,   // 00 来自寄存器，01 来自 EX/MEM，10 来自 MEM/WB，11 来自 PC
                                    // 100 来自 EX/MEM 的 PC + 4，101 来自 MEM/WB 的 PC + 4
                                    // 110 来自 EX/MEM 的 imm，111 来自 MEM/WB 的 imm
    output reg  [2:0]   ForwardB,   // 00 来自寄存器，01 来自 EX/MEM，10 来自 MEM/WB，11 来自 imm
    output reg  [1:0]   ForwardC
);
    always @(*) begin
        if (auipc) begin
            assign ForwardA = 3'b011;
        end else begin
            if          (EX_MEM_reg_write == 1 && EX_MEM_rd != 0 && EX_MEM_rd == ID_EX_rs1) begin
                if      (EX_MEM_mem_to_reg == 2'b01) assign ForwardA = 3'b110;
                else if (EX_MEM_mem_to_reg == 2'b10) assign ForwardA = 3'b100;
                else                                 assign ForwardA = 3'b001;
            end else if (MEM_WB_reg_write == 1 && MEM_WB_rd != 0 && MEM_WB_rd == ID_EX_rs1) begin
                if      (MEM_WB_mem_to_reg == 2'b01) assign ForwardA = 3'b111;
                else if (MEM_WB_mem_to_reg == 2'b10) assign ForwardA = 3'b101;
                else                                 assign ForwardA = 3'b010;
            end else begin
                assign ForwardA = 3'b000;
            end
        end
        if (alu_src_b) begin
            assign ForwardB = 3'b011;
        end else begin
            if          (EX_MEM_reg_write == 1 && EX_MEM_rd != 0 && EX_MEM_rd == ID_EX_rs2) begin
                if      (EX_MEM_mem_to_reg == 2'b01) assign ForwardB = 3'b110;
                else if (EX_MEM_mem_to_reg == 2'b10) assign ForwardB = 3'b100;
                else                                 assign ForwardB = 3'b001;
            end else if (MEM_WB_reg_write == 1 && MEM_WB_rd != 0 && MEM_WB_rd == ID_EX_rs2) begin
                if      (MEM_WB_mem_to_reg == 2'b01) assign ForwardB = 3'b111;
                else if (MEM_WB_mem_to_reg == 2'b10) assign ForwardB = 3'b101;
                else                                 assign ForwardB = 3'b010;
            end else begin
                assign ForwardB = 3'b000;
            end
        end
        if      (EX_MEM_reg_write && EX_MEM_rd != 0 && EX_MEM_rd == ID_EX_rs2) assign ForwardC = 2'b01;
        else if (MEM_WB_reg_write && MEM_WB_rd != 0 && MEM_WB_rd == ID_EX_rs2) assign ForwardC = 2'b01;
        else assign ForwardC = 2'b00;
    end
endmodule
