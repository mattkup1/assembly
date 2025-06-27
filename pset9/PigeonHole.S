# mytargil.S
# Written by: Dr. Avi Treistman
# Computer Architecture Lab
# Jerusalem College of Technology 2025

# RISC-V Assembly code for a simple program that interacts with the user
# and performs basic arithmetic operations.

# Pigeonhole Sort Algorithm

.include "ecalls.inc"
.equ NUMS, 8
.equ NUM_STR, 8+'0'

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
    li s3, 0x80                     # MAX (init to min single byte int = -128)
    li s4, 0x7f                     # MIN (init to max single byte int = 127)
    li a7, ECALL_PRINT_STRING       # Print "Enter "
    la a0, prompt
    ecall

    # Read NUMS integers
    la s1, array                    # s1 = array
    addi s2, s2, NUMS               # s2 = array + len(array)
read_loop:
    li a7, ECALL_PRINT_STRING       # Print "Enter integer: "
    la a0, input_msg
    ecall

    li a7, ECALL_READ_INT           # syscall for read integer
    ecall
   
    sw a0, 0(s1)                    # Store input in array[i]

    addi s1, s1, 1                  # s1  = (s1 + 1)
    bge a0, s3, not_bigger          # if a0 <= s3 (MAX) then skip
    mv s3, a0                       # else s3 (MAX) = input
    not_bigger:
    ble a0, s3,not_smaller          # if a0 >= s4 (MIN) then skip
    mv s4, a0                       # else s4 (MIN) = input

    not_smaller:
    ble s1, s2, read_loop           # if (beg <= end) read next number

#calculate range 
    sub s3, s3, s4                  # s3 = MAX - MIN
    addi s3, s3, 1                  # s3 = range = MAX - MIN + 1

#round up to multiple of 8
    addi s5, s3, 7                  # s5 = s3 + 7
    andi s5, s5, 0xfffffff8         # Clear the lower 3 bits to round down to the nearest multiple of 8

#s3 = HOLES
#s4 = MIN_VAL
#s5 = Stack adjustment

# Initialize holes to 0
sub sp, sp, s5                  # allocate space on stack for holes array
add s1, sp, s5                  # s1 = &holes[end]
   
init_holes:                     # i = end(holes)
    sb zero, 0(s1)              # holes[i] = 0
    addi s1, s1, -1             # i -= 1
    bne sp, s1, init_holes      # Repeat while i != beg(holes)

# Populate holes
    la s1, array                # s1 = &array[0]
    add s2, s1,(NUMS*4)         # s2 = array[end]
    mv t0, sp                   # t0 = &holes
    #for each element X in A
populate_holes:
    lb t1, 0(s1)                # t1= array[i]
    sub t1, t1, s4              # Offset value to handle negative indices
    add t1, t0, t1              # calculate holes[x-min_val]
    lb   t2, 0(t1)              # t2 holes[x-min_val]
    addi t2, t2, 1              # t2 +1,holes[x-min_val] + 1
    sw   t2, 0(t1)              # holes[x-min_val] += 1
    addi s1, s1, 4              # next num
    blt s1, s2, populate_holes

# Reconstruct sorted array
    li t0, 0              # Index for holes
    li t1, 0              # Index for array
    mv t2, sp
    la t3, array
    add t6, zero, s3      # end loop
reconstruct:
    add t4, t2, t0        # hole[i]
    lb t4, 0(t4)          # t4 = Count in hole[t0]

    loop:                  
    beq t4, zero, nexti   # while holes[i] > 0
    add t5, t0, s4
    sw  t5, 0(t3)         # A[index] = i + min_val
    addi t3, t3, 4        # move to A[a+1]
    addi t4, t4, 1       # count --s
    j loop

nexti:
   addi t0, t0, 1
   bgt t0, t6, print_array
   j reconstruct

# Print sorted array
print_array:
    li a7, ECALL_PRINT_STRING
    la a0, output_msg
    ecall
    la s1, array
    addi s2, s1, (NUMS*4)

print_loop:
    lw a0, 0(s1)
    li a7, ECALL_PRINT_INT
    ecall

    # Print newline character
    li a0, '\n'                 # ASCII code for newline
    li a7, ECALL_PRINT_STRING     # Syscall for print_char
    ecall

    addi s1, s1, 4
 
    bne s1, s2, print_loop

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
array:      .space (NUMS*4)        # Space for NUM integers (4 bytes each)
