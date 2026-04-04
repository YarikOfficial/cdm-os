### INTERRUPT TABLE ###
asect 0x00
core_init: ext
default_handler: ext
key_handler: ext

# Таблица векторных прерываний (IVT)
dc core_init, 0 # Вектор запуска/сброса, начальный PS
dc default_handler, 0 # Невыровненный SP
dc default_handler, 0 # Невыровненный PC
dc default_handler, 0 # Недопустимая инструкция
dc default_handler, 0 # Double Fault
dc key_handler, 0 # Прерывания клавиатуры
align 0x80 # Зарезервировать место для других IVT


### HANDLERS ###
rsect exc_handlers

default_handler>
    halt

key_handler>
    save r0
    save r1
    save r2

    ldi r0, 0xF000 # Символ на клавиатуре
    ldi r1, 0xF008 # Вход терминала

    ldw r0, r0 # Загружаем символ из клавиатуры
    stw r1, r0 # Выводим на терминал

    ldi r0, 0xF002 # Регистр состояния клавиатуры
    ldi r2, 0x1
    ldw r0, r1
    or r2, r1
    stw r0, r1

    restore r0
    restore r1
    restore r2
    rti


### CORE MODULES ###
rsect os_modules

# PRINT TEXT FROM [R0]
os_tty_print>
    save r1
    save r2
    ldi r2, 0xF008 # ter_sym
print_loop:
    ldb r0, r1 # load char from kb_sym
    inc r0     # inc char pointer

    stb r2, r1 # store to ter_sym

    tst r1          # test char
    bnz print_loop  # if char != 0 then loop

    restore r1
    restore r2
    rts
    

### CORE ###
rsect os_core

os_tty_print: ext

# Code
core_init>
    ldi r0, 0x8000 # Меняем указатель стека
    stsp r0

# enable the terminal
    ldi r0, 0xF00A
    ldi r1, 0x1
    stw r0, r1

# print greeting :D
    ldi r0, text_os_greeting
    jsr os_tty_print
    ei # enable interrupts

loop:
    wait # wait for an interrupt
    br loop # loop forever ;)

    di # disable interrupts

test_text: dc "This is the test text!", 0
text_os_greeting: dc "Welcome to ZachetOS!", 0
    
end.
