//
// read an Intel MDS (hex) file and send to simple loader
// as ":ababab;" string
//
// usage:  hex_load <file.hex>
//

// #define DEBUG

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

void send( char ch) {
  char sch;

#ifdef DEBUG
  printf("Send: '%c'\n", ch);
#endif  

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


void expect( char ch) {
  char rch;
  int res;
  
  do {
    res = read( fd, &rch, 1);
  } while( res != 1);

  if( rch != ch) {
    printf("Error, expected %c, got %c\n", ch, rch);
    exit( 1);
  }
}

int main( int argc, char*argv[] )
{
  char buff[255];
  FILE *fhex;
  char ch;
  int first = 1;
  
  printf("Ready?  hit <CR>");
  fgets( buff, 10, stdin);

  if( (fd = sio_open("/dev/ttyUSB0", B1200)) < 0) {
    printf("Error opening serial port\n");
    exit( 1);
  }

  if( (fhex = fopen( argv[1], "r")) == NULL) {
    printf("Error opening hex file %s\n", argv[1]);
    exit(1);
  }

  flush();

  send( ':');			/* send start */
  expect( ':');
  expect( '>');

  while( fgets( buff, 255, fhex) != NULL) {
    if( *buff == ':') {
      uint8_t count = g2hex( buff+1);
      uint8_t lo, hi;
      hi = g2hex( buff+3);
      lo = g2hex( buff+5);
      uint16_t addr = (hi << 8) | lo;
      uint8_t type = g2hex( buff+7);
      printf("Count: %02x addr=%04x type=%02x\n",
	     count, addr, type);
      if( type == 0) {
	if( first) {
	  if( addr != LOAD) {
	    printf("Error:  file doesn't start at 0x8100\n");
	    exit( 1);
	  } else {
	    printf("Load point 0x%x confirmed\n", LOAD);
	    first = 0;
	  }
	}
	for( int i=0; i<count; i++) {
	  uint8_t dat = g2hex( buff+9+2*i);
	
	  // send byte dat
	  sprintf( buff, "%02X", dat);
	  send( buff[0]);
	  expect( buff[0]);
	  send( buff[1]);
	  expect( buff[1]);
	  expect( '>');

	  ++addr;
	}
      } else if( type == 1) {
	printf("Ready to start?  hit <CR>");
	fgets( buff, 10, stdin);

	send( ';');
	expect( ';');
	
      } else {
	printf("Unknown record type 0x%02x\n", type);
      }
    }
  }  


  close( fd);

}
