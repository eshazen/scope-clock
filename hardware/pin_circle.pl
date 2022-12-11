#!/usr/bin/perl
#
# make a circle of pins
# substitute in KiCAD v6 footprint
#
use Math::Trig;

my $npin = 14;
my $r = (1.75/2) * 25.4;

my $mirr_y = -1;		# mirror Y - needed for KiCAD
my $mirr_x = -1;		# mirror X - needed for bottom view

my $dir = -1;


my $dt = (2*pi)/$npin;

my $pin1 = $dt*3;

my %pins;

my $t = $pin1;

for( my $i=0; $i<$npin; $i++) {
    my $x = $mirr_x * cos( $t) * $r;
    my $y = $mirr_y * sin( $t) * $r;
    $pins{$i+1} = sprintf "(at %6.3f %6.3f)", $x, $y;
    $t += $dt * $dir;
}

while( my $line = <>) {
    chomp $line;
    if( $line =~ /\(pad /) {
	my ($pin) = $line =~ /\(pad "(\d+)"/;
	if( $pins{$pin}) {
	    my $at = $pins{$pin};
	    $line =~ s/\(at [^)]+\)/$at/;
	} else {
	    die "Couldn't find pin $pin\n";
	}
    }
    print "$line\n";
}
