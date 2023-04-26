`timescale 1ns / 1ps

module RAM (
    input           clk,
    input           we,
    input   [31:0]  write_data,
    input   [10:0]  address,
    output  [31:0]  read_data
);
    reg [31:0] ram [0:2047];

    genvar idx;
    for (idx = 0; idx < 512; idx = idx + 1) begin
        initial $dumpvars(0, ram[idx]);
    end

    initial begin
        for (integer i = 10; i < 2048; i = i + 1) ram[i] <= 0;
        $readmemh("tests/PipelineForwarding/test.ram.hex", ram);
    end

    always @(posedge clk) begin
        if (we == 1) ram[address] <= write_data;
    end

    assign read_data = ram[address];
endmodule