# DAC board

This is the control/interface board, designed to work with the Z80 CPU board from my retro-25 calculator project [git](https://github.com/eshazen/retro-25/tree/master/hardware/cpu/RevA).

**See bottom for ECOs**

Features:

* MAX503/530 DAC.  Needs 1 address bit and 8 bit data with strobe.
* UART with FT232 USB interface.  Thinking of IM6402 since it's dead simple.  Needs a 16X clock.
* Buttons, encoders, maybe a couple of LED drives
* Z-axis drive (9-12V to J2 on CRT board; could be +/-5V)
* Real-time clock e.g. DS1306

The CPU board interface is somewhat limited-- there are only two decoded nIORQ+Addr strobes and no access to nWR or nRD.  However, there is one address line and 5 latched outputs, which could be used for direction or additional address decoding.

## J1 (16 pins)

This connector was intended to drive an LED board.  It has the
unbuffered data buss, one address line and two strobes decoded with
nIORQ and address only.

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

This connector was intended to scan a matrix keyboard.  It has 5
latched outputs and 7 buffered inputs with pull-ups to +5.  There is
no access to the read strobe, so data to be read should be latched
somehow.  Also, there is no GND on this connector.

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

**CPU I/O decode**

    00 - KB/serial WR
	40 - nLED1 WR       (functions via U5)
	80 - KB/serial RD
	C0 - nLED2 WR       (access RTC when Q4 high)
	
Strobe nLED1 (address 0x40) accesses the DAC.  This is write-only (Q0
must be '1') with the channel selected by Q1.  Address A0 selects the
low 8 bits or upper 4 bits of the DAC data.  Strobe nLED2 accesses
either the UART or the switch/LED register selected by Q2.

### Output bits (address 0)

| Bit | Function      | 0         | 1                 |
|-----|---------------|-----------|-------------------|
| Q0  | Bus direction | RD        | WR                |
|     | LSB of U5     | even addr | odd addr          |
| Q1  | A2 of U5      |           |                   |
| Q2  | Z enable      | Z enabled | Z disabled        |
| Q3  | UART reset    |           | reset UART        |
| Q4  | RTC CE        |           | enable RTC access |
|     |               |           |                   |

### Input bits (address 80)

| Bit | Value | Function         |
|-----|-------|------------------|
| KD0 | 01    | Shaft encoder sw |
| KD1 | 02    | Shaft encoder A  |
| KD2 | 04    | Shaft encoder B  |
| KD3 | 08    | SW1              |
| KD4 | 10    | SW2              |
| KD5 | 20    | RTC SDO          |
| KD6 |       |                  |

### LS138 (U5)

Accessed at addresses 40/41

| Zero | Addr | Q1 | A0 | Q0 | Function                                        |
|------|------|----|----|----|-------------------------------------------------|
| 0    | 40   | 0  | 0  | 0  | UART Data Rd                                    |
| 1    | 40   | 0  | 0  | 1  | UART Data Wr                                    |
| 0    | 41   | 0  | 1  | 0  | Uart Status Rd                                  |
| 1    | 41   | 0  | 1  | 1  | `nEXP` expansion latch Wr                       |
| 2    | 40   | 1  | 0  | 0  |                                                 |
| 3    | 40   | 1  | 0  | 1  | `nDACY` H=idle, L=load DACs, reset DAC addr     |
| 2    | 41   | 1  | 1  | 0  |                                                 |
| 3    | 41   | 1  | 1  | 1  | `nDACX` L->H write DAC data, increment DAC addr |

### U3 expansion

Access by writing to address 41 with port zero low bits set to '01'.

| Bit | Funct     |
|-----|-----------|
| 0   | LED D1    |
| 1   | LED D2    |
| 2   | LED D3    |
| 3   | RTC SDI   |
| 4   | HV Enable |
| 5   |           |


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

## Changed for Rev 2

* Transistor pinout (Q1) is wrong **fixed**
* Jumper pins 22, 23 of U8, U9 (+5V to DAC missing) **fixed**

### Modifications to make the DAC run faster

* Add a '161 and a '139 so that the address cycles through the 4 DAC bytes automatically:
   * Disconnect nCE and wire to nWR **fixed**
   * Disconnect nLDAC and wire to nDACY (also to '161 nRESET)
   * Disconnect nDACX and wire to '161 CP and '139 nEN **fixed**
   * Wire '161 Q1 to '139 A0. **fixed**
   * Ground '139 A1 **fixed** 
   * Wire 139 O0 to DAC_X nWR and nCE **fixed**
   * Wire 139 O1 to DAC_Y nWR and nCE **fixed**
   * Wire '161 Q0 to both DAC A0+A1  **fixed**
* cut trace to pins 8,9 of U8, U9 (DAC A0, A1) **fixed**
* (wire U8 pin 8 to U3 pin 10) nope.  That's A0/A1 taken care of above
* Ground 12, 14, 17 on DAC **fixed**
* DAC VDD missing **fixed**
* Swap nEXP and nDACX on U5 **fixed**

* Wire RTC SDI (pin 12) to LED3 **fixed**

