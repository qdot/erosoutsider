#! perl -w

use lib '.','./t','./lib','../lib';
# can run from here or distribution base
require 5.003;

# Before installation is performed this script should be runnable with
# `perl test1.t time' which pauses `time' seconds (0..5) between pages

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..275\n"; }
END {print "not ok 1\n" unless $loaded;}
use Win32::SerialPort 0.19;
require "DefaultPort.pm";
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

# assume a "vanilla" port on "COM1"

use strict;

## verifies the (0, 1) list returned by binary functions
sub test_bin_list {
    return undef unless (@_ == 2);
    return undef unless (0 == shift);
    return undef unless (1 == shift);
    return 1;
}

## verifies the (0, 255) list returned by byte functions
sub test_byte_list {
    return undef unless (@_ == 2);
    return undef unless (0 == shift);
    return undef unless (255 == shift);
    return 1;
}

## verifies the (0, 0xffff) list returned by short functions
sub test_short_list {
    return undef unless (@_ == 2);
    return undef unless (0 == shift);
    return undef unless (0xffff == shift);
    return 1;
}

## verifies the (0, 0xffffffff) list returned by long functions
sub test_long_list {
    return undef unless (@_ == 2);
    return undef unless (0 == shift);
    return undef unless (0xffffffff == shift);
    return 1;
}

## verifies the value returned by byte functions
sub test_byte_value {
    my $v = shift;
    return undef if (($v < 0) or ($v > 255));
    return 1;
}

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

my $fault = 0;
my $ob;
my $pass;
my $fail;
my $in;
my $in2;
my @opts;
my $out;
my $err;
my $blk;
my $e;
my $tick;
my $tock;
my %required_param;
my @necessary_param = Win32::SerialPort->set_test_mode_active(1);

unlink $cfgfile;
foreach $e (@necessary_param) { $required_param{$e} = 0; }

## 2 - 5 SerialPort Global variable ($Babble);

is_bad(Win32::SerialPort::debug());		# 2: start out false

is_ok(Win32::SerialPort::debug(1));		# 3: set it

is_bad(Win32::SerialPort::debug(2));		# 4: invalid binary=false

# 5: yes_true subroutine, no need to SHOUT if it works

$e="yes_true failed:";
unless (Win32::SerialPort::debug("T"))   { print "$e \"T\"\n"; $fault++; }
if     (Win32::SerialPort::debug("F"))   { print "$e \"F\"\n"; $fault++; }

no strict 'subs';
unless (Win32::SerialPort::debug(T))     { print "$e T\n";     $fault++; }
if     (Win32::SerialPort::debug(F))     { print "$e F\n";     $fault++; }
unless (Win32::SerialPort::debug(Y))     { print "$e Y\n";     $fault++; }
if     (Win32::SerialPort::debug(N))     { print "$e N\n";     $fault++; }
unless (Win32::SerialPort::debug(ON))    { print "$e ON\n";    $fault++; }
if     (Win32::SerialPort::debug(OFF))   { print "$e OFF\n";   $fault++; }
unless (Win32::SerialPort::debug(TRUE))  { print "$e TRUE\n";  $fault++; }
if     (Win32::SerialPort::debug(FALSE)) { print "$e FALSE\n"; $fault++; }
unless (Win32::SerialPort::debug(Yes))   { print "$e Yes\n";   $fault++; }
if     (Win32::SerialPort::debug(No))    { print "$e No\n";    $fault++; }
unless (Win32::SerialPort::debug("yes")) { print "$e \"yes\"\n"; $fault++; }
if     (Win32::SerialPort::debug("f"))   { print "$e \"f\"\n";   $fault++; }
use strict 'subs';

is_zero($fault);				# 5

# 6: Constructor

unless (is_ok ($ob = Win32::SerialPort->new ($file))) {
    die "could not open port $file\n";		# 6
    # next test would die at runtime without $ob
}

is_bad($ob->debug);				# 7 end up false

#### 8 - 99: Check Port Capabilities 

## 8 - 21: Binary Capabilities

is_ok($ob->can_baud);				# 8
is_ok($ob->can_databits);			# 9
is_ok($ob->can_stopbits);			# 10
is_ok($ob->can_dtrdsr);				# 11
is_ok($ob->can_handshake);			# 12
is_ok($ob->can_parity_check);			# 13
is_ok($ob->can_parity_config);			# 14
is_ok($ob->can_parity_enable);			# 15
is_ok($ob->can_rlsd);				# 16
is_ok($ob->can_rtscts);				# 17
is_ok($ob->can_xonxoff);			# 18
is_ok($ob->can_interval_timeout);		# 19
is_ok($ob->can_total_timeout);			# 20
is_ok($ob->can_xon_char);			# 21

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

## 22 - 24: Unusual Parameters (for generic port)

$fail=$ob->can_spec_char;			# 22
printf (($fail ? "spec_char not generic but\n" : "")."ok %d\n",$tc++);

$fail=$ob->can_16bitmode;			# 23
printf (($fail ? "16bitmode not generic but\n" : "")."ok %d\n",$tc++);

$pass=$ob->is_rs232;				# 24
$in = $ob->is_modem;				# 24 alternate
if ($pass)	{ printf ("ok %d\n", $tc++); }
elsif ($in)	{ printf ("modem is\nok %d\n", $tc++); }
else	 	{ printf ("not ok %d\n", $tc++); }

## 25 - 44: Byte Capabilities

$in = $ob->xon_char;
is_ok(test_byte_value($in));			# 25
is_bad(scalar $ob->xon_char(500));		# 26
@opts = $ob->xon_char;
is_ok(test_byte_list(@opts));			# 27
is_ok(scalar $ob->xon_char(0x11));		# 28

$in = $ob->xoff_char;
is_ok(test_byte_value($in));			# 29
is_bad(scalar $ob->xoff_char(-1));		# 30
@opts = $ob->xoff_char;
is_ok(test_byte_list(@opts));			# 31
is_ok(scalar $ob->xoff_char(0x13));		# 32

$in = $ob->eof_char;
is_ok(test_byte_value($in));			# 33
is_bad(scalar $ob->eof_char(500));		# 34
@opts = $ob->eof_char;
is_ok(test_byte_list(@opts));			# 35
is_zero(scalar $ob->eof_char(0));		# 36

$in = $ob->event_char;
is_ok(test_byte_value($in));			# 37
is_bad(scalar $ob->event_char(5000));		# 38
@opts = $ob->event_char;
is_ok(test_byte_list(@opts));			# 39
is_zero(scalar $ob->event_char(0x0));		# 40

$in = $ob->error_char;
is_ok(test_byte_value($in));			# 41
is_bad(scalar $ob->error_char(65600));		# 42

@opts = $ob->error_char;
is_ok(test_byte_list(@opts));			# 43

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_zero(scalar $ob->error_char(0x0));		# 44

#### 45 - 93: Set Basic Port Parameters 

## 45 - 50: Baud (Valid/Invalid/Current)

@opts=$ob->baudrate;		# list of allowed values
is_ok(1 == grep(/^9600$/, @opts));		# 45
is_zero(scalar grep(/^9601/, @opts));		# 46

is_ok($in = $ob->baudrate);			# 47
is_ok(1 == grep(/^$in$/, @opts));		# 48

is_bad(scalar $ob->baudrate(9601));		# 49
is_ok($in == $ob->baudrate(9600));		# 50
    # leaves 9600 pending


## 51 - 56: Parity (Valid/Invalid/Current)

@opts=$ob->parity;		# list of allowed values
is_ok(1 == grep(/none/, @opts));		# 51
is_zero(scalar grep(/any/, @opts));		# 52

is_ok($in = $ob->parity);			# 53
is_ok(1 == grep(/^$in$/, @opts));		# 54

is_bad(scalar $ob->parity("any"));		# 55
is_ok($in eq $ob->parity("none"));		# 56
    # leaves "none" pending

## 57: Missing Param test

is_bad($ob->write_settings);			# 57

# 58 - 63: Databits (Valid/Invalid/Current)

@opts=$ob->databits;		# list of allowed values
is_ok(1 == grep(/8/, @opts));			# 58
is_zero(scalar grep(/4/, @opts));		# 59

is_ok($in = $ob->databits);			# 60
is_ok(1 == grep(/^$in$/, @opts));		# 61

is_bad(scalar $ob->databits(3));		# 62
is_ok($in == $ob->databits(8));			# 63
    # leaves 8 pending


## 64 - 69: Stopbits (Valid/Invalid/Current)

@opts=$ob->stopbits;		# list of allowed values
is_ok(1 == grep(/1.5/, @opts));			# 64
is_zero(scalar grep(/3/, @opts));		# 65

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok($in = $ob->stopbits);			# 66
is_ok(1 == grep(/^$in$/, @opts));		# 67

is_bad(scalar $ob->stopbits(3));		# 68
is_ok($in == $ob->stopbits(1));			# 69
    # leaves 1 pending


## 70 - 75: Handshake (Valid/Invalid/Current)

@opts=$ob->handshake;		# list of allowed values
is_ok(1 == grep(/none/, @opts));		# 70
is_zero(scalar grep(/moo/, @opts));		# 71

is_ok($in = $ob->handshake);			# 72
is_ok(1 == grep(/^$in$/, @opts));		# 73

is_bad(scalar $ob->handshake("moo"));		# 74
is_ok($in = $ob->handshake("rts"));		# 75
    # leaves "rts" pending for status


## 76 - 81: Buffer Size

($in, $out) = $ob->buffer_max(512);
is_bad(defined $in);				# 76
($in, $out) = $ob->buffer_max;
is_ok(defined $in);				# 77

if (($in > 0) and ($in < 4096))		{ $in2 = $in; } 
else					{ $in2 = 4096; }

if (($out > 0) and ($out < 4096))	{ $err = $out; } 
else					{ $err = 4096; }

is_ok(scalar $ob->buffers($in2, $err));		# 78

@opts = $ob->buffers(4096, 4096, 4096);
is_bad(defined $opts[0]);			# 79
($in, $out)= $ob->buffers;
is_ok($in2 == $in);				# 80
is_ok($out == $err);				# 81

## 82: Alias

is_ok("TestPort" eq $ob->alias("TestPort"));	# 82


## 83 - 88: Read Timeouts

@opts = $ob->read_interval;
is_ok(test_long_list(@opts));			# 83
is_ok(0xffffffff == $ob->read_interval(0xffffffff));	# 84

@opts = $ob->read_const_time;
is_ok(test_long_list(@opts));			# 85
is_zero($ob->read_const_time(0));		# 86

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

@opts = $ob->read_char_time;
is_ok(test_long_list(@opts));			# 87
is_zero($ob->read_char_time(0));		# 88


## 89 - 92: Write Timeouts

@opts = $ob->write_const_time;
is_ok(test_long_list(@opts));			# 89
is_ok(200 == $ob->write_const_time(200));	# 90

@opts = $ob->write_char_time;
is_ok(test_long_list(@opts));			# 91
is_ok(10 == $ob->write_char_time(10));		# 92

## 93 - 96: Other Parameters (Defaults)

is_ok(1 == $ob->binary(1));			# 93

is_zero($ob->parity_enable(0));			# 94

@opts = $ob->xon_limit;
is_ok(test_short_list(@opts));			# 95

@opts = $ob->xoff_limit;
is_ok(test_short_list(@opts));			# 96

## 97 - 99: Finish Initialize

is_ok(scalar $ob->write_settings);		# 97

is_ok(100 == $ob->xon_limit(100));		# 98
is_ok(200 == $ob->xoff_limit(200));		# 99


## 100 - 130: Constants from Package

is_ok(1 == $ob->BM_fCtsHold);			# 100
is_ok(2 == $ob->BM_fDsrHold);			# 101
is_ok(4 == $ob->BM_fRlsdHold);			# 102
is_ok(8 == $ob->BM_fXoffHold);			# 103
is_ok(0x10 == $ob->BM_fXoffSent);		# 104
is_ok(0x20 == $ob->BM_fEof);			# 105
is_ok(0x40 == $ob->BM_fTxim);			# 106

is_ok(0x10 == $ob->MS_CTS_ON);			# 107
is_ok(0x20 == $ob->MS_DSR_ON);			# 108

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok(0x40 == $ob->MS_RING_ON);			# 109
is_ok(0x80 == $ob->MS_RLSD_ON);			# 110

is_ok(0x1 == $ob->CE_RXOVER);			# 111
is_ok(0x2 == $ob->CE_OVERRUN);			# 112

is_ok(0x4 == $ob->CE_RXPARITY);			# 113
is_ok(0x8 == $ob->CE_FRAME);			# 114
is_ok(0x10 == $ob->CE_BREAK);			# 115
is_ok(0x100 == $ob->CE_TXFULL);			# 116
is_ok(0x8000 == $ob->CE_MODE);			# 117

## 118 - 123: Status

@opts = $ob->status;
is_ok(defined @opts);				# 118

# for an unconnected port, should be $in=0, $out=0, $blk=1 (no CTS), $err=0

($blk, $in, $out, $err)=@opts;
is_ok(defined $blk);				# 119
is_zero($in);					# 120
is_zero($out);					# 121

is_ok($blk == $ob->BM_fCtsHold);		# 122
is_zero($err);					# 123

## 124 - 130: No Handshake, Polled Write

is_ok("none" eq $ob->handshake("none"));	# 124

$e="testing is a wonderful thing - this is a 60 byte long string";
#   123456789012345678901234567890123456789012345678901234567890
my $line = $e.$e.$e;		# about 185 MS at 9600 baud

$tick=$ob->get_tick_count;
$pass=$ob->write($line);
$tock=$ob->get_tick_count;

is_ok($pass == 180);				# 125
$err=$tock - $tick;
is_bad (($err < 160) or ($err > 210));		# 126
print "<185> elapsed time=$err\n";

($blk, $in, $out, $err)=$ob->status;
is_zero($blk);					# 127
if ($blk) { printf "status: blk=%lx\n", $blk; }
is_zero($in);					# 128
is_zero($out);					# 129

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_zero($err);					# 130

## 131 - 136: Block by DSR without Output

is_ok($ob->purge_tx);				# 131
is_ok("dtr" eq $ob->handshake("dtr"));		# 132

($blk, $in, $out, $err)=$ob->status;
is_ok($blk == $ob->BM_fDsrHold);		# 133
is_zero($in);					# 134
is_zero($out);					# 135
is_zero($err);					# 136

## 137 - 141: Unsent XOFF without Output

is_ok("xoff" eq $ob->handshake("xoff"));	# 137

($blk, $in, $out, $err)=$ob->status;
is_zero($blk);					# 138
if ($blk) { printf "status: blk=%lx\n", $blk; }
is_zero($in);					# 139
is_zero($out);					# 140
is_zero($err);					# 141

## 142 - 150: Block by XOFF without Output

is_ok($ob->xoff_active);			# 142

is_ok(scalar $ob->transmit_char(0x33));		# 143

$in2=($ob->BM_fXoffHold | $ob->BM_fTxim);
($blk, $in, $out, $err)=$ob->status;
is_ok($blk & $in2);				# 144
is_zero($in);					# 145
is_zero($out);					# 146
is_zero($err);					# 147

is_ok($ob->xon_active);				# 148
($blk, $in, $out, $err)=$ob->status;
is_zero($blk);					# 149
if ($blk) { printf "status: blk=%lx\n", $blk; }
is_zero($err);					# 150

## 151 - 152: No Handshake

is_ok("none" eq $ob->handshake("none"));	# 151

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok($ob->purge_all);				# 152

## 153 - 158: Optional Messages

@opts = $ob->user_msg;
is_ok(test_bin_list(@opts));			# 153
is_zero(scalar $ob->user_msg);			# 154
is_ok(1 == $ob->user_msg(1));			# 155

@opts = $ob->error_msg;
is_ok(test_bin_list(@opts));			# 156
is_zero(scalar $ob->error_msg);			# 157
is_ok(1 == $ob->error_msg(1));			# 158

## 159 - 164: Save and Check Configuration

is_ok(scalar $ob->save($cfgfile));		# 159

is_ok(9600 == $ob->baudrate);			# 160
is_ok("none" eq $ob->parity);			# 161
is_ok(8 == $ob->databits);			# 162
is_ok(1 == $ob->stopbits);			# 163
is_ok(1 == $ob->close);				# 164
undef $ob;

## 165 - 167: Check File Headers

is_ok(open CF, "$cfgfile");			# 165
my ($signature, $name, @values) = <CF>;
close CF;

is_ok(1 == grep(/SerialPort_Configuration_File/, $signature));	# 166

chomp $name;
is_ok($name eq $file);				# 167

## 168 - 169: Check that Values listed exactly once

$fault = 0;
foreach $e (@values) {
    chomp $e;
    ($in, $out) = split(',',$e);
    $fault++ if ($out eq "");
    $required_param{$in}++;
    }
is_zero($fault);				# 168

$fault = 0;
foreach $e (@necessary_param) {
    $fault++ unless ($required_param{$e} ==1);
    }
is_zero($fault);				# 169

## 170 - 177: Reopen as (mostly 5.003 Compatible) Tie using File 

    # constructor = TIEHANDLE method		# 170
unless (is_ok ($ob = tie(*PORT,'Win32::SerialPort', $cfgfile))) {
    printf "could not reopen port from $cfgfile\n";
    exit 1;
    # next test would die at runtime without $ob
}

    # tie to PRINT method
$tick=$ob->get_tick_count;
$pass=print PORT $line;
$tock=$ob->get_tick_count;

is_ok($pass == 1);				# 171
$err=$tock - $tick;
is_bad (($err < 160) or ($err > 210));		# 172
print "<185> elapsed time=$err\n";

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

    # tie to PRINTF method
$tick=$ob->get_tick_count;
if ( $] < 5.004 ) {
    $out=sprintf "123456789_%s_987654321", $line;
    $pass=print PORT $out;
}
else {
    $pass=printf PORT "123456789_%s_987654321", $line;
}
$tock=$ob->get_tick_count;

is_ok($pass == 1);				# 173
$err=$tock - $tick;
is_bad (($err < 180) or ($err > 235));		# 174
print "<205> elapsed time=$err\n";

    # output conversion defaults: -opost onlcr -ocrnl
$e = "\r"x100;
$e .= "\n"x160;
$tick=$ob->get_tick_count;
$pass=print PORT $e;
$tock=$ob->get_tick_count;

is_ok($pass == 1);				# 175
$err=$tock - $tick;
is_bad (($err < 250) or ($err > 300));		# 176
print "<275> elapsed time=$err\n";

is_ok(1 == $ob->stty_opost(1));			# 177
$tick=$ob->get_tick_count;
$pass=print PORT $e;
$tock=$ob->get_tick_count;

is_ok($pass == 1);				# 178
$err=$tock - $tick;
is_bad (($err < 410) or ($err > 465));		# 179
print "<435> elapsed time=$err\n";

is_ok(1 == $ob->stty_ocrnl(1));			# 180
$tick=$ob->get_tick_count;
$pass=print PORT $e;
$tock=$ob->get_tick_count;

is_ok($pass == 1);				# 181
$err=$tock - $tick;
is_bad (($err < 510) or ($err > 575));		# 182
print "<535> elapsed time=$err\n";

is_ok(0 == $ob->stty_opost(0));			# 183
$tick=$ob->get_tick_count;
$pass=print PORT $e;
$tock=$ob->get_tick_count;

is_ok($pass == 1);				# 184
$err=$tock - $tick;
is_bad (($err < 250) or ($err > 300));		# 185
print "<275> elapsed time=$err\n";

is_ok(1 == $ob->stty_opost(1));			# 186
$tick=$ob->get_tick_count;
$pass=print PORT $e;
$tock=$ob->get_tick_count;

is_ok($pass == 1);				# 187
$err=$tock - $tick;
is_bad (($err < 510) or ($err > 575));		# 188
print "<535> elapsed time=$err\n";

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok(0 == $ob->stty_onlcr(0));			# 189
$tick=$ob->get_tick_count;
$pass=print PORT $e;
$tock=$ob->get_tick_count;

is_ok($pass == 1);				# 190
$err=$tock - $tick;
is_bad (($err < 250) or ($err > 300));		# 191
print "<275> elapsed time=$err\n";

    # tie to READLINE method
is_ok (500 == $ob->read_const_time(500));	# 192
$tick=$ob->get_tick_count;
$fail = <PORT>;
$tock=$ob->get_tick_count;

is_bad(defined $fail);				# 193
$err=$tock - $tick;
is_bad (($err < 480) or ($err > 540));		# 194
print "<500> elapsed time=$err\n";

## 195 - 204: Port in Use (new + quiet)

my $ob2;
is_bad ($ob2 = Win32::SerialPort->new ($file));		# 195
is_bad (defined $ob2);					# 196
is_zero ($ob2 = Win32::SerialPort->new ($file, 1));	# 197
is_bad ($ob2 = Win32::SerialPort->new ($file, 0));	# 198
is_bad (defined $ob2);					# 199

is_bad ($ob2 = Win32API::CommPort->new ($file));	# 200
is_bad (defined $ob2);					# 201
is_zero ($ob2 = Win32API::CommPort->new ($file, 1));	# 202
is_bad ($ob2 = Win32API::CommPort->new ($file, 0));	# 203
is_bad (defined $ob2);					# 204

## 225 - 278: Other DCB bits

      # for handshake == "none"
is_zero($ob->output_dsr);				# 205
is_zero($ob->output_cts);				# 206
is_zero($ob->input_xoff);				# 207
is_zero($ob->output_xoff);				# 208

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_zero($ob->ignore_null(0));				# 209
is_zero($ob->ignore_no_dsr(0));				# 210

is_zero($ob->subst_pe_char(0));				# 211
is_zero($ob->abort_on_error(0));			# 212
is_zero($ob->tx_on_xoff(0));				# 213

is_zero($ob->ignore_null);				# 214
is_ok($ob->ignore_null(1));				# 215
is_ok($ob->ignore_null);				# 216
is_zero($ob->ignore_null(0));				# 217
is_zero($ob->ignore_null);				# 218

is_zero($ob->ignore_no_dsr);				# 219
is_ok($ob->ignore_no_dsr(1));				# 220
is_ok($ob->ignore_no_dsr);				# 221
is_zero($ob->ignore_no_dsr(0));				# 222
is_zero($ob->ignore_no_dsr);				# 223

is_zero($ob->subst_pe_char);				# 224
is_ok($ob->subst_pe_char(1));				# 225
is_ok($ob->subst_pe_char);				# 226
is_zero($ob->subst_pe_char(0));				# 227
is_zero($ob->subst_pe_char);				# 228

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_zero($ob->abort_on_error);				# 229
is_ok($ob->abort_on_error(1));				# 230
is_ok($ob->abort_on_error);				# 231
is_zero($ob->abort_on_error(0));			# 232
is_zero($ob->abort_on_error);				# 233

is_zero($ob->tx_on_xoff);				# 234
is_ok($ob->tx_on_xoff(1));				# 235
is_ok($ob->tx_on_xoff);					# 236
is_zero($ob->tx_on_xoff(0));				# 237
is_zero($ob->tx_on_xoff);				# 238

is_ok("dtr" eq $ob->handshake("dtr"));			# 239
is_ok($ob->output_dsr);					# 240
is_zero($ob->output_cts);				# 241
is_zero($ob->input_xoff);				# 242
is_zero($ob->output_xoff);				# 243

is_ok("rts" eq $ob->handshake("rts"));			# 244
is_zero($ob->output_dsr);				# 245
is_ok($ob->output_cts);					# 246
is_zero($ob->input_xoff);				# 247
is_zero($ob->output_xoff);				# 248

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok("xoff" eq $ob->handshake("xoff"));		# 249
is_zero($ob->output_dsr);				# 250
is_zero($ob->output_cts);				# 251
is_ok($ob->input_xoff);					# 252
is_ok($ob->output_xoff);				# 253

is_ok("none" eq $ob->handshake("none"));		# 254
is_zero($ob->output_dsr);				# 255

is_zero($ob->output_cts);				# 256
is_zero($ob->input_xoff);				# 257
is_zero($ob->output_xoff);				# 258

## 259 - 2xx: Pulsed DCB bits

if ( ($] < 5.005) and ($] >= 5.004) ) {

        # pulses not supported on GSAR port
    $tick=$ob->get_tick_count;
    is_ok ($ob->dtr_active(0));			# 259
    is_bad ($ob->pulse_dtr_on(100));		# 260
    is_ok ($ob->dtr_active(1));			# 261
    is_bad ($ob->pulse_dtr_off(100));		# 262
    is_ok ($ob->rts_active(0));			# 263
    is_bad ($ob->pulse_rts_on(100));		# 264
    is_ok ($ob->rts_active(1));			# 265
    is_bad ($ob->pulse_rts_off(100));		# 266
    is_bad ($ob->pulse_break_on(100));		# 267
    $tock=$ob->get_tick_count;

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

    is_ok (1);					# 268
    is_ok (1);					# 269
    is_ok (1);					# 270
    is_ok (1);					# 271

    $err=$tock - $tick;
    is_bad ($err > 60);				# 272
    print "<15> elapsed time=$err\n";
}
else {
    is_ok ($ob->dtr_active(0));			# 259
    $tick=$ob->get_tick_count;
    is_ok ($ob->pulse_dtr_on(100));		# 260
    $tock=$ob->get_tick_count;
    $err=$tock - $tick;
    is_bad (($err < 180) or ($err > 240));	# 261
    print "<200> elapsed time=$err\n";

    is_ok ($ob->dtr_active(1));			# 262
    $tick=$ob->get_tick_count;
    is_ok ($ob->pulse_dtr_off(200));		# 263
    $tock=$ob->get_tick_count;
    $err=$tock - $tick;
    is_bad (($err < 370) or ($err > 450));	# 264
    print "<400> elapsed time=$err\n";

    is_ok ($ob->rts_active(0));			# 265
    $tick=$ob->get_tick_count;
    is_ok ($ob->pulse_rts_on(150));		# 266
    $tock=$ob->get_tick_count;
    $err=$tock - $tick;
    is_bad (($err < 275) or ($err > 345));	# 267
    print "<300> elapsed time=$err\n";

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

    is_ok ($ob->rts_active(1));			# 268
    $tick=$ob->get_tick_count;
    is_ok ($ob->pulse_rts_on(50));		# 269
    $tock=$ob->get_tick_count;
    $err=$tock - $tick;
    is_bad (($err < 80) or ($err > 130));	# 270
    print "<100> elapsed time=$err\n";

    $tick=$ob->get_tick_count;
    is_ok ($ob->pulse_break_on(50));		# 271
    $tock=$ob->get_tick_count;
    $err=$tock - $tick;
    is_bad (($err < 80) or ($err > 130));	# 272
    print "<100> elapsed time=$err\n";
}

is_ok ($ob->rts_active(0));			# 273
is_ok ($ob->dtr_active(0));			# 274


    # destructor = CLOSE method
if ( $] < 5.005 ) {
    is_ok($ob->close);				# 275
}
else {
    is_ok(close PORT);				# 275
}

    # destructor = DESTROY method
undef $ob;					# Don't forget this one!!
untie *PORT;

