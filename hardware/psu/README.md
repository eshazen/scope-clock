# Power Supply

So, after building a prototype we learn that we need:

* +5V for logic (~1A)
* -5V for Z axis drive (low current)
* 8-stage CW generator for -1500V
   * Jumpers to select output voltage
   * Discharge circuit for power-down
* Voltage doubler for +360V with two-stage R-C filter (200 ohm, 100uF or so)
