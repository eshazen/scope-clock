//
// bracket for fuse
//

e = 0.1;
$fn = 32;
mm = 25.4;

nsw = 1;			/* number of switches */

mtg_hole = 0.15*mm; 		/* mounting hole (6-32) */
mtg_nut = 9;

hole_dia = 15;			/* switch hole */

f_thk = 1.6;			/* front thick */
b_thk = 3;			/* base thick */
s_thk = 1.6;			/* side thickness */

sw_spc = 25;			/* pitch */


// front panel in x/y
f_wid = sw_spc*nsw;

f_hgt = 25+b_thk;			/* front panel height */
f_hole = 14+b_thk;			/* front panel hole offset from bottom */

module front() {
     difference() {
	  cube( [f_wid, f_hgt, f_thk]);
	  translate( [sw_spc/2, f_hole, -e]) {
	       for( i=[0:nsw-1]) {
		    translate( [i*sw_spc, 0, 0])
			 cylinder( h=f_thk+3*2, d=hole_dia);
	       }
	  }
     }
}

module hex( h, d) {
     $fn = 6;
     cylinder( h=h, d=d);
}

module mtg_hole_at( x, y) {
     translate( [x, y, -e]) {
	  cylinder( h=b_thk+2*e, d=mtg_hole);
	  translate( [0, 0, b_thk/2])
	       hex( b_thk, mtg_nut);
     }
}

// base plate in x/y
base_wid = f_wid;
base_hgt = 35;
module base() {
     difference() {
	  cube( [base_wid, base_hgt, b_thk]);
	  mtg_hole_at( base_wid/2, base_hgt/2);
     }
}


// side bracket
module side() {
     linear_extrude( height=s_thk, convexity=10) {
	  polygon( [[0,0] , [base_hgt, 0], [0, f_hgt] ]);
     }
}


translate( [0, e, 0])  rotate( [90, 0, 0])  front();
base();

translate( [base_wid-s_thk, -e, 0])  rotate( [90, 0, 90])   side();
translate( [0, -e, 0])  rotate( [90, 0, 90])   side();

