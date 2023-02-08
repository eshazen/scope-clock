// #define DEBUG

// rotate 180 degrees, (invert X and Y)
#define FLIP

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "hershey.h"

// center for X/Y
#define CENTR 0x800
// maximum deflection
#define DEFL 0x200

#define LEFT (CENTR-DEFL)
#define RIGHT (CENTR+DEFL)

// scale
#define SCAL 7

void draw( int x, int y, int cx, int cy, int do_draw);

int nvert = 0;			/* total vertex count */

int main( int argc, char *argv[]) {
  if( argc < 2) {
    printf("usage:  write_text <text> [options]\n");
    exit(1);
  }

  int linesp = 32;		/* line spacing */
  char *text = argv[1];
  int x = LEFT;
  int y = CENTR;

  // count the vertexes
  for( int i=0; i<strlen( text); i++) {
    int c = text[i]-32;		/* character index */
    int nv = simplex[c][0];	/* number of verteces */
    if( nv) {
      // draw all the vectors (ignore penup for now)
      for( int k=0; k<nv; k++) {
	int cx = simplex[c][2+2*k];
	int cy = simplex[c][3+2*k];
	if( cx >= 0 && cy >= 0) {
	  nvert++;
	}
      }
    }
  }

  printf( "; %d verteces\n", nvert);
  if( nvert > 63) {
    printf ("; Too many!\n");
  }
  printf( "\tDB %d\n", nvert*4);

  int do_draw;

  for( int i=0; i<strlen( text); i++) {
    do_draw = 0;
    int c = text[i]-32;		/* character index */
    int nv = simplex[c][0];	/* number of verteces */
    int cw = simplex[c][1];	/* text width */
#ifdef DEBUG    
    printf("; char = '%c' (%d) with %d vertices width %d\n", text[i], text[i], nv, cw);
#endif
    if( nv) {
      // draw all the vectors (ignore penup for now)
      for( int k=0; k<nv; k++) {
	int cx = simplex[c][2+2*k];
	int cy = simplex[c][3+2*k];
#ifdef DEBUG
	printf("; vector %d (%d, %d)\n", k, cx, cy);
#endif
	if( cx >= 0 && cy >= 0) {
	  draw( x, y, cx, cy, do_draw);
	  do_draw = 1;
	} else {
	  do_draw = 0;
	}
      }
    }
    x += cw*SCAL;
  }
  
  printf("\tDB 0ffh\n");
}


// emit a vector
void draw( int x, int y, int cx, int cy, int do_draw)
{
  unsigned int xc = RIGHT-(x+cx*SCAL);
  unsigned int yc = RIGHT-(y+cy*SCAL);

  if( do_draw)
    xc |= 0x8000;
  
  printf("\tDW %04xH, %04xH  ; %s\n", xc, yc, do_draw ? "draw" : "move");
}
