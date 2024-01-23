//
// support bracket for CRT board
//

// printed with thk=1, too thin!  Maybe 1.5 or 2?
// Also the hole_dia of 0.170 is not quite big enough for 8-32 screws
//

$fn=32;
e=0.1;

function mm(x)=x*25.4;

pcb_len = mm(3.35);
pcb_hole_off = mm(0.175);
pcb_hole_dia = mm(0.170);

pcb_up = mm(0.25);

brkt_wid = mm(0.5);
brkt_z = mm(1);
thk = 1;

side_len = pcb_len-mm(0.5);

module hole_at(x,y,dia) {
     translate( [x, y, -e])
	  cylinder( h=thk+2*e, d=dia);
}

module body() {
     difference() {
	  cube( [brkt_wid, pcb_len+pcb_up, thk]);
	  hole_at( pcb_hole_off, pcb_up+pcb_hole_off, pcb_hole_dia);
	  hole_at( pcb_hole_off, pcb_up+pcb_len-pcb_hole_off, pcb_hole_dia);
     }
}

module side() {
     linear_extrude( height=thk) {
	  polygon( points = [[0,0], [0, side_len], [brkt_z, 0]]);
     }
}

module base() {
     difference() {
	  cube( [brkt_wid, brkt_z, thk]);
	  hole_at( pcb_hole_off, thk+pcb_hole_off, mm(.150));
	  hole_at( brkt_wid-pcb_hole_off, brkt_z-pcb_hole_off, mm(.15));
     }
}


body();
translate( [brkt_wid+thk-e, 0, 0]) rotate( [0, -90, 0]) side();

translate( [0, thk, 0])
rotate( [90, 0, 0])
base();
