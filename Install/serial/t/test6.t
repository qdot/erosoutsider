#! perl -w

use lib '.','./t','..','./lib','../lib';
# can run from here or distribution base
require 5.003;

# Before installation is performed this script should be runnable with
# `perl test6.t time' which pauses `time' seconds (0..5) between pages

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..315\n"; }
END {print "not ok 1\n" unless $loaded;}
use AltPort 0.15;		# check inheritance & export
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
my $instead;
my $out;
my $blk;
my $err;
my $e;
my $tick;
my $tock;
my $patt;
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

#### 3 - 45: Check Port Capabilities from stty() Match Save

my @opts = $ob->stty();
my @saves = @opts;
is_ok (scalar @opts);				# 3
is_ok (9600 == shift @opts);			# 4
is_ok ("intr" eq shift @opts);			# 5

is_ok ("^C" eq shift @opts);			# 6
is_ok ("quit" eq shift @opts);			# 7
is_ok ("^D" eq shift @opts);			# 8
is_ok ("erase" eq shift @opts);			# 9
is_ok ("^H" eq shift @opts);			# 10
is_ok ("kill" eq shift @opts);			# 11
is_ok ("^U" eq shift @opts);			# 12

is_ok ("eof" eq shift @opts);			# 13
is_ok ("^Z" eq shift @opts);			# 14
is_ok ("eol" eq shift @opts);			# 15
is_ok ("^J" eq shift @opts);			# 16
is_ok ("start" eq shift @opts);			# 17
is_ok ("^Q" eq shift @opts);			# 18
is_ok ("stop" eq shift @opts);			# 19
is_ok ("^S" eq shift @opts);			# 20
is_ok ("-echo" eq shift @opts);			# 21
is_ok ("echoe" eq shift @opts);			# 22

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ("echok" eq shift @opts);			# 23
is_ok ("-echonl" eq shift @opts);		# 24
is_ok ("echoke" eq shift @opts);		# 25
is_ok ("-echoctl" eq shift @opts);		# 26
is_ok ("-istrip" eq shift @opts);		# 27
is_ok ("-icrnl" eq shift @opts);		# 28
is_ok ("-ocrnl" eq shift @opts);		# 29
is_ok ("-igncr" eq shift @opts);		# 30
is_ok ("-inlcr" eq shift @opts);		# 31

is_ok ("onlcr" eq shift @opts);			# 32
is_ok ("-opost" eq shift @opts);		# 33
is_ok ("-isig" eq shift @opts);			# 34
is_ok ("-icanon" eq shift @opts);		# 35
is_ok ("cs8" eq shift @opts);			# 36
is_ok ("-cstopb" eq shift @opts);		# 37
is_ok ("-clocal" eq shift @opts);		# 38
is_ok ("-crtscts" eq shift @opts);		# 39
is_ok ("-ixoff" eq shift @opts);		# 40
is_ok ("-ixon" eq shift @opts);			# 41
is_ok ("-parenb" eq shift @opts);		# 42
is_ok ("-parodd" eq shift @opts);		# 43
is_ok ("-inpck" eq shift @opts);		# 44

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_zero (scalar @opts);				# 45

print "Change all the parameters\n";

#### 46 - 74: Modify All Port Capabilities

is_ok ($ob->stty_echo(1) == 1);			# 46
is_ok ($ob->is_xon_char(0x91) == 0x91);		# 47
is_ok ($ob->is_xoff_char(0x92) == 0x92);	# 48

is_ok ($ob->is_baudrate(1200) == 1200);		# 49
is_ok ($ob->is_parity("odd") eq "odd");		# 50
is_ok ($ob->is_databits(7) == 7);		# 51
is_ok ($ob->is_stopbits(2) == 2);		# 52
is_ok ($ob->is_handshake("xoff") eq "xoff");	# 53

is_ok ($ob->stty_echoke(0) == 0);		# 54
is_ok ($ob->stty_echoctl(1) == 1);		# 55
is_ok ($ob->stty_istrip(1) == 1);		# 56
is_ok ($ob->stty_icrnl(1) == 1);		# 57
is_ok ($ob->stty_ocrnl(1) == 1);		# 58
is_ok ($ob->stty_igncr(1) == 1);		# 59
is_ok ($ob->stty_inlcr(1) == 1);		# 60
is_ok ($ob->stty_onlcr(0) == 0);		# 61
is_ok ($ob->stty_opost(1) == 1);		# 62
is_ok ($ob->stty_isig(1) == 1);			# 63
is_ok ($ob->stty_icanon(1) == 1);		# 64
is_ok ($ob->stty_echoe(0) == 0);		# 65
is_ok ($ob->stty_echok(0) == 0);		# 66

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->stty_intr("a") eq "a");		# 67
is_ok ($ob->stty_quit("b") eq "b");		# 68
is_ok ($ob->stty_eof("c") eq "c");		# 69
is_ok ($ob->stty_eol("d") eq "d");		# 70
is_ok ($ob->stty_erase("e") eq "e");		# 71
is_ok ($ob->stty_kill("f") eq "f");		# 72
is_ok ($ob->stty_echonl(1) == 1);		# 73

$pass = $ob->can_parity_enable;
if ($pass) {
    is_ok (scalar $ob->is_parity_enable(1));	# 74
}
else {
    is_zero (scalar $ob->is_parity_enable);	# 74
}

#### 75 - xx: Check Port Capabilities from stty() Match Changes

@opts = $ob->stty();
is_ok (scalar @opts);				# 75
is_ok (1200 == shift @opts);			# 76
is_ok ("intr" eq shift @opts);			# 77
is_ok ("a" eq shift @opts);			# 78
is_ok ("quit" eq shift @opts);			# 79
is_ok ("b" eq shift @opts);			# 80
is_ok ("erase" eq shift @opts);			# 81
is_ok ("e" eq shift @opts);			# 82
is_ok ("kill" eq shift @opts);			# 83
is_ok ("f" eq shift @opts);			# 84

is_ok ("eof" eq shift @opts);			# 85
is_ok ("c" eq shift @opts);			# 86
is_ok ("eol" eq shift @opts);			# 87
is_ok ("d" eq shift @opts);			# 88

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ("start" eq shift @opts);			# 89
is_ok ("0x91" eq shift @opts);			# 90
is_ok ("stop" eq shift @opts);			# 91
is_ok ("0x92" eq shift @opts);			# 92
is_ok ("echo" eq shift @opts);			# 93
is_ok ("-echoe" eq shift @opts);		# 94

is_ok ("-echok" eq shift @opts);		# 95
is_ok ("echonl" eq shift @opts);		# 96
is_ok ("-echoke" eq shift @opts);		# 97
is_ok ("echoctl" eq shift @opts);		# 98
is_ok ("istrip" eq shift @opts);		# 99
is_ok ("icrnl" eq shift @opts);			# 100
is_ok ("ocrnl" eq shift @opts);			# 101
is_ok ("igncr" eq shift @opts);			# 102
is_ok ("inlcr" eq shift @opts);			# 103

is_ok ("-onlcr" eq shift @opts);		# 104
is_ok ("opost" eq shift @opts);			# 105
is_ok ("isig" eq shift @opts);			# 106
is_ok ("icanon" eq shift @opts);		# 107
is_ok ("cs7" eq shift @opts);			# 108
is_ok ("cstopb" eq shift @opts);		# 109
is_ok ("-clocal" eq shift @opts);		# 110

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ("-crtscts" eq shift @opts);		# 111
is_ok ("ixoff" eq shift @opts);			# 112
is_ok ("ixon" eq shift @opts);			# 113

$pass = $ob->can_parity_enable;
if ($pass) {
    is_ok ("parenb" eq shift @opts);		# 114
    is_ok ("parodd" eq shift @opts);		# 115
    is_ok ("inpck" eq shift @opts);		# 116
}
else {
    is_ok ("-parenb" eq shift @opts);		# 114
    is_ok ("-parodd" eq shift @opts);		# 115
    is_ok ("-inpck" eq shift @opts);		# 116
}
is_zero (scalar @opts);				# 117
is_bad ($ob->stty("bad"));			# 118
is_bad ($ob->stty(1234));			# 119
is_bad ($ob->stty("quit",undef));		# 120

#### 121 - 165: Check Port Capabilities from stty() Restore

is_ok ($ob->stty(@saves));			# 121

@opts = $ob->stty();
is_ok (scalar @opts);				# 122
is_ok (scalar @saves == scalar @opts);		# 123
is_ok (9600 == shift @opts);			# 124
is_ok ("intr" eq shift @opts);			# 125

is_ok ("^C" eq shift @opts);			# 126
is_ok ("quit" eq shift @opts);			# 127
is_ok ("^D" eq shift @opts);			# 128
is_ok ("erase" eq shift @opts);			# 129
is_ok ("^H" eq shift @opts);			# 130
is_ok ("kill" eq shift @opts);			# 131
is_ok ("^U" eq shift @opts);			# 132

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ("eof" eq shift @opts);			# 133
is_ok ("^Z" eq shift @opts);			# 134
is_ok ("eol" eq shift @opts);			# 135
is_ok ("^J" eq shift @opts);			# 136
is_ok ("start" eq shift @opts);			# 137
is_ok ("^Q" eq shift @opts);			# 138
is_ok ("stop" eq shift @opts);			# 139
is_ok ("^S" eq shift @opts);			# 140
is_ok ("-echo" eq shift @opts);			# 141
is_ok ("echoe" eq shift @opts);			# 142

is_ok ("echok" eq shift @opts);			# 143
is_ok ("-echonl" eq shift @opts);		# 144
is_ok ("echoke" eq shift @opts);		# 145
is_ok ("-echoctl" eq shift @opts);		# 146
is_ok ("-istrip" eq shift @opts);		# 147
is_ok ("-icrnl" eq shift @opts);		# 148
is_ok ("-ocrnl" eq shift @opts);		# 149
is_ok ("-igncr" eq shift @opts);		# 150
is_ok ("-inlcr" eq shift @opts);		# 151

is_ok ("onlcr" eq shift @opts);			# 152
is_ok ("-opost" eq shift @opts);		# 153
is_ok ("-isig" eq shift @opts);			# 154

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ("-icanon" eq shift @opts);		# 155
is_ok ("cs8" eq shift @opts);			# 156
is_ok ("-cstopb" eq shift @opts);		# 157
is_ok ("-clocal" eq shift @opts);		# 158
is_ok ("-crtscts" eq shift @opts);		# 159
is_ok ("-ixoff" eq shift @opts);		# 160
is_ok ("-ixon" eq shift @opts);			# 161
is_ok ("-parenb" eq shift @opts);		# 162
is_ok ("-parodd" eq shift @opts);		# 163
is_ok ("-inpck" eq shift @opts);		# 164

is_zero (scalar @opts);				# 165

is_ok (Win32::SerialPort::cntl_char(undef) eq "<undef>");	# 166
is_ok (Win32::SerialPort::cntl_char("\c_") eq "^_");		# 167
is_ok (Win32::SerialPort::cntl_char(" ") eq " ");		# 168
is_ok (Win32::SerialPort::cntl_char("\176") eq "~");		# 169
is_ok (Win32::SerialPort::cntl_char("\177") eq "0x7f");		# 170
is_ok (Win32::SerialPort::cntl_char("\200") eq "0x80");		# 171
is_ok (Win32::SerialPort::argv_char("^B") == 0x02);		# 172
is_ok (Win32::SerialPort::argv_char("^_") == 0x1f);		# 173
is_ok (Win32::SerialPort::argv_char("0xab") == 0xab);		# 174
is_ok (Win32::SerialPort::argv_char("0202") == 0x82);		# 175

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

print "Change all the parameters via stty\n";

#### 176 - xxx: Modify All Parameters with stty()

is_ok ($ob->stty_echo == 0);			# 176
is_ok ($ob->stty("echo"));			# 177
is_ok ($ob->stty_echo == 1);			# 178
is_ok ($ob->stty("-echo"));			# 179
is_ok ($ob->stty_echo == 0);			# 180

is_ok ($ob->is_xon_char == 0x11);		# 181
is_ok ($ob->is_xoff_char == 0x13);		# 182
is_ok ($ob->stty("start",0xc1));		# 183
is_ok ($ob->is_xon_char == 0xc1);		# 184
is_ok ($ob->is_xoff_char == 0x13);		# 185
is_ok ($ob->stty("stop",0xc3));			# 186
is_ok ($ob->is_xon_char == 0xc1);		# 187
is_ok ($ob->is_xoff_char == 0xc3);		# 188
is_ok ($ob->stty("start",0x11,"stop",0x13));	# 189
is_ok ($ob->is_xon_char == 0x11);		# 190
is_ok ($ob->is_xoff_char == 0x13);		# 191

is_ok ($ob->baudrate == 9600);			# 192
is_ok ($ob->stty(1200));			# 193
is_ok ($ob->baudrate == 1200);			# 194
is_ok ($ob->stty("9600"));			# 195
is_ok ($ob->baudrate == 9600);			# 196

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->is_databits == 8);			# 197
is_ok ($ob->is_stopbits == 1);			# 198
is_ok ($ob->stty("cs5","cstopb"));		# 199
is_ok ($ob->is_databits == 5);			# 200
is_ok ($ob->is_stopbits == 2);			# 201
is_ok ($ob->stty("cs6","-cstopb"));		# 202
is_ok ($ob->is_databits == 6);			# 203
is_ok ($ob->is_stopbits == 1);			# 204
is_ok ($ob->stty("cs7"));			# 205
is_ok ($ob->is_databits == 7);			# 206
is_ok ($ob->stty("cs8"));			# 207
is_ok ($ob->is_databits == 8);			# 208

is_ok ($ob->is_handshake eq "none");		# 209
is_ok ($ob->stty("ixon"));			# 210
is_ok ($ob->is_handshake eq "xoff");		# 211
is_ok ($ob->stty("-ixon"));			# 212
is_ok ($ob->is_handshake eq "none");		# 213
is_ok ($ob->stty("ixoff"));			# 214
is_ok ($ob->is_handshake eq "xoff");		# 215
is_ok ($ob->stty("-ixoff"));			# 216
is_ok ($ob->is_handshake eq "none");		# 217
is_ok ($ob->stty("crtscts"));			# 218

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->is_handshake eq "rts");		# 219
is_ok ($ob->stty("-crtscts"));			# 220
is_ok ($ob->is_handshake eq "none");		# 221
is_ok ($ob->stty("-clocal"));			# 222
is_ok ($ob->is_handshake eq "dtr");		# 223
is_ok ($ob->stty("clocal"));			# 224
is_ok ($ob->is_handshake eq "none");		# 225

is_ok ($ob->is_parity eq "none");		# 226
is_ok ($ob->stty("parodd"));			# 227
is_ok ($ob->is_parity eq "odd");		# 228
is_ok ($ob->stty("-parodd"));			# 229
is_ok ($ob->is_parity eq "even");		# 230
$pass = $ob->can_parity_enable;
if ($pass) {
    is_ok ($ob->is_parity_enable == 0);		# 231
    is_ok ($ob->stty("inpck"));			# 232
    is_ok ($ob->is_parity_enable != 0);		# 233
    is_ok ($ob->stty("-parenb"));		# 234
    is_ok ($ob->is_parity_enable == 0);		# 235
    is_ok ($ob->stty("parenb"));		# 236
    is_ok ($ob->is_parity_enable != 0);		# 237
    is_ok ($ob->stty("-parenb"));		# 238
}
else {
    is_ok ($ob->is_parity_enable == 0);		# 231
    is_ok ($ob->stty("inpck"));			# 232
    is_ok ($ob->is_parity_enable == 0);		# 233
    is_ok ($ob->stty("-parenb"));		# 234
    is_ok ($ob->is_parity_enable == 0);		# 235
    is_ok ($ob->stty("parenb"));		# 236
    is_ok ($ob->is_parity_enable == 0);		# 237
    is_ok ($ob->stty("-parenb"));		# 238
}
is_ok ($ob->stty("-inpck"));			# 239
is_ok ($ob->is_parity eq "none");		# 240

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->is_parity_enable == 0);		# 241
is_ok ($ob->stty_echoe == 1);			# 242
is_ok ($ob->stty_echok == 1);			# 243
is_ok ($ob->stty_echoke == 1);			# 244
is_ok ($ob->stty_echoctl == 0);			# 245
is_ok ($ob->stty_echonl == 0);			# 246

is_ok ($ob->stty("-echoe","-echok","-echoke"));	# 247
is_ok ($ob->stty("echoctl","echonl"));		# 248
is_ok ($ob->stty_echoe == 0);			# 249
is_ok ($ob->stty_echok == 0);			# 250
is_ok ($ob->stty_echoke == 0);			# 251
is_ok ($ob->stty_echoctl == 1);			# 252
is_ok ($ob->stty_echonl == 1);			# 253

is_ok ($ob->stty("echoe","echok","echoke"));	# 254
is_ok ($ob->stty("-echoctl","-echonl"));	# 255
is_ok ($ob->stty_echoe == 1);			# 256
is_ok ($ob->stty_echok == 1);			# 257
is_ok ($ob->stty_echoke == 1);			# 258
is_ok ($ob->stty_echoctl == 0);			# 259
is_ok ($ob->stty_echonl == 0);			# 260

is_ok ($ob->stty_istrip == 0);			# 261
is_ok ($ob->stty("istrip"));			# 262

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->stty_istrip == 1);			# 263
is_ok ($ob->stty_isig == 0);			# 264
is_ok ($ob->stty_icanon == 0);			# 265
is_ok ($ob->stty("-istrip","isig","icanon"));	# 266
is_ok ($ob->stty_istrip == 0);			# 267
is_ok ($ob->stty_isig == 1);			# 268
is_ok ($ob->stty_icanon == 1);			# 269
is_ok ($ob->stty_opost == 0);			# 270

is_ok ($ob->stty("-isig","-icanon","opost"));	# 271
is_ok ($ob->stty_isig == 0);			# 272
is_ok ($ob->stty_icanon == 0);			# 273
is_ok ($ob->stty_opost == 1);			# 274
is_ok ($ob->stty_ocrnl == 0);			# 275
is_ok ($ob->stty_onlcr == 1);			# 276

is_ok ($ob->stty("ocrnl","-onlcr","-opost"));	# 277
is_ok ($ob->stty_opost == 0);			# 278
is_ok ($ob->stty_ocrnl == 1);			# 279
is_ok ($ob->stty_onlcr == 0);			# 280
is_ok ($ob->stty_icrnl == 0);			# 281

is_ok ($ob->stty("-ocrnl","onlcr","icrnl"));	# 282
is_ok ($ob->stty_ocrnl == 0);			# 283
is_ok ($ob->stty_onlcr == 1);			# 284

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->stty_icrnl == 1);			# 285
is_ok ($ob->stty_igncr == 0);			# 286
is_ok ($ob->stty_inlcr == 0);			# 287

is_ok ($ob->stty("-icrnl","igncr","inlcr"));	# 288
is_ok ($ob->stty_icrnl == 0);			# 289
is_ok ($ob->stty_igncr == 1);			# 290
is_ok ($ob->stty_inlcr == 1);			# 291

is_ok ($ob->stty("-igncr","-inlcr"));		# 292
is_ok ($ob->stty_igncr == 0);			# 293
is_ok ($ob->stty_inlcr == 0);			# 294

is_ok ($ob->stty_intr eq "\cC");		# 295
is_ok ($ob->stty_quit eq "\cD");		# 296
is_ok ($ob->stty_eof eq "\cZ");			# 297
is_ok ($ob->stty_eol eq "\cJ");			# 298
is_ok ($ob->stty_erase eq "\cH");		# 299
is_ok ($ob->stty_kill eq "\cU");		# 300

is_ok ($ob->stty("intr",ord("A"),"quit",ord "B",
		 "eof",0x43,"eol",68,
		 "erase",0105,"kill",0x66));	# 301

is_ok ($ob->stty_intr eq "A");			# 302
is_ok ($ob->stty_quit eq "B");			# 303
is_ok ($ob->stty_eof eq "C");			# 304
is_ok ($ob->stty_eol eq "D");			# 305
is_ok ($ob->stty_erase eq "E");			# 306
is_ok ($ob->stty_kill eq "f");			# 307

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->stty("intr","^C","quit",4, "eof",032,"eol",0x0a,
		 "erase",ord("\cH"),
		 "kill",ord "\cU"));		# 308

is_ok ($ob->stty_intr eq "\cC");		# 309
is_ok ($ob->stty_quit eq "\cD");		# 310
is_ok ($ob->stty_eof eq "\cZ");			# 311
is_ok ($ob->stty_eol eq "\cJ");			# 312
is_ok ($ob->stty_erase eq "\cH");		# 313
is_ok ($ob->stty_kill eq "\cU");		# 314

is_ok ($ob->close);				# 315
undef $ob;
