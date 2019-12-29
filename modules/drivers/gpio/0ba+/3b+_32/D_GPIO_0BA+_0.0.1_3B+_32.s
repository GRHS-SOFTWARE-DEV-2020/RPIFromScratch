.section .init
.include "../gpio_0ba+_driver.s"

/*
    DRIVER DEFINITION FOR : rpi3b+ 32 bit
 */

 // define the implementation
 interface_definition:

        _D_GPIO_set_pin_1_
        _D_GPIO_clear_pin_1_
        _D_GPIO_get_pin_value_1_
        _D_GPIO_enable_event_detect_1_
        _D_GPIO_disable_event_detect_1_
        _D_GPIO_pin_event_status_1_
        _D_GPIO_get_event_status_masks_1_
        _D_GPIO_get_pin_function_1_
        _D_GPIO_set_pin_function_input_1_
        _D_GPIO_set_pin_function_output_1_
        _D_GPIO_set_pin_function_0_1_
        _D_GPIO_set_pin_function_1_1_
        _D_GPIO_set_pin_function_2_1_
        _D_GPIO_set_pin_function_3_1_
        _D_GPIO_set_pin_function_4_1_
        _D_GPIO_set_pin_function_5_1_
        _D_GPIO_reserve_pin_1_

