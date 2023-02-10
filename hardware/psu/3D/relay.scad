//
// CUI PR16 relay ("DIP22-like" package)
//

case_wid = 12.6;
case_len = 29;
case_hgt = 20;

row_spc = 7.6;
row_len = 25.4;
pin_spc = 2.54;

pin_len = 3.7;
pin_dia = 1.0;

$fn=32;

module pin_at( x, y) {
     translate( [x, y, 0])
	  cylinder( d=pin_dia, h=pin_len);
}

module relay() {
     translate( [-case_wid/2, -case_len/2, 0])
	  color("orange") cube( [case_wid, case_len, case_hgt]);
     // to pin 1
     translate( [-row_spc/2, row_len/2, -pin_len]) {
	  for( x=[0,row_spc]) {
	       for( y=[0, -15.24, -15.24-5.08, -15.24-5.08*2]) {
		    pin_at( x,y);
	       }
	  }	     
     }
}


relay();

