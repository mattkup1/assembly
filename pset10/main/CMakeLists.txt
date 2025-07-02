idf_component_register(SRCS "mytargil.S" "ecalls.c" "main.c" "led_strip_encoder.c"
                    INCLUDE_DIRS "."
                    PRIV_REQUIRES esp_driver_rmt  esp_driver_uart
                    )