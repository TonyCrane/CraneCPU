`timescale 1ns / 1ps

module CPU(
    input           clk,
    input           rst,
    input           stall,
    input   [31:0]  inst,
    input   [63:0]  data_in,  // data from data memory
    input   [4:0]   debug_reg_addr,
    output  [63:0]  addr_out, // data memory address
    output  [63:0]  data_out, // data to data memory
    output  [63:0]  pc_out,   // connect to instruction memory
    output          mem_write,
    output          mem_read,
    output  [63:0]  debug_reg,
    output  [63:0]  satp,
    output  [2:0]   data_width
);
    reg     [63:0]  pc;
    wire    [63:0]  pc_next;
    
    wire    [63:0]  IF_ID_pc;
    wire    [31:0]  IF_ID_inst;

    wire    [63:0]  read_data1, read_data2, imm;
    wire    [63:0]  csr_read_data, csr_ret_pc;
    wire    [63:0]  csr_write_scause, sstatus, csr_write_sstatus;
    wire    [11:0]  csr_read_addr, csr_write_addr;
    wire    [3:0]   alu_op;
    wire    [2:0]   mem_to_reg;
    wire    [1:0]   pc_src, trap;
    wire            alu_src;
    wire            reg_write, branch, b_type, auipc, mem_write_;
    wire            mem_read_, bubble_stop, jump;
    wire            csr_write, csr_write_src, rev_imm;
    wire            alu_work_on_word;
    wire    [2:0]   data_width_;
    wire    [63:0]  ID_EX_data1, ID_EX_data2;
    wire    [63:0]  ID_EX_pc, ID_EX_imm;
    wire    [4:0]   ID_EX_rs1, ID_EX_rs2;
    wire    [4:0]   ID_EX_write_addr;
    wire    [3:0]   ID_EX_alu_op;
    wire    [2:0]   ID_EX_mem_to_reg;
    wire    [1:0]   ID_EX_pc_src;
    wire            ID_EX_alu_src;
    wire            ID_EX_reg_write, ID_EX_branch, ID_EX_b_type, ID_EX_auipc, ID_EX_mem_write;
    wire            ID_EX_mem_read;
    wire    [11:0]  ID_EX_csr_write_addr;
    wire            ID_EX_csr_write, ID_EX_csr_write_src, ID_EX_rev_imm;
    wire    [63:0]  ID_EX_csr_write_data, ID_EX_csr_read_data;
    wire            ID_EX_alu_work_on_word;
    wire    [2:0]   ID_EX_data_width;

    wire    [63:0]  alu_data1, alu_data2, alu_result;
    wire            alu_zero;
    wire    [2:0]   forwardA, forwardB;
    wire    [1:0]   forwardC;
    wire    [63:0]  ex_mem_data2;
    wire    [63:0]  EX_MEM_alu_result, EX_MEM_pc, EX_MEM_imm;
    wire    [63:0]  EX_MEM_data2;
    wire    [4:0]   EX_MEM_write_addr;
    wire    [2:0]   EX_MEM_mem_to_reg;
    wire    [1:0]   EX_MEM_pc_src;
    wire            EX_MEM_reg_write, EX_MEM_branch, EX_MEM_b_type, EX_MEM_mem_write, EX_MEM_mem_read;
    wire    [11:0]  EX_MEM_csr_write_addr;
    wire            EX_MEM_csr_write, EX_MEM_csr_write_src, EX_MEM_rev_imm;
    wire    [63:0]  EX_MEM_csr_write_data, EX_MEM_csr_read_data;
    wire    [2:0]   EX_MEM_data_width;

    wire    [63:0]  write_data;
    wire    [63:0]  jal_addr, jalr_addr;
    wire    [63:0]  MEM_WB_data_in, MEM_WB_alu_result, MEM_WB_pc, MEM_WB_imm;
    wire    [4:0]   MEM_WB_write_addr;
    wire    [2:0]   MEM_WB_mem_to_reg;
    wire            MEM_WB_reg_write;
    wire    [11:0]  MEM_WB_csr_write_addr;
    wire            MEM_WB_csr_write, MEM_WB_csr_write_src, MEM_WB_rev_imm;
    wire    [63:0]  MEM_WB_csr_write_data, MEM_WB_csr_read_data;


    assign pc_out = pc;

    reg             ID_EX_flush, IF_ID_en;


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 64'h80200000;
        end else if (~bubble_stop && ~stall) begin
            pc <= pc_next;
        end
    end

    RegIFID reg_IFID (
        .clk(clk), .rst(rst), .en(~stall),
        .stall(bubble_stop), .flush(jump || trap != 2'b0),
        .pc_IF(pc), .inst_IF(inst),
        .pc_ID(IF_ID_pc), .inst_ID(IF_ID_inst)
    );

    RegIDEX reg_IDEX (
        .clk(clk), .rst(rst), .en(~stall),
        .flush(bubble_stop),
        .pc_ID(IF_ID_pc), .pc_src_ID(pc_src), .rs1_ID(IF_ID_inst[19:15]), .rs2_ID(IF_ID_inst[24:20]), .rd_ID(IF_ID_inst[11:7]),
        .data1_ID(read_data1), .data2_ID(read_data2), .imm_ID(imm),
        .alu_op_ID(alu_op), .alu_src_ID(alu_src), .alu_work_on_word_ID(alu_work_on_word),
        .reg_write_ID(reg_write), .mem_to_reg_ID(mem_to_reg), .mem_read_ID(mem_read_), .mem_write_ID(mem_write_), .data_width_ID(data_width_),
        .branch_ID(branch), .b_type_ID(b_type), .auipc_ID(auipc),
        .csr_write_ID(csr_write), .csr_write_src_ID(csr_write_src), .csr_rd_ID(csr_write_addr), .csr_write_data_ID(read_data1), .csr_read_data_ID(csr_read_data),

        .pc_EX(ID_EX_pc), .pc_src_EX(ID_EX_pc_src), .rs1_EX(ID_EX_rs1), .rs2_EX(ID_EX_rs2), .rd_EX(ID_EX_write_addr),
        .data1_EX(ID_EX_data1), .data2_EX(ID_EX_data2), .imm_EX(ID_EX_imm),
        .alu_op_EX(ID_EX_alu_op), .alu_src_EX(ID_EX_alu_src), .alu_work_on_word_EX(ID_EX_alu_work_on_word),
        .reg_write_EX(ID_EX_reg_write), .mem_to_reg_EX(ID_EX_mem_to_reg), .mem_read_EX(ID_EX_mem_read), .mem_write_EX(ID_EX_mem_write), .data_width_EX(ID_EX_data_width),
        .branch_EX(ID_EX_branch), .b_type_EX(ID_EX_b_type), .auipc_EX(ID_EX_auipc),
        .csr_write_EX(ID_EX_csr_write), .csr_write_src_EX(ID_EX_csr_write_src), .csr_rd_EX(ID_EX_csr_write_addr), .csr_write_data_EX(ID_EX_csr_write_data), .csr_read_data_EX(ID_EX_csr_read_data)
    );

    RegEXMEM reg_EXMEM (
        .clk(clk), .rst(rst), .en(~stall),
        .pc_EX(ID_EX_pc), .pc_src_EX(ID_EX_pc_src),
        .rd_EX(ID_EX_write_addr), .data2_EX(ex_mem_data2), .imm_EX(ID_EX_imm), .alu_result_EX(alu_result),
        .mem_to_reg_EX(ID_EX_mem_to_reg), .reg_write_EX(ID_EX_reg_write), .mem_write_EX(ID_EX_mem_write), .mem_read_EX(ID_EX_mem_read), .data_width_EX(ID_EX_data_width),
        .branch_EX(ID_EX_branch), .b_type_EX(ID_EX_b_type),
        .csr_rd_EX(ID_EX_csr_write_addr), .csr_write_EX(ID_EX_csr_write), .csr_write_src_EX(ID_EX_csr_write_src), .csr_write_data_EX(csr_write_src ? csr_write_sstatus : alu_data1), .csr_read_data_EX(ID_EX_csr_read_data),

        .pc_MEM(EX_MEM_pc), .pc_src_MEM(EX_MEM_pc_src),
        .rd_MEM(EX_MEM_write_addr), .data2_MEM(EX_MEM_data2), .imm_MEM(EX_MEM_imm), .alu_result_MEM(EX_MEM_alu_result),
        .mem_to_reg_MEM(EX_MEM_mem_to_reg), .reg_write_MEM(EX_MEM_reg_write), .mem_write_MEM(EX_MEM_mem_write), .mem_read_MEM(EX_MEM_mem_read), .data_width_MEM(EX_MEM_data_width),
        .branch_MEM(EX_MEM_branch), .b_type_MEM(EX_MEM_b_type),
        .csr_rd_MEM(EX_MEM_csr_write_addr), .csr_write_MEM(EX_MEM_csr_write), .csr_write_src_MEM(EX_MEM_csr_write_src), .csr_write_data_MEM(EX_MEM_csr_write_data), .csr_read_data_MEM(EX_MEM_csr_read_data)
    );

    RegMEMWB reg_MEM_WB (
        .clk(clk), .rst(rst), .en(~stall),
        .pc_MEM(EX_MEM_pc), .imm_MEM(EX_MEM_imm), .alu_result_MEM(EX_MEM_alu_result), .data_in_MEM(data_in),
        .rd_MEM(EX_MEM_write_addr), .mem_to_reg_MEM(EX_MEM_mem_to_reg), .reg_write_MEM(EX_MEM_reg_write),
        .csr_rd_MEM(EX_MEM_csr_write_addr), .csr_write_MEM(EX_MEM_csr_write), .csr_write_src_MEM(EX_MEM_csr_write_src), .csr_write_data_MEM(EX_MEM_csr_write_data), .csr_read_data_MEM(EX_MEM_csr_read_data),

        .pc_WB(MEM_WB_pc), .imm_WB(MEM_WB_imm), .alu_result_WB(MEM_WB_alu_result), .data_in_WB(MEM_WB_data_in),
        .rd_WB(MEM_WB_write_addr), .mem_to_reg_WB(MEM_WB_mem_to_reg), .reg_write_WB(MEM_WB_reg_write),
        .csr_rd_WB(MEM_WB_csr_write_addr), .csr_write_WB(MEM_WB_csr_write), .csr_write_src_WB(MEM_WB_csr_write_src), .csr_write_data_WB(MEM_WB_csr_write_data), .csr_read_data_WB(MEM_WB_csr_read_data)
    );

//--------------------ID--------------------//

    StallUnit stallunit (
        .ID_EX_mem_read(ID_EX_mem_read),
        .ID_EX_rd(ID_EX_write_addr),
        .IF_ID_rs1(IF_ID_inst[19:15]),
        .IF_ID_rs2(IF_ID_inst[24:20]),
        .jump(jump),
        .ID_EX_reg_write(ID_EX_reg_write),
        .bubble_stop(bubble_stop)
    );

    assign jal_addr = IF_ID_pc + imm;
    wire    [63:0]  reg1, reg2;
    assign reg1 = (jump && EX_MEM_reg_write && (EX_MEM_write_addr != 0) && (EX_MEM_write_addr == IF_ID_inst[19:15])) ? (EX_MEM_mem_to_reg == 3'b011 ? data_in : EX_MEM_alu_result) : read_data1;
    assign reg2 = (jump && EX_MEM_reg_write && (EX_MEM_write_addr != 0) && (EX_MEM_write_addr == IF_ID_inst[24:20])) ? (EX_MEM_mem_to_reg == 3'b011 ? data_in : EX_MEM_alu_result) : read_data2;
    assign jalr_addr = reg1 + reg2;
    wire    [63:0]  alu_res_tmp;
    assign alu_res_tmp = 
        (alu_op == 4'b0100) ? (reg1 ^ reg2) :
        (alu_op == 4'b0011) ? (reg1 < reg2) :
        ($signed(reg1) < $signed(reg2));

    MuxPC mux_pc (
        .I0(jump ? pc : pc + 4),
        .I1(jalr_addr),
        .I2(jal_addr),
        .I3(csr_ret_pc),
        .s(pc_src),
        .branch(branch),
        .b_type(b_type),
        .alu_res(alu_res_tmp),
        .o(pc_next)
    );

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

    wire set_satp;
    assign set_satp = EX_MEM_csr_write && (EX_MEM_csr_write_addr == 12'h180);

    CSRs csrs (
        .clk(clk),
        .rst(rst),
        .we(set_satp ? EX_MEM_csr_write : MEM_WB_csr_write),
        .trap(trap),
        .pc(IF_ID_pc),
        .csr_read_addr(csr_read_addr),
        .csr_write_addr(set_satp ? EX_MEM_csr_write_addr : MEM_WB_csr_write_addr),
        .csr_write_data(set_satp ? EX_MEM_csr_write_data : MEM_WB_csr_write_data),
        .csr_write_scause(csr_write_scause),
        .csr_read_data(csr_read_data),
        .csr_satp(satp),
        .csr_sstatus(sstatus)
    );

    CSRReturnForwarding csrretforwarding (
        .ID_EX_csr_write(ID_EX_csr_write),
        .ID_EX_csr_write_addr(ID_EX_csr_write_addr),
        .ID_EX_csr_write_data(ID_EX_csr_write_data),
        .EX_MEM_alu_result(EX_MEM_alu_result),
        .csr_read_data(csr_read_data),
        .trap(trap),
        .EX_MEM_rd(EX_MEM_write_addr),
        .ID_EX_rs1(ID_EX_rs1),
        .csr_ret_pc(csr_ret_pc)
    );

    Control control (
        .op_code(IF_ID_inst[6:0]),
        .funct3(IF_ID_inst[14:12]),
        .funct7_5(IF_ID_inst[30]),
        .csr(IF_ID_inst[31:20]),
        .pc(IF_ID_pc),
        .sstatus(sstatus),
        .pc_src(pc_src),
        .reg_write(reg_write),
        .alu_src_b(alu_src),
        .alu_op(alu_op),
        .mem_to_reg(mem_to_reg),
        .mem_write(mem_write_),
        .branch(branch),
        .b_type(b_type),
        .auipc(auipc),
        .mem_read(mem_read_),
        .jump(jump),
        .trap(trap),
        .csr_read_addr(csr_read_addr),
        .csr_write_addr(csr_write_addr),
        .csr_write(csr_write),
        .csr_write_src(csr_write_src),
        .csr_write_sstatus(csr_write_sstatus),
        .csr_write_scause(csr_write_scause),
        .rev_imm(rev_imm),
        .alu_work_on_word(alu_work_on_word),
        .data_width(data_width_)
    );

    ImmGen immgen (
        .inst(IF_ID_inst),
        .imm(imm)
    );

//--------------------EX--------------------//

    ForwardingUnit forwarding (
        .EX_MEM_rd(EX_MEM_write_addr),
        .MEM_WB_rd(MEM_WB_write_addr),
        .ID_EX_rs1(ID_EX_rs1),
        .ID_EX_rs2(ID_EX_rs2),
        .EX_MEM_reg_write(EX_MEM_reg_write),
        .MEM_WB_reg_write(MEM_WB_reg_write),
        .EX_MEM_mem_to_reg(EX_MEM_mem_to_reg),
        .MEM_WB_mem_to_reg(MEM_WB_mem_to_reg),
        .auipc(ID_EX_auipc),
        .alu_src_b(ID_EX_alu_src),
        .ForwardA(forwardA),
        .ForwardB(forwardB),
        .ForwardC(forwardC)
    );

    Mux8x64 mux_alu_a (
        .I0(ID_EX_data1),
        .I1(EX_MEM_alu_result),
        .I2(write_data),
        .I3(ID_EX_pc),
        .I4(EX_MEM_pc + 4),
        .I5(MEM_WB_pc + 4),
        .I6(EX_MEM_imm),
        .I7(MEM_WB_imm),
        .s(forwardA),
        .o(alu_data1)
    );

    wire    [63:0]  alu_b_imm;
    assign alu_b_imm = (ID_EX_mem_to_reg == 3'b100 ? ID_EX_csr_read_data : ID_EX_imm);

    Mux8x64 mux_alu_b (
        .I0(ID_EX_data2),
        .I1(EX_MEM_alu_result),
        .I2(write_data),
        .I3(alu_b_imm),
        .I4(EX_MEM_pc + 4),
        .I5(MEM_WB_pc + 4),
        .I6(EX_MEM_imm),
        .I7(MEM_WB_imm),
        .s(forwardB),
        .o(alu_data2)
    );

    ALU alu (
        .a(alu_data1),
        .b(alu_data2),
        .alu_op(ID_EX_alu_op),
        .alu_work_on_word(ID_EX_alu_work_on_word),
        .res(alu_result),
        .zero(alu_zero)
    );

    Mux4x64 mux_data2 (
        .I0(ID_EX_data2),
        .I1(EX_MEM_alu_result),
        .I2(write_data),
        .I3(64'h00000000),
        .s(forwardC),
        .o(ex_mem_data2)
    );

//--------------------MEM--------------------//
    assign addr_out = EX_MEM_alu_result;
    assign data_out = EX_MEM_data2;
    assign mem_write = EX_MEM_mem_write;
    assign mem_read = EX_MEM_mem_read;
    assign data_width = EX_MEM_data_width;

//--------------------WB--------------------//

    Mux8x64 mux8x64 (
        .I0(MEM_WB_alu_result),
        .I1(MEM_WB_imm),
        .I2(MEM_WB_pc + 4),
        .I3(MEM_WB_data_in),
        .I4(MEM_WB_csr_read_data),
        .I5(64'b0),
        .I6(64'b0),
        .I7(64'b0),
        .s(MEM_WB_mem_to_reg),
        .o(write_data)
    );

    
endmodule
