`timescale 1ns / 1ps
`define CLK 10

module tb_top import riscv_pkg::*;  ();

logic clk = 1'b1;
always #(`CLK/2) clk = ~clk;

logic rst_n;
logic [3:0] sw, led;
logic [31:0] PC;
state_t curr_state;

riscv_top dut(
    /* AUTOINST */
    // Inputs
    .CLK100MHZ (clk),
    .rst_ni(rst_n),
    .sw_i(sw),
    // Outputs
    .PC_o  (PC),
    .led_o(led)
);

initial begin
    rst_n = 1'b1;
    sw = 4'b1010;
    
    @(posedge clk);
    rst_n = 1'b0;
    @(posedge clk);
    rst_n = 1'b1;

    @(posedge clk * 50);
    $stop(0);
end

endmodule
