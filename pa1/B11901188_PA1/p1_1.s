.globl __start

.rodata
    msg0: .string "This is p1-1 (recursive)"
    msg1: .string "\nThe integer n: "
    msg2: .string "\nThe result is: "
.data
    n: .word 25

.text

__start:
    # load n in t1
    lw t1, n
    # print msg
    li a0, 4
    la a1, msg0
    ecall
    li a0, 4
    la a1, msg1
    ecall
    li a0, 1
    mv a1, t1
    ecall
    
    jal ra, fib # do calculation in fib
    
    # print msg
    li a0, 4
    la a1, msg2
    ecall
    # print result in t0
    li a0, 1
    mv a1, t0
    ecall
    
    #exit
    li a0, 10
    ecall
       
fib:
    ### TODO ### 
    # Hint: you may need to store some value in the stack

    # initialize, store the variables needed
    addi  sp, sp, -16   # make space on stack, reserve some space for the variables
    sw    ra, 12(sp)    # save return address
    sw    t1, 8(sp)     # save the current "n"

    # base case, when n = 0 or 1, fib(0) = 0, fib(1) = 1
    beqz t1, fib_zero   # if n == 0, jump to fib_zero
    li   t2, 1          # t2 = 1
    beq  t1, t2, fib_one #if n == 1, jump to fib_one
    
    # recursive cases: fib(n) = fib(n-1) + fib(n-2)
    # fib(n-1)
    addi t1, t1, -1     # t1 = n - 1
    jal ra, fib         # this will cal fib(n-1)
    mv  t3, t0          # save fib(n-1) result in t3
    sw  t3, 4(sp)       # save t3 to stack, beacuse t3 will be overwritten when recursing

    # fib(n-2)
    lw t1, 8(sp)        # restore n from the stack(memory)
    addi t1, t1, -2      # t1 = n-2
    jal ra, fib          # calculate fib(n-2)
    lw  t3, 4(sp)
    add t0, t0, t3      # t0 = fib(n-1) + fib(n-2)

    # return 
    j fib_end           # jump to fib_end

fib_zero:
    li t0, 0        # fib(0) = 0
    j fib_end

fib_one:
    li t0, 1        # fib(1) = 1

fib_end:
    lw ra, 12(sp)   # restore return address
    lw t1, 8(sp)    # restore need
    addi sp, sp, 16 # pop stack frame
    jr ra           # return to caller    



