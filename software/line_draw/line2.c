#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

void plot( int16_t x, int16_t y) {
  printf("%5d, %5d\n", x, y);
}

void line2( int16_t x0, int16_t y0, int16_t x1, int16_t y1) {

  int16_t dx, dy, sx, sy, error, e2;

  dx = abs(x1 - x0);
  sx = x0 < x1 ? 1 : -1;
  dy = -abs(y1 - y0);
  sy = y0 < y1 ? 1 : -1;
  error = dx + dy;

  printf("(%d,%d) - (%d,%d)\n", x0, y0, x1, y1);
  printf("DX=%d  SX=%d  DY=%d  SY=%d  error=%d\n", dx, dy, sx, sy, error);

  printf("%4s %4s  %4s %4s\n", "x0", "y0", "err", "e2");

  while(1) {

    printf("%4d %4d  %4d %4d\n", x0, y0, error, e2);

    //    plot( x0, y0);
    if( x0 == x1 && y0 == y1) break;
    e2 = 2 * error;
    if( e2 >= dy) {
      if( x0 == x1) break;
      error += dy;
      x0 += sx;
    }
    if( e2 <= dx) {
      if( y0 == y1) break;
      error += dx;
      y0 += sy;
    }
  }

}


int main( int argc,  char *argv[]) {

  int16_t x0, y0, x1, y1;

  x0 = strtoul( argv[1], NULL, 0);
  y0 = strtoul( argv[2], NULL, 0);
  x1 = strtoul( argv[3], NULL, 0);
  y1 = strtoul( argv[4], NULL, 0);

  line2( x0, y0, x1, y1);
}
