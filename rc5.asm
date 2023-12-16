# load key schedule
lui s0, 0x80000
addi t0, zero, 0
sw   t0, 0(s0)
sw   t0, 4(s0)

lui  t0, 0x008C5
srli t0, t0, 12
lui  t1, 0x46F8E
or   s1, t0, t1
sw   s1, 8(s0)

lui  t0, 0x00085
srli t0, t0, 12
lui  t1, 0x460C6
or   s1, t0, t1
sw   s1, 12(s0)

lui  t0, 0x00B8A
srli t0, t0, 12
lui  t1, 0x70F83
or   s1, t0, t1
sw   s1, 16(s0)

lui  t0, 0x00303
srli t0, t0, 12
lui  t1, 0x284B8
or   s1, t0, t1
sw   s1, 20(s0)

lui  t0, 0x00454
srli t0, t0, 12
lui  t1, 0x513E1
or   s1, t0, t1
sw   s1, 24(s0)

lui  t0, 0x00D22
srli t0, t0, 12
lui  t1, 0xF621E
or   s1, t0, t1
sw   s1, 28(s0)

lui  t0, 0x0065D
srli t0, t0, 12
lui  t1, 0x31250
or   s1, t0, t1
sw   s1, 32(s0)

lui  t0, 0x00A5D
srli t0, t0, 12
lui  t1, 0x11A83
or   s1, t0, t1
sw   s1, 36(s0)

lui  t0, 0x0086B
srli t0, t0, 12
lui  t1, 0xD4276
or   s1, t0, t1
sw   s1, 40(s0)

lui  t0, 0x0082D
srli t0, t0, 12
lui  t1, 0x713AD
or   s1, t0, t1
sw   s1, 44(s0)

lui  t0, 0x00F99
srli t0, t0, 12
lui  t1, 0x4B792
or   s1, t0, t1
sw   s1, 48(s0)

lui  t0, 0x004DD
srli t0, t0, 12
lui  t1, 0x2799A
or   s1, t0, t1
sw   s1, 52(s0)

lui  t0, 0x00C49
srli t0, t0, 12
lui  t1, 0xA7901
or   s1, t0, t1
sw   s1, 56(s0)

lui  t0, 0x0071A
srli t0, t0, 12
lui  t1, 0xDEDE8
or   s1, t0, t1
sw   s1, 60(s0)

lui  t0, 0x00196
srli t0, t0, 12
lui  t1, 0x36C03
or   s1, t0, t1
sw   s1, 64(s0)

lui  t0, 0x00249
srli t0, t0, 12
lui  t1, 0xA7EFC
or   s1, t0, t1
sw   s1, 68(s0)

lui  t0, 0x00BB8
srli t0, t0, 12
lui  t1, 0x61A78
or   s1, t0, t1
sw   s1, 72(s0)

lui  t0, 0x00D2B
srli t0, t0, 12
lui  t1, 0x3B0A1
or   s1, t0, t1
sw   s1, 76(s0)

lui  t0, 0x00A76
srli t0, t0, 12
lui  t1, 0x4DBFC
or   s1, t0, t1
sw   s1, 80(s0)

lui  t0, 0x00167
srli t0, t0, 12
lui  t1, 0xAE162
or   s1, t0, t1
sw   s1, 84(s0)

lui  t0, 0x00B0A
srli t0, t0, 12
lui  t1, 0x30D76
or   s1, t0, t1
sw   s1, 88(s0)

lui  t0, 0x00304
srli t0, t0, 12
lui  t1, 0x43192
or   s1, t0, t1
sw   s1, 92(s0)

lui  t0, 0x00431
srli t0, t0, 12
lui  t1, 0xF6CC1
or   s1, t0, t1
sw   s1, 96(s0)

lui  t0, 0x00380
srli t0, t0, 12
lui  t1, 0x65046
or   s1, t0, t1
sw   s1, 100(s0)

# start of dmem: s0
# A: s1, b: s2, A_round_key_offset: s2, B_round_key_offset: s3
# set s0 to 0xdeadbeef and s1 to 0xdeadc0de (pt)
lui  t0, 0x00eef
srli t0, t0, 12
lui  t1, 0xdeadb
or   s1, t0, t1

lui  t0, 0x000de
srli t0, t0, 12
lui  t1, 0xdeadc
or   s2, t0, t1

# set s3 to 8 and s4 to 12
# will get incremented by 8 until s2 == 96
addi s3, zero, 8
addi s4, zero, 12
addi s5, zero, 104

Lround:
    xor  t0, s1, s2 # t0 = A ^ B
    andi t3, s2, 0x1f
    addi t4, zero, 32
    sub  t4, t4, t3
    sll  t5, t0, t3 # t0 = (A ^ B) << B
    srl  t0, t0, t4
    or   t0, t0, t5
    add  t1, s0, s3
    lw   t2, 0(t1)  # t2 = s[2*i]
    add  t0, t0, t2 # t0 = ((A ^ B) << B) + s[2*i]
    add  s1, zero, t0
    
    xor  t3, s2, t0 # t3 = B ^ A
    andi t6, s1, 0x1f
    addi t4, zero, 32
    sub  t4, t4, t6
    sll  t5, t3, t6 # t0 = (A ^ B) << B
    srl  t3, t3, t4
    or   t3, t3, t5
    add  t1, s0, s4
    lw   t2, 0(t1)  # t2 = s[2*i+1]
    add  s2, t3, t2 # s2 = ((B ^ A) << A) + s[2*i+1]
    
    # increment and continue looping if needed
    addi s3, s3, 8
    addi s4, s4, 8
    bne  s3, s5, Lround

# enc finished
ebreak
