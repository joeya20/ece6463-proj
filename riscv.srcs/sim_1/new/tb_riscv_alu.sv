`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2023 06:52:58 PM
// Design Name: 
// Module Name: tb_riscv_alu
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

module tb_riscv_alu import riscv_pkg::*; ();

logic [31:0]    srcA;
logic [31:0]    srcB;
alu_op_t        ALU_op;
logic           zero;
logic [31:0]    out;

riscv_alu dut(
    .srcA_i(srcA),
    .srcB_i(srcB),
    .op_i(ALU_op),
    .zero_o(zero),
    .out_o(out)
);

always begin
    srcA = '0;
    srcB = '0;
    ALU_op = ADD;
    #1
    assert (zero == 1'b1)
    else   $error("Error: zero not asserted");
    assert (out == '0)
    else   $error("Error: incorrect ALU output");
    #5
    srcA = 32'hFFFF_FFFF;
    #1
    assert (zero == 1'b0)
    else   $error("Error: zero asserted unexpectedly");
    assert (out == 32'hFFFF_FFFF)
    else   $error("Error: incorrect ALU output");
    #5
    ALU_op = SUB;
    srcA = 32'd1000;
    srcB = 32'd999;
    #1
    assert (out == 32'd1)
    else   $error("Error: incorrect ALU output");
    #5
    ALU_op = XOR;
    srcA = 32'b0000_0000_0000_0000_1111_1111_1111_1111;
    srcB = 32'b1010_1010_1010_1010_1010_1010_1010_1010;
    #1
    assert (out ==  32'b1010_1010_1010_1010_0101_0101_0101_0101)
    else   $error("Error: incorrect ALU output");
    #5
    ALU_op = SLL;
    srcA = 32'h0000_0001;
    srcB = 32'h0000_0001;
    #1
    assert (out ==  32'h0000_0002)
    else   $error("Error: incorrect ALU output");
    #5
    ALU_op = SRL;
    srcA = 32'h8000_0001;
    srcB = 32'h0000_0001;
    #1
    assert (out ==  32'h4000_0000)
    else   $error("Error: incorrect ALU output");
    #5
    ALU_op = SRA;
    srcA = 32'h8000_0001;
    srcB = 32'h0000_0001;
    #1
    assert (out == 32'hc000_0000)
    else   $error("Error: incorrect ALU output");
    #5
    ALU_op = OR;
    srcA = 32'b0000_0000_0000_0000_1111_1111_1111_1111;
    srcB = 32'b1010_1010_1010_1010_1010_1010_1010_1010;
    #1
    assert (out ==  32'b1010_1010_1010_1010_1111_1111_1111_1111)
    else   $error("Error: incorrect ALU output");
    #5
    ALU_op = AND;
    srcA = 32'b0000_0000_0000_0000_1111_1111_1111_1111;
    srcB = 32'b1010_1010_1010_1010_1010_1010_1010_1010;
    #1
    assert (out ==  32'b0000_0000_0000_0000_1010_1010_1010_1010)
    else   $error("Error: incorrect ALU output");
    #5
    ALU_op = SLT;
    srcA = 32'h8010_0000;
    srcB = 32'h0000_0001;
    #1
    assert (out == 32'd1)
    else   $error("Error: incorrect ALU output");
    #5
    ALU_op = SLT;
    srcA = 32'h4010_0000;
    #1
    assert (out == 32'd0)
    else   $error("Error: incorrect ALU output");
    #5
    ALU_op = SLTU;
    #1
    assert (out == 32'd0)
    else   $error("Error: incorrect ALU output");
    #5
    srcA = 32'h8010_0000;
    srcB = 32'h0000_0001;
    #1
    assert (out == 32'd0)
    else   $error("Error: incorrect ALU output");
    #5
    srcA = 32'h0000_0001;
    srcB = 32'h8010_0000;
    #1
    assert (out == 32'd1)
    else   $error("Error: incorrect ALU output");
    
    #5
    $finish();
end

endmodule

