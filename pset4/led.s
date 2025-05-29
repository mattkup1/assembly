.data

.text

li s0,0

main:
    li a7,12                    # Read command from user
    ecall

    mv a1,a0                    # Copy command to a1

    
    li t0,'s'                   # If command is s / c / t - Read bit position
    beq a1,t0,read_led_pos
    li t0,'c'
    beq a1,t0,read_led_pos
    li t0,'t'
    beq a1,t0,read_led_pos
    j bottom_main

    
    read_led_pos:               # Read bit position from user
        li a7,5
        ecall
        mv a2,a0                # Copy LED position to a2
        
bottom_main:
    mv a0,s0                    # Copy LED register to a0
    jal led_control
    mv s0,a0
    j main

led_control:
    addi sp,sp,-16
    sw a0,12(sp)
    sw a1,8(sp)
    sw a2,4(sp)

    li t0,'s'                   # Case set
    beq a1,t0,set

    li t0,'c'
    beq a1,t0,clear

    li t0,'t'
    beq a1,t0,toggle

    li t0,'l'                   # Case set
    beq a1,t0,shift_left

    li t0,'r'
    beq a1,t0,shift_right

    li t0,'b'
    beq a1,t0,rotate_right

    li t0,'d'
    beq a1,t0,rotate_left

    end_led_ctrl:
    lw a2,4(sp)
    lw a1,8(sp)
    addi sp,sp,16
    ret


print_led:


set_or_toggle:
    li t0,1
    set_loop:
        beq a2,zero,end_set_loop
        slli t0,t0,1
        addi a2,a2,-1
    end_set_loop:
        li t0,'s'                       // Case set
        beq a1,t0,skip_toggle
    toggle:                             // Toggle LED at argumented position
        xor a0,t0,a0                    
        j end_led_ctrl
    skip_toggle:                        // Turn on LED at argumented position
        or a0,t0,a0
        j end_led_ctrl

clear:
    li t0,0xfffffffe
    clear_loop:
        beq a2,zero,end_clear_loop
        slli t0,t0,1
        addi t0,t0,1                    // Set LSB to 1
        addi a2,a2,-1
    end_clear_loop:
        and a0,t0,a0                    // Perform bitwise and between shifted number and led register to clear argumented led
        j end_led_ctrl

shift_left:
    slli a0,a0,1
    j end_led_ctrl

shift_right:
    srli a0,a0,1
    j end_led_ctrl

rotate_left:                            
    srli t0,a0,31                       // Store LED register MSB in t0
    slli a0,a0,1                        // Shift LED register left by 1, LSB will be 0
    add a0,a0,t0                        // Add stored MSB to shifted LED register, Effectively moving the MSB to the LSB position
    j end_led_ctrl

rotate_right:
    andi t0,a0,1                        // Store LED register LSB in t0
    slli t0,t0,31                       // Move stored LSB from t0 LSB t0 MSB
    srli a0,a0,1                        // Shift LED register right by 1, MSB will be 0
    add a0,a0,t0                        // Add stored LSB (stored in t0 MSB) to shifted LED register - Effectively moving the LSB to the MSB position
    j end_led_ctrl