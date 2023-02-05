#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>

#include "text2vec.h"

int main( int argc, char *argv[]) {
  a_point *p;
  int nv;
  char *str;
  double scale = 1.0;
  int ps = 0;

  double x0 = 0.25;
  double y0 = 0.25;

  if( argc < 2) {
    printf("usage: test_vec [options] <text>\n");
    exit(1 );
  }

  for( int i=1; i<argc; i++) {
    if( *argv[i] == '-') {
      switch( toupper( argv[i][1])) {
      case 'P':
	printf("%%!PS-Adobe-2.0\n");
	ps = 1;
	break;
      case 'S':
	++i;
	scale = atof( argv[i]);
	break;
      default:
	break;
      }
    } else {
      str = argv[i];
    }
  }

  nv = text2vec( argv[1], NULL, scale, x0, y0);
  printf("%% %d vectors used\n", nv);

  p = calloc( nv, sizeof(a_point));

  nv = text2vec( argv[1], p, scale, x0, y0);

  if( ps)
    printf("newpath\n");

  for( int i=0; i<nv; i++) {
    if( ps) {
      if( p[i].draw)
	printf("%f %f lineto\n", p[i].x, p[i].y);
      else
	printf("%f %f moveto\n", p[i].x, p[i].y);
    } else {
      printf("; %d %f %f\n", p[i].draw, p[i].x, p[i].y);
    }
  }

  if( ps) {
    printf("stroke\n");
    printf("showpage\n");
  }
}
