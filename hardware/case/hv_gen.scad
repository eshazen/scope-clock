//
// holder for components in Cockroft-Walton multipler
//

mm = 25.4;
e = 0.1;
$fn = 32;

s32 = sqrt(3)/2;

cap_d = 22.2;
cap_spc = 0.25;
hole_d = cap_d+2*cap_spc;

mtg_hole_d = 0.15*mm;
mtg_hole_off = 0.25*mm;

cap_dx = 30;
cap_h = cap_dx*s32;

nstage = 3;

module cap( dia) {
     color("#404040")
	  cylinder( h=cap_h, d=dia);
}


module cyl_array( dia) {
     for( i=[0:nstage-1] ) {
	  translate( [cap_dx*i, 0, 0]) {
	       cap( dia);
	       translate( [cap_dx/2, cap_h , 0]) cap( dia);
	  }
     }
}

module m_hole_at( x, y, d) {
     translate( [x, y, 0])
	  cylinder( h=cap_h, d=mtg_hole_d);
}


bbx = 10;			/* board border in x */
bby = 5;			/* board border in y */

board_x = 2*bbx+cap_d + (nstage-0.5)*cap_dx;
board_y = 2*bby+cap_d+cap_h;
board_thk = 1.0;

module board() {

     difference() {
	  translate( [-cap_d/2-bbx, -cap_d/2-bby, cap_h/2]) {
	       cube( [board_x, board_y, board_thk]);
	  }
	  translate( [-cap_d/2-bbx, -cap_d/2-bby, -e]) {
	       m_hole_at( mtg_hole_off, mtg_hole_off, mtg_hole_d);
	       m_hole_at( board_x-mtg_hole_off, mtg_hole_off, mtg_hole_d);
	       m_hole_at( mtg_hole_off, board_y-mtg_hole_off, mtg_hole_d);
	       m_hole_at( board_x-mtg_hole_off, board_y-mtg_hole_off, mtg_hole_d);
	  }
	  cyl_array( hole_d);
     }
}

// cyl_array( cap_d);
//projection() {
     board();
//}
