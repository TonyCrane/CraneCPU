`timescale 1ns / 1ps

module CPU(
    input           clk,
    input           rst,
    input   [31:0]  inst,
    input   [31:0]  data_in,  // data from data memory
    input   [4:0]   debug_reg_addr,
    output  [31:0]  addr_out, // data memory address
    output  [31:0]  data_out, // data to data memory
    output  [31:0]  pc_out,   // connect to instruction memory
    output          mem_write,
    output  [31:0]  debug_reg
);
    reg     [31:0]  pc;
    wire    [31:0]  pc_next;
    
    reg     [31:0]  IF_ID_pc;
    reg     [31:0]  IF_ID_inst;

    wire    [31:0]  read_data1, read_data2, imm;
    wire    [3:0]   alu_op;
    wire    [1:0]   pc_src, mem_to_reg;
    wire            reg_write, alu_src, branch, b_type, auipc, mem_write_;
    reg     [31:0]  ID_EX_data1, ID_EX_data2;
    reg     [31:0]  ID_EX_pc, ID_EX_imm;
    reg     [4:0]   ID_EX_write_addr;
    reg     [3:0]   ID_EX_alu_op;
    reg     [1:0]   ID_EX_pc_src, ID_EX_mem_to_reg;
    reg             ID_EX_reg_write, ID_EX_alu_src, ID_EX_branch, ID_EX_b_type, ID_EX_auipc, ID_EX_mem_write;

    wire    [31:0]  alu_data1, alu_data2, alu_result;
    wire            alu_zero;
    reg     [31:0]  EX_MEM_alu_result, EX_MEM_pc, EX_MEM_imm;
    reg     [31:0]  EX_MEM_data2;
    reg     [4:0]   EX_MEM_write_addr;
    reg     [1:0]   EX_MEM_pc_src, EX_MEM_mem_to_reg;
    reg             EX_MEM_reg_write, EX_MEM_branch, EX_MEM_b_type, EX_MEM_mem_write;

    wire    [31:0]  write_data;
    wire    [31:0]  jal_addr, jalr_addr;
    reg     [31:0]  MEM_WB_data_in, MEM_WB_alu_result, MEM_WB_pc, MEM_WB_imm;
    reg     [4:0]   MEM_WB_write_addr;
    reg     [1:0]   MEM_WB_mem_to_reg;
    reg             MEM_WB_reg_write;


    assign pc_out = pc;

    always @(posedge clk or posedge rst) begin 
        if (rst) begin
            pc <= 32'b0;
            IF_ID_pc <= 32'b0;
            IF_ID_inst <= 32'b0;
            ID_EX_pc <= 32'b0;
            ID_EX_data1 <= 32'b0;
            ID_EX_data2 <= 32'b0;
            ID_EX_imm <= 32'b0;
            ID_EX_write_addr <= 5'b0;
            ID_EX_alu_op <= 4'b0;
            ID_EX_pc_src <= 2'b0;
            ID_EX_mem_to_reg <= 2'b0;
            ID_EX_reg_write <= 1'b0;
            ID_EX_alu_src <= 1'b0;
            ID_EX_branch <= 1'b0;
            ID_EX_b_type <= 1'b0;
            ID_EX_auipc <= 1'b0;
            ID_EX_mem_write <= 1'b0;
            EX_MEM_alu_result <= 32'b0;
            EX_MEM_pc <= 32'b0;
            EX_MEM_imm <= 32'b0;
            EX_MEM_data2 <= 32'b0;
            EX_MEM_write_addr <= 5'b0;
            EX_MEM_pc_src <= 2'b0;
            EX_MEM_mem_to_reg <= 2'b0;
            EX_MEM_reg_write <= 1'b0;
            EX_MEM_branch <= 1'b0;
            EX_MEM_b_type <= 1'b0;
            EX_MEM_mem_write <= 1'b0;
            MEM_WB_data_in <= 32'b0;
            MEM_WB_alu_result <= 32'b0;
            MEM_WB_pc <= 32'b0;
            MEM_WB_imm <= 32'b0;
            MEM_WB_write_addr <= 5'b0;
            MEM_WB_mem_to_reg <= 2'b0;
            MEM_WB_reg_write <= 1'b0;
        end
        else begin
            pc <= pc_next;

            IF_ID_pc <= pc;
            IF_ID_inst <= inst;

            ID_EX_pc <= IF_ID_pc;
            ID_EX_data1 <= read_data1;
            ID_EX_data2 <= read_data2;
            ID_EX_imm <= imm;
            ID_EX_write_addr <= IF_ID_inst[11:7];
            ID_EX_pc_src <= pc_src;
            ID_EX_mem_to_reg <= mem_to_reg;
            ID_EX_reg_write <= reg_write;
            ID_EX_alu_src <= alu_src;
            ID_EX_branch <= branch;
            ID_EX_b_type <= b_type;
            ID_EX_auipc <= auipc;
            ID_EX_alu_op <= alu_op;
            ID_EX_mem_write <= mem_write_;

            EX_MEM_pc <= ID_EX_pc;
            EX_MEM_imm <= ID_EX_imm;
            EX_MEM_data2 <= ID_EX_data2;
            EX_MEM_alu_result <= alu_result;
            EX_MEM_write_addr <= ID_EX_write_addr;
            EX_MEM_pc_src <= ID_EX_pc_src;
            EX_MEM_mem_to_reg <= ID_EX_mem_to_reg;
            EX_MEM_reg_write <= ID_EX_reg_write;
            EX_MEM_branch <= ID_EX_branch;
            EX_MEM_b_type <= ID_EX_b_type;
            EX_MEM_mem_write <= ID_EX_mem_write;

            MEM_WB_data_in <= data_in;
            MEM_WB_alu_result <= EX_MEM_alu_result;
            MEM_WB_pc <= EX_MEM_pc;
            MEM_WB_imm <= EX_MEM_imm;
            MEM_WB_write_addr <= EX_MEM_write_addr;
            MEM_WB_mem_to_reg <= EX_MEM_mem_to_reg;
            MEM_WB_reg_write <= EX_MEM_reg_write;

        end
    end

//--------------------ID--------------------//

    Regs regs (
        .clk(clk),
        .rst(rst),
        .we(MEM_WB_reg_write),
        .read_addr_1(IF_ID_inst[19:15]),
        .read_addr_2(IF_ID_inst[24:20]),
        .write_addr(MEM_WB_write_addr),
        .write_data(write_data),
        .read_data_1(read_data1),
        .read_data_2(read_data2),
        .debug_reg_addr(debug_reg_addr),
        .debug_reg(debug_reg)
    );

    Control control (
        .op_code(IF_ID_inst[6:0]),
        .funct3(IF_ID_inst[14:12]),
        .funct7_5(IF_ID_inst[30]),
        .alu_op(alu_op),
        .pc_src(pc_src),
        .mem_to_reg(mem_to_reg),
        .reg_write(reg_write),
        .alu_src_b(alu_src),
        .branch(branch),
        .b_type(b_type),
        .mem_write(mem_write_),
        .auipc(auipc)
    );

    ImmGen immgen (
        .inst(IF_ID_inst),
        .imm(imm)
    );

//--------------------EX--------------------//

    Mux2x32 mux2x32_1 (
        .I0(ID_EX_data1),
        .I1(ID_EX_pc),
        .s(ID_EX_auipc),
        .o(alu_data1)
    );

    Mux2x32 mux2x32_2 (
        .I0(ID_EX_data2),
        .I1(ID_EX_imm),
        .s(ID_EX_alu_src),
        .o(alu_data2)
    );

    ALU alu (
        .a(alu_data1),
        .b(alu_data2),
        .alu_op(ID_EX_alu_op),
        .res(alu_result),
        .zero(alu_zero)
    );

//--------------------MEM--------------------//
    assign addr_out = EX_MEM_alu_result;
    assign data_out = EX_MEM_data2;
    assign mem_write = EX_MEM_mem_write;

    assign jal_addr = EX_MEM_pc + EX_MEM_imm;
    assign jalr_addr = EX_MEM_alu_result;

    MuxPC mux_pc (
        .I0(pc + 4),
        .I1(jalr_addr),
        .I2(jal_addr),
        .I3(jal_addr),
        .s(EX_MEM_pc_src),
        .branch(EX_MEM_branch),
        .b_type(EX_MEM_b_type),
        .alu_res(EX_MEM_alu_result),
        .o(pc_next)
    );

    // assign pc_next = pc + 4;

//--------------------WB--------------------//

    Mux4x32 mux4x32 (
        .I0(MEM_WB_alu_result),
        .I1(MEM_WB_imm),
        .I2(MEM_WB_pc + 4),
        .I3(MEM_WB_data_in),
        .s(MEM_WB_mem_to_reg),
        .o(write_data)
    );

    
endmodule
