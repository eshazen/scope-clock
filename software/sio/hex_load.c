//
// read an Intel MDS (hex) file and send to cheezy Arduino programmer
// as "w <addr> <data>" commands
//
// usage:  hex_load <file.hex> {P|V|F}
//           P - program and check each byte
//           V - verify entire file
//           F - fix incorrect bytes
//           D - read debug loop

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <unistd.h>
#include <ctype.h>

#include "sio_cmd.h"


// read from eeprom
uint8_t ee_read( int fd, uint16_t addr) {
  char *s;
  char buff[255];
  
  sprintf( buff, "r %d\n", addr);
  s = sio_cmd( fd, buff);

  char *p = rindex( s, '=');
  int rdat;
  sscanf( p+2, "%x", &rdat);
  return rdat & 0xff;
}


// write to eeprom
void ee_write( int fd, uint16_t addr, uint8_t dat) {
  char *s;
  char buff[255];
  
  sprintf(buff, "w %d 0x%02x\n", addr, dat);
  s = sio_cmd( fd, buff);
}



// parse two hex digits as a byte
uint8_t g2hex( char *s) {
  char tmp[8];
  strcpy( tmp, "0x");
  tmp[2] = s[0];
  tmp[3] = s[1];
  tmp[4] = '\0';
  return strtoul( tmp, NULL, 0);
}

int main( int argc, char*argv[] )
{
  char buff[255];
  char *s;
  int fd;
  FILE *fhex;
  int check = 0;
  int prog = 0;
  int fix = 0;
  int debug = 0;

  int errz = 0;

  if( argc > 2) {
    switch( toupper( *argv[2])) {
    case 'D':
      printf("debug loop\n");
      debug = 1;
      break;
    case 'P':
      prog = 1;
      check = 1;
      printf("program and verify\n");
      break;
    case 'V':
      check = 1;
      printf("Verify only\n");
      break;
    case 'F':
      fix = 1;
      check = 1;
      printf("Try to fix errors\n");
      break;
    default:
      printf("Usage:  hex_load <file> {P|V|F}\n");
      exit(1);
    }
  }  

  printf("Ready?  hit <CR>");
  fgets( buff, 10, stdin);

  if( (fd = sio_open("/dev/ttyACM0", B9600)) < 0) {
    printf("Error opening serial port\n");
    exit( 1);
  }

  if( (fhex = fopen( argv[1], "r")) == NULL) {
    printf("Error opening hex file %s\n", argv[1]);
    exit(1);
  }

  if( debug) {
    uint16_t addr;
    int rdat;
    while(1) {
      rdat = ee_read( fd, addr);
      ++addr;
    }
      
  }

  while( fgets( buff, 255, fhex) != NULL) {
    if( *buff == ':') {
      uint8_t count = g2hex( buff+1);
      uint8_t lo, hi;
      uint16_t addr;
      hi = g2hex( buff+3);
      lo = g2hex( buff+5);
      addr = (hi << 8) | lo;
      uint8_t type = g2hex( buff+7);
      printf("Count: %02x addr=%04x type=%02x\n",
	     count, addr, type);
      if( type == 0) {
	for( int i=0; i<count; i++) {
#ifdef DEBUG
	  printf("loop %d addr 0x%x\n", i, addr);
#endif
	  uint8_t dat = g2hex( buff+9+2*i);
	  int rdat;
	
	  // program if not only checking
	  if( prog)
	    ee_write( fd, addr, dat);

	  // check no matter what
	  rdat = ee_read( fd, addr);

	  if( dat != rdat) {
	    printf("Error at %d read 0x%x expected 0x%x\n", addr, rdat, dat);
	    ++errz;

	    if( fix) {
	      printf("Trying to re-program...");
	      ee_write( fd, addr, dat);
	      rdat = ee_read( fd, addr);
	    
	      if( dat != rdat)
		printf("Failed to fix error\n");
	      else
		printf("OK now\n");

	    }

	  } else {
	    printf("%04x %02x\n", addr, dat);
	  }

	  ++addr;
	}
      } else {
	printf("(ignored)\n");
      }
    }
  }

  close( fd);

  printf("%d total errors\n", errz);
}
