#! perl -w

use lib '.','./t','./lib','../lib';
# can run from here or distribution base
require 5.004;

# Before installation is performed this script should be runnable with
# `perl test7.t time' which pauses `time' seconds (0..5) between pages

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..88\n"; }
END {print "not ok 1\n" unless $loaded;}
use Win32::SerialPort 0.14;
use Win32;
require "DefaultPort.pm";
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

# assume a "vanilla" port on "COM1"

use strict;

my $tc = 2;		# next test number

sub is_ok {
    my $result = shift;
    printf (($result ? "" : "not ")."ok %d\n",$tc++);
    return $result;
}

sub is_zero {
    my $result = shift;
    if (defined $result) {
        return is_ok ($result == 0);
    }
    else {
        printf ("not ok %d\n",$tc++);
    }
}

sub is_bad {
    my $result = shift;
    printf (($result ? "not " : "")."ok %d\n",$tc++);
    return (not $result);
}

my $file = "COM1";
if ($SerialJunk::Makefile_Test_Port) {
    $file = $SerialJunk::Makefile_Test_Port;
}
if (exists $ENV{Makefile_Test_Port}) {
    $file = $ENV{Makefile_Test_Port};
}

my $naptime = 0;	# pause between output pages
if (@ARGV) {
    $naptime = shift @ARGV;
    unless ($naptime =~ /^[0-5]$/) {
	die "Usage: perl test?.t [ page_delay (0..5) ] [ COMx ]";
    }
}
if (@ARGV) {
    $file = shift @ARGV;
}
my $cfgfile = $file."_test.cfg";

my $e="testing is a wonderful thing - this is a 60 byte long string";
#      123456789012345678901234567890123456789012345678901234567890
my $line = $e.$e.$e;		# about 185 MS at 9600 baud

my $fault = 0;
my $ob;
my $pass;
my $fail;
my $match;
my $left;
my @opts;
my $patt;
my $err;
my $blk;
my $tick;
my $tock;
my @necessary_param = Win32::SerialPort->set_test_mode_active(1);

## 2: Open as Tie using File 

    # constructor = TIEHANDLE method		# 2
unless (is_ok ($ob = tie(*PORT,'Win32::SerialPort', $cfgfile))) {
    printf "could not reopen port from $cfgfile\n";
    exit 1;
    # next test would die at runtime without $ob
}

### 3 - 20: Defaults for stty and lookfor

@opts = $ob->are_match("\n");
is_ok ($#opts == 0);				# 3
is_ok ($opts[0] eq "\n");			# 4
is_ok ($ob->lookclear == 1);			# 5
is_ok ($ob->is_prompt("") eq "");		# 6
is_ok ($ob->lookfor eq "");			# 7
is_ok ($ob->streamline eq "");			# 8

($pass, $fail, $patt, $err) = $ob->lastlook;
is_ok ($pass eq "");				# 9
is_ok ($fail eq "");				# 10
is_ok ($patt eq "");				# 11
is_ok ($err eq "");				# 12
is_ok ($ob->matchclear eq "");			# 13

is_ok("none" eq $ob->handshake("none"));	# 14
is_ok(0 == $ob->stty_onlcr(0));			# 15

is_ok(0 == $ob->read_char_time(0));		# 16
is_ok(1000 == $ob->read_const_time(1000));	# 17
is_ok(0 == $ob->read_interval(0));		# 18
is_ok(0 == $ob->write_char_time(0));		# 19
is_ok(2000 == $ob->write_const_time(2000));	# 20

    # tie to PRINT method
$tick=$ob->get_tick_count;
$pass=print PORT $line;
is_zero($^E);					# 21
$tock=$ob->get_tick_count;

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok($pass == 1);				# 22
$err=$tock - $tick;
is_bad (($err < 160) or ($err > 210));		# 23
print "<185> elapsed time=$err\n";

    # tie to READLINE method
$tick=$ob->get_tick_count;
$fail = <PORT>;
is_ok($^E == 1121);				# 24
$tock=$ob->get_tick_count;

is_bad(defined $fail);				# 25
$err=$tock - $tick;
is_bad (($err < 800) or ($err > 1200));		# 26
print "<1000> elapsed time=$err\n";

$tick=$ob->get_tick_count;
@opts = <PORT>;
is_ok($^E == 1121);				# 27
$tock=$ob->get_tick_count;

is_bad(@opts);					# 28
$err=$tock - $tick;
is_bad (($err < 800) or ($err > 1200));		# 29
print "<1000> elapsed time=$err\n";

    # tie to PRINTF method
$tick=$ob->get_tick_count;
$pass=printf PORT "123456789_%s_987654321", $line;
is_zero($^E);					# 30
$tock=$ob->get_tick_count;

is_ok($pass == 1);				# 31
$err=$tock - $tick;
is_bad (($err < 180) or ($err > 235));		# 32
print "<205> elapsed time=$err\n";

    # tie to GETC method
$tick=$ob->get_tick_count;
$fail = getc PORT;
is_ok($^E);					# 33
$tock=$ob->get_tick_count;

is_bad(defined $fail);				# 34
$err=$tock - $tick;
is_bad (($err < 800) or ($err > 1200));		# 35
print "<1000> elapsed time=$err\n";

    # tie to WRITE method
$tick=$ob->get_tick_count;
if ( $] < 5.005 ) {
    $pass=print PORT $line;
    is_ok($pass == 1);				# 36
}
else {
    $pass=syswrite PORT, $line, length($line), 0;
    is_ok($pass == 180);			# 36
}
is_zero($^E);					# 37
$tock=$ob->get_tick_count;

$err=$tock - $tick;
is_bad (($err < 160) or ($err > 210));		# 38
print "<185> elapsed time=$err\n";

    # tie to READ method
my $in = "1234567890";
$tick=$ob->get_tick_count;
$fail = sysread (PORT, $in, 5, 0);
is_ok($^E);					# 39
$tock=$ob->get_tick_count;

is_bad(defined $fail);				# 40
$err=$tock - $tick;
is_bad (($err < 800) or ($err > 1200));		# 41
print "<1000> elapsed time=$err\n";

    # READLINE hardware errors
($blk, $pass, $fail, $err)=$ob->is_status(0x8);	# test only
$tick=$ob->get_tick_count;
$fail = <PORT>;
$tock=$ob->get_tick_count;
is_ok($^E == 1117);				# 42
is_bad(defined $fail);				# 43
$err=$tock - $tick;
is_bad ($err > 100);				# 44
print "<0> elapsed time=$err\n";
is_ok ($ob->reset_error == 0);			# 45

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

($blk, $pass, $fail, $err)=$ob->is_status(0x8);	# test only
$tick=$ob->get_tick_count;
@opts = <PORT>;
$tock=$ob->get_tick_count;
is_ok($^E == 1117);				# 46
is_bad(@opts);					# 47
$err=$tock - $tick;
is_bad ($err > 100);				# 48
print "<0> elapsed time=$err\n";
is_zero ($ob->reset_error);			# 49

    # READLINE data processing
is_ok ($ob->linesize == 1);			# 50
is_zero ($ob->linesize(0));			# 51
is_ok ($ob->lookclear("First\nSecond\n\nFourth\nLast Line\nEND") == 1);	# 52

$tick=$ob->get_tick_count;
$pass = <PORT>;
$tock=$ob->get_tick_count;
is_zero($^E);					# 53
is_ok($pass eq "First\n");			# 54
$err=$tock - $tick;
is_bad ($err > 100);				# 55
print "<0> elapsed time=$err\n";

is_ok ($ob->lastline("Last L..e") eq "Last L..e");	# 56
$tick=$ob->get_tick_count;
@opts = <PORT>;
$tock=$ob->get_tick_count;
is_zero($^E);					# 57
is_ok($#opts == 3);				# 58
is_ok($opts[0] eq "Second\n");			# 59
is_ok($opts[1] eq "\n");			# 60
is_ok($opts[2] eq "Fourth\n");			# 61
is_ok($opts[3] eq "Last Line\n");		# 62

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

($pass, $fail, $patt, $err) = $ob->lastlook;
is_ok ($pass eq "");				# 63
is_ok ($fail eq "END");				# 64
is_ok ($patt eq "\n");				# 65
is_ok ($err eq "");				# 66
is_ok ($ob->matchclear eq "");			# 67

    # preload and do three lines non-blocking
is_ok ($ob->lookclear("One\n\nThree\nFour\nLast Line\nplus") == 1);	# 68
$tick=$ob->get_tick_count;
$pass = <PORT>;
$tock=$ob->get_tick_count;
is_zero($^E);					# 69
is_ok($pass eq "One\n");			# 70
$err=$tock - $tick;
is_bad ($err > 100);				# 71
print "<0> elapsed time=$err\n";

$pass = <PORT>;
is_ok($pass eq "\n");				# 72
($pass, $fail, $patt, $err) = $ob->lastlook;
is_ok ($pass eq "");				# 73
is_ok ($fail eq "Three\nFour\nLast Line\nplus");	# 74
is_ok ($patt eq "\n");				# 75

$pass = <PORT>;
is_ok($pass eq "Three\n");			# 76
($pass, $fail, $patt, $err) = $ob->lastlook;
is_ok ($pass eq "");				# 77
is_ok ($fail eq "Four\nLast Line\nplus");	# 78
is_ok ($patt eq "\n");				# 79

    # switch back to blocking reads
is_ok ($ob->linesize(1) == 1);			# 80
$tick=$ob->get_tick_count;
$pass = <PORT>;
$tock=$ob->get_tick_count;
is_ok($^E == 1121);				# 81
$err=$tock - $tick;
is_bad (($err < 800) or ($err > 1200));		# 82
print "<1000> elapsed time=$err\n";

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_bad($pass);					# 83
($pass, $fail, $patt, $err) = $ob->lastlook;
is_ok ($pass eq "");				# 84
is_ok ($fail eq "Four\nLast Line\nplus");	# 85
is_ok ($patt eq "");				# 86
is_ok ($err eq "");				# 87

    # destructor = CLOSE method
if ( $] < 5.005 ) {
    is_ok($ob->close);				# 88
}
else {
    is_ok(close PORT);				# 88
}

    # destructor = DESTROY method
undef $ob;					# Don't forget this one!!
untie *PORT;
