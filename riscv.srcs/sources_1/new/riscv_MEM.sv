`timescale 1ns / 1ps

module riscv_MEM
import riscv_pkg::*;
(
    input   logic           clk_i,
    input   logic           rst_ni,
    input   logic [31:0]    alu_out_i,
    input   logic [31:0]    wdata_i,
    input   logic [15:0]    sw_i,

    // control signals
    input   logic           en_i,
    input   logic           wen_i,
    input   store_type_t    store_type_i,
    input   load_type_t     load_type_i,
    
    output  logic [15:0]    led_o,
    output  logic [31:0]    rdata_o
);

logic [31:0] word_index;
logic [1:0] byte_index;
logic [31:0] sh_wdata, sb_wdata, dmem_wdata;
logic [31:0] dmem_rdata;
logic [9:0] dmem_addr;
logic dmem_addr_valid, dmem_en, dmem_wen;
logic sw_addr_valid, led_addr_valid;
logic [15:0] sw_0, sw_1, led_q, led_d;
logic [31:0] rdata;

// filter out invalid (out-of-bounds) reads and writes
assign dmem_addr_valid =    (alu_out_i >= 32'h8000_0000 && alu_out_i < 32'h8000_0400);
assign sw_addr_valid =      (alu_out_i == 32'h00100010);
assign led_addr_valid =     (alu_out_i == 32'h00100014);
assign N_addr_valid =       (alu_out_i == 32'h00100000);

/* DMEM signals */
assign dmem_en = dmem_addr_valid & en_i;
assign dmem_wen = dmem_addr_valid & wen_i;
assign word_index = alu_out_i >> 2;
assign byte_index = alu_out_i[1:0];
assign dmem_addr = word_index[9:0];

/* write signals */
// we assume no multi-word writes
// sh_wdata with byte index 3 is implemeneted as sb
assign sh_wdata = (byte_index == 2'b00) ? {dmem_rdata[31:16], wdata_i[15:0]}                    :
                  (byte_index == 2'b01) ? {dmem_rdata[31:24], {wdata_i[15:0], dmem_rdata[7:0]}} :
                  (byte_index == 2'b10) ? {wdata_i[15:0], dmem_rdata[15:0]}                     :
                  {wdata_i[7:0], dmem_rdata[23:0]};

assign sb_wdata =   (byte_index == 2'b00) ? {dmem_rdata[31:8], wdata_i[7:0]}                        :
                    (byte_index == 2'b01) ? {dmem_rdata[31:16], {wdata_i[7:0], dmem_rdata[7:0]}}  :
                    (byte_index == 2'b10) ? {dmem_rdata[31:24], {wdata_i[7:0], dmem_rdata[15:0]}} :
                    {wdata_i[7:0], dmem_rdata[23:0]};

assign dmem_wdata = (store_type_i == SW) ? wdata_i :
                    (store_type_i == SH) ? sh_wdata :
                    (store_type_i == SB) ? sb_wdata :
                    dmem_rdata;  // this should never occur under regular circumstances

assign led_d = (led_addr_valid & wen_i) ? 
                (
                    (store_type_i == SW) ? wdata_i[15:0] :
                    (store_type_i == SH) ? sh_wdata[15:0] :
                    (store_type_i == SB) ? sb_wdata[15:0] :
                    led_q
                ) : 
                led_q;

always_comb begin
    rdata = '0;
    rdata_o = '0;
    case ({dmem_addr_valid, led_addr_valid, sw_addr_valid, N_addr_valid})
        4'b1000: rdata = dmem_rdata;
        4'b0100: rdata = {16'h0000, led_q};
        4'b0010: rdata = {16'h0000, sw_1};
        4'b0001: rdata = 32'd16956693;
        default: rdata = '0; // this should never occur under regular circumstances
    endcase

    case (load_type_i)
        LW:    rdata_o = rdata;
        LH:    rdata_o = {{16{rdata[(byte_index*4)+15]}}, rdata[byte_index*4+:16]};
        LHU:   rdata_o = {16'd0          , rdata[15:0]};
        LB:    rdata_o = {{24{rdata[(byte_index*4)+7]}}, rdata[byte_index*4+:8]};
        LBU:   rdata_o = {24'd0          , rdata[7:0]};
        default: rdata_o = '0; // this should never occur under regular circumstances
    endcase
end

// sw_0 and sw_1 are synchronizers since sw is external input
always_ff @ (posedge clk_i) begin
    if(!rst_ni) begin
        sw_0 <= '0;
        sw_1 <= '0;
        led_q <= '0;
    end else begin
        sw_0 <= sw_i;
        sw_1 <= sw_0;
        led_q <= led_d;
    end
end

bram dmem(
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .en_i(dmem_en),
    .addr_i(dmem_addr),
    // read signals
    .rdata_o(dmem_rdata),
    // write signals
    .wen_i(dmem_wen),
    .wdata_i(dmem_wdata)
);

assign led_o = led_q;

endmodule
