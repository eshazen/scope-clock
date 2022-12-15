
include <3bp1.scad>
include <6sn7.scad>

mm = 25.4;

//
// draw CRT with bias board at origin
// pointing in +X
//
module crt() {
     translate( [126, 0, -12]) {
	  rotate( [90, 0, 180]) {
	       translate( [0, 100, 0]) {
		    color("red") import("anderson_crt.stl");
		    translate( [125, -88, 3])
			 3bp1();
	       }
	  }
     }
}

//
// draw deflection amp
// with corner at origin
//
module amp() {
     translate( [-45, -45, 0])
     rotate( [0, 0, 90])
	  color("green")
	  import("deflection_amp.stl");
     // install the tubes
     translate( [49, 44, 1.6+14.5]) {
	  6sn7();
	  translate( [0, 2*mm, 0]) 6sn7();
	  translate( [0, 4*mm, 0]) 6sn7();
     }
}

// move the CRT up
translate( [0, 0, 75]) crt();
translate( [-10, 200, 0]) rotate( [0, 0, 180]) amp();

