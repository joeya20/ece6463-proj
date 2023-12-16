    `timescale 1ns / 1ps

    module riscv_ctrl
    import riscv_pkg::*;
    (
        input   logic           clk_i,
        input   logic           rst_ni,
        input   logic [31:0]    instr_i,
        input   logic           alu_zero_i,
        // Fetch stage control signals
        output  logic           update_pc_o,
        output  logic           imem_en_o,
        output  logic           take_branch_o,
        // Decode stage control signals
        output  instr_type_t    instr_type_o,
        // Execute stage control signals
        output  logic           use_imm_o,
        output  logic           use_pc_o,
        output  logic           use_const_4_o,
        output  logic           jalr_o,
        output  logic           clr_alu_srcA_o,
        output  alu_op_t        alu_op_o,
        // MEM stage control signals
        output  logic           dmem_en_o,
        output  logic           dmem_wen_o,
        output  store_type_t    store_type_o,
        output  load_type_t     load_type_o,
        // WB stage control signals
        output  logic           reg_wen_o,
        output  logic           mem_to_reg_o,
        output  state_t         curr_state_o
    );

    state_t curr_state, next_state;
    assign curr_state_o = curr_state;

    logic [6:0] opcode;
    assign opcode = instr_i[6:0];

    logic [2:0] funct3;
    assign funct3 = instr_i[14:12];

    logic [6:0] funct7;
    assign funct7 = instr_i[31:25];

    // take branch needs to be registered because there is a 1 cycle delay between checking the branch and fetching the next instruction
    logic take_branch_q, take_branch_d;
    assign take_branch_o = take_branch_q;

    logic jalr_q, jalr_d;
    assign jalr_o = jalr_q;

    assign instr_type_o =
        (opcode == 7'b0110011) ?    R_type  :
        (opcode == 7'b0010011) ?    I_type  :
        (opcode == 7'b0100011) ?    S_type  : // SW/SH/SB
        (opcode == 7'b1101111) ?    J_type  : // JAL
        (opcode == 7'b1100011) ?    B_type  :
        (opcode == 7'b1100111) ?    JALR    :
        (opcode == 7'b0000011) ?    LOAD    : // LW/H/B/HU/BU
        (opcode == 7'b0010111) ?    AUIPC   :
        (opcode == 7'b0110111) ?    LUI     :
        (opcode == 7'b0001111) ?    FENCE   :
        (opcode == 7'b1110011) ?    (instr_i[20] ? EBREAK : ECALL) :
        INVALID;

    always_ff @( posedge clk_i ) begin
        if(!rst_ni) begin
            curr_state <= FETCH;
            take_branch_q <= '0;
            jalr_q <= '0;
        end
        else begin
            curr_state <= next_state;
            take_branch_q <= take_branch_d;
            jalr_q <= jalr_d;
        end
    end

    always_comb begin
        next_state = curr_state;
        // IF stage
        take_branch_d = take_branch_q;
        update_pc_o = 1'b0;
        imem_en_o = 1'b0;
        // ID stage
        reg_wen_o = 1'b0;
        // EX stage
        jalr_d = jalr_q;
        use_imm_o = 1'b0;
        use_pc_o = 1'b0;
        clr_alu_srcA_o = 1'b0;
        use_const_4_o = 1'b0;
        alu_op_o = ADD;
        // MEM stage
        dmem_en_o = 1'b0;
        dmem_wen_o = 1'b0;
        store_type_o = SW;
        load_type_o = LW;
        // WB stage
        mem_to_reg_o = 1'b0;

        case (curr_state)
            UPDATE_PC: begin
                jalr_d = 1'b0;
                take_branch_d = 1'b0;
                update_pc_o = 1'b1;
                next_state = FETCH;
            end
            FETCH: begin
                imem_en_o = 1'b1;
                next_state = DECODE;
            end
            DECODE: begin
                case (instr_type_o)
                    R_type:
                        next_state = R_EX;
                    I_type:
                        next_state = I_EX;
                    S_type:
                        next_state = MEM_ADDR;
                    LOAD:
                        next_state = MEM_ADDR;
                    B_type:
                        case (funct3)
                            BEQ: next_state = BEQ_BNE_EX;
                            BNE: next_state = BEQ_BNE_EX;
                            BLT: next_state = BLT_BGE_EX;
                            BGE: next_state = BLT_BGE_EX;
                            BLTU: next_state = BLTU_BGEU_EX;
                            BGEU: next_state = BLTU_BGEU_EX;
                            default: ;
                        endcase
                    JALR:
                        next_state = JUMP_EX;
                    J_type:
                        next_state = JUMP_EX;
                    AUIPC:
                        next_state = AUIPC_EX;
                    LUI:
                        next_state = LUI_EX;
                    FENCE:
                        next_state = UPDATE_PC;
                    EBREAK:
                        next_state = HALT;
                    ECALL:
                        next_state = HALT;
                    default: ;
                endcase
            end
            // R-type
            R_EX: begin
                next_state = alu_WB;
                use_imm_o = 1'b0;
                casez ({funct7, funct3})
                    10'b?0?????_000: // ADD
                        alu_op_o = ADD;
                    10'b?1?????_000: // SUB
                        alu_op_o = SUB;
                    10'b???????_001: // SLL
                        alu_op_o = SLL;
                    10'b???????_010: // SLT
                        alu_op_o = SLT;
                    10'b???????_011: // SLTU
                        alu_op_o = SUB;
                    10'b???????_100: // XOR
                        alu_op_o = XOR;
                    10'b?0?????_101: // SRL
                        alu_op_o = SRL;
                    10'b?1?????_101: // SRA
                        alu_op_o = SRA;
                    10'b???????_110: // OR
                        alu_op_o = OR;
                    10'b???????_111: // AND
                        alu_op_o = AND;
                    default: ;
                endcase
            end
            // I-type
            I_EX: begin
                use_imm_o = 1'b1;
                if(instr_type_o == I_type) begin
                    next_state = alu_WB;
                    casez (funct3)
                        3'b000: // ADDI
                            alu_op_o = ADD;
                        3'b010: // SLTI
                            alu_op_o = SLT;
                        3'b011: // SLTIU
                            alu_op_o = SLTU;
                        3'b100: // XORI
                            alu_op_o = XOR;
                        3'b110: // ORI
                            alu_op_o = OR;
                        3'b111: // ANDI
                            alu_op_o = AND;
                        3'b001: // SLLI
                            alu_op_o = SLL;
                        3'b101: begin // SRLI, SRAI
                            if(funct7 == 7'b0000000) alu_op_o = SRL;
                            else alu_op_o = SRA;
                        end
                        default: ;
                    endcase
                end
            end
            JUMP_EX: begin
                // compute PC + 4 to write to rd
                // branch address is calculated in parallel
                next_state = alu_WB;
                take_branch_d = 1'b1;
                use_pc_o = 1'b1;
                use_imm_o = 1'b0;
                use_const_4_o = 1'b1;
                jalr_d = (instr_type_o == JALR);
                clr_alu_srcA_o = 1'b0;
                alu_op_o = ADD;
            end
            AUIPC_EX: begin    // rd = PC + imm
                next_state = alu_WB;
                use_imm_o = 1'b1;
                use_pc_o = 1'b1;
                alu_op_o = ADD;
            end
            LUI_EX: begin      // rd = imm
                next_state = alu_WB;
                use_imm_o = 1'b1;
                clr_alu_srcA_o = 1'b1;
                alu_op_o = ADD;
            end
            // common terminal state for R-type and I-type that writeback alu output
            alu_WB: begin
                next_state = UPDATE_PC;
                dmem_en_o = 1'b0;
                dmem_wen_o = 1'b0;
                mem_to_reg_o = 1'b0;
                reg_wen_o = 1'b1;
            end
            // LW/H/B and SW/H/B
            MEM_ADDR: begin
                use_imm_o = 1'b1;
                alu_op_o = ADD;
                use_pc_o = 1'b0;
                clr_alu_srcA_o = 1'b0;
                next_state = (instr_type_o == S_type) ? MEM_WRITE : MEM_READ;
            end
            MEM_READ: begin
                next_state = MEM_WB;
                dmem_en_o = 1'b1;
                dmem_wen_o = 1'b0;
                load_type_o = load_type_t'(funct3);
            end
            MEM_WB: begin
                next_state = UPDATE_PC;
                mem_to_reg_o = 1'b1;
                reg_wen_o = 1'b1;
            end
            MEM_WRITE: begin
                next_state = UPDATE_PC;
                dmem_en_o = 1'b1;
                dmem_wen_o = 1'b1;
                store_type_o = store_type_t'(funct3[1:0]);
            end
            BEQ_BNE_EX: begin
                next_state = BEQ_BNE_CHECK;
                use_imm_o = 1'b0;
                use_pc_o = 1'b0;
                clr_alu_srcA_o = 1'b0;
                alu_op_o = SUB;
            end
            BLT_BGE_EX: begin
                next_state = BLT_BGE_CHECK;
                use_imm_o = 1'b0;
                use_pc_o = 1'b0;
                clr_alu_srcA_o = 1'b0;
                alu_op_o = SLT;
            end
            BLTU_BGEU_EX: begin
                next_state = BLT_BGE_CHECK;
                use_imm_o = 1'b0;
                use_pc_o = 1'b0;
                clr_alu_srcA_o = 1'b0;
                alu_op_o = SLTU;
            end
            BEQ_BNE_CHECK: begin
                next_state = UPDATE_PC;
                take_branch_d = (branch_type_t'(funct3) == BEQ) ?
                    alu_zero_i :
                    ~alu_zero_i;
            end
            BLT_BGE_CHECK: begin
                next_state = UPDATE_PC;
                take_branch_d =
                (branch_type_t'(funct3) == BLT || branch_type_t'(funct3) == BLTU) ?
                    ~alu_zero_i :
                    alu_zero_i;
            end
            // just hang in halt
            HALT: begin
                next_state = HALT;
            end
            default: ;
        endcase
    end

    endmodule
