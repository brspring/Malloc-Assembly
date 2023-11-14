# Rodar com:
# as main.s -o malloc.o   
# ld malloc.o -o imprime -dynamic-linker /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2 -lc -e main

.section .data
    heapStart: .quad 0 
    format:    .asciz "Valor de heapStart: %p\n"

.section .text
.global setup_brk
.global dismiss_brk
.global memory_alloc

setup_brk:
    movq $12, %rax           # 12 em rax é o código do brk
    movq $0, %rdi            # nao faz nada na heap, só indica o endereço atual
    syscall

    movq %rax, heapStart
    ret

    # movq $format, %rdi  # Configura o primeiro argumento para printf (formato da string)
    # movq heapStart, %rsi
    # call printf
    
    # movq $60, %rax         
    # syscall
dismiss_brk:
    movq $12, %rax          # 12 em rax é o código do brk
    movq heapStart, %rdi
    syscall
    ret

memory_alloc:
    movq %rdi, %rbx         # parametro no rbx
    movq heapStart, %r12    # heapStart no r12, r12 = heapStart
    movq $12, %rax          # rax esta com valor atual do brk
    movq $0, %rdi
    syscall

    _loop_start:
        cmpq %r12, %rax
        je _tudo_ocupado        # nao encontrou nenhum bloco livre, aloca no fim 
        cmpq $1, (%r12)         # compara o valor do offset com 1
        addq $8, %r12           # soma 8 no r12 pra ir pro tamanho do bloco
        jne _livre              # soma 8 no r12                          
        addq (%r12), %r12       # soma o tamanho do bloco no r12 para ir para  o fim do bloco menos 8 bytes
        addq $8, %r12           # vai para o inicio do proximo bloco
        jmp _loop_start
        _livre:
            cmpq (%r12), %rdi   # compara o tamanho do bloco atual com o tamanho pedido
            jg _proximo_bloco   # se o tamanho do bloco atual for menor que o tamanho pedido, vai para o proximo bloco
            movq %rdi, (%r12)   # coloca o tamanho novo no segundo quadradinho
            subq $8, %r12       # vai para o inicio do bloco 
            movq $1, (%r12)     # diz que ta ocupado
            movq %r12, %rax     
            addq $16, %rax      # retorna o começo do bloco  de dados
            ret
            _proximo_bloco:
                addq (%r12), %r12   # vai para o proximo bloco
                addq $8, %r12       # vai para o proximo bloco
                jmp _loop_start
        _tudo_ocupado:
          movq %r12, %rdi    # coloca em rdi o valor de r12, que é o valor atual da heapstart
          addq $16, %rdi     
          addq %rbx, %rdi # rdi recebe o valor novo do brk
          movq $12, %rax
          syscall
          movq $1, (%r12) # coloca 1 para falar que o novo bloco ta ocupado
          addq $8, %r12
          movq %rbx, (%r12) # coloca o tamanho do novo bloco
          addq $8, %r12 # r12 tem o endereço do começo do bloco
          movq %r12, %rax # oo endereço do começo  do novo bloco é movido no rax p retornar

    # loop que procura a primeira os 8bytes que indicam uma posicao livre
    # se achar, verifica os segundos 8bytes para ver se tem espaco suficiente
