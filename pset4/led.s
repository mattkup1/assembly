.text

li s0,0                                 # Initialize LED register with 0

main:
    li a7,12                            # Read command from user
    ecall

    mv a1,a0                            # Copy command to a1

    
    li t0,'s'                           # If command is s / c / t - Read bit position
    beq a1,t0,read_led_pos              
    li t0,'c'
    beq a1,t0,read_led_pos
    li t0,'t'
    beq a1,t0,read_led_pos
    j bottom_main

    
    read_led_pos:                       # Read bit position from user
        li a7,5
        ecall
        mv a2,a0                        # Copy LED position to a2
        
bottom_main:
    mv a0,s0                            # Copy LED register to a0
    jal led_control                     # Execute command via led_control function with arguments a0, a1, a2
    mv s0,a0                            # Copy returned LED register a0 back to s0
    jal print_led
    j main

led_control:                            # led_control function body
    addi sp,sp,-24                      # Memory management
    sw a0,20(sp)
    sw a1,16(sp)
    sw a2,12(sp)
    sw t0,8(sp)
    sw t1,4(sp)

    li t0,'s'                           # Case set
    beq a1,t0,set_or_toggle

    li t0,'c'                           # Case clear
    beq a1,t0,clear

    li t0,'t'                           # Case toggle
    beq a1,t0,set_or_toggle

    li t0,'r'                           # Case shift right
    beq a1,t0,shift_right

    li t0,'l'                           # Case shift left
    beq a1,t0,shift_left

    li t0,'b'                           # Case rotate right
    beq a1,t0,rotate_right

    li t0,'d'                           # Case rotate left
    beq a1,t0,rotate_left

    end_led_ctrl:
    lw t1,4(sp)
    lw t0,8(sp)                         # Restore register values
    lw a2,12(sp)
    lw a1,16(sp)
    addi sp,sp,24
    ret                                 # Return


set_or_toggle:
    li t0,1                             # Set t0 LSB to 1 and all other bits to 0
    set_loop:                           # Shift t0 left and set the 1 bit to argumented position
        beq a2,zero,end_set_loop        # Break once the 1 bit in t0 is in the correct position
        addi a2,a2,-1                   # Decrement iterator
        slli t0,t0,1                    # Shift t0 right by 1
        j set_loop

    end_set_loop:
        li t1,'s'                       # Case set
        beq a1,t1,skip_toggle
    toggle:                             # Toggle LED at argumented position
        xor a0,t0,a0                    
        j end_led_ctrl
    skip_toggle:                        # Turn on LED at argumented position
        or a0,t0,a0
        j end_led_ctrl

clear:
    li t0,0xfffffffe                    # Set t0 MSB to 0 and all other bits to 1
    clear_loop:                         # Shift t0 right and set the 0 bit to argumented position
        beq a2,zero,end_clear_loop      
        slli t0,t0,1                    # Shift t0 left by 1
        addi t0,t0,1                    # Set new LSB to 1
        addi a2,a2,-1                   # Decrement iterator (argumented)
        j clear_loop
    end_clear_loop:
        and a0,t0,a0                    # Perform bitwise and between shifted number and led register to clear argumented led
        j end_led_ctrl

shift_left:
    slli a0,a0,1                        # Shift LED register left by 1
    j end_led_ctrl

shift_right:
    srli a0,a0,1                        # Shift LED register right by 1
    j end_led_ctrl

rotate_left:                            
    srli t0,a0,31                       # Store LED register MSB in t0
    slli a0,a0,1                        # Shift LED register left by 1, LSB will be 0
    add a0,a0,t0                        # Add stored MSB to shifted LED register, Effectively moving the MSB to the LSB position
    j end_led_ctrl

rotate_right:
    andi t0,a0,1                        # Store LED register LSB in t0
    slli t0,t0,31                       # Move stored LSB from t0 LSB t0 MSB
    srli a0,a0,1                        # Shift LED register right by 1, MSB will be 0
    add a0,a0,t0                        # Add stored LSB (stored in t0 MSB) to shifted LED register - Effectively moving the LSB to the MSB position
    j end_led_ctrl  


print_led:
    addi sp,sp,-24                      # Memory management
    sw a0,20(sp)
    sw a1,16(sp)
    sw a2,12(sp)
    sw t0,8(sp)
    sw t1,4(sp)
    sw t2,0(sp)

    mv t0,a0                            # Copy LED register from a0 to t0, as a0 will be used for syscalls
    li t1,32                            # Set iterator to amount of iterations (32)
    print_loop:
        beq t1,zero,end_print           # Break on 33rd iteration
        addi t1,t1,-1                   # Decrement iterator
        srli t2,t0,31                   # Store LED register MSB in t0 
        slli t0,t0,1                    # Shift LED register left to stage next LED for printing
        beq t2,zero,print_off           # Case LED off - Print "."

        li a7,11                        # Else, LED is on - Print #
        li a0,'#'
        ecall
        j print_loop

        print_off:
            li a7,11                    # Print '.' for off
            li a0,'.'
            ecall

            j print_loop

    end_print:
        li a7,11                        # Print newline
        li a0,10                        # Load newline ASCII code to a0
        ecall

        lw t2,0(sp)                     # Restore register values
        lw t1,4(sp)
        lw t0,8(sp)
        lw a2,12(sp)
        lw a1,16(sp)
        lw a0,20(sp)
        addi sp,sp,24
        ret                             # Return

    
