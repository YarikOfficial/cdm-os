# FILE SYSTEM TABLE
asect 0x8000

fs_table>
    dc "prog1", 0
    ds 11
    dc prog1

    dc "prog2", 0
    ds 11
    dc prog2

    dc "ls", 0
    ds 14
    dc program_ls

    # NEW: gets()
    dc "input", 0
    ds 11
    dc program_input

    # NEW: calc
    dc "calc", 0
    ds 12
    dc program_calc

    dc 0, 0


# PROGRAM CODE
asect 0x8200
os_string_prog1: ext
os_string_prog2: ext
os_string_ls: ext
os_string_input_ask: ext
os_string_input_ans: ext
os_string_calc_a: ext
os_string_calc_b: ext
os_string_calc_result: ext
os_string_newline: ext
kernel_driver_tty_print: ext
os_lib_gets: ext
os_lib_atoi: ext
os_lib_itoa_u16: ext

# NEW: buffers for programs
input_buffer: ds 0x20
calc_buf_a: ds 0x20
calc_buf_b: ds 0x20
calc_result_buf: ds 0x20

prog1>
    ldi r0, os_string_prog1
    jsr kernel_driver_tty_print
    rts

prog2>
    ldi r0, os_string_prog2
    jsr kernel_driver_tty_print
    rts

program_ls>
    ldi r0, os_string_ls
    jsr kernel_driver_tty_print
    rts

# NEW: reads a line and prints it back
program_input>
    ldi r0, os_string_input_ask
    jsr kernel_driver_tty_print

    ldi r0, input_buffer
    ldi r1, 0x20
    jsr os_lib_gets

    ldi r0, os_string_input_ans
    jsr kernel_driver_tty_print

    ldi r0, input_buffer
    jsr kernel_driver_tty_print

    ldi r0, os_string_newline
    jsr kernel_driver_tty_print
    rts

# NEW: simple calculator: reads a and b, prints a + b
program_calc>
    push r4

    ldi r0, os_string_calc_a
    jsr kernel_driver_tty_print

    ldi r0, calc_buf_a
    ldi r1, 0x20
    jsr os_lib_gets

    ldi r0, calc_buf_a
    jsr os_lib_atoi
    move r1, r4

    ldi r0, os_string_calc_b
    jsr kernel_driver_tty_print

    ldi r0, calc_buf_b
    ldi r1, 0x20
    jsr os_lib_gets

    ldi r0, calc_buf_b
    jsr os_lib_atoi

    add r4, r1

    move r1, r0
    ldi r1, calc_result_buf
    jsr os_lib_itoa_u16

    ldi r0, os_string_calc_result
    jsr kernel_driver_tty_print

    ldi r0, calc_result_buf
    jsr kernel_driver_tty_print

    ldi r0, os_string_newline
    jsr kernel_driver_tty_print

    pop r4
    rts

end
