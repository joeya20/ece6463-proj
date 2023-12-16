#!/bin/python3

# to use this file, run the following command in the terminal:
# python3 simple_function_rc5.py -i <64-bit hexadecimal input>
# it will print the output in the following format:
# <64-bit hexadecimal input> <64-bit hexadecimal output>

import argparse
from random import randint

rom = [
    None,
    None,
	0x46F8E8C5,
	0x460C6085,
	0x70F83B8A,
	0x284B8303,
	0x513E1454,
	0xF621ED22,
	0x3125065D,
	0x11A83A5D,
	0xD427686B,
	0x713AD82D,
	0x4B792F99,
	0x2799A4DD,
	0xA7901C49,
	0xDEDE871A,
	0x36C03196,
	0xA7EFC249,
	0x61A78BB8,
	0x3B0A1D2B,
	0x4DBFCA76,
	0xAE162167,
	0x30D76B0A,
	0x43192304,
	0xF6CC1431,
	0x65046380,    
]

def simple_function_rc5(din):
    i_cnt = 1
    ab_xor = 0
    a_rot = 0
    a = 0
    a_reg = 0
    ba_xor = 0
    b_rot = 0
    b_reg = 0

    a_reg = (din >> 32) & 0xFFFFFFFF
    b_reg = din & 0xFFFFFFFF

    #it's difficult to constrain variable bit lengths in pure python
    #in this function we do it by &-ing things with 0xFFFFFFFF all the time
    #this will keep everything in the 32-bit range
    for i_cnt in range(1, 13):
        ab_xor = a_reg ^ b_reg
        a_rot = ((ab_xor << (b_reg & 0x1F)) | (ab_xor >> (32 - (b_reg & 0x1F)))) & 0xFFFFFFFF
        a = (a_rot + rom[i_cnt << 1 | 0]) & 0xFFFFFFFF

        ba_xor = b_reg ^ a
        b_rot = ((ba_xor << (a & 0x1F)) | (ba_xor >> (32 - (a & 0x1F)))) & 0xFFFFFFFF
        b = (b_rot + rom[i_cnt << 1 | 1]) & 0xFFFFFFFF
        
        a_reg = a & 0xFFFFFFFF
        b_reg = b & 0xFFFFFFFF

    return a_reg << 32 | b_reg

def main():
    pt = int('deadbeefdeadc0de', 16)
    ct = simple_function_rc5(pt)
    # with open("stim.dat", "+w") as file:
    #     for i in range(100):
    #         pt = randint(1, 0xffffffff_ffffffff)
    #         ct = simple_function_rc5(pt)
    #         file.write("%016x\t%016x\n" % (pt, ct))
    print("%016x\t%016x\n" % (pt, ct))

if __name__ == "__main__":
    main()
