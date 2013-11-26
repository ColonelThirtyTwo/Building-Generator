
CC=gcc
CFLAGS=-O2 -Wall
LUABC=generator.bc.c glfw.bc.c main.bc.c map.bc.c oop.bc.c room.bc.c

main.exe: main_exec.c $(LUABC)
	$(CC) $(CFLAGS) main_exec.c $(LUABC) -lluajit-5.1 -o main.exe

%.bc.c: %.lua
	luajit -b $< $@

clean:
	rm *.bc.c main.exe

.PHONY: clean
