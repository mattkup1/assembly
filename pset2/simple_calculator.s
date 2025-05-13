# Name: Matt Kuperwasser
# ID: 32267270
# Course: Computer Architecture Lab
# Homework 2, Question 1
# Partner: Moshe Hanau, ID: 215538257


.data
input_signal: .asciz ">> "
result_msg: .asciz "Result: "
overflow_msg: .asciz "Overflow error!\n"
newline: .asciz "\n"

.text

start:

la a0,input_signal				# Print '<<'
li a7,4
ecall

li a7,5							# Read first number
ecall

add t0,a0,zero					# Store result and first number in t0

loop:
	la a0,input_signal			# Print '<<'
	li a7,4
	ecall
	
	li a7,12					# Read operator
	ecall
	
	li t2,'='
	beq a0,t2,print_result		# Break if operator is '='
		
	mv t3,a0					# Move operator to t3
	
	la a0,input_signal			# Print '<<'
	li a7,4
	ecall

	li a7,5						# Read number
	ecall
	
	add t1,a0,zero				# Move input in t1
	
	li t2,'+'
	beq t3,t2,addition
	li t2,'-'
	beq t3,t2,subtraction
	li t2,'*'
	beq t3,t2,multiplication
	
	j loop						# Next iteration
	

addition: 						# t0 += t1
	add t2,t0,t1				# t2 = result
	xor t4,t0,t1				# check if signs are different (MSB differs)
	blt t4,zero,no_overflow_add	# case sign is different, No overflow
	xor t4,t2,t0				# case same sign, Check if result sign is different from t0
	bge t4,zero,no_overflow_add	# Case same sign, No overflow
	j overflow					# case overflow detected
	
	no_overflow_add:
		add t0,t0,t1
		j loop
	
	
subtraction: 					# t0 -= t1
	sub t2,t0,t1				# t2 = result
	xor t4,t0,t1				# check if signs are different
	blt t4,zero,no_overflow_sub
	xor t4,t2,t0				# check if result sign is different from t0
	bge t4,zero,no_overflow_sub
	j overflow
	
	no_overflow_sub:
		sub t0,t0,t1
		j loop
	

multiplication: 				# t0 *= t1 
	mulh t2,t0,t1				# store high bits
	mul t3,t0,t1				# store result in t3
	srai t4,t3,31				# store sign bit in t4
	bne t2,t4,overflow			# check if high is all sign bit
	mul t0,t0,t1				# case no overflow
	j loop

overflow:						# print overflow message
li a7,4
la a0,overflow_msg
ecall
j start							# jump to beginning

print_result:					# Print the result
li a7,4
la a0,result_msg
ecall
li a7,1
add a0,t0,zero
ecall

li a7,4							# Print new line
la a0,newline
ecall

j start							# jump to beginning

li a7,10 						# exit program
ecall


