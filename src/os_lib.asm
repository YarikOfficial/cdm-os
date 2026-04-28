rsect OS_LIB

# NEW: shared keyboard state from kernel_main.asm
kb_buffer: ext
kb_tail: ext
kb_line_ready: ext

# os_lib_strlen
# input:  r0 = string pointer
# output: r1 = length before '\0'
os_lib_strlen>
    push r2
    push r3

    move r0, r2
    ldi r1, 0

strlen_loop:
    ldb r2, r3
    tst r3
    bz strlen_done

    inc r2
    inc r1
    br strlen_loop

strlen_done:
    pop r3
    pop r2
    rts


# Fixed strcmp from new.
# input:  r0 = first string, r1 = second string
# output: r2 = 0 if equal, 1 if not equal
os_lib_strcmp>
    push r3
    push r4
    push r5
    push r6

    move r0, r3
    move r1, r4

strcmp_loop:
    ldb r3, r5
    ldb r4, r6
    cmp r5, r6
    bne strcmp_not_equal

    tst r5
    bz strcmp_equal

    inc r3
    inc r4
    br strcmp_loop

strcmp_not_equal:
    ldi r2, 1
    pop r6
    pop r5
    pop r4
    pop r3
    rts

strcmp_equal:
    ldi r2, 0
    pop r6
    pop r5
    pop r4
    pop r3
    rts


# NEW: gets-like function for programs input/calc.
# input:
#   r0 = destination buffer
#   r1 = max length including '\0'
# output:
#   destination buffer filled with zero-terminated string
os_lib_gets>
    push r2
    push r3
    push r4
    push r5
    push r6

    move r0, r3 # r3 = destination
    move r1, r4 # r4 = max length

gets_wait:
    wait
    ldi r2, kb_line_ready
    ldb r2, r5
    tst r5
    bz gets_wait

    ldi r2, kb_buffer # r2 = source
    ldi r6, 0         # r6 = copied count

    tst r4
    bz gets_clear_state

gets_copy_loop:
    move r4, r5
    dec r5            # r5 = max length - 1
    cmp r6, r5
    bhs gets_finish_string

    ldb r2, r5
    tst r5
    bz gets_copy_zero

    stb r3, r5
    inc r2
    inc r3
    inc r6
    br gets_copy_loop

gets_copy_zero:
    stb r3, r5
    br gets_clear_state

gets_finish_string:
    ldi r5, 0
    stb r3, r5

gets_clear_state:
    ldi r2, kb_tail
    ldi r5, 0
    stb r2, r5

    ldi r2, kb_line_ready
    stb r2, r5

    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    rts


# NEW: ASCII decimal string -> number.
# input:  r0 = pointer to zero-terminated decimal string
# output: r1 = parsed number
# Works left-to-right: result = result * 10 + digit
os_lib_atoi>
    push r2
    push r3
    push r4
    push r5
    push r6

    move r0, r2 # r2 = string pointer
    ldi r1, 0   # r1 = result

atoi_loop:
    ldb r2, r3
    tst r3
    bz atoi_done

    ldi r6, 48
    sub r3, r6, r3 # r3 = digit = char - '0'

    # r4 = result * 10
    move r1, r4
    add r4, r4     # r4 = 2 * result
    move r4, r5    # r5 = 2 * result
    add r4, r4     # r4 = 4 * result
    add r4, r4     # r4 = 8 * result
    add r5, r4     # r4 = 10 * result
    add r3, r4     # r4 = 10 * result + digit
    move r4, r1

    inc r2
    br atoi_loop

atoi_done:
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    rts


# NEW: unsigned number -> decimal string.
# input:
#   r0 = value
#   r1 = destination buffer
# output:
#   zero-terminated decimal string in buffer
os_lib_itoa_u16>
    push r2
    push r3
    push r4
    push r5
    push r6

    move r0, r2 # r2 = value
    move r1, r3 # r3 = destination
    ldi r4, 0   # r4 = started flag

# ten-thousands
    ldi r6, 10000
    ldi r5, 0
itoa_10000_loop:
    cmp r2, r6
    blo itoa_10000_done
    sub r2, r6, r2
    inc r5
    br itoa_10000_loop
itoa_10000_done:
    tst r5
    bz itoa_10000_skip
    ldi r6, 48
    add r5, r6, r6
    stb r3, r6
    inc r3
    ldi r4, 1
itoa_10000_skip:

# thousands
    ldi r6, 1000
    ldi r5, 0
itoa_1000_loop:
    cmp r2, r6
    blo itoa_1000_done
    sub r2, r6, r2
    inc r5
    br itoa_1000_loop
itoa_1000_done:
    tst r4
    bnz itoa_1000_write
    tst r5
    bz itoa_1000_skip
itoa_1000_write:
    ldi r6, 48
    add r5, r6, r6
    stb r3, r6
    inc r3
    ldi r4, 1
itoa_1000_skip:

# hundreds
    ldi r6, 100
    ldi r5, 0
itoa_100_loop:
    cmp r2, r6
    blo itoa_100_done
    sub r2, r6, r2
    inc r5
    br itoa_100_loop
itoa_100_done:
    tst r4
    bnz itoa_100_write
    tst r5
    bz itoa_100_skip
itoa_100_write:
    ldi r6, 48
    add r5, r6, r6
    stb r3, r6
    inc r3
    ldi r4, 1
itoa_100_skip:

# tens
    ldi r6, 10
    ldi r5, 0
itoa_10_loop:
    cmp r2, r6
    blo itoa_10_done
    sub r2, r6, r2
    inc r5
    br itoa_10_loop
itoa_10_done:
    tst r4
    bnz itoa_10_write
    tst r5
    bz itoa_10_skip
itoa_10_write:
    ldi r6, 48
    add r5, r6, r6
    stb r3, r6
    inc r3
itoa_10_skip:

# units, always write at least one digit
    ldi r6, 48
    add r2, r6, r6
    stb r3, r6
    inc r3

# zero terminator
    ldi r6, 0
    stb r3, r6

    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    rts

end
