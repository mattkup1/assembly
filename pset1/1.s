# Name: Matt Kuperwasser 322667270
# Partner: Moshe Hanau
# Course: Lab in Computer Architecture
# Assignment 1, Question 1

.data 
array1: .word 10 20 30 40 50 0 						# original array
array2: .space 24									# copy array
count_msg: .asciz "The count is:"					# Staged strings for later printing
dest_arr_msg: .asciz "The destination array is: " 
print_space: .asciz " "	
newline: .asciz "\n"

.text 
la t0 array1					# load address of array1 to pointer t0
la t1 array2					# load address of array2 to pointer t2
li t3 0							# t3 is the counter

cpy_loop:						# begin iterations
	lw t2 0(t0)					# load current value from array1 to t2
	beq t2 zero exit_cpy		# break if current value is the terminating 0		
	sw t2 0(t1)					# store current value to array2 at current location
	addi t1 t1 4				# increase pointers by word
	addi t0 t0 4
	addi t3 t3 1				# increment counter

j cpy_loop						# next iteration

exit_cpy:						# at the end of the loop, print
	la a0 count_msg				# print staged message
	li a7 4
	ecall

	add a0 t3 zero				# print counter
	li a7 1			
	ecall

	la a0 newline				# print new line
	li a7 4
	ecall

	la a0 dest_arr_msg			# print destination array elements - Print leading text
	li a7 4
	ecall

li t4 0							# iteration counter
la t1 array2		
print_loop:						# print each element
	beq t4 t3 exit_print_loop	# break before 6th iteration			
	lw a0 0(t1)					# print current element
	li a7 1
	ecall	
	la a0 print_space 			# print trailing space
	li a7 4
	ecall
	
	addi t1 t1 4				# Set pointer to next element
	addi t4 t4 1
j print_loop					# Next iteration

exit_print_loop:
	la a0 newline
	li a7 4
	ecall

li a7 10						# terminate program
ecall









