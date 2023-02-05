#
# Try building line drawing routine for Z80
# 

all: line_draw.hex

DEFINES = -DONLY_REG_T -DZ80PACK -DZ80
CFLAGS = +z80 --list $(DEFINES) -clib=sdcc_iy

SOURCES = line_draw.c

line_draw.o: $(SOURCES)
	zcc $(CFLAGS) -DVFD -c line_draw.c -pragma-define:CRT_ORG_CODE=0x9000

#diskey_sw_vfd.o: diskey_sw_vfd.asm
#	z80asm diskey_sw_vfd.asm

line_draw.bin: line_draw.o
	zcc +z80 -m -O3 -startup=1 -clib=sdcc_iy \
	line_draw.o \
        -o line_draw -lm -create-app -startup=0 -pragma-define:CRT_ORG_CODE=0x9000

line_draw.hex: line_draw.bin
	srec_cat line_draw.bin -binary -offset 0x9000 -o line_draw.hex -intel

clean:
	rm -f *~ *.o *.lst *.sym *.ihx *.lk *.map *.rel *.bin *.def *.lis
