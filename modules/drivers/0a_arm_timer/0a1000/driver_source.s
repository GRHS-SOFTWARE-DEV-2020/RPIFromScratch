.section .init
.include "armtimer_0a1000_header.s"

/*
    INDIVIDUAL DRIVER FOR : rpi3b+ 32 bit
 */

// now define the interface implementation
interface_definition:

    _D_ARMTIMER_is_timer_running_1_
    _D_ARMTIMER_get_timer_1_
    _D_ARMTIMER_set_timer_1_
    _D_ARMTIMER_set_timer_reload_1_
    _D_ARMTIMER_start_timer_1_
    _D_ARMTIMER_stop_timer_1_
    _D_ARMTIMER_set_timer_prescale_1_
    _D_ARMTIMER_is_freecount_running_1_
    _D_ARMTIMER_get_freecount_1_
    _D_ARMTIMER_start_freecount_1_
    _D_ARMTIMER_stop_freecount_1_
    _D_ARMTIMER_set_freecount_prescale_1_
    _D_ARMTIMER_enable_interrupt_1_
    _D_ARMTIMER_disable_interrupt_1_
