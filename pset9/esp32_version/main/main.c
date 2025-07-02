// main.c
// Main program that calls the student's assembly function
// This program initializes the ecall system and calls the student's assembly function
// Written by: Dr. Avi Treistman
// Computer Architecture Lab
// Jerusalem College of Technology 2025

#include <stdio.h>
#include <stdlib.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_system.h"
#include "esp_log.h"
#include "led_strip_encoder.h"

#define APP_VERSION_MAJOR "1"
#define APP_VERSION_MINOR "0"
#define APP_VERSION_PATCH "0"
#define APP_VERSION_STRING "JCT Template Version:"APP_VERSION_MAJOR"."APP_VERSION_MINOR"."APP_VERSION_PATCH

extern int ecall_init(void); 
extern void myexercise(void *pvParameters);
extern int handle_ecall(int ecall_num, int arg0, int arg1, int arg2);

static const char* TAG = "Exercise";

void app_main(void)
{
  
    ecall_init(); // Initialize the ecall system    
    init_led_strip_encoder(); // Initialize the LED strip encoder
    ESP_LOGI(TAG, "ecall_init returned");
    vTaskDelay(pdMS_TO_TICKS(2000)); // 100ms delay
    ESP_LOGI(TAG, APP_VERSION_STRING);
    ESP_LOGI(TAG, "Starting Targil");
    ESP_LOGI(TAG, "Calling assembly function: myexercise");
    myexercise(NULL);

    while(1) {
        vTaskDelay(pdMS_TO_TICKS(1000)); // 1 second delay
    };
    ESP_LOGI(TAG, "Assembly function returned");
}