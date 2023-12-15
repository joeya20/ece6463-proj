//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/04/2023 05:35:28 PM
// Design Name: 
// Module Name: tb_riscv_IF
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

module tb_riscv_IF import riscv_pkg::*; ();

logic clk = 1'b1;
always #(`CLK/2) clk = ~clk;

logic rst_n;
logic fetch_en;
logic branch;
logic [31:0] branch_addr;
logic [31:0] instr;
logic [31:0] PC;

riscv_IF dut(
    .clk_i(clk),
    .rst_ni(rst_n),
    .fetch_en_i(fetch_en),
    .branch_i(branch),
    .branch_addr_i(branch_addr),
    .instr_o(instr),
    .PC_o(PC)
);

always begin
    rst_n = 1'b1;
    fetch_en = 1'b0;
    branch = '0;
    branch_addr = '0;

    // check reset
    @(posedge clk);
    rst_n = 1'b0;
    @(posedge clk);
    rst_n = 1'b1;
    assert(PC == 32'h0100_0000) else $error("invalid PC reset value");
    
    @(negedge clk);
    fetch_en = 1'b1;
    
    @(posedge clk);
    
    @(posedge clk);
    fetch_en = 1'b0;
    assert(PC == 32'h0100_0004) else $error("invalid PC increment");
    
    @(posedge clk);
    assert(instr == 32'h0000_0001) else $error("invalid instr value");
    
    @(posedge clk);
//    // check non-branching behavior
//    @(posedge clk);
//    assert(PC == 32'h0100_0004) else $error("invalid PC increment");
//    assert(instr == 32'h0000_0000) else $error("invalid instr reset value");
//    @(negedge clk);
//    branch_addr = 32'h0100_0100;
//    branch = 1'b1;
//    @(posedge clk);
//    assert(PC == 32'h0100_0008) else $error("invalid PC increment");
//    assert(instr == 32'h0000_0001) else $error("invalid instr value");

//    @(negedge clk);
//    branch_addr = 32'h1111_1111;
////    // check branching behavior
//    @(posedge clk);
//    assert(PC == 32'h0100_0100) else $error("invalid PC value after branch");
//    @(posedge clk);
//    assert(instr == 32'h0000_0040) else $error("invalid instr value");
 
//    @(posedge clk);
//    assert(PC == 32'h0100_0000) else $error("invalid handling of out of bounds address");
//    @(posedge clk);
//    assert(instr == 32'h0000_0000) else $error("invalid instr value");

////     do exhaustive test of valid address range
//    branch = 1'b0;
//    rst_n = 1'b0;
//    @(posedge clk);
//    rst_n = 1'b1;
//    for(integer i = 0; i < 1024; i = i + 1) begin
//        assert(PC == (32'h0100_0000 + i*4)) else $error("invalid PC increment");
//        @(posedge clk);
//        assert(instr == (32'h0000_0000 + i)) else $error("invalid instr value");
//    end
    $finish();
end

endmodule
