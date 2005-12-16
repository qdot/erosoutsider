#! perl -w

use lib '.','./t','..','./lib','../lib';
# can run from here or distribution base
require 5.003;

# Before installation is performed this script should be runnable with
# `perl test3.t time' which pauses `time' seconds (0..5) between pages

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..244\n"; }
END {print "not ok 1\n" unless $loaded;}
use AltPort qw( :STAT :PARAM 0.19 );		# check inheritance & export
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

my $s="testing is a wonderful thing - this is a 60 byte long string";
#      123456789012345678901234567890123456789012345678901234567890
my $line = $s.$s.$s;		# about 185 MS at 9600 baud

is_ok(0x0 == nocarp);				# 2
my @necessary_param = AltPort->set_test_mode_active(1);

unlink $cfgfile;
foreach $e (@necessary_param) { $required_param{$e} = 0; }

# 3: Constructor

unless (is_ok ($ob = AltPort->new ($file))) {
    die "could not open port $file\n";		# 3
    # next test would die at runtime without $ob
}

is_zero($ob->debug);				# 4

is_ok($ob->debug(1));				# 5

is_zero($ob->debug(0));				# 6

is_zero($ob->debug);				# 7


#### 8 - 99: Check Port Capabilities 

## 8 - 21: Binary Capabilities

is_ok(scalar $ob->can_baud);			# 8
is_ok(scalar $ob->can_databits);		# 9
is_ok(scalar $ob->can_stopbits);		# 10
is_ok(scalar $ob->can_dtrdsr);			# 11
is_ok(scalar $ob->can_handshake);		# 12
is_ok(scalar $ob->can_parity_check);		# 13
is_ok(scalar $ob->can_parity_config);		# 14

is_ok(scalar $ob->can_parity_enable);		# 15
is_ok(scalar $ob->can_rlsd);			# 16
is_ok(scalar $ob->can_rtscts);			# 17
is_ok(scalar $ob->can_xonxoff);			# 18
is_ok(scalar $ob->can_interval_timeout);	# 19
is_ok(scalar $ob->can_total_timeout);		# 20
is_ok(scalar $ob->can_xon_char);		# 21

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

## 22 - 24: Unusual Parameters (for generic port)

$fail=$ob->can_spec_char;			# 22
printf (($fail ? "spec_char not generic but " : "")."ok %d\n",$tc++);

$fail=$ob->can_16bitmode;			# 23
printf (($fail ? "16bitmode not generic but " : "")."ok %d\n",$tc++);

$pass=$ob->is_rs232;				# 24
$in = $ob->is_modem;				# 24 alternate
if ($pass)	{ printf ("ok %d\n", $tc++); }
elsif ($in)	{ printf ("modem is ok %d\n", $tc++); }
else	 	{ printf ("not ok %d\n", $tc++); }


## 25 - 43: Byte Capabilities

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

@opts=$ob->are_baudrate;		# list of allowed values
is_ok(1 == grep(/^9600$/, @opts));		# 45
is_zero(scalar grep(/^9601/, @opts));		# 46

is_ok($in = $ob->is_baudrate);			# 47
is_ok(1 == grep(/^$in$/, @opts));		# 48

is_bad(scalar $ob->is_baudrate(9601));		# 49
is_ok($in == $ob->is_baudrate(9600));		# 50
    # leaves 9600 pending


## 51 - 56: Parity (Valid/Invalid/Current)

@opts=$ob->are_parity;		# list of allowed values
is_ok(1 == grep(/none/, @opts));		# 51
is_zero(scalar grep(/any/, @opts));		# 52

is_ok($in = $ob->is_parity);			# 53
is_ok(1 == grep(/^$in$/, @opts));		# 54

is_bad(scalar $ob->is_parity("any"));		# 55
is_ok($in eq $ob->is_parity("none"));		# 56
    # leaves "none" pending

## 57: Missing Param test

is_bad($ob->write_settings);			# 57


## 58 - 63: Databits (Valid/Invalid/Current)

@opts=$ob->are_databits;		# list of allowed values
is_ok(1 == grep(/8/, @opts));			# 58
is_zero(scalar grep(/4/, @opts));		# 59

is_ok($in = $ob->is_databits);			# 60
is_ok(1 == grep(/^$in$/, @opts));		# 61

is_bad(scalar $ob->is_databits(3));		# 62
is_ok($in == $ob->is_databits(8));		# 63
    # leaves 8 pending


## 64 - 69: Stopbits (Valid/Invalid/Current)

@opts=$ob->are_stopbits;		# list of allowed values
is_ok(1 == grep(/1.5/, @opts));			# 64
is_zero(scalar grep(/3/, @opts));		# 65

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok($in = $ob->is_stopbits);			# 66
is_ok(1 == grep(/^$in$/, @opts));		# 67

is_bad(scalar $ob->is_stopbits(3));		# 68
is_ok($in == $ob->is_stopbits(1));		# 69
    # leaves 1 pending


## 70 - 75: Handshake (Valid/Invalid/Current)

@opts=$ob->are_handshake;		# list of allowed values
is_ok(1 == grep(/none/, @opts));		# 70
is_zero(scalar grep(/moo/, @opts));		# 71

is_ok($in = $ob->is_handshake);			# 72
is_ok(1 == grep(/^$in$/, @opts));		# 73

is_bad(scalar $ob->is_handshake("moo"));	# 74
is_ok($in = $ob->is_handshake("rts"));		# 75
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

is_ok("AltPort" eq $ob->alias("AltPort"));	# 82


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

is_zero(scalar $ob->parity_enable(0));		# 94

@opts = $ob->xon_limit;
is_ok(test_short_list(@opts));			# 95

@opts = $ob->xoff_limit;
is_ok(test_short_list(@opts));			# 96

## 97 - 99: Finish Initialize

is_ok(scalar $ob->write_settings);		# 97

is_ok(100 == $ob->xon_limit(100));		# 98
is_ok(200 == $ob->xoff_limit(200));		# 99


## 100 - 127: Constants from Package

no strict 'subs';
is_ok(1 == BM_fCtsHold);			# 100
is_ok(2 == BM_fDsrHold);			# 101
is_ok(4 == BM_fRlsdHold);			# 102
is_ok(8 == BM_fXoffHold);			# 103
is_ok(0x10 == BM_fXoffSent);			# 104
is_ok(0x20 == BM_fEof);				# 105
is_ok(0x40 == BM_fTxim);			# 106
is_ok(0x7f == BM_AllBits);			# 107

is_ok(0x10 == MS_CTS_ON);			# 108

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok(0x20 == MS_DSR_ON);			# 109
is_ok(0x40 == MS_RING_ON);			# 110
is_ok(0x80 == MS_RLSD_ON);			# 111

is_ok(0x1 == CE_RXOVER);			# 112
is_ok(0x2 == CE_OVERRUN);			# 113
is_ok(0x4 == CE_RXPARITY);			# 114
is_ok(0x8 == CE_FRAME);				# 115
is_ok(0x10 == CE_BREAK);			# 116
is_ok(0x100 == CE_TXFULL);			# 117
is_ok(0x8000 == CE_MODE);			# 118

is_ok(0x0 == ST_BLOCK);				# 119
is_ok(0x1 == ST_INPUT);				# 120
is_ok(0x2 == ST_OUTPUT);			# 121
is_ok(0x3 == ST_ERROR);				# 122

is_ok(0xffffffff == LONGsize);			# 123
is_ok(0xffff == SHORTsize);			# 124
is_ok(0x1 == nocarp);				# 125
is_ok(0x0 == yes_true("F"));			# 126
is_ok(0x1 == yes_true("T"));			# 127
use strict 'subs';

## 128 - 133: Status

@opts = $ob->status;
is_ok(defined @opts);				# 128

# for an unconnected port, should be $in=0, $out=0, $blk=1 (no CTS), $err=0

($blk, $in, $out, $err)=@opts;
is_ok(defined $blk);				# 129
is_zero($in);					# 130

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_zero($out);					# 131
is_ok($blk == $ob->BM_fCtsHold);		# 132
is_zero($err);					# 133

## 134 - 140: No Handshake, Polled Write

is_ok("none" eq $ob->handshake("none"));	# 134

$tick=$ob->get_tick_count;
$pass=$ob->write($line);
$tock=$ob->get_tick_count;

is_ok($pass == 180);				# 135
$err=$tock - $tick;
is_bad (($err < 160) or ($err > 210));		# 136
print "<185> elapsed time=$err\n";

($blk, $in, $out, $err)=$ob->status;
is_zero($blk);					# 137
if ($blk) { printf "status: blk=%lx\n", $blk; }
is_zero($in);					# 138
is_zero($out);					# 139
is_zero($err);					# 140

## 141 - 146: Block by DSR without Output

is_ok(scalar $ob->purge_tx);			# 141
is_ok("dtr" eq $ob->handshake("dtr"));		# 142

($blk, $in, $out, $err)=$ob->status;
is_ok($blk == $ob->BM_fDsrHold);		# 143
is_zero($in);					# 144
is_zero($out);					# 145
is_zero($err);					# 146

## 147 - 151: Unsent XOFF without Output

is_ok("xoff" eq $ob->handshake("xoff"));	# 147

($blk, $in, $out, $err)=$ob->status;
is_zero($blk);					# 148
if ($blk) { printf "status: blk=%lx\n", $blk; }
is_zero($in);					# 149
is_zero($out);					# 150
is_zero($err);					# 151

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

## 152 - 160: Block by XOFF without Output

is_ok(scalar $ob->xoff_active);			# 152

is_ok(scalar $ob->xmit_imm_char(0x33));		# 153

$in2=($ob->BM_fXoffHold | $ob->BM_fTxim);
($blk, $in, $out, $err)=$ob->status;
is_ok($blk & $in2);				# 154
is_zero($in);					# 155
is_zero($out);					# 156
is_zero($err);					# 157

is_ok(scalar $ob->xon_active);			# 158
($blk, $in, $out, $err)=$ob->status;
is_zero($blk);					# 159
if ($blk) { printf "status: blk=%lx\n", $blk; }
is_zero($err);					# 160

## 161 - 162: No Handshake

is_ok("none" eq $ob->handshake("none"));	# 161
is_ok(scalar $ob->purge_all);			# 162

## 163 - 168: Optional Messages

@opts = $ob->user_msg;
is_ok(test_bin_list(@opts));			# 163
is_zero(scalar $ob->user_msg);			# 164
is_ok(1 == $ob->user_msg(1));			# 165

@opts = $ob->error_msg;
is_ok(test_bin_list(@opts));			# 166
is_zero(scalar $ob->error_msg);			# 167
is_ok(1 == $ob->error_msg(1));			# 168

## 169 - 173: Save and Check Configuration

is_ok(scalar $ob->save($cfgfile));		# 169

is_ok(9600 == $ob->baudrate);			# 170
is_ok("none" eq $ob->parity);			# 171
is_ok(8 == $ob->databits);			# 172
is_ok(1 == $ob->stopbits);			# 173

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

## 174 - 187: Other Misc. Tests

is_ok(scalar $ob->can_rlsd_config);		# 174

is_ok($ob->suspend_tx);				# 175
is_ok(scalar $ob->dtr_active(1));		# 176
is_ok(scalar $ob->rts_active(1));		# 177
is_ok(scalar $ob->break_active(1));		# 178
is_zero($ob->modemlines);			# 179

sleep 1;

is_ok($ob->resume_tx);				# 180
is_ok(scalar $ob->dtr_active(0));		# 181
is_ok(scalar $ob->rts_active(0));		# 182
is_ok(scalar $ob->break_active(0));		# 183
is_zero($ob->is_modemlines);			# 184
is_ok($ob->debug_comm(1));			# 185
is_zero($ob->debug_comm(0));			# 186

is_ok(1 == $ob->close);				# 187
undef $ob;

## 188 - 190: Check File Headers

is_ok(open CF, "$cfgfile");			# 188
my ($signature, $name, @values) = <CF>;
close CF;

is_ok(1 == grep(/SerialPort_Configuration_File/, $signature));	# 189

chomp $name;
is_ok($name eq $file);				# 190

## 191 - 192: Check that Values listed exactly once

$fault = 0;
foreach $e (@values) {
    chomp $e;
    ($in, $out) = split(',',$e);
    $fault++ if ($out eq "");
    $required_param{$in}++;
    }
is_zero($fault);				# 191

$fault = 0;
foreach $e (@necessary_param) {
    $fault++ unless ($required_param{$e} ==1);
    }
is_zero($fault);				# 192

## 193 - 200: Reopen as (mostly 5.003 Compatible) Tie using File 

    # constructor = TIEHANDLE method		# 193
unless (is_ok ($ob = tie(*PORT,'AltPort', $cfgfile))) {
    printf "could not reopen port from $cfgfile\n";
    exit 1;
    # next test would die at runtime without $ob
}

    # tie to PRINT method
$tick=$ob->get_tick_count;
$pass=print PORT $line;
$tock=$ob->get_tick_count;

is_ok($pass == 1);				# 194

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

$err=$tock - $tick;
is_bad (($err < 160) or ($err > 210));		# 195
print "<185> elapsed time=$err\n";

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

is_ok($pass == 1);				# 196

$err=$tock - $tick;
is_bad (($err < 180) or ($err > 235));		# 197
print "<205> elapsed time=$err\n";

    # tie to READLINE method
is_ok (500 == $ob->read_const_time(500));	# 198
$tick=$ob->get_tick_count;
$fail = <PORT>;
$tock=$ob->get_tick_count;

is_bad(defined $fail);				# 199
$err=$tock - $tick;
is_bad (($err < 480) or ($err > 540));		# 200
print "<500> elapsed time=$err\n";

## 201 - 215: Record and Field Separators

my $r = "I am the very model of an output record separator";	## =49
#        1234567890123456789012345678901234567890123456789
my $f = "The fields are alive with the sound of music";		## =44
my $ff = "$f, with fields they have sung for a thousand years";	## =93
my $rr = "$r, not animal or vegetable or mineral or any other";	## =98

is_ok($ob->output_record_separator eq "");	# 201
is_ok($ob->output_field_separator eq "");	# 202
$, = "";
$\ = "";

    # tie to PRINT method
$tick=$ob->get_tick_count;
$pass=print PORT $s, $s, $s;
$tock=$ob->get_tick_count;

is_ok($pass == 1);				# 203

$err=$tock - $tick;
is_bad (($err < 160) or ($err > 210));		# 204
print "<185> elapsed time=$err\n";

is_ok($ob->output_field_separator($f) eq "");	# 205
$tick=$ob->get_tick_count;
$pass=print PORT $s, $s, $s;
$tock=$ob->get_tick_count;

is_ok($pass == 1);				# 206

$err=$tock - $tick;
is_bad (($err < 260) or ($err > 310));		# 207
print "<275> elapsed time=$err\n";

is_ok($ob->output_record_separator($r) eq "");	# 208
$tick=$ob->get_tick_count;
$pass=print PORT $s, $s, $s;
$tock=$ob->get_tick_count;

is_ok($pass == 1);				# 209

$err=$tock - $tick;
is_bad (($err < 310) or ($err > 360));		# 210
print "<325> elapsed time=$err\n";

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok($ob->output_record_separator eq $r);	# 211
is_ok($ob->output_field_separator eq $f);	# 212
$, = $ff;
$\ = $rr;

$tick=$ob->get_tick_count;
$pass=print PORT $s, $s, $s;
$tock=$ob->get_tick_count;

$, = "";
$\ = "";
is_ok($pass == 1);				# 213

$err=$tock - $tick;
is_bad (($err < 310) or ($err > 360));		# 214
print "<325> elapsed time=$err\n";

$, = $ff;
$\ = $rr;
is_ok($ob->output_field_separator("") eq $f);	# 215
$tick=$ob->get_tick_count;
$pass=print PORT $s, $s, $s;
$tock=$ob->get_tick_count;

$, = "";
$\ = "";
is_ok($pass == 1);				# 216

$err=$tock - $tick;
is_bad (($err < 410) or ($err > 460));		# 217
print "<425> elapsed time=$err\n";

$, = $ff;
$\ = $rr;
is_ok($ob->output_record_separator("") eq $r);	# 218
$tick=$ob->get_tick_count;
$pass=print PORT $s, $s, $s;
$tock=$ob->get_tick_count;

$, = "";
$\ = "";
is_ok($pass == 1);				# 219

$err=$tock - $tick;
is_bad (($err < 460) or ($err > 510));		# 220
print "<475> elapsed time=$err\n";


is_ok($ob->output_field_separator($f) eq "");	# 221
is_ok($ob->output_record_separator($r) eq "");	# 222

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

is_ok($pass == 1);				# 223

$err=$tock - $tick;
is_bad (($err < 240) or ($err > 295));		# 224
print "<260> elapsed time=$err\n";

is_ok($ob->output_field_separator("") eq $f);	# 225
is_ok($ob->output_record_separator("") eq $r);	# 226

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

## 227 - 241: Port in Use (new + quiet)

my $ob2;
is_bad ($ob2 = Win32::SerialPort->new ($file));		# 227
is_bad (defined $ob2);					# 228
is_zero ($ob2 = Win32::SerialPort->new ($file, 1));	# 229
is_bad ($ob2 = Win32::SerialPort->new ($file, 0));	# 230
is_bad (defined $ob2);					# 231

is_bad ($ob2 = Win32API::CommPort->new ($file));	# 232
is_bad (defined $ob2);					# 233
is_zero ($ob2 = Win32API::CommPort->new ($file, 1));	# 234
is_bad ($ob2 = Win32API::CommPort->new ($file, 0));	# 235
is_bad (defined $ob2);					# 236

is_bad ($ob2 = AltPort->new ($file));		# 237
is_bad (defined $ob2);				# 238

is_zero ($ob2 = AltPort->new ($file, 1));	# 239
is_bad ($ob2 = AltPort->new ($file, 0));	# 240
is_bad (defined $ob2);				# 241

    # destructor = CLOSE method
if ( $] < 5.005 ) {
    is_ok($ob->close);				# 242
}
else {
    is_ok(close PORT);				# 242
}
is_ok(4096 == internal_buffer);			# 243

    # destructor = DESTROY method
undef $ob;					# Don't forget this one!!
untie *PORT;

no strict 'vars';	# turn off strict in order to check
			# "RAW" symbols not exported by default

is_bad(defined $CloseHandle);			# 244
$CloseHandle = 1;	# for "-w"
