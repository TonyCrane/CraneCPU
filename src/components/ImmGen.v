`timescale 1ns / 1ps

module ImmGen(
    input   [31:0]  inst,
    output  [63:0]  imm
);
    `include "Opcodes.vh"
    reg [3:0] type;
    reg [31:0] out;
    assign imm = {{32{out[31]}}, out[31:0]};

    always @(*) begin
        case (inst[6:0])
            LUI:        type <= U;
            AUIPC:      type <= U;
            JAL:        type <= J;
            BRANCH:     type <= B;
            LOAD:       type <= I;
            STORE:      type <= S;
            OP_IMM:     type <= I;
            OP:         type <= R;
            SYSTEM:     type <= I;
            OP_IMM_32:  type <= I;
            OP_32:      type <= R;
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