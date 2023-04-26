`timescale 1ns / 1ps

module CoreSim;
    reg clk, rst;
    Core core(
        .clk(clk),
        .aresetn(~rst),
        .step(1'b0),
        .debug_mode(1'b1),
        .debug_reg_addr(5'b0)
    );

    initial begin
        $dumpvars(0, CoreSim);
        #1000 $finish;
    end

    initial begin
        clk = 0;
        rst = 1;
        #2 rst = 0;
    end
    always #1 clk = ~clk;
endmodule