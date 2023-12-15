`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2023 07:12:04 PM
// Design Name: 
// Module Name: tb_riscv_ctrl
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
`define CLK 10

module tb_riscv_ctrl import riscv_pkg::*; ();

logic clk = 1'b1;
always #(`CLK/2) clk = ~clk;

logic rst_n;
logic [31:0] instr;
logic        ALU_zero;
logic        fetch_en, take_branch, reg_wen, use_imm, use_pc, const_4, jalr, clr_ALU_srcA, dmem_en, dmem_wen, mem_to_reg;
instr_type_t instr_type;
alu_op_t alu_op;
store_type_t store_type;
load_type_t load_type;

riscv_ctrl dut(
    .clk_i(clk),
    .rst_ni(rst_n),
    .instr_i(instr),
    .ALU_zero_i(ALU_zero),
    .fetch_en_o(fetch_en),
    .take_branch_o(take_branch),
    .curr_instr_o(instr_type),
    .reg_wen_o(reg_wen),
    .use_imm_o(use_imm),
    .use_pc_o(use_pc),
    .const_4_o(const_4),
    .jalr_o(jalr),
    .clr_ALU_srcA_o(clr_ALU_srcA),
    .ALU_op_o(alu_op),
    .dmem_en_o(dmem_en),
    .dmem_wen_o(dmem_wen),
    .store_type_o(store_type),
    .load_type_o(load_type),
    .mem_to_reg_o(mem_to_reg)
);

initial begin
    instr = '0;
    ALU_zero = '0;
    rst_n = 1'b1;

    @(posedge clk);
    rst_n = 1'b0;
    
    @(posedge clk);
    rst_n = 1'b1;
    test_fetch_fetch_en: assert (fetch_en == 1'b1)
      else $error("failed test_fetch_fetch_en");
    test_fetch_branch: assert (take_branch == 1'b0)
      else $error("failed test_fetch_branch");
    
    @(negedge clk);
    instr[6:0] = 7'b0110011;
    instr[14:12] = 3'b000;
    instr[31:25] = 7'b0100000;
    
    @(posedge clk);
    test_decode_r_type: assert (instr_type == R_type)
      else $error("failed test_decode_r_type");
      
   @(posedge clk);
    test_r_type_imm: assert (use_imm == 1'b0)
      else $error("failed test_r_type_imm");
    test_r_type_alu_op: assert (alu_op == SUB)
      else $error("failed test_r_type_alu_op");
    test_r_type_const4: assert (const_4 == 1'b0)
      else $error("failed test_r_type_const4");
    test_r_type_use_pc: assert (use_pc == 1'b0)
      else $error("failed test_r_type_use_pc");
    test_r_type_jalr: assert (jalr == 1'b0)
      else $error("failed test_r_type_jalr");
    test_r_type_clr_ALU_srcA: assert (clr_ALU_srcA == 1'b0)
      else $error("failed test_r_type_clr_ALU_srcA");
    
   @(posedge clk);
    test_r_type_mem_to_reg: assert (mem_to_reg == 1'b0)
      else $error("failed test_r_type_mem_to_reg");
    test_r_type_reg_wen: assert (reg_wen == 1'b1)
      else $error("failed test_r_type_reg_wen");
    test_r_type_dmem_wen: assert (dmem_wen == 1'b0)
      else $error("failed test_r_type");
   
   @(posedge clk);  // fetch stage
   
   @(negedge clk);
    instr[6:0] = 7'b0010011;
    instr[14:12] = 3'b100;
    
   @(posedge clk); // decode stage
    test_decode_i_type: assert (instr_type == I_type)
      else $error("failed test_decode_i_type");
   
   @(posedge clk); // EX stage
    test_i_type_imm: assert (use_imm == 1'b1)
      else $error("failed test_r_type_imm");
    test_i_type_alu_op: assert (alu_op == XOR)
      else $error("failed test_r_type_alu_op");
    test_i_type_const4: assert (const_4 == 1'b0)
      else $error("failed test_i_type_const4");
    test_i_type_use_pc: assert (use_pc == 1'b0)
      else $error("failed test_i_type_use_pc");
    test_i_type_jalr: assert (jalr == 1'b0)
      else $error("failed test_i_type_jalr");
    test_i_type_clr_ALU_srcA: assert (clr_ALU_srcA == 1'b0)
      else $error("failed test_i_type_clr_ALU_srcA");
      
    @(posedge clk); // WB stage
    test_i_type_mem_to_reg: assert (mem_to_reg == 1'b0)
      else $error("failed test_i_type_mem_to_reg");
    test_i_type_reg_wen: assert (reg_wen == 1'b1)
      else $error("failed test_i_type_reg_wen");
    test_i_type_dmem_wen: assert (dmem_wen == 1'b0)
      else $error("failed test_i_type_dmem_wen");
    
   
   // LH test
   @(posedge clk);  // fetch stage
   
   @(negedge clk);
    instr[6:0] = 7'b0000011;
    instr[14:12] = 3'b001;
    
   @(posedge clk);  // decode stage
    test_decode_LH: assert (instr_type == LOAD)
      else $error("failed test_decode_LH");
      
   @(posedge clk); // EX stage
    test_LH_imm: assert (use_imm == 1'b1)
      else $error("failed test_LH_imm");
    test_LH_alu_op: assert (alu_op == ADD)
      else $error("failed test_LH_alu_op");
    test_LH_const4: assert (const_4 == 1'b0)
      else $error("failed test_LH_const4");
    test_LH_use_pc: assert (use_pc == 1'b0)
      else $error("failed test_LH_use_pc");
    test_LH_jalr: assert (jalr == 1'b0)
      else $error("failed test_LH_jalr");
    test_LH_clr_ALU_srcA: assert (clr_ALU_srcA == 1'b0)
      else $error("failed test_LH_clr_ALU_srcA");
       
   @(posedge clk); // MEM WRITE
    test_LH_dmem_en: assert (dmem_en == 1'b1)
      else $error("failed test_LH_dmem_en");
    test_LH_dmem_wen: assert (dmem_wen == 1'b0)
      else $error("failed test_LH_dmem_wen");
    test_LH_load_type: assert (load_type == LH)
      else $error("failed test_LH_load_type");
      
    @(posedge clk); // WB stage
    test_LH_mem_to_reg: assert (mem_to_reg == 1'b1)
      else $error("failed test_LH_mem_to_reg");
   
   // JALR test
   @(posedge clk);  // fetch stage
   
   @(negedge clk);
    instr[6:0] = 7'b1100111;
    instr[14:12] = 3'b000;
    
   @(posedge clk);  // decode stage
    test_decode_JALR: assert (instr_type == JALR)
      else $error("failed test_decode_JALR");
      
   @(posedge clk); // EX stage
    test_JALR_alu_op: assert (alu_op == ADD)
      else $error("failed test_LH_alu_op");
    test_JALR_const4: assert (const_4 == 1'b1)
      else $error("failed test_JALR_const4");
    test_JALR_use_pc: assert (use_pc == 1'b1)
      else $error("failed test_JALR_use_pc");
    test_JALR_jalr: assert (jalr == 1'b1)
      else $error("failed test_JALR_jalr");
    test_JALR_imm: assert (use_imm == 1'b0)
      else $error("failed test_JALR_imm");
    test_JALR_clr_ALU_srcA: assert (clr_ALU_srcA == 1'b0)
      else $error("failed test_JALR_clr_ALU_srcA");
       
    @(posedge clk); // WB stage
    test_JALR_mem_to_reg: assert (mem_to_reg == 1'b0)
      else $error("failed test_JALR_mem_to_reg");
    test_JALR_branch: assert (take_branch == 1'b1)
      else $error("failed test_JALR_branch");
    test_JALR_reg_wen: assert (reg_wen == 1'b1)
      else $error("failed test_JALR_reg_wen");
    test_JALR_dmem_en: assert (dmem_wen == 1'b0)
      else $error("failed test_JALR_dmem_en");
    test_JALR_dmem_wen: assert (dmem_wen == 1'b0)
      else $error("failed test_JALR_dmem_wen");
   
   // BEQ test
   @(posedge clk);  // fetch stage
    test_JALR_branch_2: assert (take_branch == 1'b1)
      else $error("failed test_JALR_branch_2");
      
   @(negedge clk);
    instr[6:0] = 7'b1100011;
    instr[14:12] = 3'b000;
    
   @(posedge clk);  // decode stage
    test_JALR_branch_3: assert (take_branch == 1'b0)
      else $error("failed test_JALR_branch_3");
    test_decode_BEQ: assert (instr_type == B_type)
      else $error("failed test_decode_BEQ");
      
   @(posedge clk); // EX stage
    test_BEQ_alu_op: assert (alu_op == SUB)
      else $error("failed test_LH_alu_op");
    test_BEQ_const4: assert (const_4 == 1'b0)
      else $error("failed test_JALR_const4");
    test_BEQ_use_pc: assert (use_pc == 1'b0)
      else $error("failed test_JALR_use_pc");
    test_BEQ_jalr: assert (jalr == 1'b0)
      else $error("failed test_JALR_jalr");
    test_BEQ_imm: assert (use_imm == 1'b0)
      else $error("failed test_JALR_imm");
    test_BEQ_clr_ALU_srcA: assert (clr_ALU_srcA == 1'b0)
      else $error("failed test_JALR_clr_ALU_srcA");
   

   @(negedge clk);
   ALU_zero = 1'b1; // take branch
   
   @(posedge clk);  // check state
   ALU_zero = 1'b0;
   
   @(posedge clk); // fetch stage
    test_BEQ_fetch_en: assert (fetch_en == 1'b1)
      else $error("failed test_BEQ_fetch_en");
    test_BEQ_branch: assert (take_branch == 1'b1)
      else $error("failed test_BEQ_branch");
   
   // FENCE      
   @(negedge clk);
    instr[6:0] = 7'b0001111;
    instr[14:12] = 3'b000;
    
   @(posedge clk);  // decode stage
    test_BEQ_branch_2: assert (take_branch == 1'b0)
      else $error("failed test_BEQ_branch_2");
    test_decode_FENCE: assert (instr_type == FENCE)
      else $error("failed test_decode_FENCE");
      
   @(posedge clk); // FETCH stage
    test_FENCE_fetch_en: assert (fetch_en == 1'b1)
      else $error("failed test_BEQ_fetch_en");
    test_FENCE_branch: assert (take_branch == 1'b0)
      else $error("failed test_BEQ_branch");
   
   // EBREAK
   @(negedge clk);
    instr[6:0] = 7'b1110011;
    instr[14:12] = 3'b000;
    instr[31:20] = 12'b000000000001;
    
   @(posedge clk);  // decode stage
    test_EBREAK_branch: assert (take_branch == 1'b0)
      else $error("failed test_EBREAK_branch");
    test_decode_EBREAK: assert (instr_type == EBREAK)
      else $error("failed test_decode_EBREAK");
   
   @(posedge clk);
   @(posedge clk);
    instr[6:0] = 7'b0001111;
    instr[14:12] = 3'b000;
   @(posedge clk);
    instr[6:0] = 7'b1100011;
    instr[14:12] = 3'b000;
   @(posedge clk);
    $finish(0);
end

endmodule
