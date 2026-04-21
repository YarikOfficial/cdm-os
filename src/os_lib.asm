rsect OS_LIB

os_lib_strcmp> #r0, r1 - string pointers
    push r3
    push r4
    push r5
    push r6

    move r0, r3
    move r1, r4
    while
        ldb r3, r5 # load s1 char
        inc r3 # s1++
        tst r5 # if not \0
    stays nz
        if
            ldb r4, r6 # load s2 char
            inc r4 # s2++
            cmp r5, r6 # cmp char1 char2
        is ne # not eq
            ldi r2, 1
            pop r6
            pop r5
            pop r4
            pop r3
            rts
        fi
    wend
    ldi r2, 0

    pop r6
    pop r5
    pop r4
    pop r3

    rts

end