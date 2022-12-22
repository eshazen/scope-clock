//
// simple model of Eaton BK/HBH-I-R fuse holder
//

$fn=32;

fh_dia = 12;
fh_len = 45;

pin_len = 3.4;
pin_dia = 1.0;

// pins
module pins() {
	  translate( [11.2, 0, -pin_len]) {
	  cylinder( d=pin_dia, h=pin_len);
	  translate( [17.8, 0, 0]) {
	       cylinder( d=pin_dia, h=pin_len);
	       translate( [15.2, 0, 0]) 	  cylinder( d=pin_dia, h=pin_len);
	  }
     }
}

// body
module body() {
     translate( [0, -fh_dia/2, 0])
	  cube( [fh_len, fh_dia, fh_dia/2]);
     translate( [0, 0, fh_dia/2])
	  rotate( [0, 90, 0]) {
	  cylinder( h=fh_len, d=fh_dia);
     }
}

module fuse_holder() {
     color("silver") pins();
     color("#404040") body();
}


fuse_holder();

