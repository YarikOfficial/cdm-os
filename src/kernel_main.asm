### INTERRUPT TABLE ###
asect 0x00
kernel_main: ext
default_handler: ext
syscall_handler: ext
tim_handler: ext
key_handler: ext

# Таблица векторных прерываний (IVT)
dc kernel_main, 0 # Вектор запуска/сброса, начальный PS
dc default_handler, 0 # 1. Невыровненный SP
dc default_handler, 0 # 2. Невыровненный PC
dc default_handler, 0 # 3. Недопустимая инструкция
dc default_handler, 0 # 4. Double Fault
dc key_handler, 0 # 5. Нажатие клавиши
dc tim_handler, 0 # 6. Резерв
dc syscall_handler, 0 # 7. syscall
align 0x80 # Зарезервировать место для других IVT


### HANDLERS ###
rsect EXC_HANDLERS

default_handler>
    halt

syscall_handler>
    rti

os_string_greeting: ext

timer interrupt is deliberately small.
# It only records that a scheduling tick happened. Real task code is run later
# from os_lib_gets/task_dispatch_once, outside the interrupt handler.
tim_handler>
    save r0
    save r1

    # total timer ticks since boot
    ldi r0, sched_tick_count
    ldw r0, r1
    inc r1
    stw r0, r1

    # one pending dispatch request for the shell/foreground loop
    ldi r0, sched_tick_pending
    ldi r1, 1
    stb r0, r1

    # If your timer device requires a memory-mapped reset/acknowledge,
    # write it here. Example, replace 0xF00C with your tim_reset address:
    #   ldi r0, 0xF00C
    #   ldi r1, 1
    #   stb r0, r1

    restore r1
    restore r0
    rti

# keyboard buffer stayed here.
# labels are exported with '>' because os_lib_gets uses them.
kb_buffer> ds 0x20
kb_tail> dc 0
kb_line_ready> dc 0 # 1 means full line is ready for os_main/os_lib_gets
command_help: dc "help", 0

# minimal cooperative scheduler state.
# state: 0 = stopped/free, 1 = runnable.
# The current implementation runs tiny background "step" functions.
# This keeps the existing program model intact: foreground programs are still
# ordinary subroutines called by key_execute_command and returned with rts.
sched_tick_count> dc 0    # word: total timer ticks
sched_tick_pending> dc 0  # byte: timer asked dispatcher to run once
sched_current_task> dc 0  # byte: 0=shell/foreground, 1/2=background PID
sched_next_task> dc 0     # byte: round-robin cursor, 0 => try task 1 first
sched_task1_state> dc 0
sched_task2_state> dc 0
sched_task1_ticks> dc 0   # word: how many slices task 1 received
sched_task2_ticks> dc 0   # word: how many slices task 2 received

key_handler>
    save r0
    save r1
    save r2
    save r3

# load kb_char
    ldi r0, 0xF000
    ldb r0, r0

# if previous line is not processed yet, do not overwrite buffer
    ldi r1, kb_line_ready
    ldb r1, r2
    tst r2
    bnz char_check_end

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
        tst r2
        bz char_check_end
        dec r2
        stb r1, r2
    # send char to tty
        ldi r1, 0xF008
        stb r1, r0
        br char_check_end
    fi

# if char == '\n'
    if
        cmp r0, 0x0A
    is eq
    # end buf with \0
        ldi r3, 0
        stb r1, r3 # kb_buffer + tail in r1

    # do not execute command inside interrupt.
    # Just mark that line is ready; os_main will execute it safely.
        ldi r1, kb_line_ready
        ldi r3, 1
        stb r1, r3

    # send char to tty
        ldi r1, 0xF008
        stb r1, r0
        br char_check_end
    fi

# else: save ordinary char to kb_buffer + tail
# protect buffer from overflow: max 31 chars + terminating zero
    cmp r2, 31
    bhs char_check_end

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
    restore r3
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
count_background_step: ext
adder_background_step: ext

# exported because os_main calls it.
# input: r0 = pointer to command string
key_execute_command>
    save r0
    save r1
    save r2
    save r3

    move r0, r3       # r3 = typed command pointer
    ldi r0, fs_table  # get fs_table start ptr

key_execute_loop:
    ldb r0, r1        # get first prog name char
    tst r1
    bz key_execute_not_found

    move r3, r1       # r0 = table name, r1 = typed command
    jsr os_lib_strcmp # r2 = 0 if names are same

    if
        tst r2
    is z
        add r0, 18    # move to addr pointer
        ldw r0, r1    # get prog pointer
        jsrr r1       # start prog
        br key_execute_end
    else
        add r0, 20    # move to next table entry
        br key_execute_loop
    fi

key_execute_not_found:
    ldi r0, os_string_error_invalid_command
    jsr kernel_driver_tty_print

key_execute_end:
    restore r3
    restore r2
    restore r1
    restore r0
    rts


# start/stop API used by shell commands bg1/bg2/kill1/kill2.
# These routines do not run the task immediately; they only change its state.
sched_start_task1>
    save r0
    save r1
    ldi r0, sched_task1_ticks
    ldi r1, 0
    stw r0, r1
    ldi r0, sched_task1_state
    ldi r1, 1
    stb r0, r1
    restore r1
    restore r0
    rts

sched_stop_task1>
    save r0
    save r1
    ldi r0, sched_task1_state
    ldi r1, 0
    stb r0, r1
    restore r1
    restore r0
    rts

sched_start_task2>
    save r0
    save r1
    ldi r0, sched_task2_ticks
    ldi r1, 0
    stw r0, r1
    ldi r0, sched_task2_state
    ldi r1, 1
    stb r0, r1
    restore r1
    restore r0
    rts

sched_stop_task2>
    save r0
    save r1
    ldi r0, sched_task2_state
    ldi r1, 0
    stb r0, r1
    restore r1
    restore r0
    rts


# task dispatcher.
# It is cooperative: on every timer tick it runs at most one small task step.
# Round-robin order: task 1, task 2, task 1, ...
# Important: dispatcher sets sched_current_task before calling a task.
# Drivers/libraries use that flag to forbid background terminal I/O.
task_dispatch_once>
    save r0
    save r1
    save r2

    # no timer tick => no scheduling work
    ldi r0, sched_tick_pending
    ldb r0, r1
    tst r1
    bz sched_dispatch_end

    # consume one pending tick
    ldi r1, 0
    stb r0, r1

    # choose first candidate by round-robin cursor
    ldi r0, sched_next_task
    ldb r0, r1
    tst r1
    bz sched_try_task1_first

sched_try_task2_first:
    jsr sched_try_task2
    tst r2
    bnz sched_dispatch_end
    jsr sched_try_task1
    br sched_dispatch_end

sched_try_task1_first:
    jsr sched_try_task1
    tst r2
    bnz sched_dispatch_end
    jsr sched_try_task2

sched_dispatch_end:
    restore r2
    restore r1
    restore r0
    rts

# Try to run task 1. Returns r2 = 1 if it ran, else r2 = 0.
sched_try_task1:
    ldi r2, 0
    ldi r0, sched_task1_state
    ldb r0, r1
    cmp r1, 1
    bne sched_try_task1_end

    ldi r0, sched_current_task
    ldi r1, 1
    stb r0, r1

    # Run one small unit of count background work.
    jsr count_background_step

    # Count how many scheduler slices count got.
    ldi r0, sched_task1_ticks
    ldw r0, r1
    inc r1
    stw r0, r1

    ldi r0, sched_current_task
    ldi r1, 0
    stb r0, r1

    ldi r0, sched_next_task
    ldi r1, 1
    stb r0, r1

    ldi r2, 1
sched_try_task1_end:
    rts

# Try to run task 2. Returns r2 = 1 if it ran, else r2 = 0.
sched_try_task2:
    ldi r2, 0
    ldi r0, sched_task2_state
    ldb r0, r1
    cmp r1, 1
    bne sched_try_task2_end

    ldi r0, sched_current_task
    ldi r1, 2
    stb r0, r1

    # Run one small unit of adder background work.
    jsr adder_background_step

    # Count how many scheduler slices adder got.
    ldi r0, sched_task2_ticks
    ldw r0, r1
    inc r1
    stw r0, r1

    ldi r0, sched_current_task
    ldi r1, 0
    stb r0, r1

    ldi r0, sched_next_task
    ldi r1, 0
    stb r0, r1

    ldi r2, 1
sched_try_task2_end:
    rts


# Background task bodies are now in programs.asm:
#   count_background_step>
#   adder_background_step>
# The kernel dispatcher only chooses which task to run and counts time slices.

### CORE ###
rsect KERNEL_MAIN

os_main: ext

kernel_main>
# set stack pointer
# keep as in main: stack starts before FS/program area at 0x8000
    ldi r0, 0x8000
    stsp r0

# branch to os_main (never return)
    br os_main
end.
