.globl __start

.rodata
    msg0:   .string "This is p3(two sum, bonus)"
    msg1:   .string "\nThe result is: "
    msg2:   .string " and "

.data
    A:      .word 2, 7, 11, 15
    len:    .word 4
    target: .word 9
    hash:   .space 400  # 100 entries * 4 bytes

.text
__start:
    # print msg
    li a0, 4
    la a1, msg0
    ecall

    # load 
    la a2, A     
    lw a3, len        
    lw a4, target 
    la a5, hash 
    
    # Hint: you can directly use the element value as the hash index
    # i.e. hash[A[i]] = i
    # first, initialize hash table with -1

    ### TODO ###
    
done:
    # print result
    li a0, 4
    la a1, msg1
    ecall

    li a0, 1
    mv a1, t0
    ecall

    li a0, 4
    la a1, msg2
    ecall

    li a0, 1
    mv a1, t1
    ecall
    
    # exit
    li a0, 10
    ecall