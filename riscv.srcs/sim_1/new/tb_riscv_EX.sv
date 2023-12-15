`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2023 07:28:45 PM
// Design Name: 
// Module Name: tb_riscv_EX
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
`define CLK 10

module tb_riscv_EX import riscv_pkg::*; ();

logic clk = 1'b1;
always #(`CLK/2) clk = ~clk;

logic           rst_n;
logic [31:0]    reg_dataA, reg_dataB, imm, PC;
logic           use_imm, use_pc, const_4, jalr, clr_ALU_srcA;
alu_op_t        ALU_op;
logic [31:0]    ALU_out, branch_addr;
logic           ALU_zero;

riscv_EX dut(
    .clk_i(clk),
    .rst_ni(rst_n),
    .reg_dataA_i(reg_dataA),
    .reg_dataB_i(reg_dataB),
    .imm_i(imm),
    .PC_i(PC),
    .use_imm_i(use_imm),
    .use_pc_i(use_pc),
    .const_4_i(const_4),
    .jalr_i(jalr),
    .clr_ALU_srcA_i(clr_ALU_srcA),
    .ALU_op_i(ALU_op),
    .ALU_out_o(ALU_out),
    .ALU_zero_o(ALU_zero),
    .branch_addr_o(branch_addr)
);

always begin
    rst_n = 1'b1;
    reg_dataA = '0;
    reg_dataB = '0;
    imm = '0;
    PC = '0;
    use_imm = 1'b0;
    use_pc = 1'b0;
    const_4 = 1'b0;
    jalr = 1'b0;
    clr_ALU_srcA = 1'b0;
    ALU_op = ADD;

    @(posedge clk);
    rst_n = 1'b0;
    @(posedge clk);
    rst_n = 1'b1;

    reg_dataA = $urandom;
    reg_dataB = $urandom;
    imm       = $urandom;
    PC        = $urandom;

    // test a simple r-type instruction
    // ALU operations are tested in alu testbench
    @(posedge clk); #1
    test_r_ADD: assert (ALU_out == reg_dataA + reg_dataB)
      else $error("failed test_r_ADD");

    // test simple i-type
    // ALU operations are tested in alu testbench
    use_imm = 1'b1;
    @(posedge clk); #1
    test_i_ADD: assert (ALU_out == reg_dataA + imm)
      else $error("failed test_i_ADD");

    // test LUI
    use_imm = 1'b1;
    clr_ALU_srcA = 1'b1;
    @(posedge clk); #1
    test_LUI: assert (ALU_out == imm)
      else $error("failed test_LUI");

    // test AUIPC
    clr_ALU_srcA = 1'b0;
    use_imm = 1'b1;
    use_pc = 1'b1;
    @(posedge clk); #1
    test_AUIPC: assert (ALU_out == PC+imm)
      else $error("failed test_AUIPC");

    // test JAL
    use_pc = 1'b1;
    use_imm = 1'b0;
    const_4 = 1'b1;
    @(posedge clk); #1
    test_JAL_alu_out: assert (ALU_out == (PC + 4))
      else $error("failed test_JAL_alu_out");
    test_JAL_branch_addr: assert (branch_addr == (PC + imm))
      else $error("failed test_JAL_branch_addr");

    // test JALR
    jalr = 1'b1;
    @(posedge clk); #1
    test_JALR_alu_out: assert (ALU_out == (PC + 4))
      else $error("failed test_JALR_alu_out");
    test_JALR_branch_addr: assert (branch_addr == (reg_dataA + imm))
      else $error("failed test_JALR_branch_addr");

    @(posedge clk);
    $finish();
end

endmodule

