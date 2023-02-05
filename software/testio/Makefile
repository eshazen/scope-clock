
all: test_vec

clean:
	rm -f *.o test_vec *~

text2vec.o: text2vec.c text2vec.h

test_vec.o: test_vec.c text2vec.h

test_vec: text2vec.o test_vec.o
	$(CC) -o $@ $^
