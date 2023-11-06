# Rodar com:
# as main.s -o malloc.o   
# ld malloc.o -o imprime -dynamic-linker /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 -lc -e main

.section .data
    heapStart: .quad 0 
    format:    .asciz "Valor de heapStart: %p\n"

.section .text
.global start
_setup_brk:
    movq $12, %rax           # 12 em rax é o código do brk
    movq $0, %rdi            # nao faz nada na heap, só indica o endereço atual
    syscall

    movq %rax, heapStart

    # movq $format, %rdi  # Configura o primeiro argumento para printf (formato da string)
    # movq heapStart, %rsi
    # call printf
    
    # movq $60, %rax         
    # syscall
_dismiss_brk:
    movq $12, %rax          # 12 em rax é o código do brk
    movq heapStart, %rdi
    syscall

_memory_alloc:
    movq %rdi, %rbx         # parametro no rbx
    movq heapStart, %rcx    # heapStart no rcx, rcx = heapStart
    movq $12, %rax          # rax esta com valor atual do brk
    movq $0, %rdi
    syscall

    _loop_start:
        cmpq %rcx, %rax
        je _tudo_ocupado        # nao encontrou nenhum bloco livre, aloca no fim 
        cmpq (%rcx), $1         # compara o valor do offset com 1
        addq $8, %rcx           # soma 8 no rcx pra ir pro tamanho do bloco
        jne _livre              # soma 8 no rcx                          
        addq (%rcx), %rcx       # soma o tamanho do bloco no rcx para ir para  o fim do bloco menos 8 bytes
        addq $8, %rcx           # vai para o inicio do proximo bloco
        jmp _loop_start
        _livre:
            cmpq (%rcx), %rdi   # compara o tamanho do bloco atual com o tamanho pedido
            jg _proximo_bloco   # se o tamanho do bloco atual for menor que o tamanho pedido, vai para o proximo bloco
            movq %rdi, (%rcx)   # coloca o tamanho novo no segundo quadradinho
            subq $8, %rcx       # vai para o inicio do bloco 
            movq $1, (%rcx)     # diz que ta ocupado
            movq %rcx, %rax     
            addq $16, %rax      # retorna o começo do bloco  de dados
            ret
            _proximo_bloco:
                addq (%rcx), %rcx   # vai para o proximo bloco
                addq $8, %rcx       # vai para o proximo bloco
                jmp _loop_start
        _tudo_ocupado:
            

    # loop que procura a primeira os 8bytes que indicam uma posicao livre
    # se achar, verifica os segundos 8bytes para ver se tem espaco suficiente

_start: