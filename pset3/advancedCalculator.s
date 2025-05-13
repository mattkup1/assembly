# Name: Matt Kuperwasser, 322667270
# Name: Moshe Hanau, 
# Course: Computer Architecture Lab
# Homework 3 - Advanced Calculator


.data 
input_signal: .asciz ">>"
result_msg: .asciz "Result: " 
overflow_msg: .asciz "Overflow error!\n"
newline: .asciz "\n"
.text


start:
	la a0,input_signal			# Print "<<" to get first number from the user
	li a7,4
	ecall
	
	li a7,5						# Get first number from user
	ecall
	
	mv s0,a0					# Store the number and result in s0
	
	loop:						# While operator is not '@', Continue taking user input
		la a0,input_signal		# Print "<<" to get operator from the user
		li a7,4
		ecall
		
		li a7,12				# Get operator from user
		ecall
		
		mv s1,a0				# Store the operator in s1

		li t0,'='				# Case operator is '='
		beq s1,t0,print_result
		li t0,'@'				# Case operator is '@'
		beq s1,t0,print_result
		
		la a0,input_signal		# Print "<<" to get the next number from the user
		li a7,4
		ecall
		li a7,5					# Get number from user
		ecall

		mv a1,s0				# Store result in arg reg a1
			
		li t0,'+'
		beq s1,t0,add_

		li t0,'-'
		beq s1,t0,sub_
		
		li t0,'*'
		beq s1,t0,multiply

		li t0,'^'
		beq s1,t0,pow

		bottom_loop:
			mv s0,a0			# Store returned result a0 back in s0
			j loop				# Jump to top of loop and get next user input

add_:
	jal ra,myAdd				# Perform a0 = a0 + a1
	j bottom_loop

sub_:
	jal ra,mySub				# Perform a0 = a1 - a0

multiply:
	jal ra,myMul				# Perform a0 = a0 * a1
	j bottom_loop	

pow:
	jal ra,myPow				# Perform a0 = a1 ^ a0
	j bottom_loop	

myAdd:							# a0 = a0 + a1
	add a0,a0,a1				# Perform addition, Store result in a0
	ret

mySub:							# a0 = a0 - a1
	jal ra,two_compliment		# Compute the 2's compliment of right operand a0
	jal ra,myAdd					# Add the negative (a0 = a0 + (- a1))
	ret

myMul:							# a1 is result, a0 is right operand - Compute a0 = a0 * a1
	addi sp,sp,-16
	sw ra,12(sp)
	sw a1,8(sp)
	sw t0,4(sp)
	sw t1,0(sp)

	slt t0,a0,zero				# Case a0 (right operand) is negative
	li t1,1
	beq t0,t1,mull_neg

	mv t0,a0					# Store right operand in t0
	mv t1,a1					# Store left operand (current result) in t1
	mul_loop:					# Repeat a1 (right operand) times 
		beq zero,t0,done_mul
		jal ra,myAdd			# Add a0 = a0 + a1
		addi t0,t0,-1			# Decrement t0
		j mul_loop				
	
	mull_neg:
		jal two_compliment		# Take 2's compliment of right operand
		mv t0,a0				# Store right operand (a0) in t0
		mv a0,a1				# Store left operand (a1) in a0
		jal two_compliment		# Take 2's compliment of left operand (result)
		mv a1,a0				# Store the 2's compliment of left operand back in a1
		mv a0,t0				# Store the 2's compliment of right operand back in a0		
		j mul_loop				# Perform multiplication

done_mul:		
		addi sp,sp,-16
		lw t1,0(sp)
		lw t0,4(sp)
		lw a1,8(sp)
		lw ra,12(sp)
		addi sp,sp,16
		ret

myPow:							# a0 = Exponent, a1 = base
	addi sp,sp,-16				# Handle memory management
	sw ra,12(sp)
	sw a0,8(sp)
	sw a1,4(sp)

	beq zero,a0,zero_exp		# Case exponent is zero
	slt t0,a0,zero				# Case exponent is a negative number
	li t1,1
	beq t0,t1,negative_exp

	mv t0,a0					# Store exponent in t0
	mv a0,a1					# Store base (a1 - result) in a0 in order to pass into the myMul function (a0 = a0 * a1)
	pow_loop:					# Multiply a0 by itself t0 (exponent) times
		beq t0,zero,done_pow
		jal ra,myMul
		addi t0,t0,-1
		j pow_loop

zero_exp:
	li a0,1
	j done_pow
negative_exp:
	mv a0,zero
	j done_pow
done_pow:
	lw a1,4(sp)
	lw ra,12(sp)
	addi sp,sp,16
	ret

two_compliment:
	addi sp,sp,-8
	sw ra,4(sp)
	sw a0,0(sp)
	xori a0,a0,0xFFFFFFFF
	addi a0,a0,1
	addi sp,sp,8
	ret


print_result:					# Print the result, Operator is in t0
	li a7,4						# Print "Result: "
	la a0,result_msg
	ecall
	li a7,1						# Print the result number stored in s0
	mv a0,s0
	ecall

	li a7,4						# Print new line
	la a0,newline
	ecall

	li t1,'@'					# Case '@' operator - Exit program
	beq s1,t1,exit
	
	j start						# Case '=' operator return to start
	
exit:							# exit program
	li a7,10 						
	ecall

