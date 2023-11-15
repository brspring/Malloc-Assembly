# Makefile for building executavel

# Compiler and flags
CC = gcc
CFLAGS = -g -no-pie -O0 -lm

# Source files
MAIN_SRC = main.s
TESTA_SRC = testa.c

# Object files
MAIN_OBJ = main.o
TESTA_OBJ = testa.o

# Target executable
TARGET = executavel

$(TARGET): $(MAIN_OBJ) $(TESTA_OBJ)
	ld $(MAIN_OBJ) $(TESTA_OBJ) /usr/lib/x86_64-linux-gnu/crt1.o /usr/lib/x86_64-linux-gnu/crti.o /usr/lib/x86_64-linux-gnu/crtn.o -lc -o $(TARGET) -dynamic-linker /lib/x86_64-linux-gnu/ld-linux-x86-64.so.2

$(MAIN_OBJ): $(MAIN_SRC)
	$(CC) -c -o $(MAIN_OBJ) $(CFLAGS) $(MAIN_SRC)

$(TESTA_OBJ): $(TESTA_SRC)
	$(CC) -c -o $(TESTA_OBJ) $(CFLAGS) $(TESTA_SRC)

clean:
	rm -f $(MAIN_OBJ) $(TESTA_OBJ) $(TARGET)
