#!/usr/bin/perl
#---------------------------------------------------------------------------
#  Title:
#      Cross-Platform Demo - "use" right module on either Win32 or linux
#  Usage:
#      perl any_os.plx PORT
#  Author:
#      Bruce Winter    brucewinter@home.net  http://members.home.net/winters
#---------------------------------------------------------------------------

# must be LF-only line ends to run on both platforms

use strict;
use vars qw($OS_win);

BEGIN {
        $OS_win = ($^O eq "MSWin32") ? 1 : 0;

        print "Perl version: $]\n";
        print "OS   version: $^O\n";

            # This must be in a BEGIN in order for the 'use' to be conditional
        if ($OS_win) {
            print "Loading Windows module\n";
            eval "use Win32::SerialPort";
	    die "$@\n" if ($@);

        }
        else {
            print "Loading Unix module\n";
            eval "use Device::SerialPort";
	    die "$@\n" if ($@);
        }
} # End BEGIN

die "\nUsage: perl any_os.plx PORT\n" unless (@ARGV);
my $port = shift @ARGV;

my $serial_port; 

if ($OS_win) {
    $serial_port = Win32::SerialPort->new ($port,1);
}
else {
    $serial_port = Device::SerialPort->new ($port,1);
}
die "Can't open serial port $port: $^E\n" unless ($serial_port);

my $baud = $serial_port->baudrate;
print "\nopened serial port $port at $baud baud\n";

$serial_port->close || die "\nclose problem with $port\n";
undef $serial_port;
