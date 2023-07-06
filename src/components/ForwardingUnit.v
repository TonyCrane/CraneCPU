`timescale 1ns / 1ps


module ForwardingUnit(
    input   [4:0]   EX_MEM_rd,
    input   [4:0]   MEM_WB_rd,
    input   [4:0]   ID_EX_rs1,
    input   [4:0]   ID_EX_rs2,
    input           EX_MEM_reg_write,
    input           MEM_WB_reg_write,
    input   [2:0]   EX_MEM_mem_to_reg,
    input   [2:0]   MEM_WB_mem_to_reg,
    input           auipc,
    input           alu_src_b,
    output  [2:0]   ForwardA,   // 00 来自寄存器，01 来自 EX/MEM，10 来自 MEM/WB，11 来自 PC
                                // 100 来自 EX/MEM 的 PC + 4，101 来自 MEM/WB 的 PC + 4
                                // 110 来自 EX/MEM 的 imm，111 来自 MEM/WB 的 imm
    output  [2:0]   ForwardB,   // 00 来自寄存器，01 来自 EX/MEM，10 来自 MEM/WB，11 来自 imm
    output  [1:0]   ForwardC
);
    reg [2:0]   forwardA, forwardB;
    reg [1:0]   forwardC;
    assign ForwardA = forwardA;
    assign ForwardB = forwardB;
    assign ForwardC = forwardC;
    always @(*) begin
        if (auipc) begin
            forwardA <= 3'b011;
        end else begin
            if          (EX_MEM_reg_write == 1 && EX_MEM_rd != 0 && EX_MEM_rd == ID_EX_rs1) begin
                if      (EX_MEM_mem_to_reg == 3'b001) forwardA <= 3'b110;
                else if (EX_MEM_mem_to_reg == 3'b010) forwardA <= 3'b100;
                else                                  forwardA <= 3'b001;
            end else if (MEM_WB_reg_write == 1 && MEM_WB_rd != 0 && MEM_WB_rd == ID_EX_rs1) begin
                if      (MEM_WB_mem_to_reg == 3'b001) forwardA <= 3'b111;
                else if (MEM_WB_mem_to_reg == 3'b010) forwardA <= 3'b101;
                else                                  forwardA <= 3'b010;
            end else begin
                forwardA <= 3'b000;
            end
        end
        if (alu_src_b) begin
            forwardB <= 3'b011;
        end else begin
            if          (EX_MEM_reg_write == 1 && EX_MEM_rd != 0 && EX_MEM_rd == ID_EX_rs2) begin
                if      (EX_MEM_mem_to_reg == 3'b001) forwardB <= 3'b110;
                else if (EX_MEM_mem_to_reg == 3'b010) forwardB <= 3'b100;
                else                                  forwardB <= 3'b001;
            end else if (MEM_WB_reg_write == 1 && MEM_WB_rd != 0 && MEM_WB_rd == ID_EX_rs2) begin
                if      (MEM_WB_mem_to_reg == 3'b001) forwardB <= 3'b111;
                else if (MEM_WB_mem_to_reg == 3'b010) forwardB <= 3'b101;
                else                                  forwardB <= 3'b010;
            end else begin
                forwardB <= 3'b000;
            end
        end
        if      (EX_MEM_reg_write && EX_MEM_rd != 0 && EX_MEM_rd == ID_EX_rs2) forwardC <= 2'b01;
        else if (MEM_WB_reg_write && MEM_WB_rd != 0 && MEM_WB_rd == ID_EX_rs2) forwardC <= 2'b10;
        else forwardC <= 2'b00;
    end
endmodule
