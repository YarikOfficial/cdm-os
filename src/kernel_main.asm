### INTERRUPT TABLE ###
asect 0x00
kernel_main: ext
default_handler: ext
syscall_handler: ext
key_handler: ext

dc kernel_main, 0
dc default_handler, 0
dc default_handler, 0
dc default_handler, 0
dc default_handler, 0
dc key_handler, 0
dc 0, 0
dc syscall_handler, 0
align 0x80


### HANDLERS ###
rsect EXC_HANDLERS

default_handler>
    halt

syscall_handler>
    rti


kb_buffer> ds 0x20
kb_tail> dc 0
kb_line_ready> dc 0

key_handler>
    save r0
    save r1
    save r2
    save r3

    # r0 = input char
    ldi r0, 0xF000
    ldb r0, r0

    # if line is already ready, just consume kb_next and exit
    ldi r1, kb_line_ready
    ldb r1, r2
    tst r2
    bnz key_done

    # if char == backspace
    if
        cmp r0, 0x08
    is eq
        ldi r1, kb_tail
        ldb r1, r2
        tst r2
        bz key_done_echoless

        dec r2
        stb r1, r2

        # erase on terminal too
        ldi r1, 0xF008
        stb r1, r0
        br key_done
    fi

    # if char == '\n'
    if
        cmp r0, 0x0A
    is eq
        # kb_buffer[kb_tail] = 0
        ldi r1, kb_tail
        ldb r1, r2

        ldi r1, kb_buffer
        add r2, r1

        ldi r3, 0
        stb r1, r3

        # kb_line_ready = 1
        ldi r1, kb_line_ready
        ldi r3, 1
        stb r1, r3

        # echo newline
        ldi r1, 0xF008
        stb r1, r0
        br key_done
    fi

    # ordinary char
    ldi r1, kb_tail
    ldb r1, r2

    # limit length: max 31 chars + 0
    cmp r2, 31
    bhs key_done

    ldi r1, kb_buffer
    add r2, r1
    stb r1, r0

    inc r2
    ldi r1, kb_tail
    stb r1, r2

    # echo char
    ldi r1, 0xF008
    stb r1, r0
    br key_done

key_done_echoless:
key_done:
    # send kb_next
    ldi r0, 0xF002
    ldi r1, 0b1
    stb r0, r1

    restore r3
    restore r2
    restore r1
    restore r0
    rti


### COMMAND EXECUTION ###
os_lib_strcmp: ext
os_string_error_invalid_command: ext
kernel_driver_tty_print: ext
fs_table: ext

key_execute_command>
    save r0
    save r1
    save r2
    save r3

    # r0 = pointer to command string
    move r0, r3

    ldi r0, fs_table
cmd_loop:
    ldb r0, r1
    tst r1
    bz cmd_not_found

    move r3, r1
    jsr os_lib_strcmp

    tst r2
    bz cmd_found

    add r0, 20
    br cmd_loop

cmd_found:
    add r0, 18
    ldw r0, r1
    jsrr r1
    br cmd_end

cmd_not_found:
    ldi r0, os_string_error_invalid_command
    jsr kernel_driver_tty_print

cmd_end:
    restore r3
    restore r2
    restore r1
    restore r0
    rts


### CORE ###
rsect KERNEL_MAIN

os_main: ext

kernel_main>
    ldi r0, 0x9000
    stsp r0
    br os_main

end.
