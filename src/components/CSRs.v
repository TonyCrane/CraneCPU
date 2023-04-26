`timescale 1ns / 1ps

module CSRs (
    input           clk,
    input           rst,
    input           we,
    input   [1:0]   trap, // 00 no trap, 01 ecall, 10 unimp
    input   [31:0]  pc,
    input   [11:0]  csr_read_addr,
    input   [11:0]  csr_write_addr,
    input   [31:0]  csr_write_data,
    output  [31:0]  csr_read_data
);
    reg [31:0] mstatus, mepc, mtvec, mcause;
    
    assign csr_read_data = (csr_read_addr == 12'h300) ? mstatus :
                           (csr_read_addr == 12'h341) ? mepc :
                           (csr_read_addr == 12'h305) ? mtvec :
                           (csr_read_addr == 12'h342) ? mcause : 0;
    
    always @(negedge clk or posedge rst) begin
        if (rst == 1) begin
            mstatus <= 0;
            mepc <= 0;
            mtvec <= 0;
            mcause <= 0;
        end
        else if (trap != 0) begin
            if (trap == 2'b01) begin
                mepc <= pc;
                mcause <= 11;
            end
            else if (trap == 2'b10) begin
                mepc <= pc;
                mcause <= 2;
            end
        end
        else if (we == 1) begin
            if      (csr_write_addr == 12'h300) mstatus <= csr_write_data;
            else if (csr_write_addr == 12'h341) mepc    <= csr_write_data;
            else if (csr_write_addr == 12'h305) mtvec   <= csr_write_data;
            else if (csr_write_addr == 12'h342) mcause  <= csr_write_data;
        end
    end
endmodule