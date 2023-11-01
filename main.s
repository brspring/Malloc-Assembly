.section .data
    heapStart: .quad 0 
    format:    .asciz "Valor de heapStart: %lld\n"

.section .text
.global main
main:
    movq $12, %rax     # 12 em rax é o código do brk
    movq $0, %rdi  # nao faz nada na heap, só indica o endereço atual
    syscall

    movq %rax, %rcx

    movq $format, %rdi  # Configura o primeiro argumento para printf (formato da string)
    movq %rcx, %rsi
    call printf
    
    movq $60, %rax         
    syscall


# Rodar com:
# as main.s -o malloc.o   
# ld malloc.o -o imprime -dynamic-linker /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 -lc -e main