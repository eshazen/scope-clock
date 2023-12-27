//
// read an Intel MDS (hex) file and send to binary loader as:
// 0x91, 0x57, addr_L, addr_H
// ....data
// usage:  hex_binary <file.hex> <baud>
//   <baud> is baud rate for load or "test" for data dump
//
//

#define DEBUG

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <unistd.h>
#include <ctype.h>

#include "sio_cmd.h"

// fixed load point, error if file doesn't start here
#define LOAD 0x8100

static int fd;

// parse two hex digits as a byte
uint8_t g2hex( char *s) {
  char tmp[8];
  strcpy( tmp, "0x");
  tmp[2] = s[0];
  tmp[3] = s[1];
  tmp[4] = '\0';
  return strtoul( tmp, NULL, 0);
}

void send( unsigned char ch) {
  unsigned char sch;

  sch = ch;
  //send start char
  write( fd, &sch, 1);
}


void flush() {
  char rch;
  int res;
  
  do {
    res = read( fd, &rch, 1);
  } while( res > 0);
}


uint8_t receive() {
  int res;
  unsigned char rch;

  do {
    res = read( fd, &rch, 1);
  } while( res != 1);

  return rch;
}

void expect( unsigned char ch, char *msg) {
  uint8_t rch;

  rch = receive();
  
  if( rch != ch) {
    printf("Error, expected 0x%02x, got 0x%02x\n", ch, rch);
    printf("While sending: %s\n", msg);
    exit( 1);
  }
}

#define MAXDAT 65536

int main( int argc, char*argv[] )
{
  char buff[255];
  FILE *fhex;
  unsigned char ch;
  int first = 1;
  uint8_t data[MAXDAT];
  uint16_t first_addr;
  uint16_t last_addr;
  uint16_t size;
  speed_t baud_r;
  int yes = 0;
  int test = 0;

  if( argc < 3) {
    printf("usage:  hex_binary <file.hex> <baud>\n");
    exit(1);
  }

  if( argc >= 3)
    yes = 1;

  char *fname = argv[1];
  char *baud = argv[2];

  if( !strcmp( baud, "test"))
    test = 1;
  else if( !strcmp( baud, "1200"))
    baud_r = B1200;
  else if( !strcmp( baud, "2400"))
    baud_r = B2400;
  else if( !strcmp( baud, "4800"))
    baud_r = B4800;
  else if( !strcmp( baud, "9600"))
    baud_r = B9600;
  else if( !strcmp( baud, "19200"))
    baud_r = B19200;
  else {
    printf("Unknown baud rate.  Need 1200/2400/4800/9600\n");
    exit(1);
  }
  
  if( !yes) {
    printf("Ready?  hit <CR>");
    fgets( buff, 10, stdin);
  }

  if( !test) {
    if( (fd = sio_open("/dev/ttyUSB1", baud_r)) < 0) {
      printf("Error opening serial port\n");
      exit( 1);
    }
  }

  if( (fhex = fopen( argv[1], "r")) == NULL) {
    printf("Error opening hex file %s\n", argv[1]);
    exit(1);
  }

  if( !test)
    flush();

  // read the file, store first address and all the data
  bzero( data, MAXDAT);
  first_addr = MAXDAT-1;
  last_addr = 0;

  while( fgets( buff, 255, fhex) != NULL) {
    if( *buff == ':') {
      uint8_t count = g2hex( buff+1);
      uint8_t lo, hi;
      hi = g2hex( buff+3);
      lo = g2hex( buff+5);
      uint16_t addr = (hi << 8) | lo;
      uint8_t type = g2hex( buff+7);
      //      printf("Count: %02x addr=%04x type=%02x\n",
      //	     count, addr, type);
      if( type == 0) {
	for( int i=0; i<count; i++) {
	  uint8_t dat = g2hex( buff+9+2*i);
	  if( addr < first_addr)
	    first_addr = addr;
	  if( addr > last_addr)
	    last_addr = addr;
	  data[addr] = dat;
	  ++addr;
	}
      } else if( type == 1) {
	printf( "End of load\n");
      } else {
	printf("Unknown record type 0x%02x\n", type);
      }
    }
  }  

  size = last_addr - first_addr + 1;
  printf("%d addresses loaded from 0x%04x to 0x%04x\n", size, first_addr, last_addr);

  int i0 = 0;

  if( test) {
    printf("Dump (y/n)?");
    if( !yes)
      fgets( buff, 10, stdin);    
    else
      buff[0] = 'Y';
    if( toupper( *buff) == 'Y') {
      for( int i=first_addr; i<=last_addr; i++) {
	//	if( data[i]) {
	  if( i != i0+1 || ((i % 16) == 0))
	    printf("\n%04x ", i);
	  printf(" %02x", data[i]);
	  i0 = i;
	  //	}
      }
      printf("\n");
    }

  } else {

    do {
      send( 0x91);
      ch = receive();
      if( ch != 0x91)
	printf("expected 0x91, got 0x%02x, try again\n", ch);
    } while( ch != 0x91);

    send( 0x57);
    expect( 0x57, "57");

    send( first_addr & 0xff);
    expect( first_addr & 0xff, "addr L");

    send( (first_addr >> 8) & 0xff);
    expect( (first_addr >> 8) & 0xff, "addr H");

    send( size & 0xff);
    expect( size & 0xff, "size L");

    send( (size >> 8) & 0xff);
    expect( (size >> 8) & 0xff, "size H");

    for( uint16_t a=first_addr; a <= last_addr; a++) {
      if( (a % 0x100) == 0)
	printf("%04x\n", a);
      send( data[a]);
      expect( data[a], "data");
    }

    close( fd);
  }
}
