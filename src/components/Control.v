`timescale 1ns / 1ps

module Control (
    input       [6:0]   op_code,
    input       [2:0]   funct3,
    input               funct7_5,
    output reg  [1:0]   pc_src,     // 00 pc+4 01 JALR 10 JAL
    output reg          reg_write,  // write register or not
    output reg          alu_src_b,  // 0 -> from register, 1 -> from imm
    output reg  [3:0]   alu_op,     // ALUop
    output reg  [1:0]   mem_to_reg, // 00 -> ALU, 01 -> imm, 10 -> pc+4, 11 -> RAM
    output reg          mem_write,  // write RAM or not
    output reg          branch,     // is branch or not
    output reg          b_type,     // 1 -> beq, 0 -> bne
    output reg          auipc       // is auipc or not
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

        case (op_code)
            7'b0000011: begin   // lw
                reg_write = 1;  alu_src_b = 1;  alu_op = ADD;
                mem_to_reg = 2'b11;
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
            end
            7'b1101111: begin   // jal
                pc_src = 2'b10; reg_write = 1;  mem_to_reg = 2'b10;
            end
            7'b0110111: begin   // lui
                reg_write = 1;  mem_to_reg = 2'b01;
            end
            7'b0110011: begin   // add slt and or sll srl sltu
                reg_write = 1;
            end
            7'b0010111: begin   // auipc
                reg_write = 1;  alu_src_b = 1;  alu_op = ADD;
                auipc = 1;
            end
            7'b1100111: begin   // jalr
                pc_src = 2'b01; reg_write = 1; mem_to_reg = 2'b10;
                alu_src_b = 1;  alu_op = ADD;
            end
        endcase
    end

endmodule