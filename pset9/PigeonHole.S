.data
prompt:     .ascii "Enter 8 integers\n"
input_msg:  .asciz "Enter integer: "
output_msg: .asciz "Sorted array:\n"
array:      .space 8       # Space for NUM integers (1 byte each)

.text

# Get array -- read NUMS integers, and calculate min and max values
la s2, array                    # S2 = pointer to first index in the array
li s3, 0x80                     # MAX (init to min single byte int = -128)
li s4, 0x7f                     # MIN (init to max single byte int = 127)
li a7, 4                        # Print "Enter "
la a0, prompt
ecall

# Read 8 integers
la s1, array                    # s1 = array
addi s2, s2, 8                  # s2 = array + len(array)

read_loop:
    li a7, 4                    # Print "Enter integer: "
    la a0, input_msg
    ecall

    li a7, 5                    # syscall for read integer
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
    addi s2, s1, 8              # s2 = array[end]
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
    addi t0, t0, 1                  # i += 1
    bgt t0, t6, print_array         # if i == Num Holes, break
    j reconstruct

    add sp, sp, s5                  # Adjust sp 

# Print sorted array
print_array:
    li a7, 4
    la a0, output_msg			    # Print "sorted array"
    ecall
    la s1, array
    addi s2, s1, 8

print_loop:
    lb a0, 0(s1)
    li a7, 1
    ecall

    # Print newline character
    li a0, '\n'                 # ASCII code for newline
    li a7, 11                   # Syscall for print_char
    ecall

    addi s1, s1, 1

    bne s1, s2, print_loop		# Repeat while &array[beg] != &array[end]

# Exit
    li a7, 10
    ecall





