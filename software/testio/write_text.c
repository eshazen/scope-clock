// #define DEBUG

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "hershey.h"

// center for X/Y
#define CENTR 0x800
// maximum deflection
#define DEFL 0x200

#define LEFT (CENTR-DEFL)

// scale
#define SCAL 10

void draw( int x, int y, int cx, int cy);

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

  for( int i=0; i<strlen( text); i++) {
    int c = text[i]-32;		/* character index */
    int nv = simplex[c][0];	/* number of verteces */
    int cw = simplex[c][1];	/* text width */
#ifdef DEBUG    
    printf("; char = '%c' (%d) with %d verteces width %d\n", text[i], text[i], nv, cw);
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
	  draw( x, y, cx, cy);
	} else {
	  // penup
	  ;
	}
      }
    }
    x += cw*SCAL;
  }
  
  printf("\tDB 0ffh\n");
}


// emit a vector
void draw( int x, int y, int cx, int cy)
{
  printf("\tDW %04xH, %04xH\n", x+cx*SCAL, y+cy*SCAL);
}
