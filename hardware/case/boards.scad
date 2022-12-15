
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
		    color("green") import("anderson_crt.stl");
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

//
// high voltage board stand-in
//
module hv() {
     color("red")
     cube( [3.5*mm, 5*mm, 1.6]);
}

//
// logic board stand-in
//
module logic() {
     color("blue")
	  cube( [3.5*mm, 4*mm, 1.6]);
}


module base() {

     cube( [8.5*mm, 11*mm, 1]);

}

// move the CRT up
translate( [0, 0, 75]) crt();
translate( [-10, 200, 0]) rotate( [0, 0, 180]) amp();

translate( [0, 5, 0]) hv();
translate( [0, 11*mm-25-4*mm, 0]) logic();


translate( [ -113, -25, -10]) base();
