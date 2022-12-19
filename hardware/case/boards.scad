
include <3bp1.scad>
include <6sn7.scad>

mm = 25.4;

//
// draw CRT with bias board at origin
// pointing in +X
//
// PCB dimensions
crt_wid = 4.8*mm;
crt_len = 3.35*mm;

crt_center_x = 47;		/* WRT corner of PCB */

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
amp_wid = 4*mm;
amp_len = 7*mm;

module amp() {
     translate( [-44.5, -44.5, 0])
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
hv_wid = 3.5*mm;
hv_len = 6.5*mm;

module hv() {
     color("red")
     cube( [hv_wid, hv_len, 1.6]);
}

//
// logic board stand-in
//
logic_wid = 7*mm;
logic_len = 2.75*mm;

module logic() {
     color("blue")
	  cube( [logic_wid, logic_len, 1.6]);
}

//
// transformer
//
trans_dia = 4.5*mm;
trans_thk = 2*mm;

module trans() {
  color("#404040")
  cylinder( h=trans_thk, d=trans_dia);
}


case_wid = 8*mm;		/* X size */
case_len = 14*mm;		/* Y size */
case_hgt = 6;			/* Z size */

module case() {

     cube( [case_wid, case_len, 1]);

}

case();				/* corner at origin */


// move the CRT up
// translate( [case_wid/2, 2*mm, 75]) crt();
translate( [crt_wid-crt_center_x, 4*mm, 75]) crt();

// toroidal transformer
translate( [crt_wid-crt_center_x, 2*mm, 75])  rotate( [90, 0, 0])  trans();

// AMP board
translate( [case_wid-amp_wid, 4*mm, 0.25*mm]) amp();

// HV board
translate( [case_wid, 0, 0.25*mm]) rotate( [0, 0, 90]) hv();


// logic board
translate( [0.5*mm, case_len-logic_len, 0.25*mm]) logic();


