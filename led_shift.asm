Lwait:
    # keep reading switches until one is "turned on"
    lw  t0, 0(s0)
    beq t0, zero, Lwait
Lon:
    lw   t0, 0(s1)
    beq  t0, zero, Lset
    # if an LED was already on, just shift it left
    slli t0, t0, 1
    sw   t0, 0(s1)
    beq zero, zero, Ldelay
Lset:
    # if all leds were off, turn the rightmost LED on
    addi t0, zero, 1
    sw   t0, 0(s1)
Ldelay:
    # delay by 15 * 6352896 + 10 cycles = 95_293_450 cycles ~= 1 sec
    addi t1, zero, 0
    lui t2, 0x0060F
LdelayLoop:
    beq t1, t2, Lwait
    addi t1, t1, 1
    beq zero, zero, LdelayLoop
