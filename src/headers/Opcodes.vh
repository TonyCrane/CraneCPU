// `ifndef OPCODES_H
// `define OPCODES_H

parameter   LOAD        = 7'b0000011,
            MISC_MEM    = 7'b0001111,
            OP_IMM      = 7'b0010011,
            AUIPC       = 7'b0010111,
            OP_IMM_32   = 7'b0011011,
            STORE       = 7'b0100011,
            OP          = 7'b0110011,
            OP_32       = 7'b0111011,
            LUI         = 7'b0110111,
            BRANCH      = 7'b1100011,
            JALR        = 7'b1100111,
            JAL         = 7'b1101111,
            SYSTEM      = 7'b1110011;

parameter   R   = 3'b000,
            I   = 3'b001,
            S   = 3'b010,
            B   = 3'b011,
            U   = 3'b100,
            J   = 3'b101;

//`endif