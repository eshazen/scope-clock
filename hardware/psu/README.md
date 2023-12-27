# Power Supply

## Rev A ECOs

* C13 should be much bigger, maybe 4700uF
* Bridge footprints are wrong (holes way too small)
* Relay wiring is incorrect
* Can't use the S4 or S6 outputs of the CW multipler,
only S5, S7.  Maybe add an S3 tap?  In any case, fix J14 wiring.

## Requirements

* AC power entry, fuse, power switch
* +8V for logic (~1A) regulator on CPU board makes 5V for DAC (Antek 6.3V winding too wimpy)
* -5V for Z axis drive (low current).  Should be regulated
* 8-stage CW generator for -1500V
   * Jumpers to select output voltage
   * Discharge circuit for power-down
* Voltage doubler for +360V with two-stage R-C filter (200 ohm, 100uF or so)
* Switched AC out (2x?) for 12V filament transfomer plus spare

It seems I have a bunch of surplus 12V transformers in my office, so probably will use two of those
to generate the +8V and -5V with bridge rectifiers.
