This directory contains a boot loader for the Retro-25 calculator.
It uses a bit-bang serial port at 4800 baud (4MHz CPU clock)
to attempt to load serial data sent by the "hex_loader" utility.
After about 10s it gives up and copies the calculator code
from EEPROM (or other code) and executes it.

Build with zmac:  http://48k.ca/zmac.html

2023 version for scope clock -- currently has only UMON
loaded at 8100H

