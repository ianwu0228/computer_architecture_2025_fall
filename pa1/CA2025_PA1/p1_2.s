.globl __start

.rodata
    msg0: .string "This is p1-2 (iterative)"
    msg1: .string "\nThe integer n: "
    msg2: .string "\nThe result is: "
.data
    n: .word 30


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
    
### TODO ###

li t0, 1    #initialize t0 to 0

# check if n == 0 || n == 1
li t6, 0
beq t1, t6, fib_zero    # n == 0
li t6, 1
beq t1, t6, fib_one     # n == 1


# n >= 2, then set up some params
addi t1, t1, -2  # make t1 the number of how many iteration
li t2, 0    # t2 = fib(0) + fib(1)
li t3, 1
add t0, t0, t2

# iterative part
fib:
    beqz t1, done   # if n == 0, done the iteration
    addi t1, t1, -1

    mv t2, t3
    mv t3, t0
    add t0, t0, t2

    j fib


# two special cases
fib_zero:
    li t0, 0
    j done

fib_one:
    li t0, 1

# done
done:
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