`timescale 1ns / 1ps

module ALU (
    input       [31:0]  a,
    input       [31:0]  b,
    input       [3:0]   alu_op,
    output  reg [31:0]  res,
    output              zero
);
    `include "AluOp.vh"
    always @(*) begin
        case (alu_op)
            ADD: res <= a + b;
            SUB: res <= a - b;
            SLL: res <= a << b[4:0];
            SLT: begin
                if (a[31] == 0 && b[31] == 1) res <= 0;
                else if (a[31] == 1 && b[31] == 0) res <= 1;
                else if (a[31] == b[31]) begin
                    if (a[30:0] < b[30:0]) res <= 1;
                    else res <= 0;
                end
            end
            SLTU: begin
                if (a < b) res <= 1;
                else res <= 0;
            end
            XOR: res <= a ^ b;
            SRL: res <= a >> b[4:0];
            SRA: res <= a >>> b[4:0];
            OR:  res <= a | b;
            AND: res <= a & b;
            default: res = 0;
        endcase
    end
    assign zero = (a-b) ? 1'b0 : 1'b1;
endmodule