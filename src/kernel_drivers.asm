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
    ldb r0, r1
    tst r1
    bz print_done
    stb r2, r1
    inc r0
    br print_loop
print_done:
    restore r2
    restore r1
    rts
end
