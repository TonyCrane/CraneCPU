`timescale 1ns / 1ps

module AddressTranslator (
    input               clk,
    input               rst,
    input               ram_en,
    input       [63:0]  satp,
    input       [63:0]  inst_addr,
    input       [63:0]  data_addr,
    input       [63:0]  memory_data1,
    input       [63:0]  memory_data2,
    output              finish,
    output  reg [63:0]  memory_addr1,
    output  reg [63:0]  memory_addr2
);
    wire   [3:0]   satp_mode;
    wire   [43:0]  satp_ppn;
    reg    [1:0]   trans_state1, next_state1;
    reg    [1:0]   trans_state2, next_state2;
    
    reg            finish1, finish2;

    reg            pte_D_1, pte_A_1, pte_G_1, pte_U_1, pte_X_1, pte_W_1, pte_R_1, pte_V_1;
    reg    [1:0]   pte_RSW_1;
    reg    [25:0]  pte_PPN2_1;
    reg    [8:0]   pte_PPN1_1, pte_PPN0_1;
    reg    [9:0]   pte_reserved_1;

    wire   [8:0]   vpn2_1, vpn1_1, vpn0_1;
    wire   [11:0]  pgoff_1;

    reg            pte_D_2, pte_A_2, pte_G_2, pte_U_2, pte_X_2, pte_W_2, pte_R_2, pte_V_2;
    reg    [1:0]   pte_RSW_2;
    reg    [25:0]  pte_PPN2_2;
    reg    [8:0]   pte_PPN1_2, pte_PPN0_2;
    reg    [9:0]   pte_reserved_2;

    wire   [8:0]   vpn2_2, vpn1_2, vpn0_2;
    wire   [11:0]  pgoff_2;

    assign vpn2_1 = inst_addr[38:30];
    assign vpn1_1 = inst_addr[29:21];
    assign vpn0_1 = inst_addr[20:12];
    assign pgoff_1 = inst_addr[11:0];

    assign vpn2_2 = data_addr[38:30];
    assign vpn1_2 = data_addr[29:21];
    assign vpn0_2 = data_addr[20:12];
    assign pgoff_2 = data_addr[11:0];

    assign satp_mode = satp[63:60];
    assign satp_ppn = satp[43:0];

    assign finish = ram_en ? finish1 && finish2 : finish1;

    localparam 
        S_IDLE = 0,
        S_LEVEL1 = 1,
        S_LEVEL2 = 2,
        S_LEVEL3 = 3;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            trans_state1 = S_IDLE;
            next_state1 = S_IDLE;
            finish1 = 1'b0;
        end else if (satp_mode == 0) begin
            finish1 = 1'b0;
            memory_addr1 = inst_addr;
        end else begin
            trans_state1 = next_state1;
            if (trans_state1 == S_IDLE) begin
                finish1 = 1'b0;
            end
            if (1'b1) begin
                if (finish1) begin
                    finish1 = 1'b0;
                end
                case (trans_state1)
                    S_IDLE: begin
                        memory_addr1 = {8'b0, satp_ppn, vpn2_1, 3'b0};
                        next_state1 = S_LEVEL1;
                        finish1 = 1'b0;
                    end
                    S_LEVEL1: begin
                        {pte_reserved_1, pte_PPN2_1, pte_PPN1_1, pte_PPN0_1, pte_RSW_1, pte_D_1, pte_A_1, pte_G_1, pte_U_1, pte_X_1, pte_W_1, pte_R_1, pte_V_1} = memory_data1[63:0];
                        if (pte_R_1 == 1 || pte_X_1 == 1) begin
                            memory_addr1 = {8'b0, pte_PPN2_1, vpn1_1, vpn0_1, pgoff_1};
                            next_state1 = S_IDLE;
                            finish1 = 1'b1;
                        end else begin
                            memory_addr1 = {8'b0, pte_PPN2_1, pte_PPN1_1, pte_PPN0_1, vpn1_1, 3'b0};
                            next_state1 = S_LEVEL2;
                            finish1 = 1'b0;
                        end
                    end
                    S_LEVEL2: begin
                        {pte_reserved_1, pte_PPN2_1, pte_PPN1_1, pte_PPN0_1, pte_RSW_1, pte_D_1, pte_A_1, pte_G_1, pte_U_1, pte_X_1, pte_W_1, pte_R_1, pte_V_1} = memory_data1[63:0];
                        if (pte_R_1 == 1 || pte_X_1 == 1) begin
                            memory_addr1 = {8'b0, pte_PPN2_1, pte_PPN1_1, vpn0_1, pgoff_1};
                            next_state1 = S_IDLE;
                            finish1 = 1'b1;
                        end else begin
                            memory_addr1 = {8'b0, pte_PPN2_1, pte_PPN1_1, pte_PPN0_1, vpn0_1, 3'b0};
                            next_state1 = S_LEVEL3;
                            finish1 = 1'b0;
                        end
                    end
                    S_LEVEL3: begin
                        {pte_reserved_1, pte_PPN2_1, pte_PPN1_1, pte_PPN0_1, pte_RSW_1, pte_D_1, pte_A_1, pte_G_1, pte_U_1, pte_X_1, pte_W_1, pte_R_1, pte_V_1} = memory_data1[63:0];
                        memory_addr1 = {8'b0, pte_PPN2_1, pte_PPN1_1, pte_PPN0_1, pgoff_1};
                        next_state1 = S_IDLE;
                        finish1 = 1'b1;
                    end
                endcase
            end
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            trans_state2 = S_IDLE;
            next_state2 = S_IDLE;
            finish2 = 1'b0;
        end else if (satp_mode == 0) begin
            finish2 = 1'b0;
            memory_addr2 = data_addr;
        end else begin
            trans_state2 = next_state2;
            if (trans_state2 == S_IDLE) begin
                finish2 = 1'b0;
                memory_addr2 = data_addr;
            end
            if (ram_en) begin
                if (finish2) begin
                    finish2 = 1'b0;
                end
                case (trans_state2)
                    S_IDLE: begin
                        memory_addr2 = {8'b0, satp_ppn, vpn2_2, 3'b0};
                        next_state2 = S_LEVEL1;
                        finish2 = 1'b0;
                    end
                    S_LEVEL1: begin
                        {pte_reserved_2, pte_PPN2_2, pte_PPN1_2, pte_PPN0_2, pte_RSW_2, pte_D_2, pte_A_2, pte_G_2, pte_U_2, pte_X_2, pte_W_2, pte_R_2, pte_V_2} = memory_data2[63:0];
                        if (pte_R_2 == 1 || pte_X_2 == 1) begin
                            memory_addr2 = {8'b0, pte_PPN2_2, vpn1_2, vpn0_2, pgoff_2};
                            next_state2 = S_IDLE;
                            finish2 = 1'b1;
                        end else begin
                            memory_addr2 = {8'b0, pte_PPN2_2, pte_PPN1_2, pte_PPN0_2, vpn1_2, 3'b0};
                            next_state2 = S_LEVEL2;
                            finish2 = 1'b0;
                        end
                    end
                    S_LEVEL2: begin
                        {pte_reserved_2, pte_PPN2_2, pte_PPN1_2, pte_PPN0_2, pte_RSW_2, pte_D_2, pte_A_2, pte_G_2, pte_U_2, pte_X_2, pte_W_2, pte_R_2, pte_V_2} = memory_data2[63:0];
                        if (pte_R_2 == 1 || pte_X_2 == 1) begin
                            memory_addr2 = {8'b0, pte_PPN2_2, pte_PPN1_2, vpn0_2, pgoff_2};
                            next_state2 = S_IDLE;
                            finish2 = 1'b1;
                        end else begin
                            memory_addr2 = {8'b0, pte_PPN2_2, pte_PPN1_2, pte_PPN0_2, vpn0_2, 3'b0};
                            next_state2 = S_LEVEL3;
                            finish2 = 1'b0;
                        end
                    end
                    S_LEVEL3: begin
                        {pte_reserved_2, pte_PPN2_2, pte_PPN1_2, pte_PPN0_2, pte_RSW_2, pte_D_2, pte_A_2, pte_G_2, pte_U_2, pte_X_2, pte_W_2, pte_R_2, pte_V_2} = memory_data2[63:0];
                        memory_addr2 = {8'b0, pte_PPN2_2, pte_PPN1_2, pte_PPN0_2, pgoff_2};
                        next_state2 = S_IDLE;
                        finish2 = 1'b1;
                    end
                endcase
            end
        end
    end

endmodule