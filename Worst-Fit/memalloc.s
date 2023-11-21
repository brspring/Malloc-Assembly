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
.global worst_size 
.global worst_addr # será usado como o end. do bloco de ocupado do pior bloco

setup_brk:
    movq $12, %rax           # 12 em rax é o código do brk
    movq $0, %rdi            # nao faz nada na heap, só indica o endereço atual
    syscall

    movq %rax, original_brk
    ret

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
    movq %rax, %r14 # worst_addr é o r14
    movq $0, %r13 # pior tamanho r13

    _loop_start:
        cmpq %r12, %rax
        je _alocacao        # nao encontrou nenhum bloco livre, aloca no fim 
        cmpq $1, (%r12)         # compara o valor do offset com 1
        jne _livre              # soma 8 no r12   
        addq $8, %r12           # soma 8 no r12 pra ir pro tamanho do bloco           
        addq (%r12), %r12       # soma o tamanho do bloco no r12 para ir para  o fim do bloco menos 8 bytes
        addq $8, %r12           # vai para o inicio do proximo bloco
        movq %r12, %r9
        jmp _loop_start
        
        _livre:
            addq $8, %r12           # soma 8 no r12 pra ir pro tamanho do bloco 
            cmpq (%r12), %rbx   # compara o tamanho do bloco atual com o tamanho pedido
            jg _proximo_bloco   # se o tamanho do bloco atual for menor que o tamanho pedido, vai para o proximo bloco
            cmpq %r13, (%r12) # compara o pior(maior) tamanho com o tamanho do bloco atual
            jl _proximo_bloco  # se o tamanho do bloco atual for menor que o pior tamanho encontrado, vai p proximo
            movq (%r12), %r13 # pior tamanho (r13) = tamanho do bloco atual 
            movq %r12, %r14 
            subq $8, %r14 # pior endereço = endereço do bloco atual (end. da parte q diz se ta ocupado)
            jmp _proximo_bloco
        _alocacao:
          cmpq %r14, %rax # compara o pior end. de alocação com o end. do final heap
          jne _meio_heap
          _final_heap: # aloca no final da heap um novo bloco
            movq %r14, %rdi    # coloca em rdi o valor de r12, que é o endereço atual nos blocos da heap
            addq $16, %rdi     # rdi = rdi + 16 (8 bytes para dizer se ta livre e 8 bytes para dizer o tamanho do bloco)
            addq %rbx, %rdi # rdi = rdi + rbx (rbx tem o tamanho do bloco)
            movq $12, %rax
            syscall # coloca o valor de rdi como o novo valor do brk
            addq $8, %r14
            movq %rbx, (%r14)
            jmp _substituiBloco
          _meio_heap: # aloca no meio da heap em algum bloco já existente
            addq $8, %r14
            movq (%r14), %r9 
            subq %rbx, %r9 # r9 = tamanho do bloco disponível - tamanho pedido
            cmpq $16, %r9 
            jle _substituiBloco
            addq $8, %r14 # +8 para ir pro começo do bloco pedido
            addq %rbx, %r14 # + tamanho do bloco pedido pra chegar no fim do bloco pedido/começo do extra
            movq $0, (%r14) # coloca 0 para dizer que o bloco extra está livre
            addq $8, %r14 # vai para o tamanho do bloco extra
            subq $16, %r9
            movq %r9, (%r14) # coloca o tamanho do bloco extra
            subq %rbx, %r14 # volta a qntd de bytes igual ao tamanho do bloco pedido
            subq $16, %r14 # volta para a parte do tamanho do bloco
            movq %rbx, (%r14)   # coloca o tamanho novo no segundo quadradinho
            _substituiBloco: 
                subq $8, %r14       # vai para o inicio do bloco 
                movq $1, (%r14)     # diz que ta ocupado
                movq %r14, %rax     
                addq $16, %rax      # retorna o começo do bloco  de dados
                ret
            _proximo_bloco:
                addq (%r12), %r12   # vai para o proximo bloco
                addq $8, %r12       # vai para o proximo bloco
                jmp _loop_start

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
