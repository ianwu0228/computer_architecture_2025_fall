# minimal_riscv.s
# This program prints "Hello, RISC-V!" and exits.

    .data
msg:    .string "Hello, RISC-V!\n"

    .text
    .globl __start

__start:
    # Print string (ecall 4 = print string)
    li a0, 4          # system call code for print string
    la a1, msg        # address of string
    ecall

    # Exit program (ecall 10 = exit)
    li a0, 10
    ecall
