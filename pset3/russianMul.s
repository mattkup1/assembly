.data 
input_signal: .asciz ">>"
result_msg: .asciz "Result: " 
op_error_msg: .asciz "Not an operator\n"
newline: .asciz "\n"
.text


start:
	la a0,input_signal			# Print "<<" to get first number from the user
	li a7,4
	ecall
	
	li a7,5						# Get first number from user
	ecall
	
	mv s0,a0					# Store the number and result in s0
	
	main_loop:					# While operator is not '@', Continue taking user input
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
		li a7,5					# Get right operand from user
		ecall

		mv a1,a0				# Copy right operand to arg reg a1
		mv a0,s0				# Copy result (left operand) to arg reg a0 
			
		li t0,'+'				# Case '+' operator
		beq s1,t0,add_			# Add a0 = a0 + a1

		li t0,'-'				# Case '-' operator
		beq s1,t0,sub_			# Subtract a0 = a0 - a1
		
		li t0,'*'				# Case '*' operator
		beq s1,t0,multiply		# Multiply a0 = a0 * a1

		li t0,'^'				# Case '^' operator
		beq s1,t0,pow			# Raise a0 = a0 ^ a1

		la a0,op_error_msg		# Case not valid operator - Print error message
		li a7,4
		ecall
		
		j main_loop

		bottom_loop:			# Once operation is complete
			mv s0,a0			# Store returned result a0 back in s0
			j main_loop			# Jump to top of loop and get next user input

add_:
	jal ra,myAdd				# Perform a0 = a0 + a1
	j bottom_loop

sub_:
	jal ra,mySub				# Perform a0 = a1 - a0
	j bottom_loop

multiply:
	jal ra,myMul				# Perform a0 = a0 * a1
	j bottom_loop	


pow:
	jal ra,myPow				# Perform a0 = pow(a0,a1)
	j bottom_loop	

myAdd:							# a0 = a0 + a1
	add a0,a0,a1				# Perform addition, Store result in a0
	ret

mySub:							# a0 = a0 - a1
	addi sp,sp,-16				# Memory management
	sw ra,12(sp)
	sw a0,8(sp)
	sw a1,4(sp)
	sw t0,0(sp)

	mv t0,a0					# Copy result a0 in t0 temporarily
	mv a0,a1					# Copy right operand a1 to a0 in order to take it's 2's compliment
	jal ra,two_compliment		# Compute the 2's compliment of right operand a1 - send to function as a0
	mv a1,a0					# Copy negative right operand back to a1
	mv a0,t0					# Copy left operand (result) back to a0
	jal ra,myAdd				# Add the negative (a0 = a0 + (- a1))

	lw t0,0(sp)					# Copy reg values back from memory (except the return value a0)
	lw a1,4(sp)
	lw ra,12(sp)
	addi sp,sp,16
	ret

myMul:							# Compute a0 = a0 * a1 (a0 is result, a1 is right operand) - Via russian method
	addi sp,sp,-24				# Decrement Stack Pointer and store register values to memory
	sw ra,20(sp)
	sw a1,16(sp)
	sw t0,12(sp)
	sw t1,8(sp)
	sw t2,4(sp)

	slt t0,a1,zero				# Case a1 (right operand) is negative - Multiply 2's compliment of both operands
	li t1,1						
	beq t0,t1,mull_neg

	neg_continue:				# mull_neg returns to this line

    mv t0,a0                    # Copy left operand to t0
	mv a0,zero					# Reset a0

	mul_loop:					# Repeat until a1 = 1
		beq t0,zero,done_mul	# Break if left operand is zero
		andi t2,t0,1			# Check if t0 (right operand) is even
		beq t2,zero,skip_add	# If even, do not perform addition
		
		jal ra,myAdd			# Case odd - Add shifted a1 to a0

		skip_add:
			srli t0,t0,1		# t0 >> 1 (divide left operand by 2)
			slli a1,a1,1		# a1 << 1 (multiply right operand by 2)
		j mul_loop				
	
	mull_neg:
		mv t0,a0				# Copy left operand a0 to t0 temporarily
		mv a0,a1				# Copy right operand a1 to a0 in order to take it's 2's compliment
		jal two_compliment		# Take 2's compliment of right operand (currently in a0)
		mv a1,a0				# Store negative right operand back in a1
		mv a0,t0				# Store left operand back in a0 in order to take it's 2's compliment
		jal two_compliment		# Take 2's compliment of left operand (result)	
		j neg_continue			# Perform multiplication - right operand is now positive

done_mul:				
		lw t2,4(sp)				# Restore register values exept for return value a0
		lw t1,8(sp)				
		lw t0,12(sp)
		lw a1,16(sp)
		lw ra,20(sp)
		addi sp,sp,24
		ret

myPow:							# a0 = Exponent, a1 = base
	addi sp,sp,-24				# Handle memory management
	sw ra,20(sp)
	sw a1,16(sp)
	sw t0,12(sp)
	sw t1,8(sp)

	beq zero,a1,zero_exp		# Case exponent is zero
	slt t0,a1,zero				# Case exponent is negative
	li t1,1
	beq t0,t1,negative_exp

	mv t0,a1					# Store exponent in t0
	mv a1,a0					# Store base in a1 in order to multiply a0 * a1
	pow_loop:					# Multiply a0 by itself t0 (exponent) times
		addi t0,t0,-1
		beq t0,zero,done_pow
		jal ra,myMul
		j pow_loop

zero_exp:						# Handle zero exponent 
	li a0,1						# Return 1 in a1
	j done_pow
negative_exp:					# Handle negative exponent
	li a0,0						# Return 0 in a0
	j done_pow
done_pow:						# Restore register values from memory
	lw t1,8(sp)
	lw t0,12(sp)
	lw a1,16(sp)
	lw ra,20(sp)
	addi sp,sp,24				# Increment Stack Pointer
	ret							# Return from function

two_compliment:					# Compute the 2's compliment of a0 and store it back in a0
	addi sp,sp,-8				# Decrement Stack Pointer copy register values to memory
	sw ra,4(sp)
	sw a0,0(sp)
								# Compute 2's compliment by inverting all bits and adding 1
	xori a0,a0,0xFFFFFFFF		# Invert all bits	
	addi a0,a0,1				# Add 1

	lw ra,4(sp)					# Restore register values from memory
	addi sp,sp,8				# Increment Stack Pointer
	ret							# Return from function

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

