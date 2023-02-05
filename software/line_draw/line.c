#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

void plot( int16_t x, int16_t y) {
  printf("%5d, %5d\n", x, y);
}

void line( int16_t x0, int16_t y0, int16_t x1, int16_t y1) {

  int16_t dx, dy, D, y;

  dx = x1 - x0;
  dy = y1 - y0;
  D = 2*dy - dx;
  y = y0;

  for( int16_t x=x0; x<=x1; x++) {
    //    plot( x, y);
    printf("%5d %5d %d\n", x, y, D);
    if( D > 0) {
      y = y + 1;
      D = D - 2*dx;
    }
    D = D + 2*dy;
  }

}


int main( int argc,  char *argv[]) {

  int16_t x0, y0, x1, y1;

  x0 = strtoul( argv[1], NULL, 0);
  y0 = strtoul( argv[2], NULL, 0);
  x1 = strtoul( argv[3], NULL, 0);
  y1 = strtoul( argv[4], NULL, 0);

  line( x0, y0, x1, y1);
}
