`timescale 1ns / 1ps

package riscv_pkg;

typedef enum logic[4:0] {
    UPDATE_PC,
    FETCH,
    DECODE,
    R_EX,
    I_EX,
    AUIPC_EX,
    LUI_EX,
    alu_WB,
    MEM_ADDR,
    MEM_READ,
    MEM_WB,
    MEM_WRITE,
    BEQ_BNE_EX,
    BLT_BGE_EX,
    BLTU_BGEU_EX,
    BEQ_BNE_CHECK,
    BLT_BGE_CHECK,
    JUMP_EX,
    HALT
} state_t;

typedef enum logic [3:0] {
    R_type,
    I_type,
    S_type,
    J_type,
    B_type,
    JALR,
    LOAD,
    AUIPC,
    LUI,
    FENCE,
    ECALL,
    EBREAK,
    INVALID
} instr_type_t;

typedef enum logic [3:0] {
    ADD,
    SUB,
    XOR,
    SLL,
    SRL,
    SRA,
    OR,
    AND,
    SLT,
    SLTU
} alu_op_t;

typedef enum logic [1:0] {
    SB = 2'b00,
    SH = 2'b01,
    SW = 2'b10
} store_type_t;

typedef enum logic [2:0] {
    LW   = 3'b010,
    LH   = 3'b001,
    LB   = 3'b000,
    LHU  = 3'b101,
    LBU  = 3'b100
} load_type_t;

typedef enum logic [2:0] {
    BEQ   = 3'b000,
    BNE   = 3'b001,
    BLT   = 3'b100,
    BGE   = 3'b101,
    BLTU  = 3'b110,
    BGEU  = 3'b111
} branch_type_t;

endpackage
