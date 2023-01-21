
all: sio_test hex_load hex_simple hex_binary hex_prog

clean:
	rm -f sio_test hex_load *.o *~ \#*

sio_test: sio_test.o sio_cmd.o
	$(CC) -o sio_test sio_test.o sio_cmd.o

hex_load: hex_load.o sio_cmd.o
	$(CC) -o hex_load hex_load.o sio_cmd.o

hex_prog: hex_prog.o sio_cmd.o
	$(CC) -o hex_prog hex_prog.o sio_cmd.o

hex_simple: hex_simple.o sio_cmd.o
	$(CC) -o hex_simple hex_simple.o sio_cmd.o

hex_binary: hex_binary.o sio_cmd.o
	$(CC) -o hex_binary hex_binary.o sio_cmd.o
