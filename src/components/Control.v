`timescale 1ns / 1ps

module Control (
    input       [6:0]   op_code,
    input       [2:0]   funct3,
    input               funct7_5,
    input       [11:0]  csr,
    output reg  [1:0]   pc_src,     // 00 pc+4 01 JALR 10 JAL
    output reg          reg_write,  // write register or not
    output reg          alu_src_b,  // 0 -> from register, 1 -> from imm
    output reg  [3:0]   alu_op,     // ALUop
    output reg  [2:0]   mem_to_reg, // 00 -> ALU, 01 -> imm, 10 -> pc+4, 11 -> RAM
    output reg          mem_write,  // write RAM or not
    output reg          branch,     // is branch or not
    output reg          b_type,     // 1 -> beq, 0 -> bne
    output reg          auipc,      // is auipc or not
    output reg  [1:0]   trap,       // 00 no trap, 01 ecall, 10 unimp
    output reg  [11:0]  csr_read_addr,
    output reg  [11:0]  csr_write_addr,
    output reg          csr_write,
    output reg          csr_write_src,
    output reg          rev_imm
);
    `include "AluOp.vh"
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
        trap        = 0;
        csr_write   = 0;
        rev_imm     = 0;
        csr_read_addr   = 0;
        csr_write_addr  = 0;
        csr_write_src   = 0;

        case (op_code)
            7'b0000011: begin   // lw
                reg_write = 1;  alu_src_b = 1;  alu_op = ADD;
                mem_to_reg = 3'b011;
            end
            7'b0100011: begin   // sw
                alu_src_b = 1;  alu_op = ADD;   mem_write = 1;
            end
            7'b0010011: begin   // addi slti xori ori andi slli srli 
                reg_write = 1;  alu_src_b = 1;  
                case (funct3)
                    3'b000: alu_op = ADD;
                    3'b010: alu_op = SLT;
                    3'b100: alu_op = XOR;
                    3'b110: alu_op = OR;
                    3'b111: alu_op = AND;
                    3'b001: alu_op = SLL;
                    3'b101: begin
                        if (funct7_5)   alu_op = SRA;
                        else            alu_op = SRL;
                    end
                endcase
            end
            7'b1100011: begin   // bne beq
                alu_op = XOR;   branch = 1; b_type = ~funct3[0];
                case (funct3)
                    3'b000: begin alu_op = XOR; b_type = 1; end     // beq
                    3'b001: begin alu_op = XOR; b_type = 0; end     // bne
                    3'b100: begin alu_op = SLT; b_type = 0; end     // blt
                    3'b101: begin alu_op = SLT; b_type = 1; end     // bge
                    3'b110: begin alu_op = SLTU; b_type = 0; end    // bltu
                    3'b111: begin alu_op = SLTU; b_type = 1; end    // bgeu
                endcase
            end
            7'b1101111: begin   // jal
                pc_src = 2'b10; reg_write = 1;  mem_to_reg = 3'b010;
            end
            7'b0110111: begin   // lui
                reg_write = 1;  mem_to_reg = 3'b001;
            end
            7'b0110011: begin   // add slt and or sll srl sltu
                reg_write = 1;
            end
            7'b0010111: begin   // auipc
                reg_write = 1;  alu_src_b = 1;  alu_op = ADD;
                auipc = 1;
            end
            7'b1100111: begin   // jalr
                pc_src = 2'b01; reg_write = 1; mem_to_reg = 3'b010;
                alu_src_b = 1;
            end
            7'b1110011: begin
                case (funct3)
                    3'b000: begin
                        case (csr)
                            12'b000000000000: begin // ecall
                                trap = 2'b01;   csr_read_addr = 12'h305;
                                pc_src = 2'b11;
                            end
                            12'b001100000010: begin // mret
                                trap = 2'b11;
                                csr_read_addr = 12'h341;  pc_src = 2'b11;
                            end
                            default: begin
                                trap = 2'b10;   csr_read_addr = 12'h305;
                                pc_src = 2'b11;
                            end
                        endcase
                    end
                    3'b001: begin // csrrw **Note**: Just implement for csrw and csrr
                        if (csr != 12'h300 && csr != 12'h341 && csr != 12'h305 && csr != 12'h342) begin
                            trap = 2'b10;   csr_read_addr = 12'h305;
                            pc_src = 2'b11;
                        end else begin
                            csr_write = 1;  csr_read_addr = csr;
                            csr_write_addr = csr; csr_write_src = 0;
                            reg_write = 1;  mem_to_reg = 3'b100;
                        end
                    end
                    3'b010: begin // csrrs
                        if (csr != 12'h300 && csr != 12'h341 && csr != 12'h305 && csr != 12'h342) begin
                            trap = 2'b10;   csr_read_addr = 12'h305;
                            pc_src = 2'b11;
                        end else begin
                            // csr_write = 1;  csr_read_addr = imm[11:0];
                            // csr_write_addr = imm[11:0]; csr_write_src = 1;
                            // alu_op = OR;    alu_src_b = 2'b10;
                            // reg_write = 1;  mem_to_reg = 3'b100;
                            csr_write = 0;  csr_read_addr = csr; // csrr
                            reg_write = 1;  mem_to_reg = 3'b100;
                        end
                    end
                    3'b011: begin // csrrc
                        csr_write = 1;  csr_read_addr = csr;
                        csr_write_addr = csr; csr_write_src = 1;
                        alu_op = AND;   alu_src_b = 2'b10;  rev_imm = 1;
                        reg_write = 1;  mem_to_reg = 3'b100;
                    end
                    3'b101: begin // csrrwi

                    end
                    3'b110: begin // csrrsi

                    end
                    3'b111: begin // csrrci

                    end
                endcase
            end
            default: begin
                trap = 2'b10;   csr_read_addr = 12'h305;
                pc_src = 2'b11;
            end
        endcase
    end

endmodule