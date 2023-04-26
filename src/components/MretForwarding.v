`timescale 1ns / 1ps

module MretForwarding (
    input           ID_EX_csr_write,
    input   [11:0]  ID_EX_csr_write_addr,
    input   [31:0]  EX_MEM_alu_result,
    input   [31:0]  csr_read_data,
    input   [1:0]   trap, // 00 no trap, 01 ecall, 10 unimp
    output  [31:0]  csr_ret_pc
);
    reg     [31:0]  _csr_ret_pc;
    assign csr_ret_pc = _csr_ret_pc;
    always @(*) begin
        if (trap == 2'b11) begin
            if (ID_EX_csr_write == 1 && ID_EX_csr_write_addr == 12'h341) begin
                _csr_ret_pc <= EX_MEM_alu_result;
            end
            else begin
                _csr_ret_pc <= csr_read_data;
            end
        end else begin
            _csr_ret_pc <= csr_read_data;
        end
    end
endmodule