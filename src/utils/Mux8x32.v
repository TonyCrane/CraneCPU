`timescale 1ns / 1ps

module Mux8x32(
    input   [31:0]  I0,
    input   [31:0]  I1,
    input   [31:0]  I2,
    input   [31:0]  I3,
    input   [31:0]  I4,
    input   [31:0]  I5,
    input   [31:0]  I6,
    input   [31:0]  I7,
    input   [2:0]   s,
    output  [31:0]  o
);
    reg [31:0] out;
    always @(*) begin
        case (s)
            3'b000: out <= I0;
            3'b001: out <= I1;
            3'b010: out <= I2;
            3'b011: out <= I3;
            3'b100: out <= I4;
            3'b101: out <= I5;
            3'b110: out <= I6;
            3'b111: out <= I7;
        endcase
    end
    assign o = out;
endmodule