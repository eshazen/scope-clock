# DAC board

This is the control/interface board, designed to work with the Z80 CPU board from my retro-25 calculator project [git](https://github.com/eshazen/retro-25/tree/master/hardware/cpu/RevA).

Features:

* MAX503/530 DAC.  Needs 1 address bit and 8 bit data with strobe.
* UART with FT232 USB interface.  Thinking of IM6402 since it's dead simple.  Needs a 16X clock.
* Buttons, encoders, maybe a couple of LED drives
* Z-axis drive (9-12V to J2 on CRT board; could be +/-5V)
* Real-time clock
* Needs +/-5V power for DAC

The CPU board interface is somewhat limited-- there are only two decoded nIORQ+Addr strobes and no access to nWR or nRD.  However, there is one address line and 5 latched outputs, which could be used for direction or additional address decoding.

## J1 (16 pins)

This connector was intended to drive an LED board.  It has the unbuffered data buss, one address line and two strobes decoded with nIORQ and address only.

| Notes           | Pin |   | Pin | Notes           |
|-----------------|-----|---|-----|-----------------|
| +5V             | 1   |   | 2   | D0 (unbuffered) |
| +5V             | 3   |   | 4   | D1              |
| GND             | 5   |   | 6   | D2              |
| GND             | 7   |   | 8   | D3              |
| GND             | 9   |   | 10  | D4              |
| nLED2 (strobe)  | 11  |   | 12  | D5              |
| nLED1 (strobe)  | 13  |   | 14  | D6              |
| A0 (unbuffered) | 15  |   | 16  | D7              |

## J3 (16 pins)

This connector was intended to scan a matrix keyboard.  It has 5 latched outputs and 7 buffered inputs with pull-ups to +5.  There is no access to the read strobe, so data to be read should be latched somehow.  Also, there is no GND on this connector.

| Notes     | Pin |   | Pin | Notes    |
|-----------|-----|---|-----|----------|
| N/A       | 1   |   | 2   | N/A      |
| N/A       | 3   |   | 4   | Input D0 |
| Input  D4 | 5   |   | 6   | Input D1 |
| Output Q4 | 7   |   | 8   | Input D2 |
| Output Q3 | 9   |   | 10  | Input D3 |
| Output Q2 | 11  |   | 12  | Input D4 |
| Output Q1 | 13  |   | 14  | Input D5 |
| Output Q0 | 15  |   | 16  | Input D6 |

## I/O Mapping/Decoding

Strobe nLED1 (address 0x40) accesses the DAC.  This is write-only (Q0 must be '1') with the channel selected by Q1.  Address A0 selects the low 8 bits or upper 4 bits of the DAC data.  Strobe nLED2 accesses either the UART or the switch/LED register selected by Q2.

### Output bits (address 0)

| Bit | Function      | 0           | 1      |
|-----|---------------|-------------|--------|
| Q0  | Bus direction | RD          | WR     |
| Q1  | DAC Channel   | X           | Y      |
|     | UART function | Ctrl/Status | Data   |
| Q2  | Device Select | UART        | LED/SW |

Propse to buffer the data with a latched output used to set direction,
and enable on the 'or' of the two decoded strobes.  Additional latched
outputs would serve as a device select.

The DAC (MAX503 or MAX530) requires only a strobe (nWR) and one
address line (A0, A1 tied) to update 10 or 12 bits using two successive write operations.

Each DAC would be mapped to two addresses so once enabled it could be
written fast using two I/O writes per word.  A single additional write
would be required to switch between X and Y channels using a device
select bit.

The UART requires one status port, one latched control port and input and output data ports.

