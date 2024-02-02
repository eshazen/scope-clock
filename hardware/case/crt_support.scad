//
// CRT support
//
// CRT neck support 2" dia
// Height 1.25 inch above base
// 4 inch width for base
//

$fn=64;
e=0.1;

function mm(x)=x*25.4;

module hole_at(x,y,dia) {
     translate( [x, y, -e])
	  cylinder( h=thk+2*e, d=dia);
}

crt_dia = mm(2.0);
crt_hgt = mm(1.25);

sup_hgt = mm(1);
sup_wid = crt_dia+mm(0.25);

thk = mm(0.125);

base_wid = mm(4);
base_len = mm(1);

hole_dia = mm(0.18);
hole_off = mm(0.25);

module sup() {
     difference() {
	  cube( [sup_wid, crt_hgt+sup_hgt, thk]);
	  translate( [sup_wid/2, crt_hgt+crt_dia/2, -e])
	       cylinder( h=thk+2*e, d=crt_dia);
     }
}

module base() {
     difference() {
	  cube( [base_wid, base_len, thk]);
	  hole_at( hole_off, (base_len-thk)/2, hole_dia);
	  hole_at( base_wid-hole_off, (base_len-thk)/2, hole_dia);
     }
}

module side() {
     linear_extrude( height=thk) {
	  polygon( points = [[0,0], [0, base_len-thk], [crt_hgt, 0]]);
     }
}


translate( [0, thk, 0]) rotate( [90, 0, 0]) sup();
translate( [ -(base_wid-sup_wid)/2, 0, 0])
base();
translate( [thk, thk-e, 0]) rotate( [0, -90, 0]) side();
translate( [sup_wid, thk-e, 0]) rotate( [0, -90, 0]) side();
