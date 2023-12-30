//
// rectangular grill generator
//

module grill( width, length, height, dx, dy, bar) {
     for( x = [0 : dx : width]) {
	  translate( [x, 0, 0])
	  cube( [bar, length, height]);
     }
     for( y = [0 : dy : length]) {
	  translate( [0, y, 0])
	  cube( [width, bar, height]);
     }
}
