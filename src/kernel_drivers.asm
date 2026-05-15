### CORE MODULES ###
rsect kernel_modules

# NEW: dispatcher sets this flag while a background task is running.
# If it is not zero, terminal output is blocked so background code cannot
# break the shell prompt or print over user input.
sched_current_task: ext

## TERMINAL
kernel_driver_tty_enable>
# enable the terminal
    save r0
    save r1
    ldi r0, 0xF00A
    ldi r1, 0x1
    stw r0, r1
    restore r1
    restore r0
    rts

# PRINT TEXT FROM [R0]
kernel_driver_tty_print>
    save r1
    save r2
    save r3

# NEW: only the foreground shell/program may write to the terminal.
# The dispatcher sets sched_current_task to a non-zero PID before calling
# a background task. In that case this driver returns without printing.
    ldi r3, sched_current_task
    ldb r3, r3
    tst r3
    bnz print_blocked

    ldi r2, 0xF008 # tty_char
print_loop:
    ldb r0, r1 # load char from text pointer
    inc r0     # inc char pointer
    stb r2, r1 # store to tty_char
    tst r1          # test char
    bnz print_loop  # if char != 0 then loop

print_blocked:
    restore r3
    restore r2
    restore r1
    rts

end