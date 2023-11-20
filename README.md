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
Essa função aloca um bloco de memória, faz isso verificando e comparando valores na nossa heap, essa é a função mais extensa e pode ser dividida da seguinte forma:

   O Início e principal parte: 
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
   Que começa manipulando o parâmetro passado para a função memory_alloc, esse parâmetro representa a quantidade de bytes que serão alocados e é armazenado no registrador brx, já a variável 'original_brk' representa o BRK original que é um apontador para o início da heap.
Em "_loop_start" ele verifica como está nossa memória e onde devemos alocar o novo bloco. Na primeira linha fazemos uma comparação para ver se a heap está toda ocupada, isto é, sem um espaçamento do tamanho do bloco que queremos alocar. 

   Se caso estiver tudo ocupado (%r12 for igual a %rax) entra em:
```s
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
```
Que aloca um novo bloco no ultimo endereço disponível da nossa heap.

Já a flag "_livre" representa que o valor do offset do bloco atual está vem 0, que representa um bloco livre e que pode recerber a alocação.
```s
 _livre:
            addq $8, %r12           # soma 8 no r12 pra ir pro tamanho do bloco 
            cmpq (%r12), %rbx   # compara o tamanho do bloco atual com o tamanho pedido
            jg _proximo_bloco   # se o tamanho do bloco atual for menor que o tamanho pedido, vai para o proximo bloco
            movq (%r12), %r9 
            subq %rbx, %r9 # r9 = bloco disponível - tamanho pedido
            cmpq $16, %r9 
            jle _substituiBloco
            addq $8, %r12 # +8 para ir pro começo do bloco pedido
            addq %rbx, %r12 # + tamanho do bloco pedido pra chegar no fim do bloco pedido/começo do extra
            movq $0, (%r12) # coloca 0 para dizer que o bloco extra está livre
            addq $8, %r12 # vai para o tamanho do bloco extra
            subq $16, %r9
            movq %r9, (%r12) # coloca o tamanho do bloco extra
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
```
   Nessa flag, verificamos se o tamanho do bloco livre condiz com o que queremos alocar. Se sim, continuamos a alocação; se não, pulamos para o próximo bloco com "_proximo_bloco", que volta ao início do nosso loop após verificar os blocos disponíveis.

   Após todas essas verificações, a maioria dos casos voltamos ao inicio da nossa procedure, que verifica os blocos novamente e que também faz a verificação da possível alocação do bloco extra. 
## memory_free 
   A função memory_free é projetada para liberar a memória associada a um bloco específico dentro do heap.
```s
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
```
Começa verificando se o endereço passado como parâmetro está dentro dos limites da memória alocada dinamicamente, comparando-o com o valor original do BRK. Após colocar em variáveis temporárias os valores do BRK e o endereço passado por parâmetro, verificamos se o endereço passado está consistente na heap; ou seja, o endereço passado não é maior do que a heap. Também verificamos se o bloco que queremos liberar já não tem offset 0; se estiver com offset 0, não precisamos liberar. Se nenhuma dessas condições for violada, mudamos os valores do offset do bloco para zero e retornamos 1 para a função, indicando sucesso na liberação.
## Rotina de Testes
 No início, desenvolvemos o código com uma abordagem inicial de apenas idealizar como a Heap funcionaria e esboçando como os blocos seriam alocados. Nesse estágio, enfrentamos a dificuldade de testar nosso código em Assembly, por este motivo, fizemos em teste de mesa e visualizamos a lógica inicial apenas no campo das ideias.

À medida que o esqueleto do nosso código começou a tomar forma, realizamos testes de alocação e identificamos erros simples. Esses erros muitas vezes decorriam da diferença entre a abstração no papel e a implementação real, como o uso do registrador %rcx, que não estava retendo o valor conforme o esperado.

Posteriormente, refinamos nosso código, incorporando as correções necessárias e para validar a funcionalidade, testamos o código com o exemplo fornecido pelo professor, utilizamos o GDB para auxiliar na verificação dos valores de cada registrador durante a execução do programa. Com esse método de teste e depuração nos permitiu percorrer o código até sua conclusão, garantindo uma implementação mais robusta.
```c

```

