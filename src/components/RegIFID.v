`timescale 1ns / 1ps

module RegIFID (
    input               clk,
    input               rst,
    input               en,
    input               stall,
    input               flush,
    input       [63:0]  pc_IF,
    input       [31:0]  inst_IF,
    output  reg [63:0]  pc_ID,
    output  reg [31:0]  inst_ID
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_ID <= 63'h80200000;
            inst_ID <= 32'h0;
        end else if (en) begin
            if (stall) begin
                pc_ID <= pc_ID;
                inst_ID <= inst_ID;
            end else if (flush) begin
                pc_ID <= pc_ID;
                inst_ID <= 32'h00000013;
            end else begin
                pc_ID <= pc_IF;
                inst_ID <= inst_IF;
            end
        end else begin
            pc_ID <= pc_ID;
            inst_ID <= inst_ID;
        end
    end
endmodule