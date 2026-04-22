rsect OS_MAIN

kernel_driver_tty_print: ext
kernel_driver_tty_enable: ext
os_string_greeting: ext
os_string_prompt_start: ext
os_lib_gets: ext
key_execute_command: ext

command_buffer: ds 0x20

os_main>
    jsr kernel_driver_tty_enable

    ldi r0, os_string_greeting
    jsr kernel_driver_tty_print

    ei

shell_loop:
    ldi r0, os_string_prompt_start
    jsr kernel_driver_tty_print

    ldi r0, command_buffer
    ldi r1, 0x20
    jsr os_lib_gets

    ldi r0, command_buffer
    jsr key_execute_command

    br shell_loop

end
