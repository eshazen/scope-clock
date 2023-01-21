all: flash_umon.hex

zout/ser_19200_boot.hex: ser_19200_boot.asm
	zmac ser_19200_boot.asm

flash_umon.hex: zout/ser_19200_boot.hex ../umon/zout/umon_8100H.hex
	srec_cat zout/ser_19200_boot.hex -Intel \
	../umon/zout/umon_8100H.hex -Intel -Offset -12544 \
	-Output eeprom-umon.hex -Intel
