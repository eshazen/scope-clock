//
// test line drawing on Z80
//
// this is a test implementation of Bresingam's line drawing
// to see what a mess sdcc makes of it.
//

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <z80.h>

void plot( int16_t x, int16_t y) {
  z80_outp( 0x41, x);
  z80_outp( 0x42, y);
}

void line2( int16_t x0, int16_t y0, int16_t x1, int16_t y1) {

  int16_t dx, dy, sx, sy, error, e2;

  dx = abs(x1 - x0);
  sx = x0 < x1 ? 1 : -1;
  dy = -abs(y1 - y0);
  sy = y0 < y1 ? 1 : -1;
  error = dx + dy;

  //  printf("(%d,%d) - (%d,%d)\n", x0, y0, x1, y1);
  //  printf("DX=%d  SX=%d  DY=%d  SY=%d  error=%d\n", dx, dy, sx, sy, error);

  //  printf("%4s %4s  %4s %4s\n", "x0", "y0", "err", "e2");

  while(1) {

    //    printf("%4d %4d  %4d %4d\n", x0, y0, error, e2);

    plot( x0, y0);
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


int main( ) {

  int16_t x0, y0, x1, y1;

  x0 = z80_inp(0x40);
  y0 = z80_inp(0x41);
    x1 = z80_inp(0x42);
  y1 = z80_inp(0x43);

  line2( x0, y0, x1, y1);

  return 0;
}

