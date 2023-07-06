parameter   BEQ     = 3'b000,
            BNE     = 3'b001,
            BLT     = 3'b100,
            BGE     = 3'b101,
            BLTU    = 3'b110,
            BGEU    = 3'b111;

parameter   COMMAND = 3'b000,
            CSRRW   = 3'b001,
            CSRRS   = 3'b010,
            CSRRC   = 3'b011,
            CSRRWI  = 3'b101,
            CSRRSI  = 3'b110,
            CSRRCI  = 3'b111;

parameter   ECALL   = 12'b000000000000,
            MRET    = 12'b001100000010,
            SRET    = 12'b000100000010,
            SFENCE  = 12'b000100100000;