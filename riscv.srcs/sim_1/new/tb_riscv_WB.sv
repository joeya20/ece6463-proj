`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2023 06:47:15 PM
// Design Name: 
// Module Name: tb_riscv_WB
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

module tb_riscv_WB;

logic [31:0]    mem_out;
logic [31:0]    ALU_out;
logic           mem_to_reg;
logic [31:0]    reg_wdata;

riscv_WB dut(
    .mem_out_i(mem_out),
    .ALU_out_i(ALU_out),
    .mem_to_reg_i(mem_to_reg),
    .reg_wdata_o(reg_wdata)
);

always begin
    mem_out = 32'd1000;
    ALU_out = 32'd0001;
    mem_to_reg = 1'b0;
    #1
    assert (reg_wdata == ALU_out)
    else   $error("Error: incorrect reg wdata");

    #5
    mem_to_reg = 1'b1;
    #1
    assert (reg_wdata == mem_out)
    else   $error("Error: incorrect reg wdata");
    #5
    $finish(0);
end

endmodule
