`timescale 1ns / 1ps

module CSRs (
    input           clk,
    input           rst,
    input           we,
    input   [1:0]   trap, // 00 no trap, 01 ecall, 10 unimp, 11 mret
    input   [63:0]  pc,
    input   [11:0]  csr_read_addr,
    input   [11:0]  csr_write_addr,
    input   [63:0]  csr_write_data,
    input   [63:0]  csr_write_scause,
    output  [63:0]  csr_read_data,
    output  [63:0]  csr_satp,
    output  [63:0]  csr_sstatus
);
    reg [63:0] sstatus, sepc, stvec, scause, satp, sscratch;
    
    assign csr_read_data = (csr_read_addr == 12'h100) ? sstatus :
                           (csr_read_addr == 12'h141) ? sepc :
                           (csr_read_addr == 12'h105) ? stvec :
                           (csr_read_addr == 12'h142) ? scause : 
                           (csr_read_addr == 12'h180) ? satp : 
                           (csr_read_addr == 12'h140) ? sscratch : 0;
    assign csr_satp = satp;
    assign csr_sstatus = sstatus;
    
    always @(negedge clk or posedge rst) begin
        if (rst == 1) begin
            sstatus <= 0;
            sepc <= 0;
            stvec <= 64'h80200000;
            scause <= 0;
            satp <= 0;
            sscratch <= 0;
        end else begin
            if (we == 1) begin
                if      (csr_write_addr == 12'h100) sstatus <= csr_write_data;
                else if (csr_write_addr == 12'h141) sepc <= csr_write_data;
                else if (csr_write_addr == 12'h105) stvec <= csr_write_data;
                else if (csr_write_addr == 12'h142) scause <= csr_write_data;
                else if (csr_write_addr == 12'h180) satp <= csr_write_data;
                else if (csr_write_addr == 12'h140) sscratch <= csr_write_data;
            end
            if (trap != 0) begin
                if (trap == 2'b01 || trap == 2'b10) begin
                    sepc <= pc;
                    scause <= csr_write_scause;
                end
            end
        end
    end
endmodule