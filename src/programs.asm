asect 0x8000

os_string_prog1: ext
os_string_prog2: ext
kernel_driver_tty_print: ext

file_table>
    dc file_name_prog1, prog1
    dc file_name_prog2, prog2
    dc 0, 0

file_name_prog1> dc "prog1", 0
file_name_prog2> dc "prog2", 0

prog1>
    ldi r0, os_string_prog1
    jsr kernel_driver_tty_print
    rts

prog2>
    ldi r0, os_string_prog2
    jsr kernel_driver_tty_print
    rts

end
