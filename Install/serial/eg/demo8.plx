#!perl -w
#
# Simple command-line terminal emulator
# by Andrej Mikus
# with small modifications by Bill Birthisel
# no local echo at either end
#
require 5.005;	# for select
use Win32::SerialPort 0.14;
use Term::ReadKey;

use strict;

my $cfgfile = "COM1_test.cfg";
my $ob = Win32::SerialPort->start ($cfgfile) or die "Can't start $cfgfile\n";
    # next test will die at runtime unless $ob


### setup for dumb terminal, your mileage may vary
$ob->stty_icrnl(1);
$ob->stty_ocrnl(1);
$ob->stty_onlcr(1);
$ob->stty_opost(1);
###

my $c;
my $p1 = "Simple Terminal Emulator\n";
$p1 .= "Type CAPITAL Q to quit\n\n";
print $p1;
$p1 =~ s/\n/\r\n/ogs if ($ob->stty_opost && $ob->stty_onlcr);
$ob->write ($p1);

for ( ;; ) {
    if ( $c = $ob -> input ) {
	$c =~ s/\r/\n/ogs if ($ob->stty_icrnl);
	print $c;
	last if $c =~ /Q/;
    }
        
    if ( defined ( $c = ReadKey ( -1 ) ) ) {
	$c =~ s/\r/\n/ogs if ($ob->stty_ocrnl);
	$c =~ s/\n/\r\n/ogs if ($ob->stty_opost && $ob->stty_onlcr);
        $ob -> write ( $c );
	last if $c eq 'Q';
    }
    select undef, undef, undef, 0.2; # traditional 5/sec.
}

$ob -> close or die "Close failed: $!\n";
undef $ob;  # closes port AND frees memory in perl
