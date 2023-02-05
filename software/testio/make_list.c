//
// generate a circle
//
#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <math.h>

#define OFF 0x800

#define PI 3.14159

int main( int argc, char *argv[])
{
  double a;
  int16_t ix, iy;
  double r = 0x100;
  int step = 12;

  if( argc > 1)
    r = atof( argv[1]);

  if( argc > 2)
    step = strtoul( argv[2], NULL, 0);

  a = 0;

  printf( "\tdb %03xH\n", step*4);

  for( int i=0; i<step; i++) {
    ix = (double)sin(a)*r + OFF;
    iy = (double)cos(a)*r + OFF;
    // printf( "%d, %d\n", ix, iy);
    printf( "\tdw %04xH, %04xH\n", ix, iy);
    a += (2.0*PI)/(double)step;
  }

  printf( "\tdb %03xH\n", 0xff);
}
