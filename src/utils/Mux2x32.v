`timescale 1ns / 1ps

module Mux2x32(
    input   [31:0]  I0,
    input   [31:0]  I1,
    input           s,
    output  [31:0]  o
);
    assign o = s ? I1 : I0;
endmodule