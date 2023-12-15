`timescale 1ns / 1ps

module riscv_WB (
    // input datapath signals
    input   logic [31:0] mem_out_i,
    input   logic [31:0] alu_out_i,
    // control signals
    input   logic        mem_to_reg_i,
    // output datapath signals
    output  logic [31:0] reg_wdata_o
);

assign reg_wdata_o = (mem_to_reg_i) ? mem_out_i : alu_out_i;

endmodule
