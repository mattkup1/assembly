# -------------------------------------
# Name: Matt Kuperwasser 322667270
# Name: Moshe Hanau 215538257
# Course: Lab in Computer Architecture
# Final project: Magic Squares
# Simulator Version
# -------------------------------------

# magicSquare.s

# RISC-V Assembly code for a program that creates a magic square of given size n using the siames method

.text

magicSquare:
    # Print welcome message
    la a0, welcome_msg
    li a7, 4   
    ecall
    j get_size
    invalid_input:
        jal ra, handle_invalid_input

    get_size:
        # Print prompt for square size 
        la a0, size_msg
        ecall

        # Size = Read int from user
        li a7, 5
        ecall
    # If size == 0 exit program
        beq a0, zero, exit
    # Input validation
        # Valid size: 3 >= size <= 10 and odd
        li t0, 3
        blt a0, t0, invalid_input
        li t0, 10
        bgt a0, invalid_input
        andi t0, a0, 1
        beqz t0, invalid_input
        # Else
        mv s1, a0                       # s1 = size
       
        jal ra, handle_valid_input      # a0 = size
            # Print size confirmation
        addi sp, sp, -8
        sw ra, 4(sp)
        sw a0, 0(sp)

        mv t0, a0
        la a0, creating_square_msg          # Print size confirmation message
        li a7, 4
        ecall
        mv a0, t0                           # Print size
        li a7, 1
        ecall
        li a0, '\n'                         # Print newline
        li a7, 11
        ecall

        # Allocate size * size space on stack
        # Use fp to access array

        mul t0, t0, t0
        mv fp, sp
        sub sp, sp, t0

handle_invalid_input:
    la a0, invalid_size_msg
    li a7, 4
    ecall
    ret



    lw ra, 4(sp)
    ret


   

# Generate, display and verify the magic square
    jal ra, generate_magic_square # generate_magic_square()r3
 
    # Exit with code 0
exit:
    li a7, ECALL_EXIT
    li a0, 0
    ecall
    




.section .data
welcome_msg:            .asciz "Welcome to the RISC-V Magic Square Generator!\n"
size_msg:               .asciz "Enter the size of the square: "
invalid_size_msg:       .asciz "Invalid square size\n"
creating_square_msg:    .asciz "Creating square of size: 3\n"
row_sums_msg:           .asciz "Row sums: "
col_sums_msg:           .asciz "Column sums: "
diag_sums_msg:          .asciz "Diagonal sums: "
goodbye_msg:            .asciz "Thank you for using this program!\n"
