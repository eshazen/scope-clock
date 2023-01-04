# Power Supply

Requirements-

* AC power entry, fuse, power switch
* +8V for logic (~1A) regulator on CPU board makes 5V for DAC
   * Can use bridge on spare 6.3V Antek winding?
* -5V for Z axis drive (low current).  Should be regulated
* 8-stage CW generator for -1500V
   * Jumpers to select output voltage
   * Discharge circuit for power-down
* Voltage doubler for +360V with two-stage R-C filter (200 ohm, 100uF or so)
* Switched AC out (2x?) for 12V filament transfomer plus spare
