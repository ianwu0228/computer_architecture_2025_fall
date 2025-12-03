.globl __start

.rodata
    msg0:   .string "This is p3(two sum)"
    msg1:   .string "\nThe result is: "
    msg2:   .string " and "

.data
    A:      .word 70, 30, 41, 35, 86, 18, 26, 57, 43, 7, 8, 44, 82, 17, 78, 12, 20, 6, 67, 77, 65, 34, 96, 4, 25, 33, 59, 62, 79, 69, 68, 91, 39, 48, 24, 83, 97, 19, 9, 32, 14, 63, 49, 76, 72, 10, 47, 29, 90, 31, 15, 52, 42, 80, 87, 98, 22, 92, 38, 5, 53, 51, 13, 74, 3, 46, 50, 95, 94, 75, 40, 21, 85, 37, 99, 54, 88, 1, 0, 58
    len:    .word 80
    target: .word 3

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
    
    ### TODO ### 

############################### initialize the array ############################
# first create a 100 elements array in the stack

addi sp, sp, -400   # preserve 400 bytes for the 100 elements
mv s0, sp           # save the base address of the array in s0
mv s1, a3           # save another len to s1

li t0, -1      # value to be stored
li t1, 100     # number of elemnts in the array
mv t2, s0      # save the base pointer to t2

create_array:
    beqz t1, create_array_done
    addi t1, t1, -1
    sw t0, 0(t2)    # save the current element to -1
    addi t2, t2, 4
    j create_array

create_array_done:


############################# main loop #######################################

# t2: current array element
# t3: complement

main:   
    beqz s1, not_found
    addi s1, s1, -1
    lw t2, 0(a2)        # t2 = A[current]
    addi a2, a2, 4
    sub t3, a4, t2      # complement = target - current
    bltz t3, store_lookup 
    li t4, 99
    bgt t3, t4, store_lookup
    li t4, -1
    slli t5, t3, 2      # t5 be the index of the array
    add t6, s0, t5
    lw t5, 0(t6)        # t5 is now lookup[complement]
    beq t5, t4, store_lookup

    mv t0, t5           # t0 = lookup[complement]
    mv t4, a3
    sub t4, t4, s1
    addi t4, t4, -1
    mv t1, t4


    j done

store_lookup:
    slli t5, t2, 2
    add t5, t5, s0      # t5 = the index for lookup[current]
    mv t4, a3
    sub t4, t4, s1
    addi t4, t4, -1
    sw t4, 0(t5)
    j main

not_found:
    li t0, -1
    li t1, -1



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