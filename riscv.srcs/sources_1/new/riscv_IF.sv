`timescale 1ns / 1ps

module riscv_IF import riscv_pkg::*;  # (
     parameter string IMEM_PATH = "rc5.mem"
) (
    input   logic           clk_i,
    input   logic           rst_ni,

    // incoming address for branches and jumps
    input   logic [31:0]    branch_addr_i,

    // control signals
    input   logic           update_pc_i,
    input   logic           imem_en_i,
    input   logic           branch_i,

    output  logic [31:0]    instr_o,
    output  logic [31:0]    PC_o
);

logic [31:0] PC_q, PC_d;
logic        PC_valid;

assign PC_valid = (PC_d >= 32'h0100_0000 && PC_d < 32'h0100_0400);

always_ff @(posedge clk_i) begin
    if(!rst_ni) begin
        PC_q <= 32'h0100_0000;
    end
    else begin
        if(update_pc_i) begin
            // if PC is out of bounds, just reset to start of imem
            PC_q <= PC_valid ? PC_d : 32'h0100_0000;
        end
    end
end

assign PC_o = PC_q;

// branches include conditional and unconditional branches
assign PC_d = branch_i ? branch_addr_i :
                PC_q + 4;

// bram address is 10-bits wide and word addressable
logic [31:0] PC_wa;
logic [9:0] imem_addr;
assign PC_wa = (PC_q >> 2);
assign imem_addr = PC_wa[9:0];

bram #(.IMEM_INIT(1), .IMEM_PATH(IMEM_PATH)) imem
(
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .addr_i(imem_addr),
    .rdata_o(instr_o),

    .en_i(imem_en_i),
    .wen_i('0),
    .wdata_i('0)
);

endmodule
