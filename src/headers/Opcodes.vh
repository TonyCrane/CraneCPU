//`ifndef OPCODES_H
//`define OPCODES_H
parameter   LW      = 7'b0000011,
            SW      = 7'b0100011,
            ADDI    = 7'b0010011,
            BNE     = 7'b1100011,
            BEQ     = 7'b1100011,
            JAL     = 7'b1101111,
            LUI     = 7'b0110111,
            ADD     = 7'b0110011,
            SLT     = 7'b0110011,
            SLTI    = 7'b0010011,
            ANDI    = 7'b0010011,
            ORI     = 7'b0010011,
            AND     = 7'b0110011,
            OR      = 7'b0110011,
            SLL     = 7'b0110011,
            XORI    = 7'b0010011,
            SLLI    = 7'b0010011,
            SRLI    = 7'b0010011,
            SRL     = 7'b0110011,
            AUIPC   = 7'b0010111,
            SLTU    = 7'b0110011,
            JALR    = 7'b1100111;

parameter   R   = 3'b000,
            I   = 3'b001,
            S   = 3'b010,
            B   = 3'b011,
            U   = 3'b100,
            J   = 3'b101;
//`endif