# FILE SYSTEM TABLE
asect 0x8000

fs_table>
    dc "count", 0
    ds 11
    dc count

    dc "sum", 0
    ds 11
    dc sum

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

    # NEW: start count as a background task.
    # Foreground "count" still works as before.
    dc "countbg", 0
    ds 9
    dc program_countbg

    # NEW: start sum as a background task.
    # Foreground "sum" still works as before.
    dc "sumbg", 0
    ds 9
    dc program_sumbg

    # NEW: stop background task 1
    dc "kill1", 0
    ds 11
    dc program_kill1

    # NEW: stop background task 2
    dc "kill2", 0
    ds 11
    dc program_kill2

    # NEW: task manager / process list
    dc "ps", 0
    ds 14
    dc program_ps

    # NEW: alias for ps
    dc "tasks", 0
    ds 11
    dc program_ps

    dc 0, 0


# PROGRAM CODE
asect 0x8200
os_string_count: ext
os_string_sum: ext
os_string_ls: ext
os_string_input_ask: ext
os_string_input_ans: ext
os_string_calc_a: ext
os_string_calc_b: ext
os_string_calc_result: ext
os_string_newline: ext
os_string_countbg_started: ext
os_string_sumbg_started: ext
os_string_countbg_stopped: ext
os_string_sumbg_stopped: ext
os_string_ps_header: ext
os_string_ps_task1: ext
os_string_ps_task2: ext
os_string_ps_run: ext
os_string_ps_stop: ext
kernel_driver_tty_print: ext
os_lib_gets: ext
os_lib_atoi: ext
os_lib_itoa_u16: ext

# NEW: scheduler API/state for background tasks and task manager
sched_start_task1: ext
sched_start_task2: ext
sched_stop_task1: ext
sched_stop_task2: ext
sched_task1_state: ext
sched_task2_state: ext
sched_task1_ticks: ext
sched_task2_ticks: ext

# NEW: buffers for programs
input_buffer: ds 0x20
calc_buf_a: ds 0x20
calc_buf_b: ds 0x20
calc_result_buf: ds 0x20

# NEW: private state for background versions of count/sum.
# These counters prove that count/sum really do background work.
# They are not printed directly by background code; ps/tasks prints scheduler ticks.
count_bg_counter: dc 0
sum_bg_counter: dc 0

count>
    ldi r0, os_string_count
    jsr kernel_driver_tty_print
    rts

sum_char> ds 0xFF
sum>
    ldi r0, os_string_sum
    jsr kernel_driver_tty_print

    ldi r0, sum_data
    ldi r1, sum_char
    jsr os_lib_itoa_u16

    move r1, r0
    jsr kernel_driver_tty_print
    rts

# NEW: background step for count.
# Important rule: a background step must be short and must not read keyboard
# or print to terminal. The dispatcher calls this repeatedly by timer ticks.
count_data> dc 0, 0
count_background_step> # add 1 to count_data
    save r0
    save r1
    ldi r0, count_bg_counter
    ldw r0, r1
    inc r1
    stw r0, r1

    ldi r0, count_data
    ldw r0, r1
    inc r1
    stw r0, r1

    restore r1
    restore r0
    rts

# NEW: background step for sum.
sum_data> dc 0, 0
sum_background_step> # add count_data to sum_data
    save r0
    save r1
    save r2
    ldi r0, sum_bg_counter
    ldw r0, r1
    inc r1
    stw r0, r1

    ldi r0, count_data
    ldw r0, r1

    ldi r0, sum_data
    ldw r0, r2

    add r1, r2

    stw r0, r2

    restore r2
    restore r1
    restore r0
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


# NEW: shell command: start count as a background task.
# It does not call count> directly, because count> prints to terminal and exits.
# Instead the scheduler repeatedly calls count_background_step>.
program_countbg>
    jsr sched_start_task1
    ldi r0, os_string_countbg_started
    jsr kernel_driver_tty_print
    rts

# NEW: shell command: start sum as a background task.
program_sumbg>
    jsr sched_start_task2
    ldi r0, os_string_sumbg_started
    jsr kernel_driver_tty_print
    rts

# NEW: shell command: stop background count.
program_kill1>
    jsr sched_stop_task1
    ldi r0, os_string_countbg_stopped
    jsr kernel_driver_tty_print
    rts

# NEW: shell command: stop background sum.
program_kill2>
    jsr sched_stop_task2
    ldi r0, os_string_sumbg_stopped
    jsr kernel_driver_tty_print
    rts

# NEW: task manager.
# Shows whether each background task is RUN/STOP and how many time slices it got.
program_ps>
    ldi r0, os_string_ps_header
    jsr kernel_driver_tty_print

    # task 1 line
    ldi r0, os_string_ps_task1
    jsr kernel_driver_tty_print

    ldi r2, sched_task1_state
    ldb r2, r0
    jsr program_print_task_state

    ldi r2, sched_task1_ticks
    ldw r2, r0
    ldi r1, calc_result_buf
    jsr os_lib_itoa_u16

    ldi r0, calc_result_buf
    jsr kernel_driver_tty_print
    ldi r0, os_string_newline
    jsr kernel_driver_tty_print

    # task 2 line
    ldi r0, os_string_ps_task2
    jsr kernel_driver_tty_print

    ldi r2, sched_task2_state
    ldb r2, r0
    jsr program_print_task_state

    ldi r2, sched_task2_ticks
    ldw r2, r0
    ldi r1, calc_result_buf
    jsr os_lib_itoa_u16

    ldi r0, calc_result_buf
    jsr kernel_driver_tty_print
    ldi r0, os_string_newline
    jsr kernel_driver_tty_print
    rts

# input: r0 = task state byte; prints RUN or STOP with fixed width
program_print_task_state:
    tst r0
    bz program_print_task_state_stop
    ldi r0, os_string_ps_run
    jsr kernel_driver_tty_print
    rts

program_print_task_state_stop:
    ldi r0, os_string_ps_stop
    jsr kernel_driver_tty_print
    rts

end
