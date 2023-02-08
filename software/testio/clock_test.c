//
// sample clock face
//

#include "clock_fun.h"

#define DEBUG

int main( int argc, char *argv[]) {

  // sizes of the features
  double sec_len = 1.0;		/* length of second hand */
  double sec_wid = 0.01;

  double min_len = 0.8;		/* length of minute hand */
  double min_wid = 0.05;	/* width of base */

  double hr_len = 0.5;		/* length of hour hand */
  double hr_wid = 0.2;		/* width of base */

  double qh_tick = 0.85;	/* inner r of quarter hour ticks */
  double hr_tick = 0.95;	/* inner r of hourly ticks */
  double m_tick = 0.98;		/* inner r of minute ticks */

  ps = 0;
  debug = 0;
  npt = 0;
  scale = 1.;
  offset = 0.;

  a_point p_end = { -1, 0., 0. };

  for( int i=1; i<argc; i++) {
    if( *argv[i] == '-') {
      switch( toupper( argv[i][1])) {
      case 'D':
	debug = 1;
	break;
      case 'P':
	ps = 1;
	break;
      case 'S':
	++i;
	scale = strtoul( argv[i], NULL, 0);
	break;
      case 'O':
	++i;
	offset = strtoul( argv[i], NULL, 0);
      default:
	break;
      }
    } else {
      ;
    }
  }

  // initialized the output
  if( ps) {
    printf("%%!PS-Adobe-2.0\n");
    printf("newpath\n");
    // letter paper is 612 x 792
    offset = 612.0/2.0;
    scale = 300.0;
  } else {
    npt = 0;
    if( scale == 1.) {
      scale = 0x180;
      offset = 0;
    }
  }

  // draw tics
  // first the quarter hours
  for( int i=0; i<=45; i+=15)
    draw_tick( i, qh_tick, 1.);
  // now the hours
  for( int i=5; i<=55; i+=5)
    draw_tick( i, hr_tick, 1.);
//  // now the minutes
//  for( int i=0; i<=59; i++)
//    draw_tick( i, m_tick, 1.);

  // draw example hands
  draw_hand( 15, sec_wid, sec_len);
  draw_hand( 0, min_wid, min_len);
  draw_hand( 45, hr_wid, hr_len);

  print_point( p_end);

  if( ps) {
    printf("stroke\n");
    printf("showpage\n");
  } else {
    printf("\tDB 0ffh\n");
  }

}


