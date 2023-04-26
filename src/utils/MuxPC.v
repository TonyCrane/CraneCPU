`timescale 1ns / 1ps

module MuxPC(
    input   [31:0]  I0,
    input   [31:0]  I1,
    input   [31:0]  I2,
    input   [31:0]  I3,
    input   [1:0]   s,
    input           branch,
    input           b_type,     // 0 bne, 1 beq
    input   [31:0]  alu_res,
    output  [31:0]  o
);
    reg [31:0] out;
    always @(*) begin
        if (branch) begin
            if (b_type) begin
                if (alu_res == 32'b0)   out <= I2;
                else                    out <= I0;
            end
            else begin
                if (alu_res == 32'b0)   out <= I0;
                else                    out <= I2;
            end
        end
        else begin
            case (s)
                2'b00: out <= I0;
                2'b01: out <= I1;
                2'b10: out <= I2;
                2'b11: out <= I3;
            endcase
        end
    end
    assign o = out;
endmodule