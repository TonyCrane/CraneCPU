`timescale 1ns / 1ps

module MMUSim;
    reg clk, rst;
    wire [31:0] inst_out;
    wire [63:0] read_data;
    wire stall_pipeline;

    MMU mmu (
        .clk(clk), .rst(rst),
        .inst_addr(64'hffffffe000200000),
        .data_addr(64'hffffffe00020b000),
        // .data_addr(64'h800),
        .write_data(64'h0000000000000000),
        .mem_write(1'b0),
        .mem_read(1'b1),
        .width(3'b011),
        .satp(64'h8000000000080202),
        .inst_out(inst_out),
        .read_data(read_data),
        .stall_pipeline(stall_pipeline)
    );

    initial begin
        $dumpvars(0, MMUSim);
        #200 $finish;
    end

    initial begin
        clk = 0;
        rst = 1;
        #2 rst = 0;
    end
    always #1 clk = ~clk;
endmodule