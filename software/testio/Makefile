
all: test_vec clock_test clock_part

clean:
	rm -f *.o test_vec *~

text2vec.o: text2vec.c text2vec.h

test_vec.o: test_vec.c text2vec.h

test_vec: text2vec.o test_vec.o
	$(CC) -o $@ $^

clock_fun.o: clock_fun.c clock_fun.h

clock_test.o: clock_test.c clock_fun.h

clock_test: clock_fun.o clock_test.o
	$(CC) -o $@ $^ -lm

clock_part: clock_fun.o clock_part.o
	$(CC) -o $@ $^ -lm

