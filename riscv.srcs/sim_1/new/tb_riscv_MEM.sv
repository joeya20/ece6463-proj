
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/02/2023 08:03:59 PM
// Design Name: 
// Module Name: tb_riscv_MEM
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

module tb_riscv_MEM import riscv_pkg::*; ();

logic clk = 1'b1;
always #(`CLK/2) clk = ~clk;

logic           rst_n;
logic [31:0] ALU_out, wdata;
logic en, wen;
store_type_t store_type;
load_type_t load_type;
logic [31:0] rdata;
logic [15:0] sw;

riscv_MEM dut(
    .clk_i(clk),
    .rst_ni(rst_n),
    .alu_out_i(ALU_out),
    .wdata_i(wdata),
    .en_i(en),
    .wen_i(wen),
    .store_type_i(store_type),
    .load_type_i(load_type),
    .sw_i(sw),
    .rdata_o(rdata)
);

initial begin
    rst_n = 1'b1;
    ALU_out = '0;
    wdata = '0;
    en = 1'b0;
    wen = 1'b0;
    store_type = SW;
    load_type = LW;

    @(posedge clk);
    rst_n = 1'b0;
        
    @(negedge clk);
    ALU_out = 32'h8000_0004;
    
    @(posedge clk);
    rst_n = 1'b1;
    reset_test: assert (rdata == '0)
        else $error("Assertion reset_test failed!");
        
    @(negedge clk);
    en = 1'b1;
    
    @(posedge clk);
    en_test: assert (rdata == '0)
        else $error("Assertion en_test failed!");
        
    @(negedge clk);
    wen = 1'b1;
    wdata = 32'hdeadbeef;
        
    @(negedge clk);
    wen = 1'b0;
    
    // have to wait 2 clock cycles
    @(posedge clk);    
    @(posedge clk);
    write_test: assert (rdata == 32'hdeadbeef)
        else $error("Assertion write_test failed!");

    @(negedge clk);    
    load_type = LH;
    
    @(posedge clk);
    LH_test: assert (rdata == 32'hffffbeef)
        else $error("Assertion LH_test failed!");

    @(negedge clk);
    load_type = LB;
    
    @(posedge clk);
    LB_test: assert (rdata == 32'hffffffef)
        else $error("Assertion LB_test failed!");
    
    @(negedge clk);
    load_type = LW;
    wen = 1'b1;
    store_type = SH;
    wdata = 32'h0000_0000;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    SH_test: assert (rdata == 32'hdead_0000)
        else $error("Assertion SH_test failed!");
        
    @(negedge clk);
    store_type = SB;
    ALU_out = 32'h8000_0006;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    SB_test: assert (rdata == 32'hde00_0000)
        else $error("Assertion SB_test failed!");
    
    @(negedge clk);
    ALU_out = 32'h00100000;
    load_type = LW;
    wen= 1'b0;
    en = 1'b1;
    
    @(posedge clk);
    N_num_test: assert (rdata == 32'd16956693)
        else $error("Assertion N number read test failed!");
    
    
    @(negedge clk);
    ALU_out = 32'h00100010;
    sw = 16'hbeef;
    wen= 1'b0;
    en = 1'b1;
    
    @(posedge  clk);
    @(posedge  clk);
    @(posedge  clk);
    sw_read_test: assert (rdata == 32'h0000beef)
        else $error("Assertion sw_read_test test failed!");
        
    @(negedge clk);
    ALU_out = 32'h00100014;
    wen= 1'b1;
    en = 1'b1;
    wdata = 32'hDEADBABE;
    store_type = SW;
    
    @(posedge  clk);
    @(posedge  clk);
    @(posedge  clk);
    led_read_write_test: assert (rdata == 32'h0000_babe)
        else $error("Assertion led_read_write_test test failed!");
    
    $finish(0);
end

endmodule