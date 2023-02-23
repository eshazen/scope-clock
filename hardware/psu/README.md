# Power Supply

Requirements-

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

## ECOs for Rev 1

* Relay wiring wrong.  Cut traces to J1 pins 1,3.  Wire pin 1 to Relay pin 11 and pin 3 to relay pin 12.
  (leave gap in cut, ~180VAC)
* Add bleeder on 360V!  (ouch!)
