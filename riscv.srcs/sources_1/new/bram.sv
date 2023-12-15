// reference: https://docs.xilinx.com/v/u/en-US/wp231
// https://docs.xilinx.com/r/en-US/ug901-vivado-synthesis/Single-Port-Block-RAM-No-Change-Mode-Verilog
// https://docs.xilinx.com/v/u/en-US/ug473_7Series_Memory_Resources

// default is 32Kb memory
// 32 bits per word * 1024 words = 32768 bits
`timescale 1ns / 1ps

module bram #(
  parameter integer LEN = 32,
  parameter integer DEPTH = 2**10,
  parameter integer IMEM_INIT = 0
) (
  input   wire                      clk_i,
  input   wire                      rst_ni,
  // general signals
  input   wire                      en_i,
  input   wire  [$clog2(DEPTH)-1:0] addr_i,
  // write signals
  input   wire                      wen_i,
  input   wire  [LEN-1:0]           wdata_i,
  // read signals
  output  reg   [LEN-1:0]           rdata_o
);

reg [LEN-1:0] mem [DEPTH];

// 'read first' or read before write mode
// slower but convenient for SH/SB
always @(posedge clk_i) begin
  if(!rst_ni) begin
    rdata_o <= '0;
  end
  else if(en_i) begin
    if (wen_i) begin
      mem[addr_i] <= wdata_i;
    end
    rdata_o <= mem[addr_i];
  end
end

generate if(IMEM_INIT)
    initial begin
        $display("reading mem_init.txt");
        $readmemh("mem_init.txt", mem);
    end
endgenerate

endmodule
