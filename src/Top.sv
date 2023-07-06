`timescale 1ns / 1ps

module Top(
    input          clk,
    input          resetn,
    input  [15:0]  switch, 
    input  [ 4:0]  button,  
    
    output [15:0]  led,
    output [ 2:0]  rgb1,
    output [ 2:0]  rgb2,
    output [ 7:0]  num_csn,
    output [ 7:0]  num_an,
    output         UART_TXD
);
    logic aresetn;
    logic step;

    logic [63:0] chip_debug_out0;
    logic [63:0] chip_debug_out1;
    logic [63:0] chip_debug_out2;
    logic [63:0] chip_debug_out3;

    logic [7:0] uart_data, sim_uart_char;
    logic uart_send, uart_ready, sim_uart_char_valid;
    logic [31:0] clk_div;
    logic clk_cpu;

    always @(posedge clk) begin
        if (!resetn) clk_div <= 0;
        else clk_div <= clk_div + 1;
    end
    assign clk_cpu = clk_div[3];

    Core chip_inst(
        .clk(clk_cpu),
        .aresetn(aresetn),
        .step(step),
        .debug_mode(switch[15]),
        .debug_reg_addr(switch[11:7]),
        .chip_debug_out0(chip_debug_out0),
        .chip_debug_out1(chip_debug_out1),
        .chip_debug_out2(chip_debug_out2),
        .chip_debug_out3(chip_debug_out3),
        .sim_uart_char_out(sim_uart_char),
        .sim_uart_char_valid(sim_uart_char_valid),
    );

    IO_Manager io_manager_inst(
        .clk(clk_cpu),
        .resetn(resetn),

        // to chip
        .aresetn(aresetn),
        .step(step),
        
        // to gpio
        .switch(switch),
        .button(button),
        .led(led),
        .num_csn(num_csn),
        .num_an(num_an),
        .rgb1(rgb1),
        .rgb2(rgb2),
        
        // debug
        .debug0(32'h88888888),
        .debug1({16'b0, switch[15:0]}),
        .debug2({12'b0, 3'b0, button[4], 3'b0, button[3], 3'b0, button[2], 3'b0, button[1], 3'b0, button[0]}),
        .debug3(32'h12345678),
        .debug4(chip_debug_out0[31:0]),
        .debug5(chip_debug_out1[31:0]),
        .debug6(chip_debug_out2[31:0]),
        .debug7(chip_debug_out3[31:0])
    );

    UART_TX_CTRL uart_tx_ctrl (
        .SEND(uart_send),
        .DATA(uart_data),
        .CLK(clk),
        .READY(uart_ready),
        .UART_TX(UART_TXD)
    );

    uart_buffer UART_BUFF (
        .clk(clk_cpu),
        .rst(~aresetn),
        .ready(uart_ready),
        .sim_uart_char_valid(sim_uart_char_valid),
        .sim_uart_char(sim_uart_char),
        .send(uart_send),
        .datao(uart_data)
    );
endmodule
