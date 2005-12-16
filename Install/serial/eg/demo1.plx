#! perl -w

######################### We start with some black magic to print on failure.

BEGIN { $| = 1; print "demo1.plx loaded "; }
END {print "not ok 1\n" unless $loaded;}
use Win32::SerialPort 0.06;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# starts configuration created by test1.pl

package COM1demo1;
use strict;

my $file = "COM1";
my $cfgfile = $file."_test.cfg";
my $tc = 2;		# next test number
my $ob;
my $pass;
my $fail;
my $in;
my $in2;
my @opts;
my $out;
my $loc;
my $e;
my $tick;
my $tock;
my @necessary_param = Win32::SerialPort->set_test_mode_active;

# 2: Constructor

$ob = Win32::SerialPort->start ($cfgfile) or die "Can't start $cfgfile\n";
    # next test will die at runtime unless $ob

# 3: Prints Prompts to Port and Main Screen

$out= "\r\n\r\n++++++++++++++++++++++++++++++++++++++++++\r\n";
$tick= "Simple Serial Terminal with echo to STDOUT\r\n\r\n";
$tock= "type CONTROL-Z on serial terminal to quit\r\n";
$e="\r\n....Bye\r\n";

print $out, $tick, $tock;
$pass=$ob->write($out);
$pass=$ob->write($tick);
$pass=$ob->write($tock);


$ob->error_msg(1);		# use built-in error messages
$ob->user_msg(1);

$in = 1;
while ($in) {
    if (($loc = $ob->input) ne "") {
	$loc =~ s/\cM/\r\n/;
	$ob->write($loc);
	print $loc;
    }
    if ($loc =~ /\cZ/) { $in--; }
    if ($ob->reset_error) { $in--; }
}
print $e;
$pass=$ob->write($e);

sleep 1;

undef $ob;
