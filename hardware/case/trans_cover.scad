//
// Antek AS-1 cover
//

mm=25.4;
$fn=64;
e = 0.1;

id = 4.75*mm;
hgt = 3.0*mm;

wthk = 1.6;
bthk = 1.6;

hdia = (3/8+0.02)*mm;

od = id + 2*wthk;

// flange
fhgt = 1.64*mm-bthk;
fid = hdia;
fod = hdia+5;

cut_hgt = 0.75*mm;
cut_wid = 0.75*mm;
cut_num = 2.0;

module wall() {
     difference() {
	  cylinder( d=od, h=hgt);
	  translate( [0, 0, -e])
	       cylinder( d=id, h=hgt+2*e);
	  for( i=[0:cut_num-1]) {
	       translate( [0, 0, hgt-cut_hgt+e])
	       rotate( [0, 0, 360*(i/cut_num)])
		    cube( [od+10, cut_wid, cut_hgt]);
	  }
     }
}

module hole_at(x,y,dia) {
     translate( [x, y, -e])
	  cylinder( h=bthk+2*e, d=dia);
}

module base() {
     difference() {
	  cylinder( d=od, h=bthk);
	  hole_at( 0, 0, hdia);
     }
     difference() {
	  cylinder( d=fod, h=fhgt);
	  translate( [0, 0, -e])
	       cylinder( d=fid, h=fhgt+2*e);
     }
}

wall();
base();

