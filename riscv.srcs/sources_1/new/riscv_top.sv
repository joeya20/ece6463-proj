`timescale 1ns / 1ps

module riscv_top   import riscv_pkg::*; #(
  parameter string IMEM_PATH = "rc5.mem"
) (
    input logic CLK100MHZ,
    input logic rst_ni,
    input  logic [15:0] sw_i,
    
    output logic [15:0] led_o
//    output logic [31:0] PC_o,
//    output state_t  curr_state_o
);

  // datapath signals
  logic        [31:0] PC;
  logic        [31:0] instr;
  logic        [31:0] branch_addr;
  logic        [31:0] reg_wdata;
  logic        [31:0] imm;
  logic        [31:0] reg_rdataA, reg_rdataB;
  logic               alu_zero;
  logic        [31:0] mem_rdata;
  logic        [31:0] alu_out;

  // control signals
  logic update_pc;
  logic imem_en;
  logic take_branch;
  instr_type_t instr_type;
  logic reg_wen;
  logic use_imm;
  logic use_pc;
  logic use_const_4;
  logic jalr;
  logic clr_alu_srcA;
  alu_op_t alu_op;
  logic mem_en, mem_wen;
  store_type_t store_type;
  load_type_t load_type;
  logic mem_to_reg;
  state_t curr_state;
  
  assign curr_state_o = curr_state;
  
  riscv_IF #(.IMEM_PATH(IMEM_PATH)) IF (
    // Inputs
    .clk_i(CLK100MHZ),
    .rst_ni(rst_ni),
    .branch_addr_i(branch_addr),
    .imem_en_i(imem_en),
    .update_pc_i(update_pc),
    .branch_i(take_branch),
    // Outputs
    .instr_o(instr),
    .PC_o(PC)
  );

  riscv_ID ID (
    /* AUTOINST */
    // Inputs
    .clk_i(CLK100MHZ),
    .rst_ni(rst_ni),
    .instr_i(instr),
    .wdata_i(reg_wdata),
    .wen_i(reg_wen),
    .curr_instr_type_i(instr_type),
    // Outputs
    .rdataA_o(reg_rdataA),
    .rdataB_o(reg_rdataB),
    .imm_o(imm)
  );

  riscv_EX EX (
    /* AUTOINST */
    // Inputs
    .clk_i(CLK100MHZ),
    .rst_ni(rst_ni),
    .reg_dataA_i(reg_rdataA),
    .reg_dataB_i(reg_rdataB),
    .imm_i(imm),
    .PC_i(PC),
    .use_imm_i(use_imm),
    .use_pc_i(use_pc),
    .use_const_4_i(use_const_4),
    .jalr_i(jalr),
    .clr_alu_srcA_i(clr_alu_srcA),
    .alu_op_i(alu_op),
    // Outputs
    .alu_out_o(alu_out),
    .alu_zero_o(alu_zero),
    .branch_addr_o(branch_addr)
  );

  riscv_MEM MEM (
    /* AUTOINST */
    // Inputs
    .clk_i(CLK100MHZ),
    .rst_ni(rst_ni),
    .alu_out_i(alu_out),
    .wdata_i(reg_rdataB),
    .en_i(mem_en),
    .wen_i(mem_wen),
    .store_type_i(store_type),
    .load_type_i(load_type),
    .sw_i(sw_i),
    // Outputs
    .led_o(led_o),
    .rdata_o(mem_rdata)
  );

  riscv_WB WB (
    // Inputs
    .mem_out_i(mem_rdata),
    .alu_out_i(alu_out),
    .mem_to_reg_i(mem_to_reg),
    // Outputs
    .reg_wdata_o(reg_wdata)
  );

  riscv_ctrl ctrl (
    /* AUTOINST */
    // Inputs
    .clk_i(CLK100MHZ),
    .rst_ni(rst_ni),
    .instr_i(instr),
    .alu_zero_i(alu_zero),
    // Outputs
    .imem_en_o(imem_en),
    .update_pc_o(update_pc),
    .take_branch_o(take_branch),
    .instr_type_o(instr_type),
    .reg_wen_o(reg_wen),
    .use_imm_o(use_imm),
    .use_pc_o(use_pc),
    .use_const_4_o(use_const_4),
    .jalr_o(jalr),
    .clr_alu_srcA_o(clr_alu_srcA),
    .alu_op_o(alu_op),
    .dmem_en_o(mem_en),
    .dmem_wen_o(mem_wen),
    .store_type_o(store_type),
    .load_type_o(load_type),
    .mem_to_reg_o(mem_to_reg),
    .curr_state_o(curr_state)
  );
  
  assign PC_o = PC;
  
endmodule
