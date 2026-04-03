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


### CORE ###
rsect os_core

prog1: ext
prog2: ext

# Code
core_init>
    ldi r0, 0x8000 # Меняем указатель стека
    stsp r0

    ldi r0, 0xF00A # Регистр терминала
    ldi r1, 0x1 # Включение вывода терминала
    stw r0, r1

    ei # enable interrupts
loop:
    wait # wait for an interrupt
    #int 5
    br loop # loop forever ;)
    di # disable interrupts
    
end.
