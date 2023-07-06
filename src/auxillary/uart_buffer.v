`timescale 1ns / 1ps

module uart_buffer (
    input clk, rst,
    input wire ready,
    input wire [7:0] sim_uart_char,
    input wire sim_uart_char_valid,
    output reg send,
    output reg [7:0] datao
);
    localparam SIZE = 256;
    reg[7:0] buffer[0:SIZE-1];

    reg [7:0] head;
    reg [7:0] tail;

    always@(posedge clk) begin
        if(rst) begin
            head <= 0;
            tail <= 0; 
        end else begin
            if (ready && (head != tail)) begin
                datao <= buffer[head];
                send <= 1'b1;
                head <= (head == SIZE-1)? 0 : head+1;
            end
            if (sim_uart_char_valid) begin
                buffer[tail] <= sim_uart_char;
                if (sim_uart_char == 8'h0a) begin
                    buffer[tail+1] <= 8'h0d;
                    tail <= (tail == SIZE-2)? 0 : 
                            (tail == SIZE-1)? 1 : tail+2;
                end else begin 
                    tail <= (tail == SIZE-1)? 0 : tail+1;
                end     
            end
            if (send == 1'b1) begin
                send <= 1'b0;
            end 
        end
    end

endmodule