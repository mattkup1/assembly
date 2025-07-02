# ecalls.inc
# This file contains the assembly code for making system calls (ecalls) in RISC-V.  
# It defines the ecall numbers and the function to handle ecalls.
# Written by: Dr. Avi Treistman
# Computer Architecture Lab
# Jerusalem College of Technology 2025


# RISC-V ecall function numbers
.equ ECALL_EXIT,         10
.equ ECALL_PRINT_CHAR,   11
.equ ECALL_PRINT_INT,    1
.equ ECALL_PRINT_STRING, 4
.equ ECALL_READ_CHAR,    12
.equ ECALL_READ_INT,     5
.equ ECALL_READ_STRING,  8
.equ ECALL_SLEEP,        24

.macro ecall
jal do_ecall
.endm 


.text
.global do_ecall
# Helper function to make ecalls
do_ecall:
    # Save the registers we need to preserve
    addi sp, sp, -16
    sw ra, 12(sp)
    
    # Call the C wrapper function
    # a7 already contains the ecall number
    # a0, a1, a2 already contain arguments
    mv a3, a2    # Move arg2 to a3
    mv a2, a1    # Move arg1 to a2
    mv a1, a0    # Move arg0 to a1
    mv a0, a7    # Move ecall number to first argument
    
    # Call the C ecall wrapper function
    call ecall_wrapper
    
    # Restore saved registers and return
    lw ra, 12(sp)
    addi sp, sp, 16
    ret

