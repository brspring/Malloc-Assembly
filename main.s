section .data
    heap_start quad 0 

section .text
    global _start

_start:
    movq $12, %rax     # nao entendi muito bem ainda, mas 12 em rax é o código do brk
    movq $0, %rdi  # nao faz nada na heap, só indica o endereço atual
    syscall

    movq %rax, [heap_start] 

    movq $60, %rax         
    syscall
