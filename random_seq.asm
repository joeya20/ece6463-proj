  addi s0, x0, 1
  addi s1, x0, 2
  add  s2, s0, s1
  slt  s3, s0, s1
  slt  s4, s2, s1
  lui  s5, 0x80000
  sw   s2, 0(s5)
  lw   s6, 0(s5)
  beq  s6, s2, test_take
  add  x1, s0, s1

test_take:
  add x5, s0, s1
  bne s6, s2, test_not_take
  slli s2, s2, 1

test_not_take:
  srli s3, s2, 1
  lui  t0, 0xFFFFF
  lui  t1, 0xAAAAA
  xor  t2, t0, t1
  or   t3, t0, t1
  and  t4, t0, t1
  jal Lfunc
  sll  s1, s1, s0
  ebreak

Lfunc:
  lui t5, 0x80000
  jr ra
