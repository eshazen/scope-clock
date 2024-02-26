
mm=25.4;
e=0.1;

$fn=64;

t_dia = 1.188*mm;
t_hgt = 2.000*mm;
pin_len = 0.375*mm;
pin_dia = 0.04*mm;
pin_circ = 0.730*mm;
pin_div = 13;

module body() {
  translate( [0, 0, 1*mm])
    intersection() {
    sphere( r=1*mm);
    cylinder( h=t_hgt/2, d=t_dia);
  }
  cylinder( h=t_hgt/2, d=t_dia);
}

color("DarkGrey")
body();

for( i=[0:pin_div]) {
    rotate( [0, 0, 360 * (i/pin_div)])
  translate( [pin_circ/2, 0, -pin_len])
    cylinder( d=pin_dia, h=pin_len);
 }
