`timescale 1ns / 1ps

module Mux4x64(
    input   [63:0]  I0,
    input   [63:0]  I1,
    input   [63:0]  I2,
    input   [63:0]  I3,
    input   [1:0]   s,
    output  [63:0]  o
);
    reg [63:0] out;
    always @(*) begin
        case (s)
            2'b00: out <= I0;
            2'b01: out <= I1;
            2'b10: out <= I2;
            2'b11: out <= I3;
        endcase
    end
    assign o = out;
endmodule