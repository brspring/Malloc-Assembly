#include <stdio.h>

#include "memalloc.h"

int main() {
    setup_brk(); // Inicializa o heap
    
    //printf("Valor de original_brk antes da alocação: %p\n", setup_brk());
    //printf("Valor de original_brk após a alocação: %p\n", memory_alloc(32));
    printf("%p", memory_alloc(32));

//    dismiss_brk(); // Libera a memória alocada

    return 0;
}
