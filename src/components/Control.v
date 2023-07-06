`timescale 1ns / 1ps

module Control (
    input       [6:0]   op_code,
    input       [2:0]   funct3,
    input               funct7_5,
    input       [11:0]  csr,
    input       [63:0]  pc,
    input       [63:0]  sstatus,
    output reg  [1:0]   pc_src,     // 00 pc+4 01 JALR 10 JAL
    output reg          reg_write,  // write register or not
    output reg          alu_src_b,  // 0 -> from register, 1 -> from imm
    output reg  [3:0]   alu_op,     // ALUop
    output reg  [2:0]   mem_to_reg, // 00 -> ALU, 01 -> imm, 10 -> pc+4, 11 -> RAM
    output reg          mem_write,  // write RAM or not
    output reg          branch,     // is branch or not
    output reg          b_type,     // 1 -> beq, 0 -> bne
    output reg          auipc,      // is auipc or not
    output reg          mem_read,
    output reg  [2:0]   data_width,
    output reg          jump,
    output reg  [1:0]   trap,       // 00 no trap, 01 ecall, 10 unimp, 11 mret(标识跳转)
    output reg  [11:0]  csr_read_addr,
    output reg  [11:0]  csr_write_addr,
    output reg          csr_write,
    output reg          csr_write_src, // 0 来自 data1 1 来自 Control
    output reg  [63:0]  csr_write_sstatus,
    output reg  [63:0]  csr_write_scause,
    output reg          rev_imm,   // ALU 运算时是否对立即数取反
    output reg          alu_work_on_word
);
    `include "AluOp.vh"
    `include "Opcodes.vh"
    `include "Funct.vh"

    `define UNKNOWN_INST_TRAP trap = 2'b10; csr_read_addr = 12'h105; pc_src = 2'b11; csr_write_scause = 64'h2;
    `define UNSUPPORTED_CSR csr != 12'h100 && csr != 12'h141 && csr != 12'h105 && csr != 12'h142 && csr != 12'h180 && csr != 12'h140

    reg     [1:0]   priv;
    wire            spp;

    initial begin
        priv = 2'b01;
    end

    assign spp = sstatus[8];

    always @(*) begin
        pc_src      = 0;
        reg_write   = 0;
        alu_src_b   = 0;
        alu_op      = {funct7_5, funct3};
        mem_to_reg  = 0;
        mem_write   = 0;
        branch      = 0;
        b_type      = 0;
        auipc       = 0;
        mem_read    = 0;
        jump        = 0;
        trap        = 0;
        csr_write   = 0;
        rev_imm     = 0;
        csr_read_addr   = 0;
        csr_write_addr  = 0;
        csr_write_src   = 0;
        alu_work_on_word = 0;

        case (op_code)
            LUI: begin
                reg_write = 1;  mem_to_reg = 3'b001;
            end
            AUIPC: begin
                reg_write = 1;  alu_src_b = 1;  alu_op = ADD;
                auipc = 1;
            end
            JAL: begin
                pc_src = 2'b10; reg_write = 1;  mem_to_reg = 3'b010; 
                jump = 1;
            end
            JALR: begin
                pc_src = 2'b01; reg_write = 1;  mem_to_reg = 3'b010;
                alu_src_b = 1;  jump = 1;
            end
            BRANCH: begin
                branch = 1; jump = 1;
                case (funct3)
                    BEQ:  begin alu_op = XOR;  b_type = 1; end
                    BNE:  begin alu_op = XOR;  b_type = 0; end
                    BLT:  begin alu_op = SLT;  b_type = 0; end
                    BGE:  begin alu_op = SLT;  b_type = 1; end
                    BLTU: begin alu_op = SLTU; b_type = 0; end
                    BGEU: begin alu_op = SLTU; b_type = 1; end
                    default: begin
                        $display("\033[33mWarning: Unknown branch funct3! [pc: %h]\033[0m", pc);
                        `UNKNOWN_INST_TRAP
                    end
                endcase
            end
            LOAD: begin
                reg_write = 1;  alu_src_b = 1;  alu_op = ADD;
                mem_to_reg = 3'b011;            mem_read = 1;
                data_width = funct3;
            end
            STORE: begin
                alu_src_b = 1;  alu_op = ADD;   mem_write = 1;
                data_width = funct3;
            end
            OP_IMM: begin
                reg_write = 1;  alu_src_b = 1;  
                case (funct3)
                    3'b000: alu_op = ADD;
                    3'b001: alu_op = SLL;
                    3'b010: alu_op = SLT;
                    3'b011: alu_op = SLTU;
                    3'b100: alu_op = XOR;
                    3'b101: begin
                        if (funct7_5)   alu_op = SRA;
                        else            alu_op = SRL;
                    end
                    3'b110: alu_op = OR;
                    3'b111: alu_op = AND;
                endcase
            end
            OP: begin
                reg_write = 1;
            end
            OP_IMM_32: begin   // addiw sltiw ...
                reg_write = 1;  alu_src_b = 1;  alu_work_on_word = 1;
                case (funct3)
                    3'b000: alu_op = ADD;
                    3'b001: alu_op = SLL;
                    3'b101: begin
                        if (funct7_5)   alu_op = SRA;
                        else            alu_op = SRL;
                    end
                    default: begin
                        $display("\033[33mWarning: Unknown OP_IMM_32 funct3! [pc: %h]\033[0m", pc);
                        `UNKNOWN_INST_TRAP
                    end
                endcase
            end
            OP_32: begin   // addw 
                reg_write = 1;  alu_work_on_word = 1;
                case (funct3)
                    3'b000: begin
                        if (funct7_5)   alu_op = SUB;
                        else            alu_op = ADD;
                    end
                    3'b001: alu_op = SLL;
                    3'b101: begin
                        if (funct7_5)   alu_op = SRA;
                        else            alu_op = SRL;
                    end
                    default: begin
                        $display("\033[33mWarning: Unknown OP_32 funct3! [pc: %h]\033[0m", pc);
                        `UNKNOWN_INST_TRAP
                    end
                endcase
            end
            SYSTEM: begin   // system
                case (funct3)
                    COMMAND: begin
                        case (csr)
                            ECALL: begin
                                trap = 2'b01;   csr_read_addr = 12'h105;
                                pc_src = 2'b11; csr_write = 1;
                                if (priv == 2'b00) begin
                                    csr_write_scause = 64'h8;   priv = 2'b01;
                                    csr_write_addr = 12'h100;   csr_write_src = 1;
                                    csr_write_sstatus = sstatus & 64'hfffffffffffeff;
                                end else if (priv == 2'b01) begin
                                    csr_write_scause = 64'h9;   priv = 2'b01;
                                end
                            end
                            SRET: begin
                                trap = 2'b11;
                                csr_read_addr = 12'h141;  pc_src = 2'b11;
                                if (!spp) begin
                                    csr_write = 1;      csr_write_addr = 12'h100;
                                    csr_write_src = 1;  priv = 2'b00;
                                    csr_write_sstatus = sstatus & 64'hfffffffffffeff;
                                end else begin
                                    priv = 2'b01;
                                end
                            end
                            SFENCE: begin
                            end
                            default: begin
                                $display("\033[33mWarning: Unknown SYSTEM instruction! [pc: %h]\033[0m", pc);
                                `UNKNOWN_INST_TRAP
                            end
                        endcase
                    end
                    CSRRW: begin
                        if (`UNSUPPORTED_CSR) begin
                            $display("\033[33mWarning: Unsupported CSR number (%h)! [pc: %h]\033[0m", csr, pc);
                            `UNKNOWN_INST_TRAP
                        end else begin
                            csr_write = 1;  csr_read_addr = csr;
                            csr_write_addr = csr; csr_write_src = 0;
                            reg_write = 1;  mem_to_reg = 3'b100;
                        end
                    end
                    CSRRS: begin
                        if (`UNSUPPORTED_CSR) begin
                            $display("\033[33mWarning: Unsupported CSR number (%h)! [pc: %h]\033[0m", csr, pc);
                            `UNKNOWN_INST_TRAP
                        end else begin
                        // csr_write = 1;  csr_read_addr = csr;
                        // csr_write_addr = csr; csr_write_src = 1;
                        // alu_op = OR;    alu_src_b = 2'b10;
                        // reg_write = 1;  mem_to_reg = 3'b100;
                            csr_write = 0;  csr_read_addr = csr; // csrr
                            alu_op = OR;    alu_src_b = 2'b01;
                            reg_write = 1;  mem_to_reg = 3'b100;
                        end
                    end
                    // CSRRC: begin
                    //     // csr_write = 1;  csr_read_addr = csr;
                    //     // csr_write_addr = csr; csr_write_src = 1;
                    //     // alu_op = AND;   alu_src_b = 2'b10;  rev_imm = 1;
                    //     // reg_write = 1;  mem_to_reg = 3'b100;
                    // end
                    // CSRRWI: begin
                    // end
                    // CSRRSI: begin
                    // end
                    // CSRRCI: begin
                    // end
                    default: begin
                        $display("\033[33mWarning: Unsupported SYSTEM funct3! [pc: %h]\033[0m", pc);
                        `UNKNOWN_INST_TRAP
                    end
                endcase
            end
            default: begin
                $display("\033[33mWarning: Unknown opcode (%b)! [pc: %h]\033[0m", op_code, pc);
                `UNKNOWN_INST_TRAP
            end
        endcase
    end

endmodule