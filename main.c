#include <stdio.h>

#include "memalloc.h"

extern void *original_brk;

int main() {
    printf("============================== ROTINAS DE TESTE ==============================\n");
	
	setup_brk();
	void *initial_brk = original_brk;
	void *f_pnt, *s_pnt, *t_pnt;

	f_pnt = memory_alloc(100);
	printf("==>> ALOCANDO UM ESPAÇO DE 100 BYTES:\n");
	printf("\tLOCAL: %s\n", f_pnt-16 == initial_brk ? "CORRETO!" : "INCORRETO!");
	printf("\tIND. DE USO: %s\n", *((long long*) (f_pnt-16)) == 1 ? "CORRETO!" : "INCORRETO!");
	printf("\tTAMANHO: %s\n", *((long long*) (f_pnt-8)) == 100 ? "CORRETO!" : "INCORRETO!");

	printf("==>> DESALOCANDO UM ESPAÇO DE 100 BYTES:\n");
	memory_free(f_pnt);
	printf("\tIND. DE USO: %s\n", *((long long*) (f_pnt-16)) == 0 ? "CORRETO!" : "INCORRETO!");
	printf("\tTAMANHO: %s\n", *((long long*) (f_pnt-8)) == 100 ? "CORRETO!" : "INCORRETO!");

	s_pnt = memory_alloc(50);
	t_pnt = memory_alloc(100);
	




    return 0;
}
