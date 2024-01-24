//
// CRT support
//
// CRT neck support 2" dia
// Height 1.25 inch above base
// 4 inch width for base
//
// bottom half for version with clamp
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

clamp_wid = mm(3);
clamp_len = mm(0.75);

ch_off = mm(0.15);

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

module side2() {
     linear_extrude( height=thk) {
	  polygon( points = [[0, 0], [clamp_len, 0], [0, sup_hgt]]);
     }
}

module bracket() {
     translate( [0, thk, 0]) rotate( [90, 0, 0]) sup();
     translate( [ -(base_wid-sup_wid)/2, 0, 0])
	  base();
     translate( [thk, thk-e, 0]) rotate( [0, -90, 0]) side();
     translate( [sup_wid, thk-e, 0]) rotate( [0, -90, 0]) side();
}

module clamp() {
     difference() {
	  cube( [clamp_wid, clamp_len, thk]);
	  hole_at( ch_off, clamp_len/2, hole_dia);
	  hole_at( clamp_wid-ch_off, clamp_len/2, hole_dia);
	  translate( [clamp_wid/2, -e, thk])
	       rotate( [-90, 0, 0])
	       cylinder( h=clamp_len+2*e, d=crt_dia);
     }
}

module bottom() {
     translate( [thk, 0, sup_hgt+crt_hgt]) rotate( [-90, 0, 90]) side2();
     translate( [sup_wid, 0, sup_hgt+crt_hgt]) rotate( [-90, 0, 90]) side2();
     bracket();
     translate( [ -(clamp_wid-sup_wid)/2, 0, sup_wid-thk])  clamp();
}

module top() {
     difference() {
	  union() {
	       cube( [clamp_wid, clamp_len, thk]);
	       translate( [(clamp_wid-sup_wid)/2, 0, 0])
		    cube( [sup_wid, thk, crt_dia/2+mm(0.25)]);
	  }
	  hole_at( ch_off, clamp_len/2, hole_dia);
	  hole_at( clamp_wid-ch_off, clamp_len/2, hole_dia);
	  translate( [clamp_wid/2, -e, 0])
	       rotate( [-90, 0, 0])
	       cylinder( h=clamp_len+2*e, d=crt_dia);
     }
     translate( [(clamp_wid-crt_dia)/2-thk, 0, thk-e]) rotate( [90, 0, 90]) side2();
     translate( [clamp_wid-(clamp_wid-crt_dia)/2, 0, thk-e]) rotate( [90, 0, 90]) side2();
}

module crt() {
     color("grey") cylinder( h=mm(2.5), d=crt_dia);
}

crt_raise = 0.5;
raise=1;

// bottom bracket
bottom();

// top clamp
// translate( [ -(clamp_wid-sup_wid)/2, 0, sup_wid+raise]) top();

// CRT neck
// translate( [sup_wid/2, mm(1), crt_hgt+crt_dia/2+crt_raise]) rotate( [90, 0, 0]) crt();
