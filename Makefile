all: target

infected: infected.s target
	nasm -f bin infected.s -o infected
	cat target >> infected

target: target.c
	gcc target.c -o target

clean:
	$(RM) infected target /tmp/orig_binary

re: clean all
