`timescale 1ns / 1ps
`define CLK 10

`timescale 1ns / 1ps
`define CLK 10

module tb_riscv_ID import riscv_pkg::*; ();

logic clk = 1'b1;
always #(`CLK/2) clk = ~clk;

logic           rst_n;
logic [31:0]    instr;
logic [31:0]    wdata;
logic           wen;
instr_type_t    curr_instr_type;
logic [31:0]    rdataA;
logic [31:0]    rdataB;
logic [31:0]    imm;

riscv_ID dut(
    .clk_i(clk),
    .rst_ni(rst_n),
    .instr_i(instr),
    .wdata_i(wdata),
    .wen_i(wen),
    .curr_instr_type_i(curr_instr_type),

    .rdataA_o(rdataA),
    .rdataB_o(rdataB),
    .imm_o(imm)
);

initial begin
    rst_n = 1'b1;
    instr = '0;
    wdata = '0;
    wen = '0;
    curr_instr_type = R_type;

    @(posedge clk);
    rst_n = 1'b0;
    @(posedge clk);
    rst_n = 1'b1;

    // test read data from RF
    instr[19:15] = 5'b00000;
    instr[24:20] = 5'b11111;
    @(posedge clk); #1
    test_1_rdataA: assert (rdataA == 32'd0)
        else $error("Assertion test_1_rdataA failed!");
    test_1_rdataB: assert (rdataB == 32'd31)
        else $error("Assertion test_1_rdataB failed!");
    test_1_imm: assert (imm == '0)
        else $error("Assertion test_1_imm failed!");

    // test write data from RF
    wdata = 32'hbeefbabe;
    wen = 1'b1;
    instr[11:7]  = 5'b00001;
    @(posedge clk);
    wen = 1'b0;
    instr[19:15] = 5'b00001;
    @(posedge clk); #1
    test_2_rdataA: assert (rdataA == 32'hbeefbabe)
        else $error("Assertion test_2_rdataA failed!");

    // test all imm types
    curr_instr_type = I_type;
    instr[31:20] = 12'b1010_1010_1010;
    @(posedge clk); #1
    test_3_I_imm: assert (imm == 32'hFFFF_FAAA)
        else $error("Assertion test_3_I_imm failed!");

    curr_instr_type = JALR;
    @(posedge clk); #1
    test_4_JALR_imm: assert (imm == 32'hFFFF_FAAA)
        else $error("Assertion test_4_JALR_imm failed!");

    curr_instr_type = S_type;
    instr[31:25] = 7'b0101111;
    instr[11:7] = 5'b11111;
    @(posedge clk); #1
    test_5_S_imm: assert (imm == 32'h0000_05FF)
        else $error("Assertion test_5_S_imm failed!");

    curr_instr_type = J_type;
    instr[31:12] = 20'b1111_1010_1100_0101_0000;
    @(posedge clk); #1
    test_6_J_imm: assert (imm == 32'b1111_1111_1111_0101_0000_0111_1010_1100)
        else $error("Assertion test_6_J_imm failed!");

    curr_instr_type = B_type;
    instr[31:25] = 7'b1_111111;
    instr[11:7] = 5'b1111_1;
    @(posedge clk); #1
    test_7_B_imm: assert (imm == 32'hffff_fffe)
        else $error("Assertion test_7_B_imm failed!");

    curr_instr_type = AUIPC;
    instr = 32'hdeadbeef;
     @(posedge clk); #1
    test_8_AUIPC_imm: assert (imm == 32'hdeadb000)
        else $error("Assertion test_8_AUIPC_imm failed!");

    curr_instr_type = LUI;
    @(posedge clk); #1
    test_9_LUI_imm: assert (imm == 32'hdeadb000)
        else $error("Assertion test_9_LUI_imm failed!");

    @(posedge clk);
    $finish();
end

endmodule

