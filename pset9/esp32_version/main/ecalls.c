// ecall.c
// This file contains the implementation of the ecall system for the RISC-V assembly code.
// The ecall system allows the assembly code to call C functions for I/O operations.
// Written by: Dr. Avi Treistman
// Computer Architecture Lab
// Jerusalem College of Technology 2025
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/uart.h"
#include "driver/uart_vfs.h"
#include "esp_log.h"
#include "esp_system.h"
#include "esp_task_wdt.h"

// RISC-V ecall function numbers
#define ECALL_EXIT         10
#define ECALL_PRINT_CHAR   11
#define ECALL_PRINT_INT    1
#define ECALL_PRINT_STRING 4
#define ECALL_READ_CHAR    12
#define ECALL_READ_INT     5
#define ECALL_READ_STRING  8
#define ECALL_SLEEP        24
// Forward declaration of the student's assembly function
extern void myexercise(void);
#define UART_NUM UART_NUM_0  // Use USB Serial (UART1)
#define BUF_SIZE 128

int ecall_init(void) {
    // Initialize the ecall system 
    uart_config_t uart_config = {
        .baud_rate = 115200,
        .data_bits = UART_DATA_8_BITS,
        .parity = UART_PARITY_DISABLE,
        .stop_bits = UART_STOP_BITS_1,
        .flow_ctrl = UART_HW_FLOWCTRL_DISABLE
    };
    uart_param_config(UART_NUM, &uart_config);
    uart_driver_install(UART_NUM, BUF_SIZE * 2, 0, 0, NULL, 0);
    vTaskDelay(pdMS_TO_TICKS(100)); // 100ms delay
    uart_vfs_dev_use_driver(UART_NUM);
    uart_vfs_dev_port_set_tx_line_endings(UART_NUM, ESP_LINE_ENDINGS_CRLF);
    uart_flush(UART_NUM);


    return 0;
}

int read_int_i() {
    uint8_t byte;
    char buffer[20];
    int index = 0;
   
    while (1) {
        // Read one byte at a time
        int len = uart_read_bytes(UART_NUM, &byte, 1, 0);
        if (len > 0) {
            // Check for newline character indicating the end of the integer
            if  (byte == '\r'){
                buffer[index] = '\0';  // Null-terminate the string
                uart_flush_input(UART_NUM);
                fpurge(stdin);
                break;
            }  else if (byte >= '0' && byte <= '9') {
                // Append byte to buffer
                buffer[index++] = byte;
    
            } else if (byte == '-' && index == 0) {
                // Append byte to buffer
                buffer[index++] = byte;
            } 
    
        }
        vTaskDelay(10 / portTICK_PERIOD_MS);
    }
        int integer_value = atoi(buffer);
       // fpurge(stdin);
        return integer_value;
}


#include "driver/uart.h"
#include "esp_log.h"

#define UART_NUM UART_NUM_0
#define BUF_SIZE 128

int nonblocking_read_line(char *buffer, size_t max_length) {
    size_t i = 0;
    uint8_t ch;

    while (i < max_length - 1) {
        int len = uart_read_bytes(UART_NUM, &ch, 1, 0);  // timeout=0 = non-blocking

        if (len == 0) {
            // No data available; you can yield or delay here
            vTaskDelay(pdMS_TO_TICKS(10));
            continue;
        }

        if (ch == '\r' || ch == '\n') {
            break;
        }

        buffer[i++] = ch;
    }

    buffer[i] = '\0';
    uart_flush_input(UART_NUM);
    return i;
}

// Function that simulates RISC-V ecalls
int handle_ecall(int ecall_num, int arg0, int arg1, int arg2) {
    switch (ecall_num) {
        case ECALL_EXIT:
            printf("\n[Program exited with code %d]\n", arg0);
             while(1) {
                  vTaskDelay(pdMS_TO_TICKS(1000)); // 1 second delay
            };
            return 0;
            
        case ECALL_PRINT_CHAR:
            putchar(arg0);
            fflush(stdout);
            return 0;
            
        case ECALL_PRINT_INT:
            printf("%d", arg0);
            fflush(stdout);
            return 0;
            
        case ECALL_PRINT_STRING:
            if (arg0 != 0) {
                printf("%s", (char*)arg0);
                fflush(stdout);
            }
            return 0;
            
        case ECALL_READ_CHAR: {
            uint8_t c;
           
        // Loop until a character is received
            while (1) {
                int len = uart_read_bytes(UART_NUM_0, &c, 1, 0);  // non-blocking read

                if (len > 0) {
                    uart_flush(UART_NUM);
                    return (int)c;  // return the character
                }
            // Optionally yield for a bit (prevents hogging the CPU)
                vTaskDelay(pdMS_TO_TICKS(10));
             }
    
        }
        case ECALL_READ_INT: {
            return read_int_i();
        }
            
        case ECALL_READ_STRING: {
            char* buffer = (char*)arg0;
            int max_length = arg1;
            
            if (buffer == NULL || max_length <= 0) {
                return -1;
            }
     
         //    if (fgets(buffer, max_length, stdin) == NULL) {
            if (nonblocking_read_line(buffer, max_length) == 0) {
                buffer[0] = '\0';
                return 0;
            }
            
            // Remove newline if present
            int len = strlen(buffer);
            if (len > 0 && buffer[len-1] == '\n') {
                buffer[len-1] = '\0';
                len--;
            }
            uart_flush_input(UART_NUM);
            return len;
        }
        case ECALL_SLEEP: {
            int sleep_time = arg0;
            if (sleep_time > 0) {
                vTaskDelay(pdMS_TO_TICKS(sleep_time));
            }
            return 0;
        }

        default:
            printf("[Unknown ecall number: %d]\n", ecall_num);
            return -1;
    }
}

// This C function will be called from assembly
int ecall_wrapper(int ecall_num, int arg0, int arg1, int arg2) {
    return handle_ecall(ecall_num, arg0, arg1, arg2);
}