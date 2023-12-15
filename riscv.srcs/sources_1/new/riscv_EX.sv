`timescale 1ns / 1ps

module riscv_EX
import riscv_pkg::*;
(
    input   logic   clk_i,
    input   logic   rst_ni,

    input   logic [31:0]    reg_dataA_i,
    input   logic [31:0]    reg_dataB_i,
    input   logic [31:0]    imm_i,
    input   logic [31:0]    PC_i,

    // control signals
    input   logic           use_imm_i,
    input   logic           use_pc_i,
    input   logic           use_const_4_i,
    input   logic           jalr_i,
    input   logic           clr_alu_srcA_i,
    input   alu_op_t        alu_op_i,

    output  logic [31:0]    alu_out_o,
    output  logic           alu_zero_o,
    output  logic [31:0]    branch_addr_o
);

logic [31:0] alu_srcA, alu_srcB;
logic [31:0] alu_out;
logic alu_zero;

assign alu_srcA =   use_pc_i ? PC_i :       // FOR AUIPC, JAL, JALR
                    clr_alu_srcA_i ? '0 :   // FOR LUI
                    reg_dataA_i;
assign alu_srcB =   use_imm_i ? imm_i :
                    use_const_4_i ? 32'd4 :   // FOR JAL, JALR
                    reg_dataB_i;

riscv_alu alu(
    .srcA_i(alu_srcA),
    .srcB_i(alu_srcB),
    .op_i(alu_op_i),
    .out_o(alu_out),
    .zero_o(alu_zero)
);

always_ff @(posedge clk_i) begin
    if(!rst_ni) begin
        branch_addr_o <= '0;
        alu_out_o <= '0;
        alu_zero_o <= '0;
    end
    else begin
        // the immediate is already correctly computed selected in the ID stage
        branch_addr_o <= (jalr_i) ? imm_i + reg_dataA_i : imm_i + PC_i;
        alu_out_o <= alu_out;
        alu_zero_o <= alu_zero;
    end
end

endmodule

