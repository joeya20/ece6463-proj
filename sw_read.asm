# s0 = 0x00100010 (sw)
lui s0, 0x00100
addi s0, s0, 0x010
lw   s1, 0(s0)
lh   s2, 0(s0)
lb   s3, 0(s0)
ebreak
