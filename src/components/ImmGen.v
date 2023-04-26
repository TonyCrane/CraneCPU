`timescale 1ns / 1ps

module ImmGen(
    input   [31:0]  inst,
    output  [31:0]  imm
);
    `include "Opcodes.vh"
    reg [3:0] type;
    reg [31:0] out;
    assign imm = out;

    always @(*) begin
        case (inst[6:0])
            LW:     type <= I;
            SW:     type <= S;
            ADDI:   type <= I;
            BNE:    type <= B;
            BEQ:    type <= B;
            JAL:    type <= J;
            LUI:    type <= U;
            ADD:    type <= R;
            SLT:    type <= R;
            SLTI:   type <= I;
            ANDI:   type <= I;
            ORI:    type <= I;
            AND:    type <= R;
            OR:     type <= R;
            SLL:    type <= R;
            XORI:   type <= I;
            SLLI:   type <= R;
            SRLI:   type <= R;
            SRL:    type <= R;
            AUIPC:  type <= U;
            SLTU:   type <= R;
            JALR:   type <= I;
        endcase
        case (type)
            R: out <= {{20{inst[31]}}, inst[31:20]};
            I: out <= {{20{inst[31]}}, inst[31:20]};
            S: out <= {{20{inst[31]}}, inst[31:25], inst[11:7]};
            B: out <= {{19{inst[31]}}, inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
            U: out <= {inst[31:12], 12'b0};
            J: out <= {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
        endcase
    end

endmodule