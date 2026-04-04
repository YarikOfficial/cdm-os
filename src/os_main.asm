rsect os_main

kernel_driver_tty_print: ext
kernel_driver_tty_enable: ext
os_string_greeting: ext

# os_main function
os_main>
    jsr kernel_driver_tty_enable

# print greeting :D
    ldi r0, os_string_greeting
    jsr kernel_driver_tty_print

# main cycle
    ei # enable interrupts
loop:
    wait # wait for an interrupt
    br loop # loop forever ;)

    di # disable interrupts

end