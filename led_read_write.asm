# s0 = 0x00100014 (led)
lui s0, 0x00100
addi s0, s0, 0x014
addi t0, zero, 0b1111
sw   t0, 0(s0)
lw   s1, 0(s0)
addi t0, zero, 0b1010
sw   t0, 0(s0)
lh   s2, 0(s0)
addi t0, zero, 0b0101
sw   t0, 0(s0)
lb   s3, 0(s0)
ebreak
