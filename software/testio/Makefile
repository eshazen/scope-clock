
all: test_vec clock_test clock_part make_list

clean:
	rm -f *.o test_vec *~

make_list.o: make_list.c

text2vec.o: text2vec.c text2vec.h

test_vec.o: test_vec.c text2vec.h

test_vec: text2vec.o test_vec.o
	$(CC) -o $@ $^

clock_fun.o: clock_fun.c clock_fun.h

clock_test.o: clock_test.c clock_fun.h

make_list: make_list.o
	$(CC) -o $@ $^ -lm

clock_test: clock_fun.o clock_test.o
	$(CC) -o $@ $^ -lm

clock_part: clock_fun.o clock_part.o
	$(CC) -o $@ $^ -lm

circles:
	./make_list 0x80 8 > circle080.asm
	./make_list 0x100 8 > circle100.asm
	./make_list 0x180 8 > circle180.asm
	zmac test_pattern.asm

