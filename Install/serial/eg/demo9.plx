#! perl -w

use lib './lib','../lib';
use Win32::SerialPort 0.19;

use strict;

my $ob = Win32::SerialPort->new ("COM1");
die "could not open port $^E\n" unless ($ob);

Win32::SerialPort::debug(1);
$ob->close;
undef $ob;
