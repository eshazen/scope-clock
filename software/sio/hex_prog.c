//
// read an Intel MDS (hex) file and send to cheezy Arduino programmer
// as "w <addr> <data>" commands
//
// usage:  hex_load <file.hex> {P|V|F}
//           P - program and check each byte
//           V - verify entire file
//           F - fix incorrect bytes
//           D - read debug loop
//
// Use new "fast" protocol programmer which understands commands like
//   B 1000 cd 10 10 ab cd ef gh      (up to 16 bytes)
//   Replies with "OK" or "error"
//
//

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
  char obuf[255];
  char tmp[10];
  char *s;
  int fd;
  FILE *fhex;
  int check = 0;
  int prog = 0;
  int fix = 0;
  int debug = 0;

  int errz = 0;

  printf("Ready?  hit <CR>");
  fgets( buff, 10, stdin);

  s = sio_cmd( fd, "");

  if( (fd = sio_open("/dev/ttyACM0", B4800)) < 0) {
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

	sprintf( obuf, "B %04x", addr);

	for( int i=0; i<count; i++) {
	  uint8_t dat = g2hex( buff+9+2*i);
	  sprintf( tmp, " %02x", dat);
	  strcat( obuf, tmp);
	}

	printf("Send: %s\n", obuf);
	s = sio_cmd( fd, obuf);
	dump_string( s);
	
	if( strstr( s, "error")) {
	  printf("Error, aborting for now\n");
	  exit( 1);
	} else if( !strstr( s, "OK")) {
	  printf("Unknown response: %s\n", s);
	  exit( 1);
	}

      } else {
	printf("(ignored)\n");
      }
    }
  }

  close( fd);

  printf("%d total errors\n", errz);
}
