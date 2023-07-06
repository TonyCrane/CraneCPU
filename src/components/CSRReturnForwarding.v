`timescale 1ns / 1ps

module CSRReturnForwarding (
    input           ID_EX_csr_write,
    input   [11:0]  ID_EX_csr_write_addr,
    input   [63:0]  EX_MEM_alu_result,
    input   [63:0]  ID_EX_csr_write_data,
    input   [63:0]  csr_read_data,
    input   [1:0]   trap, // 00 no trap, 01 ecall, 10 unimp
    input   [4:0]   EX_MEM_rd,
    input   [4:0]   ID_EX_rs1,
    output  [63:0]  csr_ret_pc
);
    reg     [63:0]  _csr_ret_pc;
    assign csr_ret_pc = _csr_ret_pc;
    always @(*) begin
        if (trap == 2'b11) begin
            if (ID_EX_csr_write == 1 && ID_EX_csr_write_addr == 12'h141) begin
                if (EX_MEM_rd == ID_EX_rs1)
                    _csr_ret_pc <= EX_MEM_alu_result;
                else
                    _csr_ret_pc <= ID_EX_csr_write_data;
            end
            else begin
                _csr_ret_pc <= csr_read_data;
            end
        end else begin
            _csr_ret_pc <= csr_read_data;
        end
    end
endmodule