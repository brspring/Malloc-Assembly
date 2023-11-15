#include <stdio.h>

#include "memalloc.h"

extern void *original_brk;

int main() {
    printf("Hello, Vinicius Fulber! Seja o novo tutor do PET! (printf inicial para não zuar a execução)\n");
    setup_brk(); // Inicializa o heap
    void *initial_brk = original_brk;
    printf("BRK Inicial: %ld\n", initial_brk);
    for (int i = 0; i < 5; i++){
        printf("%ld\n", memory_alloc(100));
    }
        
    

//    dismiss_brk(); // Libera a memória alocada

    return 0;
}
