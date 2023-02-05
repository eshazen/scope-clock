/*
 * text2vec.c - convert an ASCII string to vectors
 *   output is a list of vectors in normalized -1..+1 space
 *
 * nv = text2vec( char* s, a_point *list, double scale)
 *     convert character string s to list of vectors
 *     scale is the height of one character
 *     return number of vectors required
 *     store in list (NULL to just count vectors)
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "hershey.h"
#include "text2vec.h"

int text2vec( char* s, a_point *list, double scale, double x0, double y0)
{
  a_point *p = list;
  int draw = 0;			/* start with move */
  int npt = 0;			/* count points */
  double x=x0*scale;
  double y=y0*scale;
  for( int i=0; i<strlen( s); i++) {
    draw = 0;
    if( s[i] < 32) {
      // process control characters (later!)
    } else {
      int c = s[i]-32;		/* character index */
      int nv = simplex[c][0];	/* number of verteces */
      int cw = simplex[c][1];	/* character width */
      if( nv) {
	// draw all the vectors
	for( int k=0; k<nv; k++) {
	  int cx = simplex[c][2+2*k];
	  int cy = simplex[c][3+2*k];

	  if( cx >= 0 && cy >= 0) {
	    if( p != NULL) {
	      p->x = x+cx/HERSHEY_MAX*scale;
	      p->y = y+cy/HERSHEY_MAX*scale;
	      p->draw = draw;
	      ++p;
	      draw = 1;
	    }
	    ++npt;
	  } else {
	    draw = 0;
	  }
	}
      }
      x += cw/HERSHEY_MAX*scale;
    }
  }
  return npt;

}

