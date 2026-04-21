### INTERRUPT TABLE ###
asect 0x00
kernel_main: ext
default_handler: ext
syscall_handler: ext
key_handler: ext

# Таблица векторных прерываний (IVT)
dc kernel_main, 0 # Вектор запуска/сброса, начальный PS
dc default_handler, 0 # 1. Невыровненный SP
dc default_handler, 0 # 2. Невыровненный PC
dc default_handler, 0 # 3. Недопустимая инструкция
dc default_handler, 0 # 4. Double Fault
dc key_handler, 0 # 5. Нажатие клавиши
dc 0, 0 # 6. Резерв
dc syscall_handler, 0 # 7. syscall
align 0x80 # Зарезервировать место для других IVT


### HANDLERS ###
rsect EXC_HANDLERS

default_handler>
    halt

syscall_handler>
    rti


kb_buffer: ds 0x20
kb_tail: dc 0
command_help: dc "help", 0

key_handler>
    save r0
    save r1
    save r2
# load kb_char
    ldi r0, 0xF000
    ldb r0, r0      
# calc kb_buffer + tail to r1
    ldi r1, kb_buffer
    ldi r2, kb_tail
    ldb r2, r2
    add r2, r1
# Checking for special symbols
# if char == backspace
    if
        cmp r0, 0x08
    is eq
    # tail--
        ldi r1, kb_tail
        ldb r1, r2
    # don't let tail < 0
        if
            dec r2
        is mi
            br char_check_end
        fi
        stb r1, r2
    # send char to tty
        ldi r1, 0xF008
        stb r1, r0      
        br char_check_end
    fi
# if char == '\n', 
    if 
        cmp r0, 0x0A
    is eq
    # end buf with \0
        ldi r2, 0
        stb r1, r2 # kb_buffer + tail in r1
    # reset tail
        ldi r1, kb_tail
        stb r1, r2
    # send char to tty
        ldi r1, 0xF008
        stb r1, r0      
    # execute command in kb_buffer
        jsr key_execute_command 
        br char_check_end
    fi
# else
# save char to kb_buffer + tail
    stb r1, r0
# update tail
    inc r2 
    ldi r1, kb_tail
    stb r1, r2
# send char to tty
    ldi r1, 0xF008
    stb r1, r0      
char_check_end:
# send kb_next
    ldi r0, 0xF002  # load kb_control
    ldi r1, 0b1     # create mask
    stb r0, r1      # store mask to kb_control
    restore r2
    restore r1
    restore r0
    rti

os_lib_strcmp: ext
os_string_help: ext
os_string_error_invalid_command: ext
os_string_prompt_start: ext
kernel_driver_tty_print: ext
fs_table: ext

key_execute_command:
    save r0
    save r1
    save r2

    ldi r0, fs_table # get fs_table start ptr
    while 
        ldb r0, r1 # get first prog name char
        tst r1
    stays nz # if char != 0
        ldi r1, kb_buffer # get prompt name

        jsr os_lib_strcmp # compare prompt with table name

        if
            tst r2 # if names are same
        is z
            add r0, 18 # move to addr pointer
            ldw r0, r1 # get prog pointer
            jsrr r1 # start prog
            add r0, 2 # move to next table entry
            break
        else
            add r0, 20 # move to next table entry
        fi
    wend

    if # if didn't find prog in table print invalid
        ldb r0, r1
        tst r1
    is z
        ldi r0, os_string_error_invalid_command
        jsr kernel_driver_tty_print 
    fi

    ldi r0, os_string_prompt_start
    jsr kernel_driver_tty_print

    restore r2
    restore r1
    restore r0

    rts

### CORE ###
rsect KERNEL_MAIN

os_main: ext

kernel_main>
# set stack pointer
    ldi r0, 0x8000 
    stsp r0

# branch to os_main (never return)
    br os_main
end.
