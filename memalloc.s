.section .data
    original_brk: .quad 0
    return_brk: .quad 3123
    format:    .asciz "Valor de original_brk: %p\n"

.section .text
.global setup_brk
.global dismiss_brk
.global memory_alloc
.global original_brk
.global memory_free

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
        movq %r12, %r9
        addq $16, %r9
        cmpq %r9, %rax
        jle _pulaBrk
        jmp _loop_start
        _pulaBrk:
            movq %rax, %r12
            jmp _loop_start
        # talvez perguntar se  r12 + 16 = brk, ent r12 = r12 + 16 e mudar primeiro condicional para menor igual
        
        _livre:
            addq $8, %r12           # soma 8 no r12 pra ir pro tamanho do bloco 
            cmpq (%r12), %rbx   # compara o tamanho do bloco atual com o tamanho pedido
            jg _proximo_bloco   # se o tamanho do bloco atual for menor que o tamanho pedido, vai para o proximo bloco
            movq (%r12), %r9 
            subq %rbx, %r9 # r9 = bloco disponível - tamanho pedido
            cmpq $16, %r9 
            jle _substituiBloco
            addq $24, %r12 # +8 para ir pro começo do bloco pedido, + 16 para alocar a parte gerencial do bloco extra
            addq %rbx, %r12 # + tamanho do bloco pedido pra chegar no fim do bloco pedido/começo do extra
            subq $8, %r12 # end. que tem o tamanho do bloco extra
            movq %r9, (%r12) # coloca o tamanho do bloco extra
            subq $8, %r12 # vai para o tamanho do bloco extra
            movq $0, (%r12) # coloca 0 para dizer que o bloco extra está livre
            subq %rbx, %r12 # volta a qntd de bytes igual ao tamanho do bloco pedido
            subq $16, %r12 # volta para o começo do bloco pedido 
            _substituiBloco: 
                movq %rbx, (%r12)   # coloca o tamanho novo no segundo quadradinho
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

memory_free:
    cmpq %rdi, original_brk 
    jge _bloco_invalido # se o endereço original do brk for maior ou igual ao endereço passado, esse endereço não está alocado
    movq %rdi, %rbx # move parametro para rbx pra usar rdi
    movq $0, %rdi
    movq $12, %rax
    syscall # valor atual do brk em rax
    cmpq %rax, %rbx # se o endereço passado for maior ou igual que o valor atual do brk, esse endereço não está alocado
    jge _bloco_invalido
    subq $16, %rbx # muda o endereço para a parte que diz se o bloco ta livre
    cmpq $1, (%rbx)
    jne _bloco_invalido # se o bloco não estiver ocupado, não pode ser liberado
    movq $0, (%rbx) # coloca 0 para dizer que o bloco está livre
    movq $1, %rax # liberação deu certo, retorna 1
    ret
    _bloco_invalido:
        movq $0, %rax # liberação deu errado, retorna 0
        ret
