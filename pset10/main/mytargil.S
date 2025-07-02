# mytargil.S
# Written by: Dr. Avi Treistman
# Computer Architecture Lab
# Jerusalem College of Technology 2025

# RISC-V Assembly code for a simple program that interacts with the user
# and performs basic arithmetic operations.

# This program demonstrates the use of system calls for input and output.
# It prompts the user for a number, calculates its square, and prints the result.
# The program continues to prompt for numbers until the user enters 0.
# It also includes a welcome and goodbye message.
# The program uses the RISC-V calling convention and system call interface. 
# The code is written in RISC-V assembly language and is intended to be run on an ESP32C6 or similar dev bopard.

# Usage for homework:
# Replace all the code from myexercise function (line 28) to the end of the file with your code.

.option norvc
.include "ecalls.inc"

.section .text
.align 2
.globl myexercise

# Function declaration
myexercise:
    # Save the return address and any callee-saved registers you need
    addi sp, sp, -16
    sw ra, 12(sp)
    sw s0, 8(sp)
    sw s1, 4(sp)  # used to store led result 
    sw s2, 0(sp)  # used to store led color
    addi s0, sp, 16  # Set up s0 as a frame pointer


get_size:
    # Print welcome message
    # Print prompt for square size
    # Size = Read int from user
    # If size == 0 exit program
        beq a0, zero, exit
    validate_input:
        ## if size > 3 and size < 10 and size is even
            j validate_input
        # Else
            # call handle_invalid_input()
            # Next iteration
            j get_size

handle_invalid_input:
    # Display error message for invalid size
    # Size must be odd and between 3 and 10 inclusive
    ret

handle_valid_input:
    # Print size confirmation

    # Allocate size * size space on stack
    # Use fp to access array

# Generate, display and verify the magic square
    jal ra, generate_magic_square # generate_magic_square()r3

 
    # Exit with code 0
exit:
    li a7, ECALL_EXIT
    li a0, 0
    ecall
    
    # Restore saved registers and return
    lw s2, 0(sp) 
    lw s1, 4(sp) 
    lw s0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    ret



.section .data
welcome_msg:  .string "Welcome to the RISC-V Assembly Example!\n"
name_msg:     .string "Please enter your name: "
prompt_msg:   .string "Please enter a number: "
result_msg:   .string "You entered: "
square_msg:   .string "The square of your number is: "
goodbye_msg:  .string "Thank you for using this program!\n"
name:      .space 80  # Space for the name (32 bytes)