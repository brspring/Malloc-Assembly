.section .data
    original_brk: .quad 0
    return_brk: .quad 3123
    format:    .asciz "Valor de original_brk: %p\n"

.section .text
.global setup_brk
.global dismiss_brk
.global memory_alloc
.global original_brk

setup_brk:
    movq $12, %rax           # 12 em rax é o código do brk
    movq $0, %rdi            # nao faz nada na heap, só indica o endereço atual
    syscall

    movq %rax, original_brk
    ret

    # movq $format, %rdi  # Configura o primeiro argumento para printf (formato da string)
    # movq original_brk, %rsi
    # call printf
    
    # movq $60, %rax         
    # syscall
dismiss_brk:
    movq $12, %rax          # 12 em rax é o código do brk
    movq original_brk, %rdi
    syscall
    ret

memory_alloc:
    movq %rdi, %rbx         # parametro no rbx
    movq original_brk, %r12    # original_brk no r12, r12 = original_brk
    movq $12, %rax          # rax esta com valor atual do brk
    movq $0, %rdi
    syscall

    _loop_start:
        cmpq %r12, %rax
        je _tudo_ocupado        # nao encontrou nenhum bloco livre, aloca no fim 
        cmpq $1, (%r12)         # compara o valor do offset com 1
        jne _livre              # soma 8 no r12   
        addq $8, %r12           # soma 8 no r12 pra ir pro tamanho do bloco           
        addq (%r12), %r12       # soma o tamanho do bloco no r12 para ir para  o fim do bloco menos 8 bytes
        addq $8, %r12           # vai para o inicio do proximo bloco
        jmp _loop_start
        _livre:
            addq $8, %r12           # soma 8 no r12 pra ir pro tamanho do bloco 
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
          movq %r12, %rdi    # coloca em rdi o valor de r12, que é o endereço atual nos blocos da heap
          addq $16, %rdi     # rdi = rdi + 16 (8 bytes para dizer se ta livre e 8 bytes para dizer o tamanho do bloco)
          addq %rbx, %rdi # rdi = rdi + rbx (rbx tem o tamanho do bloco)
          movq $12, %rax
          syscall # coloca o valor de rdi como o novo valor do brk
          movq $1, (%r12) # coloca 1 para falar que o novo bloco ta ocupado
          addq $8, %r12
          movq %rbx, (%r12) # coloca o tamanho do novo bloco
          addq $8, %r12 # r12 tem o endereço do começo do bloco
          movq %r12, %rax # oo endereço do começo  do novo bloco é movido no rax p retornar
          ret
