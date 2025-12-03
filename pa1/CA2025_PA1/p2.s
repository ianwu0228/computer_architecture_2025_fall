.globl __start

.rodata
    msg0: .string "This is p2 (max subarray sum)"
    msg1: .string "\nThe result is: "
.data
    A:   .word 829, -89, 202, 766, -325, -408, 440, 851, 921, 315, -37, -43, 644, 654, 533, 844, -393, 995, 185, 68, 587, 354, 697, 654, 256, 805, 829, -317, 130, 392, 873, 922, 230, 428, -59, 614, 300, -498, -61, 197, 37, 386, 119, 7, -394, -47, 477, -235, 467, 456
    len: .word 50

.text

__start:
    # print msg
    li a0, 4
    la a1, msg0
    ecall
    
    lw t1, len        # t1 = len
    la t2, A          # t2 = base address of A
    
    ### TODO ###
    
# t0: max_so_far
# t3: current_sum
# t4: current_element (x)
# t5: current_sum + x (t3 + t4)


lw t4, 0(t2)     # load A[0] to current_element
mv t0, t4       # make max_so_far be A[0] first
mv t3, t4       # current_sum = current_element
li t5, 0        # initialize t5
addi t1, t1, -1 # t1 -= 1
addi t2, t2, 4



mss:
    beqz t1, done   # if loop through all the array, then done
    lw t4, 0(t2)
    addi t1, t1, -1 # t1 -= 1
    add t5, t3, t4
    bgt t4, t5, current_sum_to_x      # compare if x > current_sum + x
    add t3, t3, t4 #current_sum += x
    j compare

current_sum_to_x:
    mv t3, t4   # current_sum = x

compare:
    ble t0, t3, max_so_far_to_current_sum   
    j cont


max_so_far_to_current_sum:
    mv t0, t3   # max_so_far = current_sum

cont:
    addi t2, t2, 4
    j mss


done:
    # print result
    li a0, 4
    la a1, msg1
    ecall
    li a0, 1
    mv a1, t0
    ecall

    # exit
    li a0, 10
    ecall