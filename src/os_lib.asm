rsect OS_LIB

kb_buffer: ext
kb_tail: ext
kb_line_ready: ext

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


os_lib_strcmp> # r0=s1, r1=s2, r2=0 if equal else 1
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


# os_lib_gets
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

    move r0, r3
    move r1, r4

gets_wait:
    wait
    ldi r2, kb_line_ready
    ldb r2, r5
    tst r5
    bz gets_wait

    ldi r2, kb_buffer
    ldi r6, 0

    tst r4
    bz gets_clear_state

gets_copy_loop:
    move r4, r5
    dec r5
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

# os_lib_atoi
# input:
#   r0 = pointer to zero-terminated decimal string
# output:
#   r1 = parsed number
os_lib_atoi>
    push r2
    push r3
    push r4
    push r5
    push r6

    move r0, r6          # r6 = start

    jsr os_lib_strlen    # r1 = len
    move r1, r5          # r5 = len

    ldi r1, 0            # result = 0
    tst r5
    bz atoi_done         # empty string -> 0

    move r6, r2          # r2 = start
    add r2, r5, r2       # r2 = start + len
    dec r2               # r2 = addr of last digit

    ldi r4, 1            # pow = 1

atoi_main_loop:
    ldb r2, r3           # r3 = current char

    ldi r5, 48
    sub r3, r5, r3       # r3 = digit = char - '0'

    # term = digit * pow
    ldi r5, 0            # r5 = term

atoi_mul_loop:
    tst r3
    bz atoi_mul_done

    add r5, r4, r5       # term += pow
    dec r3
    br atoi_mul_loop

atoi_mul_done:
    add r1, r5, r1       # result += term

    # pow = pow * 10
    move r4, r5          # r5 = pow
    add r5, r5, r3       # r3 = 2*pow
    add r3, r3, r5       # r5 = 4*pow
    add r5, r5, r5       # r5 = 8*pow
    add r5, r3, r4       # r4 = 8*pow + 2*pow = 10*pow

    cmp r6, r2
    beq atoi_done       # дошли до первого символа

    dec r2
    br atoi_main_loop

atoi_done:
    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    rts

# os_lib_itoa_u16
# input:
#   r0 = value
#   r1 = destination buffer
# output:
#   decimal string in buffer
os_lib_itoa_u16>
    push r2
    push r3
    push r4
    push r5
    push r6

    move r0, r2
    move r1, r3
    ldi r4, 0
    ldi r5, 0


itoa_hundreds_loop:
    ldi r6, 100
    cmp r2, r6
    blo itoa_tens_loop
    sub r2, r6, r2
    inc r4
    br itoa_hundreds_loop

itoa_tens_loop:
    ldi r4, 10
    cmp r2, r6
    blo itoa_write
    sub r2, r6, r2
    inc r5
    br itoa_tens_loop

itoa_write:
    # если есть сотни — печатаем их
    tst r4
    bz itoa_check_tens
    ldi r6, 48
    add r4, r6, r6
    stb r3, r6
    inc r3

itoa_check_tens:
    # если есть сотни или десятки — печатаем десятки
    tst r4
    bnz itoa_write_tens
    tst r5
    bz itoa_write_units

itoa_write_tens:
    ldi r6, 48
    add r5, r6, r6
    stb r3, r6
    inc r3

itoa_write_units:
    ldi r6, 48
    add r2, r6, r6
    stb r3, r6
    inc r3

    ldi r6, 0
    stb r3, r6

    pop r6
    pop r5
    pop r4
    pop r3
    pop r2
    rts
itoa_tens_done:
    tst r5
    bz itoa_units_only

    ldi r4, 48
    add r5, r4, r4
    stb r3, r4
    inc r3

itoa_units_only:
    ldi r4, 48
    add r2, r4, r4
    stb r3, r4
    inc r3

    ldi r4, 0
    stb r3, r4

    pop r5
    pop r4
    pop r3
    pop r2
    rts
end
