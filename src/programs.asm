# FILE SYSTEM TABLE
asect 0x8000 

fs_table>
    dc "prog1", 0, prog1
    dc "prog2", 0, prog2
    dc 0, 0


# PROGRAM CODE
asect 0x8200 
os_string_prog1: ext
os_string_prog2: ext
kernel_driver_tty_print: ext

prog1>
    ldi r0, os_string_prog1
    jsr kernel_driver_tty_print
    rts

prog2>
    ldi r0, os_string_prog2
    jsr kernel_driver_tty_print
    rts

end
