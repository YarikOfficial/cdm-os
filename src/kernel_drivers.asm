### CORE MODULES ###
rsect kernel_modules

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
    ldi r2, 0xF008 # tty_char
print_loop:
    ldb r0, r1 # load char from kb_char
    inc r0     # inc char pointer
    stb r2, r1 # store to tty_char
    tst r1          # test char
    bnz print_loop  # if char != 0 then loop
    restore r1
    restore r2
    rts

end