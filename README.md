# ECE-6463 Project Milestone 3 Submission

## Design (found in riscv.srcs/sources_1/new)
1. riscv_top          - processor top-level
2. riscv_ID           - Instruction Fetch Stage
3. riscv_IF           - Instrucstion Decode Stage
4. riscv_EX           - Execute Stage
5. riscv_MEM          - Memory stage
6. riscv_WB           - Writeback stage
7. riscv_ctrl         - Controller

## Verification (found in riscv.srcs/sim_1/new)
1. tb_* - testbenches for corresponding modules
2. random_seq.txt     - random sequence of instructions to test various instructions
3. sw_read.txt        - reading switches
4. led_read_write.txt - reading/writing leds
5. rc5.txt            - rc5 encryption test (pt - deadbeefdeadc0de), result verified using the python script from hw4
6. led_shift.txt      - test that interacts with leds/switches; when any switch is "on", the leds stay in position for ~1 second and rotate to the left. when no switch is on, the LEDs are static.

different assembly tests can be run by changing the IMEM_PATH parameter in tb_top.sv

## documentation
1. README.md          - this short README
2. *.asm              - assembly instructions for corresponding tests 2-6
