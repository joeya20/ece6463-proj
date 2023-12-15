`timescale 1ns / 1ps

module riscv_alu
import riscv_pkg::*;
(
    input logic [31:0]  srcA_i,
    input logic [31:0]  srcB_i,
    input alu_op_t      op_i,

    output logic        zero_o,
    output logic [31:0] out_o
);

logic [31:0]    sub_out;
logic           overflow;
assign {overflow, sub_out} = srcA_i - srcB_i;

always_comb begin
    case (op_i)
        ADD: out_o = srcA_i + srcB_i;
        SUB: out_o = sub_out;
        XOR: out_o = srcA_i ^ srcB_i;
        SLL: out_o = srcA_i << srcB_i[4:0];
        SRL: out_o = srcA_i >> srcB_i[4:0];
        SRA: out_o = $signed(srcA_i) >>> srcB_i[4:0];
        OR : out_o = srcA_i | srcB_i;
        AND: out_o = srcA_i & srcB_i;
        SLT: begin
            // if they have opposite signs
            // srcA < srcB if srcA < 0 (implies srcB > 0)
            if (srcA_i[31] ^ srcB_i[31]) begin
                out_o = srcA_i[31];
            end
            // if they have the same signs
            // srcA < srcB if srcA-srcB < 0
            else begin
                out_o = sub_out[31];
            end
        end
        // if they have the same signs
        // srcA < srcB if srcA-srcB < 0
        SLTU: out_o = overflow;
        default: out_o = '0;
    endcase
end

assign zero_o = out_o == '0;

endmodule
