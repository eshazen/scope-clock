//
// 3BP1 CRT, somewhat crude
//

module 3bp1() {
     
     mm = 25.4;
     e = 0.1;

     $fn = 32;


// origin at center of base in the plane of the PCB more or less

     module tube() {
	  // neck
	  cylinder( h=(5.38+e)*mm, d=2*mm);
	  // top
	  translate( [0, 0, 5.38*mm])
	       cylinder( h=3.875*mm, d1=2*mm, d2=3.063*mm);
     }

// pin circle
     pin_dia = 0.093*mm;
     pin_cir = (1.75/2)*mm;
     pin_len = 0.35*mm;

     module base() {
	  color( "black") {
	       cylinder( h=1*mm, d=2.25*mm);
	  }
	  color( "silver") {
	       for( a=[0:14]) {
		    rotate( [0, 0, (360/14)*a])
			 translate( [ pin_cir, 0, -pin_len])
			 cylinder( h=pin_len, d=pin_dia);
	       }
	  }
     }

	  % tube();
     base();
}
