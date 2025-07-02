# -------------------------------------
# Course: Lab in Computer Architecture
# Lab 9: Pigeon Hole Sort Algorithm
# esp32 Version
# -------------------------------------

# mytargil.S
# Written by: Dr. Avi Treistman
# Computer Architecture Lab
# Jerusalem College of Technology 2025

# RISC-V Assembly code for a simple program that interacts with the user
# and performs basic arithmetic operations.

# Pigeonhole Sort Algorithm

.include "ecalls.inc"
.equ NUMS, 8
.equ NUM_STR, 8 + '0'
.equ MAX_BYTE_INT, 127
.equ MIN_BYTE_INT, -128

.section .text
.align 2
.globl myexercise

# Function declaration
myexercise:
    # Save the return address and any callee-saved registers you need
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)
    sw s1, 20(sp)  
    sw s2, 16(sp)  
    sw s3, 12(sp)  
    sw s4, 8(sp)  
    sw s5, 4(sp)  
    addi s0, sp, 32 # Set up s0 as a frame pointer

# Get array -- read NUMS integers, and calculate min and max values
la s2, array                    # S2 = pointer to first index in the array
li s3, MIN_BYTE_INT             # MAX (init to min single byte int = -128)
li s4, MAX_BYTE_INT             # MIN (init to max single byte int = 127)
li a7, ECALL_PRINT_STRING       # Print "Enter 8 integers: "
la a0, prompt
ecall

# Read 8 integers
la s1, array                    # s1 = array
addi s2, s2, NUMS               # s2 = array + len(array)

read_loop:
    li a7, ECALL_PRINT_STRING   # Print "Enter integer: "
    la a0, input_msg
    ecall

    li a7, ECALL_READ_INT       # syscall for read integer
    ecall

    sb a0, 0(s1)                # Store input in array[i]

    addi s1, s1, 1              # s1 += 4 : i += 1
    ble a0, s3, not_bigger      # if a0 <= s3 (MAX) then skip
    mv s3, a0                   # else s3 (MAX) = input
not_bigger:
    bge a0, s4,not_smaller      # if a0 >= s4 (MIN) then skip
    mv s4, a0                   # else s4 (MIN) = input

not_smaller:
    blt s1, s2, read_loop       # if (beg <= end) read next number

#calculate range 
    sub s3, s3, s4              # s3 = MAX - MIN
    addi s3, s3, 1              # s3 = range = MAX - MIN + 1

    #round up to multiple of 8
    addi s5, s3, 7              # s5 = s3 + 7
    andi s5, s5, 0xfffffff8     # Clear the lower 3 bits to round down to the nearest multiple of 8

    #s3 = Num HOLES
    #s4 = MIN_VAL
    #s5 = Stack adjustment

    # Initialize holes to 0
    sub sp, sp, s5              # allocate space on stack for holes array
    add s1, sp, s5              # s1 = &holes[end]

init_holes:                     # i = end(holes)
    sb zero, 0(s1)              # holes[i] = 0
    addi s1, s1, -1             # i -= 1
    bne sp, s1, init_holes      # Repeat while i != beg(holes)

    # Populate holes
    la s1, array                # s1 = &array[0]
    addi s2, s1, NUMS              # s2 = array[end]
    mv t0, sp                   # t0 = &holes
#for each element X in A
populate_holes:
    lb t1, 0(s1)                # t1 = array[i]
    sub t1, t1, s4              # t1 = array[i] - MIN_VAL = offset
    add t1, t0, t1              # t1 = &(holes + offset)
    lb t2, 0(t1)                # t2 = holes[offset]
    addi t2, t2, 1              # t2 += 1
    sb t2, 0(t1)                # holes[offset] += 1
    addi s1, s1, 1              # next num
    blt s1, s2, populate_holes  # repeat while &holes[beg] < &holes[end]

# Reconstruct sorted array
    li t0, 0                    # t0 = 0 = i
    mv t2, sp                   # t2 = &holes
    la t3, array                # t3 = &array
    mv t6, s3                   # t6 = NUM_HOLES
reconstruct:
    add t4, t2, t0              # t4 = &(holes + i)
    lb t4, 0(t4)                # t4 = hole[i]

loop:                  
    beq t4, zero, nexti         # while holes[i] > 0
    add t5, t0, s4              # t5 = i - offset
    sb t5, 0(t3)                # array[j] = i - offset
    addi t3, t3, 1              # j += 1
    addi t4, t4, -1             # holes[i] -= 1
    j loop

nexti:
    addi t0, t0, 1              # i += 1
    bgt t0, t6, print_array     # if i == Num Holes, break
    j reconstruct

    add sp, sp, s5              # Adjust sp 

# Print sorted array
print_array:
    li a7, ECALL_PRINT_STRING
    la a0, output_msg			# Print "sorted array"
    ecall
    la s1, array
    addi s2, s1, NUMS

print_loop:
    lb a0, 0(s1)
    li a7, ECALL_PRINT_INT
    ecall

    # Print newline character
    li a0, '\n'                 # ASCII code for newline
    li a7, ECALL_PRINT_CHAR     # Syscall for print_char
    ecall

    addi s1, s1, 1

    bne s1, s2, print_loop		# Repeat while &array[beg] != &array[end]

    # Exit
    li a7, ECALL_EXIT
    ecall

    # Restore saved registers and return
    add sp, sp, s4  #restore space on stack
    lw ra, 28(sp)
    lw s0, 24(sp)
    lw s1, 20(sp)  
    lw s2, 16(sp) 
    lw s3, 12(sp)  
    lw s4, 8(sp)  
    lw s5, 8(sp)  
    addi sp, sp, 32
    ret


.section .data
prompt:     .ascii "Enter "
            .byte  NUM_STR
            .asciz " integers\n"
input_msg:  .asciz "Enter integer: "
output_msg: .asciz "Sorted array:\n"
array:      .space (NUMS)        # Space for NUM integers (1 byte each)
