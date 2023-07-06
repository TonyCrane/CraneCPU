`timescale 1ns / 1ps

module CoreSim;
    reg clk, rst;
    Core core (
        .clk(clk),
        .aresetn(~rst),
        .step(1'b0),
        .debug_mode(1'b1),
        .debug_reg_addr(5'b0)
    );

    // initial begin
    //     $dumpvars(0, CoreSim);
    //     // #700000 $finish;
    //     // #2000 $finish;
    //     // #1000000000 $finish;
    // end

    initial begin
        clk = 0;
        rst = 1;
        #2 rst = 0;
    end
    always #1 clk = ~clk;
    // always #5000000 begin
    //     $display("pc: %h", core.cpu.MEM_WB_pc);
    // end
endmodule