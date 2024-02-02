//
// 12 x 17 inch chassis
//

include <3bp1.scad>
include <6sn7.scad>

include <grill.scad>

mm = 25.4;

sides = 1;
front = 1;
lid = 0;
left = 1;
control = 0;			/* control panels */
chassis = 1;			/* chassis underneath */

chas_hgt = 2*mm;

// PCB standoff height
pcb_so = 0.25*mm;

// overal case dimensions
case_wid = 17*mm;		/* X size */
case_len = 12*mm;		/* Y size */

case_hgt = 4.5*mm;			/* Z size */
case_thk = 1.6;

// front control panel
fp_hgt = 1.75*mm;

// height of CRT centerline
crt_up = 2.25*mm;

//
// draw a transformer
//
module transf( core_len, core_thk, winding_thk, overall_wid, height) {
     dx = core_len/5;
     dz = height/5;
     color("silver")
     translate( [0, 0, 0]) {
	  translate( [-core_len/2, -core_thk/2])
	       cube( [core_len, core_thk, height]);
	  translate( [-core_len/2, 0, 0]) cylinder( h=1, d=core_thk);
	  translate( [core_len/2, 0, 0]) cylinder( h=1, d=core_thk);
	  translate( [-dx*1.5, -winding_thk/2, dz])
	       cube( [3*dx, winding_thk, dz*3]);
     }
}



//
// draw CRT with bias board at origin
// pointing in +X
//
// PCB dimensions
crt_wid = 4.8*mm;
crt_len = 3.35*mm;

crt_tube = 9.4*mm;

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



cpu_wid = 4.6*mm;
cpu_len = 5.8*mm;

module cpu_stack() {
     translate( [-mm, mm+cpu_len, 0]) {
	  color("#308030")
	       import("cpu.stl");
	  translate( [0, 0, pcb_so*2])
	       color("#20e020")
	       import("dac.stl");
     }
}


//
// draw deflection amp
// with corner at origin
//
amp_wid = 7*mm;
amp_len = 4*mm;

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
hv_wid = 7.0*mm;
hv_len = 4.5*mm;

module hv() {
     color("#80a030") {
//	  cube( [hv_wid, hv_len, 1.6]);
	  rotate( [0, 0, 180])
	  translate( [-hv_wid-mm, mm, 0])
	  import("psu.stl");
     }
}


//
// toroidal transformer
//
toroid_dia = 4.5*mm;
toroid_thk = 2*mm;

module toroid() {
  color("#404040")
  cylinder( h=toroid_thk, d=toroid_dia);
}

module case() {

     // base plate
     color("#202020")
     cube( [case_wid, case_len, case_thk]);

     if( sides) {

	  // rear
	  % cube( [case_wid, case_thk, case_hgt]);

	  // right
	  rotate( [0, 0, 90])
	  % cube( [case_len, case_thk, case_hgt]);

	  // left
	  translate( [case_wid, 0, 0])
	  rotate( [0, 0, 90])
	  % cube( [case_len, case_thk, case_hgt]);

	  // front
	  if( front) {
	       translate( [0, case_len, 0])
		    % cube( [case_wid, case_thk, case_hgt]);
	  }

	  // lid
	  if( lid) {
	       translate( [0, 0, case_hgt])
		    color("gray")
		    grill( case_wid, case_len, case_thk, 0.25*mm, 0.25*mm, case_thk/2);
	  }

	  if( control) {
	       // front control panel
	       translate( [0, case_len+case_thk, 0])
		    color("black")
		    cube( [case_wid, case_thk, fp_hgt]);

	       // right control panel
	       rotate( [0, 0, 90])
		    color("black")
		    cube( [case_len, case_thk, fp_hgt]);
	  }
     }

     if( chassis) {
	  translate( [0, 0, -chas_hgt])
	       color("#a88000")
	       cube( [case_wid, case_len, chas_hgt]);
     }

}


// filament transfomer
fil_a = 50;  fil_b = 21;  fil_c = 44;  fil_d = 71;  fil_h = 43;

// logic transfomer (LP-427)
log_a = 43;  log_b = 21;  log_c = 49;  log_d = 70;  log_h = 43;

// space between/around transformers
trans_spc = 0.3*mm;



module assembly() {

     case();				/* corner at origin */


// rotate the CRT assembly
//     rotate( [10, 0, 0])
// move the CRT up
     translate( [3*mm, case_len-crt_tube, crt_up]) crt();

// toroidal transformer
     translate( [-toroid_dia/2-trans_spc+case_wid-hv_wid, trans_spc+toroid_dia/2, 0.25*mm])
	  toroid();

// AMP board
     translate( [case_wid-0.25*mm, case_len-amp_len, pcb_so])
     rotate( [0, 0, 90])
	  amp();

// HV board

     translate( [case_wid-hv_wid, case_len-hv_len-amp_len-trans_spc*2, 0.25*mm])
	  hv();
     
// logic board
     translate( [case_wid-hv_wid-0.5*mm, case_len, pcb_so])
     rotate( [0, 0, 180])
     cpu_stack();

// transformers

     translate( [case_wid-fil_c/2-trans_spc*2, fil_d/2+trans_spc*0.6, case_thk]) {
	  rotate( [0, 0, 60]) transf( fil_a, fil_b, fil_c, fil_d, fil_h);
	  translate( [-fil_c-trans_spc, 0, 0])
	       	  rotate( [0, 0, 60]) transf( log_a, log_b, log_c, log_d, log_h);
	  translate( [2*(-log_c-trans_spc), 0, 0])
	       	  rotate( [0, 0, 60]) transf( log_a, log_b, log_c, log_d, log_h);
     }
     


}


assembly();
// hv();

