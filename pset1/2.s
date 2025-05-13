# Matt Kuperwasser 322667270
# Partner: Moshe Hanau
# Course: Lab in Computer Architecture
# Submission 1 - Basic I/O - Question 2

.data
request_number: .asciz "Please enter a two-digit number: "
error_msg: .asciz "Invalid Value\n"
sum_msg: .asciz "The sum is: "
newline: .asciz "\n"

.text

li a1 0                                 # a1 is the summary variable

begin_loop:
    la a0 request_number                # Prompt user for number
    li a7 4
    ecall

    li a7 5                             # Read int to a0
    ecall

    beq a0,zero print_sum               # If Input is 0 - Print sum

                        	##### Input validation #####
    slti t0,a0,-9
    bne	t0,zero,check_neg
    j check_pos

    check_neg:                          # Input < -9
        slti t0,a0,-99
        bne t0,zero,print_error_msg       # Case Input < -99 - Input is not a 2 digit number
        j valid_input                   # Else - Input is a valid 2 digit number
    
    check_pos:                          # Input > -9
        slti t0,a0,10
        bne t0,zero,print_error_msg       # Case Input < 10 - Input is not a 2 digit number
        slti t0,a0,100
        beq t0,zero,print_error_msg       # Case input > 99 - Input is not a 2 digit number
        j valid_input                   # Else - Input is a valid 2 digit number

    print_error_msg:
        la a0 error_msg
        li a7,4
        ecall
        j begin_loop                   # Read a new number from user
    
    valid_input:
        add a1 a0 a1                    # Summarize

	j begin_loop

print_sum:
    la a0,sum_msg                       # Print sum_msg
    li a7,4
    ecall

    add a0,a1,zero                      # Print the sum (a1)
    li a7,1
    ecall

    la a0,newline                       # Print newline after sum
    li a7,4
    ecall

    li a1,0                             # Clear sum variable
	j begin_loop                            # Get new set of inputs
	
li a7,10
ecall




