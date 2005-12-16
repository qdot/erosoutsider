#! perl -w

use lib '.','./t','./lib','../lib';
# can run from here or distribution base
require 5.003;

# Before installation is performed this script should be runnable with
# `perl test2.t time' which pauses `time' seconds (0..5) between pages

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..145\n"; }
END {print "not ok 1\n" unless $loaded;}
use Win32::SerialPort 0.18;
require "DefaultPort.pm";
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

# tests start using file created by test1.pl

use strict;
use Win32;

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

my $fault = 0;
my $tc = 2;		# next test number
my $ob;
my $pass;
my $fail;
my $in;
my $in2;
my @opts;
my $out;
my $blk;
my $err;
my $e;
my $tick;
my $tock;
my @necessary_param = Win32::SerialPort->set_test_mode_active(1);

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

# 2: Constructor

unless (is_ok ($ob = Win32::SerialPort->start ($cfgfile))) {
    printf "could not open port from $cfgfile\n";
    exit 1;
    # next test would die at runtime without $ob
}

#### 3 - 24: Check Port Capabilities Match Save

is_ok ($ob->xon_char == 0x11);			# 3
is_ok ($ob->xoff_char == 0x13);			# 4
is_ok ($ob->eof_char == 0);			# 5
is_ok ($ob->event_char == 0);			# 6
is_ok ($ob->error_char == 0);			# 7
is_ok ($ob->baudrate == 9600);			# 8
is_ok ($ob->parity eq "none");			# 9
is_ok ($ob->databits == 8);			# 10
is_ok ($ob->stopbits == 1);			# 11
is_ok ($ob->handshake eq "none");		# 12
is_ok ($ob->read_interval == 0xffffffff);	# 13
is_ok ($ob->read_const_time == 0);		# 14
is_ok ($ob->read_char_time == 0);		# 15
is_ok ($ob->write_const_time == 200);		# 16
is_ok ($ob->write_char_time == 10);		# 17

($in, $out)= $ob->buffers;
is_ok (4096 == $in);				# 18
is_ok (4096 == $out);				# 19

is_ok ($ob->alias eq "TestPort");		# 20

is_ok ($ob->binary == 1);			# 21

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->parity_enable == 0);		# 22
is_ok ($ob->xoff_limit == 200);			# 23
is_ok ($ob->xon_limit == 100);			# 24


## 25 - 30: Status

is_ok (4 == scalar (@opts = $ob->status));	# 25

# for an unconnected port, should be $in=0, $out=0, $blk=0, $err=0

($blk, $in, $out, $err)=@opts;
is_ok (defined $blk);				# 26
is_zero ($in);					# 27
is_zero ($out);					# 28
is_zero ($blk);					# 29
if ($blk) { printf "status: blk=%lx\n", $blk; }
is_zero ($err);					# 30

# 31 - 33: "Instant" return for read_interval=0xffffffff

$tick=$ob->get_tick_count;
($in, $in2) = $ob->read(10);
$tock=$ob->get_tick_count;

is_zero ($in);					# 31
is_bad ($in2);					# 32
$out=$tock - $tick;
is_ok ($out < 100);				# 33
print "<0> elapsed time=$out\n";

print "Beginning Timed Tests at 2-5 Seconds per Set\n";

# 34, 35: 2 Second Constant Timeout

is_ok (2000 == $ob->read_const_time(2000));	# 34
is_zero ($ob->read_interval(0));		# 35

# 36 - 38

$tick=$ob->get_tick_count;
($in, $in2) = $ob->read(10);
$tock=$ob->get_tick_count;

is_zero ($in);					# 36
is_bad ($in2);					# 37
$out=$tock - $tick;
is_bad (($out < 1800) or ($out > 2400));	# 38
print "<2000> elapsed time=$out\n";


# 39 - 42: 4 Second Timeout Constant+Character

is_ok (100 == $ob->read_char_time(100));	# 39

$tick=$ob->get_tick_count;
($in, $in2) = $ob->read(20);
$tock=$ob->get_tick_count;

is_zero ($in);					# 40
is_bad ($in2);					# 41
$out=$tock - $tick;
is_bad (($out < 3800) or ($out > 4400));	# 42
print "<4000> elapsed time=$out\n";


# 43 - 46: 3 Second Character Timeout

is_zero ($ob->read_const_time(0));		# 43

$tick=$ob->get_tick_count;
($in, $in2) = $ob->read(30);
$tock=$ob->get_tick_count;

is_zero ($in);					# 44
is_bad ($in2);					# 45
$out=$tock - $tick;
is_bad (($out < 2800) or ($out > 3400));	# 46
print "<3000> elapsed time=$out\n";


# 47 - 51: 2 Second Constant Write Timeout

is_zero ($ob->read_char_time(0));		# 47
is_ok (0xffffffff == $ob->read_interval(0xffffffff));	#48
is_ok (2000 == $ob->write_const_time(2000));	# 49
is_zero ($ob->write_char_time(0));		# 50
is_ok ("rts" eq $ob->handshake("rts"));		# 51 ; so it blocks

# 52 - 53

$e="12345678901234567890";

$tick=$ob->get_tick_count;
is_zero ($ob->write($e));			# 52
$tock=$ob->get_tick_count;

$out=$tock - $tick;
is_bad (($out < 1800) or ($out > 2400));	# 53
print "<2000> elapsed time=$out\n";

# 54 - 56: 3.5 Second Timeout Constant+Character

is_ok (75 ==$ob->write_char_time(75));		# 54

$tick=$ob->get_tick_count;
is_zero ($ob->write($e));			# 55
$tock=$ob->get_tick_count;

$out=$tock - $tick;
is_bad (($out < 3300) or ($out > 3900));	# 56
print "<3500> elapsed time=$out\n";


# 57, 58: 2.5 Second Read Constant Timeout

is_ok (2500 == $ob->read_const_time(2500));	# 57
is_zero ($ob->read_interval(0));		# 58
is_ok (scalar $ob->purge_all);			# 59

$tick=$ob->get_tick_count;
$in = $ob->read_bg(10);
$tock=$ob->get_tick_count;

is_zero ($in);					# 60
$out=$tock - $tick;
is_ok ($out < 100);				# 61
print "<0> elapsed time=$out\n";

($pass, $in, $in2) = $ob->read_done(0);
$tock=$ob->get_tick_count;

is_zero ($pass);				# 62
is_zero ($in);					# 63
is_ok ($in2 eq "");				# 64
$out=$tock - $tick;
is_ok ($out < 100);				# 65


print "A Series of 1 Second Groups with Background I/O\n";

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 66
is_zero ($in);					# 67
is_ok ($in2 eq "");				# 68
is_zero ($ob->write_bg($e));			# 69
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 70
is_zero ($out);					# 71

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 72
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 73

($blk, $in, $out, $err)=$ob->status;
is_zero ($in);					# 74
is_ok ($out == 20);				# 75
is_ok ($blk == 1);				# 76
is_zero ($err);					# 77

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);
is_ok ($pass);					# 78
is_zero ($in);					# 79
is_ok ($in2 eq "");				# 80
$tock=$ob->get_tick_count;			# expect about 3 seconds
$out=$tock - $tick;
is_bad (($out < 2800) or ($out > 3400));	# 81
print "<3000> elapsed time=$out\n";
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 82

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);		# double check ok?
is_ok ($pass);					# 83
is_zero ($in);					# 84
is_ok ($in2 eq "");				# 85
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 86

sleep 1;
($pass, $out) = $ob->write_done(0);
is_ok ($pass);					# 87
is_zero ($out);					# 88
$tock=$ob->get_tick_count;			# expect about 5 seconds
$out=$tock - $tick;
is_bad (($out < 4800) or ($out > 5400));	# 89
print "<5000> elapsed time=$out\n";

$tick=$ob->get_tick_count;			# new timebase
$in = $ob->read_bg(10);
is_zero ($in);					# 90
($pass, $in, $in2) = $ob->read_done(0);

is_zero ($pass);				# 91 
is_zero ($in);					# 92
is_ok ($in2 eq "");				# 93

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 94
## print "testing fail message:\n";
$in = $ob->read_bg(10);
is_bad (defined $in);				# 95 - already reading

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 96
($pass, $in, $in2) = $ob->read_done(1);
is_ok ($pass);					# 97
is_zero ($in);					# 98 
is_ok ($in2 eq "");				# 99
$tock=$ob->get_tick_count;			# expect 2.5 seconds
$out=$tock - $tick;
is_bad (($out < 2300) or ($out > 2800));	# 100
print "<2500> elapsed time=$out\n";

$tick=$ob->get_tick_count;			# new timebase
$in = $ob->read_bg(10);
is_zero ($in);					# 101
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 102
is_zero ($in);					# 103
is_ok ($in2 eq "");				# 104

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 105 
is_ok (scalar $ob->purge_rx);			# 106 
($pass, $in, $in2) = $ob->read_done(1);
is_ok (scalar $ob->purge_rx);			# 107 
if (Win32::IsWinNT()) {
    is_zero ($pass);				# 108 
}
else {
    is_ok ($pass);				# 108 
}
is_zero ($in);					# 109 
is_ok ($in2 eq "");				# 110
$tock=$ob->get_tick_count;			# expect 1 second
$out=$tock - $tick;
is_bad (($out < 900) or ($out > 1200));		# 111
print "<1000> elapsed time=$out\n";

is_zero ($ob->write_bg($e));			# 112
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 113

sleep 1;
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 114
is_ok (scalar $ob->purge_tx);			# 115 
($pass, $out) = $ob->write_done(1);
is_ok (scalar $ob->purge_tx);			# 116 
if (Win32::IsWinNT()) {
    is_zero ($pass);				# 117 
}
else {
    is_ok ($pass);				# 117 
}
$tock=$ob->get_tick_count;			# expect 2 seconds
$out=$tock - $tick;
is_bad (($out < 1900) or ($out > 2200));	# 118
print "<2000> elapsed time=$out\n";

$tick=$ob->get_tick_count;			# new timebase
$in = $ob->read_bg(10);
is_zero ($in);					# 119
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 120
is_zero ($ob->write_bg($e));			# 121
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 122

sleep 1;
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 123

($pass, $in, $in2) = $ob->read_done(1);
is_ok ($pass);					# 124 
is_zero ($in);					# 125 
is_ok ($in2 eq "");				# 126
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 127
$tock=$ob->get_tick_count;			# expect 2.5 seconds
$out=$tock - $tick;
is_bad (($out < 2300) or ($out > 2800));	# 128
print "<2500> elapsed time=$out\n";

($pass, $out) = $ob->write_done(1);
is_ok ($pass);					# 129
$tock=$ob->get_tick_count;			# expect 3.5 seconds
$out=$tock - $tick;
is_bad (($out < 3300) or ($out > 3800));	# 130
print "<3500> elapsed time=$out\n";

is_ok(1 == $ob->user_msg);			# 131
is_zero(scalar $ob->user_msg(0));		# 132
is_ok(1 == $ob->user_msg(1));			# 133
is_ok(1 == $ob->error_msg);			# 134
is_zero(scalar $ob->error_msg(0));		# 135
is_ok(1 == $ob->error_msg(1));			# 136

#### 137 - 143: Application Parameter Defaults

is_ok ($ob->devicetype eq 'none');		# 137
is_ok ($ob->hostname eq 'localhost');		# 138
is_zero ($ob->hostaddr);			# 139
is_ok ($ob->datatype eq 'raw');			# 140
is_ok ($ob->cfg_param_1 eq 'none');		# 141
is_ok ($ob->cfg_param_2 eq 'none');		# 142
is_ok ($ob->cfg_param_3 eq 'none');		# 143

undef $ob;

# 144 - 145: Reopen tests (unconfirmed) $ob->close via undef

sleep 1;
unless (is_ok ($ob = Win32::SerialPort->start ($cfgfile))) {
    printf "could not reopen port from $cfgfile\n";	# 144
    exit 1;
    # next test would die at runtime without $ob
}
is_ok(1 == $ob->close);				# 145
undef $ob;
