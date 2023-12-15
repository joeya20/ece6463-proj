`timescale 1ns / 1ps

module riscv_ID
import riscv_pkg::*;
(
    input   logic           clk_i,
    input   logic           rst_ni,
    input   logic [31:0]    instr_i,
    input   logic [31:0]    wdata_i,

    // control signals
    input   logic           wen_i,
    input   instr_type_t    curr_instr_type_i,

    output  logic [31:0]    rdataA_o,
    output  logic [31:0]    rdataB_o,
    output  logic [31:0]    imm_o
);

logic [4:0] rs, rt, rd;
assign rs = instr_i[19:15];
assign rt = instr_i[24:20];
assign rd = instr_i[11:7];

logic [31:0] I_imm, S_imm, U_imm, J_imm, B_imm;
assign I_imm = {{21{instr_i[31]}}, instr_i[30:20]};
assign S_imm = {{21{instr_i[31]}}, {instr_i[30:25], instr_i[11:7]}};
assign U_imm = {instr_i[31:12], 12'd0};
assign J_imm = {{12{instr_i[31]}}, {instr_i[19:12], {instr_i[20], {instr_i[30:25], {instr_i[24:21], 1'b0}}}}};
assign B_imm = {{20{instr_i[31]}}, {instr_i[7], {instr_i[30:25], {instr_i[11:8], 1'b0}}}};

logic [31:0] RF_rdataA, RF_rdataB;
always_ff @( posedge clk_i ) begin : pipeline_regs
    if(!rst_ni) begin
        rdataA_o <= '0;
        rdataB_o <= '0;
        imm_o <= '0;
    end
    else begin
        rdataA_o <= RF_rdataA;
        rdataB_o <= RF_rdataB;
        // output correct immediate depending on instruction type
        case (curr_instr_type_i)
            I_type: imm_o <= I_imm;
            S_type: imm_o <= S_imm;
            J_type: imm_o <= J_imm;
            B_type: imm_o <= B_imm;
            AUIPC: imm_o <= U_imm;
            LUI: imm_o <= U_imm;
            JALR: imm_o <= I_imm;
            default: ;
        endcase
    end
end

riscv_regFile rf(
    .clk_i(clk_i),
    .rst_ni(rst_ni),

    .rregA_i(rs),
    .rregB_i(rt),
    .rdataA_o(RF_rdataA),
    .rdataB_o(RF_rdataB),

    .wen_i(wen_i),
    .wreg_i(rd),
    .wdata_i(wdata_i)
);

endmodule
