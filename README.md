mais fácil de ser visualizado em: 

# Implementação de um Sistema de Gerenciamento de Alocação Dinâmica de Memória
Participantes:

Bruno Aziz Spring Machado   --- GRR20211279

Gustavo Vinicius Paulino    --- GRR20220067

## Ideia principal
Começamos a implementação fazendo as duas funções mais simples e intuitivas, que são: "setup_brk" e "dismiss_brk". Após isso a implementação da função principal a "memory_alloc" e por ultimo "memory_free".
Onde alocamos um bloco de memória com  registro de informações gerenciais dos blocos de memória na heap. Esse registro é composto por duas quadwords (ou seja, tem 16 bytes), sendo que a primeira identifica se o bloco está sendo usado ou não (0 para livre e 1 para em uso); e a
segunda indica o tamanho do bloco relacionado (quantidade de bytes) e o restante representa o bloco de dados em si. 
# Principais Funções
   
 ## setup_brk:
```s
setup_brk:
    movq $12, %rax           
    movq $0, %rdi            
    syscall

    movq %rax, original_brk
    ret
```
Obtém o endereço atual do BRK, usando a chamada do sistema "movq $12, %rax" que indica o valor do BRK e "movq $0, %rdi" que indica que não houve alterações na heap.

## dismiss_brk:
```s
dismiss_brk:
    movq $12, %rax         
    movq original_brk, %rdi
    syscall
    ret
```
## memory_alloc
A função principal pode ser dividida em algumas partes, o começo sendo:
```s
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
```
Que começa manipulando o parâmetro passado para a função memory_alloc, este parâmetro representa a quantidade de bytes que serão alocados e é armazenado no registrador brx, e a variável 'original_brk' representa o BRK do início da heap.

## Rotina de Testes

```c

```

