//
// parts for clock tables
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
  scale = 0x180;
  offset = 0x400;

  a_point p_end = { -1, 0., 0. };

  for( int i=1; i<argc; i++) {
    if( *argv[i] == '-') {
      switch( toupper( argv[i][1])) {
      case 'D':
	debug = 1;
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

  npt = 0;

  printf(";----- auto-generated clock display tables -----\n");
  printf("clock_tics:\n");

  // draw tics
  // first the quarter hours
  for( int i=0; i<=45; i+=15)
    draw_tick( i, qh_tick, 1.);
  // now the hours
  for( int i=5; i<=55; i+=5)
    draw_tick( i, hr_tick, 1.);
  print_point( p_end);
  printf("\tDB 0ffh\n");

  // second hands
  printf(";----- second hand, 60 positions -----\n");
  printf("clock_seconds:\n");
  for( int s=0; s<60; s++) {
    printf("sec_hand_%02d:\n", s);
    draw_hand( s, sec_wid, sec_len);
    print_point( p_end);
    printf("\tDB 0ffh\n");
  }

  // minute hands
  printf(";----- minute hand, 60 positions -----\n");
  printf("clock_minutes:\n");
  for( int s=0; s<60; s++) {
    printf("min_hand_%02d:\n", s);
    draw_hand( s, min_wid, min_len);
    print_point( p_end);
    printf("\tDB 0ffh\n");
  }

  // hour hands
  printf(";----- hour hand, 60 positions -----\n");
  printf("clock_hours:\n");
  for( int s=0; s<60; s++) {
    printf("hr_hand_%02d:\n", s);
    draw_hand( s, hr_wid, hr_len);
    print_point( p_end);
    printf("\tDB 0ffh\n");
  }

  // handy table of sizes
  printf("sec_hand_size equ (sec_hand_01-sec_hand_00)\n");
  printf("min_hand_size equ (min_hand_01-min_hand_00)\n");
  printf("hr_hand_size equ (hr_hand_01-hr_hand_00)\n");


}


