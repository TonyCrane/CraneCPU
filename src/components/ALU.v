`timescale 1ns / 1ps

module ALU (
    input   [63:0]  a,
    input   [63:0]  b,
    input   [3:0]   alu_op,
    input           alu_work_on_word,
    output  [63:0]  res,
    output          zero
);
    `include "AluOp.vh"

    reg    [63:0]  res_tmp;
    assign res = alu_work_on_word ? {{32{res_tmp[31]}}, res_tmp[31:0]} : res_tmp;

    always @(*) begin
        case (alu_op)
            ADD: res_tmp <= a + b;
            SUB: res_tmp <= a - b;
            SLL: res_tmp <= a << b[5:0];
            SLT: begin
                if (a[63] == 0 && b[63] == 1) res_tmp <= 0;
                else if (a[63] == 1 && b[63] == 0) res_tmp <= 1;
                else if (a[63] == b[63]) begin
                    if (a[62:0] < b[62:0]) res_tmp <= 1;
                    else res_tmp <= 0;
                end
            end
            SLTU: begin
                if (a < b) res_tmp <= 1;
                else res_tmp <= 0;
            end
            XOR: res_tmp <= a ^ b;
            SRL: res_tmp <= a >> b[5:0];
            SRA: res_tmp <= $signed(a) >>> b[5:0];
            OR:  res_tmp <= a | b;
            AND: res_tmp <= a & b;
            default: res_tmp = 0;
        endcase
    end
    assign zero = (a-b) ? 1'b0 : 1'b1;
endmodule