`timescale 1ns / 1ps

module Memory (
    input           clk,
    input   [63:0]  address1,
    input   [2:0]   width1,
    output  [63:0]  read_data1,
    input           we2,
    input   [63:0]  write_data2,
    input   [63:0]  address2,
    input   [2:0]   width2,
    output  [63:0]  read_data2,
    output  [7:0]   sim_uart_char_out,
    output          sim_uart_char_valid
);
    localparam SIM_UART_ADDR = 64'h10000000;
    parameter START_ADDR = 2149580800; // 80200000
    parameter END_ADDR = 2151677952;   // 80400000
    reg [7:0] memory [START_ADDR:END_ADDR];

    initial begin
        // $readmemh("tests/kernel/memory.hex", memory);
        $readmemh("tests/PageTableSim/ram.hex", memory);
    end

    always @(posedge clk) begin
        if (we2 == 1 && (address2 != SIM_UART_ADDR)) begin
            memory[address2] <= write_data2[7:0];
            if (width2[0] | width2[1]) memory[address2 + 1] <= write_data2[15:8];
            if (width2[1]) begin
                memory[address2 + 2] <= write_data2[23:16];
                memory[address2 + 3] <= write_data2[31:24];
            end
            if (width2[0] & width2[1]) begin
                memory[address2 + 4] <= write_data2[39:32];
                memory[address2 + 5] <= write_data2[47:40];
                memory[address2 + 6] <= write_data2[55:48];
                memory[address2 + 7] <= write_data2[63:56];
            end

            // if (width2[0] & width2[1]) $display("%h: RAM[%h] <= %h", CoreSim.core.cpu.EX_MEM_pc, address2, write_data2);
            // else if (width2[1])        $display("%h: RAM[%h] <= %h", CoreSim.core.cpu.EX_MEM_pc, address2, write_data2[31:0]);
            // else if (width2[0])        $display("%h: RAM[%h] <= %h", CoreSim.core.cpu.EX_MEM_pc, address2, write_data2[15:0]);
            // else                       $display("%h: RAM[%h] <= %h", CoreSim.core.cpu.EX_MEM_pc, address2, write_data2[7:0]);
        end
    end

    assign read_data2 = address2 == SIM_UART_ADDR ? 64'b0 :
        (width2[0] & width2[1]) ? {memory[address2 + 7], memory[address2 + 6], memory[address2 + 5], memory[address2 + 4], memory[address2 + 3], memory[address2 + 2], memory[address2 + 1], memory[address2]} :
        (width2[1]) ? {width2[2] ? 32'b0 : {32{memory[address2 + 3][7]}}, memory[address2 + 3], memory[address2 + 2], memory[address2 + 1], memory[address2]} :
        (width2[0]) ? {width2[2] ? 48'b0 : {48{memory[address2 + 1][7]}}, memory[address2 + 1], memory[address2]} :
        {width2[2] ? 56'b0 : {56{memory[address2][7]}}, memory[address2]};

    assign read_data1 = address1 == SIM_UART_ADDR ? 64'b0 :
        (width1[0] & width1[1]) ? {memory[address1 + 7], memory[address1 + 6], memory[address1 + 5], memory[address1 + 4], memory[address1 + 3], memory[address1 + 2], memory[address1 + 1], memory[address1]} :
        (width1[1]) ? {width1[2] ? 32'b0 : {32{memory[address1 + 3][7]}}, memory[address1 + 3], memory[address1 + 2], memory[address1 + 1], memory[address1]} :
        (width1[0]) ? {width1[2] ? 48'b0 : {48{memory[address1 + 1][7]}}, memory[address1 + 1], memory[address1]} :
        {width1[2] ? 56'b0 : {56{memory[address1][7]}}, memory[address1]};
    
    reg [7:0]   uart_char;
    reg         uart_addr_valid;

    initial begin
        uart_addr_valid <= 0;
    end
    assign sim_uart_char_valid = uart_addr_valid;
    assign sim_uart_char_out = uart_char;
    always @(posedge clk) begin
        uart_addr_valid <= we2 && (address2 == SIM_UART_ADDR);
        uart_char <= write_data2[7:0];
        if (sim_uart_char_valid) $write("%c", sim_uart_char_out);
    end
endmodule