`timescale 1ns / 1ps

module riscv_regFile #(
    parameter integer XLEN = 32
) (
    input   logic           clk_i,
    input   logic           rst_ni,

    input   logic [4:0]     rregA_i,
    input   logic [4:0]     rregB_i,
    output  logic [31:0]    rdataA_o,
    output  logic [31:0]    rdataB_o,

    input   logic           wen_i,
    input   logic [4:0]     wreg_i,
    input   logic [31:0]    wdata_i
);

reg [XLEN-1:0] regs [32];

//initial begin
//    for (integer i = 0; i < 32; i = i + 1) begin
//        regs[i] = i;
//    end
//end

assign rdataA_o = regs[rregA_i];
assign rdataB_o = regs[rregB_i];

always @(posedge clk_i) begin
    if (!rst_ni) begin
        regs[0] <= '0;
    end
    else if(wen_i && wreg_i > 0) begin
        regs[wreg_i] <= wdata_i;
    end
end

endmodule

