all: flash_umon.hex

umon=umon_new_8100H.hex

zout/ser_19200_boot.hex: ser_19200_boot.asm
	zmac ser_19200_boot.asm

flash_umon.hex: zout/ser_19200_boot.hex ../umon/zout/${umon}
	srec_cat zout/ser_19200_boot.hex -Intel \
	../umon/zout/${umon} -Intel -Offset -12544 \
	-Output eeprom-umon.hex -Intel
