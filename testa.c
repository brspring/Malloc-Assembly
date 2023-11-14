#include <stdio.h>

#include "memalloc.h"

int main() {
    setup_brk(); // Inicializa o heap
    
    //printf("Valor de heapStart antes da alocação: %p\n", setup_brk());
    //printf("Valor de heapStart após a alocação: %p\n", memory_alloc(32));
    printf("%p", memory_alloc(32));
    printf("SAH");

//    dismiss_brk(); // Libera a memória alocada

    return 0;
}
