#! perl -w

use lib '.','./t','..','./lib','../lib';
# can run from here or distribution base
require 5.003;

# Before installation is performed this script should be runnable with
# `perl test4.t time' which pauses `time' seconds (0..5) between pages

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..516\n"; }
END {print "not ok 1\n" unless $loaded;}
use AltPort 0.18;		# check inheritance & export
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
my @opts;
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

#### 3 - 26: Check Port Capabilities Match Save

is_ok ($ob->is_xon_char == 0x11);		# 3
is_ok ($ob->is_xoff_char == 0x13);		# 4
is_ok ($ob->is_eof_char == 0);			# 5
is_ok ($ob->is_event_char == 0);		# 6
is_ok ($ob->is_error_char == 0);		# 7
is_ok ($ob->is_baudrate == 9600);		# 8
is_ok ($ob->is_parity eq "none");		# 9
is_ok ($ob->is_databits == 8);			# 10
is_ok ($ob->is_stopbits == 1);			# 11
is_ok ($ob->is_handshake eq "none");		# 12
is_ok ($ob->is_read_interval == 0xffffffff);	# 13
is_ok ($ob->is_read_const_time == 0);		# 14
is_ok ($ob->is_read_char_time == 0);		# 15
is_ok ($ob->is_write_const_time == 200);	# 16
is_ok ($ob->is_write_char_time == 10);		# 17

($in, $out)= $ob->are_buffers;
is_ok (4096 == $in);				# 18
is_ok (4096 == $out);				# 19

is_ok ($ob->alias eq "AltPort");		# 20
is_ok ($ob->is_binary == 1);			# 21
is_zero (scalar $ob->is_parity_enable);		# 22

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->is_xoff_limit == 200);		# 23
is_ok ($ob->is_xon_limit == 100);		# 24
is_ok ($ob->user_msg == 1);			# 25
is_ok ($ob->error_msg == 1);			# 26

### 27 - 65: Defaults for stty and lookfor

@opts = $ob->are_match;
is_ok ($#opts == 0);				# 27
is_ok ($opts[0] eq "\n");			# 28
is_ok ($ob->lookclear == 1);			# 29
is_ok ($ob->is_prompt eq "");			# 30
is_ok ($ob->lookfor eq "");			# 31
is_ok ($ob->streamline eq "");			# 32

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "");				# 33
is_ok ($out eq "");				# 34
is_ok ($patt eq "");				# 35
is_ok ($instead eq "");				# 36
is_ok ($ob->matchclear eq "");			# 37

is_ok ($ob->stty_intr eq "\cC");		# 38
is_ok ($ob->stty_quit eq "\cD");		# 39
is_ok ($ob->stty_eof eq "\cZ");			# 40
is_ok ($ob->stty_eol eq "\cJ");			# 41
is_ok ($ob->stty_erase eq "\cH");		# 42
is_ok ($ob->stty_kill eq "\cU");		# 43
is_ok ($ob->stty_bsdel eq "\cH \cH");		# 44

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

my $space76 = " "x76;
my $cstring = "\r$space76\r";
is_ok ($ob->stty_clear eq $cstring);		# 45

is_ok ($ob->is_stty_intr == 3);			# 46
is_ok ($ob->is_stty_quit == 4);			# 47
is_ok ($ob->is_stty_eof == 26);			# 48
is_ok ($ob->is_stty_eol == 10);			# 49
is_ok ($ob->is_stty_erase == 8);		# 50
is_ok ($ob->is_stty_kill == 21);		# 51

is_ok ($ob->stty_echo == 0);			# 52
is_ok ($ob->stty_echoe == 1);			# 53
is_ok ($ob->stty_echok == 1);			# 54
is_ok ($ob->stty_echonl == 0);			# 55
is_ok ($ob->stty_echoke == 1);			# 56
is_ok ($ob->stty_echoctl == 0);			# 57
is_ok ($ob->stty_istrip == 0);			# 58
is_ok ($ob->stty_icrnl == 0);			# 59
is_ok ($ob->stty_ocrnl == 0);			# 60
is_ok ($ob->stty_igncr == 0);			# 61
is_ok ($ob->stty_inlcr == 0);			# 62
is_ok ($ob->stty_onlcr == 1);			# 63
is_ok ($ob->stty_opost == 0);			# 64
is_ok ($ob->stty_isig == 0);			# 65
is_ok ($ob->stty_icanon == 0);			# 66

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

#### 67 - 73: Application Parameter Defaults

is_ok ($ob->devicetype eq 'none');		# 67
is_ok ($ob->hostname eq 'localhost');		# 68
is_zero ($ob->hostaddr);			# 69
is_ok ($ob->datatype eq 'raw');			# 70
is_ok ($ob->cfg_param_1 eq 'none');		# 71
is_ok ($ob->cfg_param_2 eq 'none');		# 72
is_ok ($ob->cfg_param_3 eq 'none');		# 73

print "Change all the parameters\n";

#### 74 - 227: Modify All Port Capabilities

is_ok ($ob->is_xon_char(1) == 0x01);		# 74
is_ok ($ob->is_xoff_char(2) == 0x02);		# 75

is_ok ($ob->devicetype('type') eq 'type');	# 76
is_ok ($ob->hostname('any') eq 'any');		# 77
is_ok ($ob->hostaddr(9000) == 9000);		# 78
is_ok ($ob->datatype('fixed') eq 'fixed');	# 79
is_ok ($ob->cfg_param_1('p1') eq 'p1');		# 80
is_ok ($ob->cfg_param_2('p2') eq 'p2');		# 81
is_ok ($ob->cfg_param_3('p3') eq 'p3');		# 82

$pass = $ob->can_spec_char;			# generic port can't set
if ($pass) {
    is_ok ($ob->is_eof_char(4) == 0x04);	# 83
    is_ok ($ob->is_event_char(3) == 0x03);	# 84
    is_ok ($ob->is_error_char(5) == 5);		# 85
}
else {
    is_ok ($ob->is_eof_char(4) == 0);		# 83
    is_ok ($ob->is_event_char(3) == 0);		# 84
    is_ok ($ob->is_error_char(5) == 0);		# 85
}

is_ok ($ob->is_baudrate(1200) == 1200);		# 86
is_ok ($ob->is_parity("odd") eq "odd");		# 87

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->is_databits(7) == 7);		# 88
is_ok ($ob->is_stopbits(2) == 2);		# 89
is_ok ($ob->is_handshake("xoff") eq "xoff");	# 90
is_ok ($ob->is_read_interval(0) == 0x0);	# 91
is_ok ($ob->is_read_const_time(1000) == 1000);	# 92
is_ok ($ob->is_read_char_time(50) == 50);	# 93
is_ok ($ob->is_write_const_time(2000) == 2000);	# 94
is_ok ($ob->is_write_char_time(75) == 75);	# 95

($in, $out)= $ob->buffers(8092, 1024);
is_ok (8092 == $ob->is_read_buf);		# 96
is_ok (1024 == $ob->is_write_buf);		# 97

is_ok ($ob->alias("oddPort") eq "oddPort");	# 98
is_ok ($ob->is_xoff_limit(45) == 45);		# 99

$pass = $ob->can_parity_enable;
if ($pass) {
    is_ok (scalar $ob->is_parity_enable(1));	# 100
}
else {
    is_zero (scalar $ob->is_parity_enable);	# 100
}

is_ok ($ob->is_xon_limit(90) == 90);		# 101
is_zero ($ob->user_msg(0));			# 102
is_zero ($ob->error_msg(0));			# 103

@opts = $ob->are_match ("END","Bye");
is_ok ($#opts == 1);				# 104
is_ok ($opts[0] eq "END");			# 105
is_ok ($opts[1] eq "Bye");			# 106
is_ok ($ob->stty_echo(0) == 0);			# 107
is_ok ($ob->lookclear("Good Bye, Hello") == 1);	# 108

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->is_prompt("Hi:") eq "Hi:");		# 109
is_ok ($ob->lookfor eq "Good ");		# 110

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "Bye");				# 111
is_ok ($out eq ", Hello");			# 112
is_ok ($patt eq "Bye");				# 113
is_ok ($instead eq "");				# 114
is_ok ($ob->matchclear eq "Bye");		# 115
is_ok ($ob->matchclear eq "");			# 116

is_ok ($ob->lookclear("Bye, Bye, Love. The END has come") == 1);	# 117
is_ok ($ob->lookfor eq "");			# 118

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "Bye");				# 119
is_ok ($out eq ", Bye, Love. The END has come");# 120
is_ok ($patt eq "Bye");				# 121
is_ok ($instead eq "");				# 122
is_ok ($ob->matchclear eq "Bye");		# 123

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "");				# 124
is_ok ($out eq ", Bye, Love. The END has come");# 125
is_ok ($patt eq "Bye");				# 126
is_ok ($instead eq "");				# 127

is_ok ($ob->lookfor eq ", ");			# 128
($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "Bye");				# 129
is_ok ($out eq ", Love. The END has come");	# 130

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($patt eq "Bye");				# 131
is_ok ($instead eq "");				# 132
is_ok ($ob->matchclear eq "Bye");		# 133

is_ok ($ob->lookfor eq ", Love. The ");		# 134
($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "END");				# 135
is_ok ($out eq " has come");			# 136
is_ok ($patt eq "END");				# 137
is_ok ($instead eq "");				# 138
is_ok ($ob->matchclear eq "END");		# 139
is_ok ($ob->lookfor eq "");			# 140
is_ok ($ob->matchclear eq "");			# 141

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "");				# 142
is_ok ($patt eq "");				# 143
is_ok ($instead eq " has come");		# 144

is_ok ($ob->lookclear("First\nSecond\nThe END") == 1);	# 145
is_ok ($ob->lookfor eq "First\nSecond\nThe ");	# 146
($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "END");				# 147
is_ok ($out eq "");				# 148
is_ok ($patt eq "END");				# 149
is_ok ($instead eq "");				# 150

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->lookclear("Good Bye, Hello") == 1);	# 151
is_ok ($ob->streamline eq "Good ");		# 152

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "Bye");				# 153
is_ok ($out eq ", Hello");			# 154
is_ok ($patt eq "Bye");				# 155
is_ok ($instead eq "");				# 156

is_ok ($ob->lookclear("Bye, Bye, Love. The END has come") == 1);	# 157
is_ok ($ob->streamline eq "");			# 158

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "Bye");				# 159
is_ok ($out eq ", Bye, Love. The END has come");# 160

is_ok ($patt eq "Bye");				# 161
is_ok ($instead eq "");				# 162
is_ok ($ob->matchclear eq "Bye");		# 163

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "");				# 164
is_ok ($out eq ", Bye, Love. The END has come");# 165
is_ok ($patt eq "Bye");				# 166
is_ok ($instead eq "");				# 167

is_ok ($ob->streamline eq ", ");		# 168
($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "Bye");				# 169
is_ok ($out eq ", Love. The END has come");	# 170
is_ok ($patt eq "Bye");				# 171

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($instead eq "");				# 172
is_ok ($ob->matchclear eq "Bye");		# 173

is_ok ($ob->streamline eq ", Love. The ");	# 174
($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "END");				# 175
is_ok ($out eq " has come");			# 176
is_ok ($patt eq "END");				# 177
is_ok ($instead eq "");				# 178
is_ok ($ob->matchclear eq "END");		# 179
is_ok ($ob->streamline eq "");			# 180
is_ok ($ob->matchclear eq "");			# 181

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "");				# 182
is_ok ($patt eq "");				# 183
is_ok ($instead eq " has come");		# 184

is_ok ($ob->lookclear("First\nSecond\nThe END") == 1);	# 185
is_ok ($ob->streamline eq "First\nSecond\nThe ");	# 186
($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "END");				# 187
is_ok ($out eq "");				# 188
is_ok ($patt eq "END");				# 189
is_ok ($instead eq "");				# 190

is_ok ($ob->stty_intr("a") eq "a");		# 191
is_ok ($ob->stty_quit("b") eq "b");		# 192
is_ok ($ob->stty_eof("c") eq "c");		# 193

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->stty_eol("d") eq "d");		# 194
is_ok ($ob->stty_erase("e") eq "e");		# 195
is_ok ($ob->stty_kill("f") eq "f");		# 196

is_ok ($ob->is_stty_intr == 97);		# 197
is_ok ($ob->is_stty_quit == 98);		# 198
is_ok ($ob->is_stty_eof == 99);			# 199

is_ok ($ob->is_stty_eol == 100);		# 200
is_ok ($ob->is_stty_erase == 101);		# 201
is_ok ($ob->is_stty_kill == 102);		# 202

is_ok ($ob->stty_clear("g") eq "g");		# 203
is_ok ($ob->stty_bsdel("h") eq "h");		# 204
is_ok ($ob->stty_echoe(0) == 0);		# 205

is_ok ($ob->stty_echok(0) == 0);		# 206
is_ok ($ob->stty_echonl(1) == 1);		# 207
is_ok ($ob->stty_echoke(0) == 0);		# 208
is_ok ($ob->stty_echoctl(1) == 1);		# 209
is_ok ($ob->stty_istrip(1) == 1);		# 210
is_ok ($ob->stty_icrnl(1) == 1);		# 211
is_ok ($ob->stty_ocrnl(1) == 1);		# 212
is_ok ($ob->stty_igncr(1) == 1);		# 213
is_ok ($ob->stty_inlcr(1) == 1);		# 214
is_ok ($ob->stty_onlcr(0) == 0);		# 215

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->stty_opost(1) == 1);		# 216
is_ok ($ob->stty_isig(1) == 1);			# 217
is_ok ($ob->stty_icanon(1) == 1);		# 218

is_ok ($ob->lookclear == 1);			# 219
is_ok ($ob->is_prompt eq "Hi:");		# 220
is_ok ($ob->is_prompt("") eq "");		# 221
is_ok ($ob->lookfor eq "");			# 222

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "");				# 223
is_ok ($out eq "");				# 224
is_ok ($patt eq "");				# 225
is_ok ($instead eq "");				# 226
is_ok ($ob->stty_echo(1) == 1);			# 227

#### 228 - 290: Check Port Capabilities Match Changes

is_ok ($ob->is_xon_char == 0x01);		# 228
is_ok ($ob->is_xoff_char == 0x02);		# 229

$pass = $ob->can_spec_char;			# generic port can't set
if ($pass) {
    is_ok ($ob->is_eof_char == 0x04);		# 230
    is_ok ($ob->is_event_char == 0x03);		# 231
    is_ok ($ob->is_error_char == 5);		# 232
}
else {
    is_ok ($ob->is_eof_char == 0);		# 230
    is_ok ($ob->is_event_char == 0);		# 231
    is_ok ($ob->is_error_char == 0);		# 232
}
is_ok ($ob->is_baudrate == 1200);		# 233

is_ok ($ob->devicetype eq 'type');		# 234
is_ok ($ob->hostname eq 'any');			# 235
is_ok ($ob->hostaddr == 9000);			# 236

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->datatype eq 'fixed');		# 237
is_ok ($ob->cfg_param_1 eq 'p1');		# 238
is_ok ($ob->cfg_param_2 eq 'p2');		# 239
is_ok ($ob->cfg_param_3 eq 'p3');		# 240

is_ok ($ob->is_databits == 7);			# 241
is_ok ($ob->is_stopbits == 2);			# 242
is_ok ($ob->is_handshake eq "xoff");		# 243
is_ok ($ob->is_read_interval == 0x0);		# 244
is_ok ($ob->is_read_const_time == 1000);	# 245
is_ok ($ob->is_read_char_time == 50);		# 246
is_ok ($ob->is_write_const_time == 2000);	# 247
is_ok ($ob->is_write_char_time == 75);		# 248

($in, $out)= $ob->are_buffers;
is_ok (8092 == $in);				# 249
is_ok (1024 == $out);				# 250
is_ok ($ob->alias eq "oddPort");		# 251

$pass = $ob->can_parity_enable;
if ($pass) {
    is_ok (scalar $ob->is_parity_enable);	# 252
}
else {
    is_zero (scalar $ob->is_parity_enable);	# 252
}

is_ok ($ob->is_xoff_limit == 45);		# 253
is_ok ($ob->is_xon_limit == 90);		# 254

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_zero ($ob->user_msg);			# 255
is_zero ($ob->error_msg);			# 256

@opts = $ob->are_match;
is_ok ($#opts == 1);				# 257
is_ok ($opts[0] eq "END");			# 258
is_ok ($opts[1] eq "Bye");			# 259

is_ok ($ob->stty_intr eq "a");			# 260
is_ok ($ob->stty_quit eq "b");			# 261
is_ok ($ob->stty_eof eq "c");			# 262
is_ok ($ob->stty_eol eq "d");			# 263
is_ok ($ob->stty_erase eq "e");			# 264
is_ok ($ob->stty_kill eq "f");			# 265

is_ok ($ob->is_stty_intr == 97);		# 266
is_ok ($ob->is_stty_quit == 98);		# 267
is_ok ($ob->is_stty_eof == 99);			# 268

is_ok ($ob->is_stty_eol == 100);		# 269
is_ok ($ob->is_stty_erase == 101);		# 270
is_ok ($ob->is_stty_kill == 102);		# 271

is_ok ($ob->stty_clear eq "g");			# 272
is_ok ($ob->stty_bsdel eq "h");			# 273

is_ok ($ob->stty_echo == 1);			# 274
is_ok ($ob->stty_echoe == 0);			# 275
is_ok ($ob->stty_echok == 0);			# 276

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->stty_echonl == 1);			# 277
is_ok ($ob->stty_echoke == 0);			# 278
is_ok ($ob->stty_echoctl == 1);			# 279

is_ok ($ob->stty_istrip == 1);			# 280
is_ok ($ob->stty_icrnl == 1);			# 281
is_ok ($ob->stty_ocrnl == 1);			# 282
is_ok ($ob->stty_igncr == 1);			# 283
is_ok ($ob->stty_inlcr == 1);			# 284
is_ok ($ob->stty_onlcr == 0);			# 285
is_ok ($ob->stty_opost == 1);			# 286
is_ok ($ob->stty_isig == 1);			# 287
is_ok ($ob->stty_icanon == 1);			# 288
is_ok ($ob->is_parity eq "odd");		# 289

print "Restore all the parameters\n";

is_ok ($ob->restart($cfgfile));			# 290

#### 291 - 361: Check Port Capabilities Match Original

is_ok ($ob->is_xoff_char == 0x13);		# 291
is_ok ($ob->is_eof_char == 0);			# 292
is_ok ($ob->is_event_char == 0);		# 293
is_ok ($ob->is_error_char == 0);		# 294
is_ok ($ob->is_baudrate == 9600);		# 295
is_ok ($ob->is_parity eq "none");		# 296
is_ok ($ob->is_databits == 8);			# 297

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->is_stopbits == 1);			# 298
is_ok ($ob->is_handshake eq "none");		# 299
is_ok ($ob->is_read_interval == 0xffffffff);	# 300
is_ok ($ob->is_read_const_time == 0);		# 301

is_ok ($ob->is_read_char_time == 0);		# 302
is_ok ($ob->is_write_const_time == 200);	# 303
is_ok ($ob->is_write_char_time == 10);		# 304

($in, $out)= $ob->are_buffers;
is_ok (4096 == $in);				# 305
is_ok (4096 == $out);				# 306

is_ok ($ob->alias eq "AltPort");		# 307
is_ok ($ob->is_binary == 1);			# 308
is_zero (scalar $ob->is_parity_enable);		# 309
is_ok ($ob->is_xoff_limit == 200);		# 310
is_ok ($ob->is_xon_limit == 100);		# 311
is_ok ($ob->user_msg == 1);			# 312
is_ok ($ob->error_msg == 1);			# 313

@opts = $ob->are_match("\n");
is_ok ($#opts == 0);				# 314
is_ok ($opts[0] eq "\n");			# 315
is_ok ($ob->lookclear == 1);			# 316
is_ok ($ob->is_prompt eq "");			# 317
is_ok ($ob->lookfor eq "");			# 318

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "");				# 319
is_ok ($out eq "");				# 320
is_ok ($patt eq "");				# 321
is_ok ($instead eq "");				# 322
is_ok ($ob->streamline eq "");			# 323
is_ok ($ob->matchclear eq "");			# 324

is_ok ($ob->stty_intr eq "\cC");		# 325
is_ok ($ob->stty_quit eq "\cD");		# 326
is_ok ($ob->stty_eof eq "\cZ");			# 327
is_ok ($ob->stty_eol eq "\cJ");			# 328
is_ok ($ob->stty_erase eq "\cH");		# 329
is_ok ($ob->stty_kill eq "\cU");		# 330
is_ok ($ob->stty_clear eq $cstring);		# 331
is_ok ($ob->stty_bsdel eq "\cH \cH");		# 332

is_ok ($ob->is_stty_intr == 3);			# 333
is_ok ($ob->is_stty_quit == 4);			# 334
is_ok ($ob->is_stty_eof == 26);			# 335
is_ok ($ob->is_stty_eol == 10);			# 336
is_ok ($ob->is_stty_erase == 8);		# 337
is_ok ($ob->is_stty_kill == 21);		# 338

is_ok ($ob->stty_echo == 0);			# 339
is_ok ($ob->stty_echoe == 1);			# 340

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok ($ob->stty_echok == 1);			# 341
is_ok ($ob->stty_echonl == 0);			# 342
is_ok ($ob->stty_echoke == 1);			# 343
is_ok ($ob->stty_echoctl == 0);			# 344
is_ok ($ob->stty_istrip == 0);			# 345

is_ok ($ob->stty_icrnl == 0);			# 346
is_ok ($ob->stty_ocrnl == 0);			# 347
is_ok ($ob->stty_igncr == 0);			# 348
is_ok ($ob->stty_inlcr == 0);			# 349
is_ok ($ob->stty_onlcr == 1);			# 350
is_ok ($ob->stty_opost == 0);			# 351
is_ok ($ob->stty_isig == 0);			# 352
is_ok ($ob->stty_icanon == 0);			# 353
is_ok ($ob->is_xon_char == 0x11);		# 354

is_zero ($ob->hostaddr);			# 355
is_ok ($ob->datatype eq 'raw');			# 356
is_ok ($ob->cfg_param_1 eq 'none');		# 357
is_ok ($ob->cfg_param_2 eq 'none');		# 358
is_ok ($ob->cfg_param_3 eq 'none');		# 359
is_ok ($ob->devicetype eq 'none');		# 360
is_ok ($ob->hostname eq 'localhost');		# 361

## 362 - 372: Status

is_ok (4 == scalar (@opts = $ob->is_status));	# 362

# for an unconnected port, should be $in=0, $out=0, $blk=0, $err=0

($blk, $in, $out, $err)=@opts;
is_ok (defined $blk);				# 363
is_zero ($in);					# 364
is_zero ($out);					# 365
is_zero ($blk);					# 366
if ($blk) { printf "status: blk=%lx\n", $blk; }
is_zero ($err);					# 367

($blk, $in, $out, $err)=$ob->is_status(0x150);	# test only
is_ok ($err == 0x150);				# 368
### printf "error: err=%lx\n", $err;

($blk, $in, $out, $err)=$ob->is_status(0x0f);	# test only
is_ok ($err == 0x15f);				# 369

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

print "=== Force all Status Errors\n";

($blk, $in, $out, $err)=$ob->status;
is_ok ($err == 0x15f);				# 370

is_ok ($ob->reset_error == 0x15f);		# 371

($blk, $in, $out, $err)=$ob->is_status;
is_zero ($err);					# 372

# 373 - 375: "Instant" return for read_interval=0xffffffff

$tick=$ob->get_tick_count;
($in, $in2) = $ob->read(10);
$tock=$ob->get_tick_count;

is_zero ($in);					# 373
is_bad ($in2);					# 374
$out=$tock - $tick;
is_ok ($out < 100);				# 375
print "<0> elapsed time=$out\n";

# 376 - 384: 1 Second Constant Timeout

is_ok (2000 == $ob->is_read_const_time(2000));	# 376
is_zero ($ob->is_read_interval(0));		# 377
is_ok (100 == $ob->is_read_char_time(100));	# 378
is_zero ($ob->is_read_const_time(0));		# 379
is_zero ($ob->is_read_char_time(0));		# 380

is_ok (0xffffffff == $ob->is_read_interval(0xffffffff));	# 381
is_ok (1000 == $ob->is_write_const_time(1000));	# 382
is_zero ($ob->is_write_char_time(0));		# 383
is_ok ("rts" eq $ob->is_handshake("rts"));	# 384 ; so it blocks

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

# 385 - 386

$e="12345678901234567890";

$tick=$ob->get_tick_count;
is_zero ($ob->write($e));			# 385
$tock=$ob->get_tick_count;

$out=$tock - $tick;
is_bad (($out < 800) or ($out > 1300));		# 386
print "<1000> elapsed time=$out\n";

# 387 - 389: 2.5 Second Timeout Constant+Character

is_ok (75 ==$ob->is_write_char_time(75));	# 387

$tick=$ob->get_tick_count;
is_zero ($ob->write($e));			# 388
$tock=$ob->get_tick_count;

$out=$tock - $tick;
is_bad (($out < 2300) or ($out > 2900));	# 389
print "<2500> elapsed time=$out\n";


# 390 - 398: 1.5 Second Read Constant Timeout

is_ok (1500 == $ob->is_read_const_time(1500));	# 390
is_zero ($ob->is_read_interval(0));		# 291
is_ok (scalar $ob->purge_all);			# 392

$tick=$ob->get_tick_count;
$in = $ob->read_bg(10);
$tock=$ob->get_tick_count;

is_zero ($in);					# 393
$out=$tock - $tick;
is_ok ($out < 100);				# 394
print "<0> elapsed time=$out\n";

($pass, $in, $in2) = $ob->read_done(0);
$tock=$ob->get_tick_count;

is_zero ($pass);				# 395
is_zero ($in);					# 396
is_ok ($in2 eq "");				# 397
$out=$tock - $tick;
is_ok ($out < 100);				# 398

if ($naptime) {
    print "++++ page break\n";
}

print "A Series of 1 Second Groups with Background I/O\n";

is_zero ($ob->write_bg($e));			# 399
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 400
is_zero ($out);					# 401

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 402
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 403

($blk, $in, $out, $err)=$ob->is_status;
is_zero ($in);					# 404
is_ok ($out == 20);				# 405
is_ok ($blk == 1);				# 406
is_zero ($err);					# 407

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);
is_ok ($pass);					# 408
is_zero ($in);					# 409
is_ok ($in2 eq "");				# 410
$tock=$ob->get_tick_count;			# expect about 2 seconds
$out=$tock - $tick;
is_bad (($out < 1800) or ($out > 2400));	# 411
print "<2000> elapsed time=$out\n";
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 412

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);		# double check ok?
is_ok ($pass);					# 413
is_zero ($in);					# 414
is_ok ($in2 eq "");				# 415

sleep 1;
($pass, $out) = $ob->write_done(0);
is_ok ($pass);					# 416
is_zero ($out);					# 417
$tock=$ob->get_tick_count;			# expect about 4 seconds
$out=$tock - $tick;
is_bad (($out < 3800) or ($out > 4400));	# 418
print "<4000> elapsed time=$out\n";

$tick=$ob->get_tick_count;			# new timebase
$in = $ob->read_bg(10);
is_zero ($in);					# 419
($pass, $in, $in2) = $ob->read_done(0);

is_zero ($pass);				# 420 
is_zero ($in);					# 421
is_ok ($in2 eq "");				# 422

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 423
## print "testing fail message:\n";
$in = $ob->read_bg(10);
is_bad (defined $in);				# 424 - already reading

($pass, $in, $in2) = $ob->read_done(1);
is_ok ($pass);					# 425
is_zero ($in);					# 426 
is_ok ($in2 eq "");				# 427
$tock=$ob->get_tick_count;			# expect 1.5 seconds
$out=$tock - $tick;
is_bad (($out < 1300) or ($out > 1800));	# 427
print "<1500> elapsed time=$out\n";

$tick=$ob->get_tick_count;			# new timebase
$in = $ob->read_bg(10);
is_zero ($in);					# 429
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 430
is_zero ($in);					# 431
is_ok ($in2 eq "");				# 432

sleep 1;
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 433 
is_ok (scalar $ob->purge_rx);			# 434 
($pass, $in, $in2) = $ob->read_done(1);
is_ok (scalar $ob->purge_rx);			# 437 
if (Win32::IsWinNT()) {
    is_zero ($pass);				# 435 
}
else {
    is_ok ($pass);				# 436 
}
is_zero ($in);					# 437 
is_ok ($in2 eq "");				# 438
$tock=$ob->get_tick_count;			# expect 1 second
$out=$tock - $tick;
is_bad (($out < 900) or ($out > 1200));		# 439
print "<1000> elapsed time=$out\n";

is_zero ($ob->write_bg($e));			# 440
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 441

sleep 1;
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 442
is_ok (scalar $ob->purge_tx);			# 443 
($pass, $out) = $ob->write_done(1);
is_ok (scalar $ob->purge_tx);			# 444 
if (Win32::IsWinNT()) {
    is_zero ($pass);				# 445 
}
else {
    is_ok ($pass);				# 445 
}
$tock=$ob->get_tick_count;			# expect 2 seconds
$out=$tock - $tick;
is_bad (($out < 1900) or ($out > 2200));	# 446
print "<2000> elapsed time=$out\n";

$tick=$ob->get_tick_count;			# new timebase
$in = $ob->read_bg(10);
is_zero ($in);					# 447
($pass, $in, $in2) = $ob->read_done(0);
is_zero ($pass);				# 448
is_zero ($ob->write_bg($e));			# 449
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 450

sleep 1;
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 451

($pass, $in, $in2) = $ob->read_done(1);
is_ok ($pass);					# 452 
is_zero ($in);					# 453
is_ok ($in2 eq "");				# 454
($pass, $out) = $ob->write_done(0);
is_zero ($pass);				# 455
$tock=$ob->get_tick_count;			# expect 1.5 seconds
$out=$tock - $tick;
is_bad (($out < 1300) or ($out > 1800));	# 456
print "<1500> elapsed time=$out\n";

($pass, $out) = $ob->write_done(1);
is_ok ($pass);					# 457
$tock=$ob->get_tick_count;			# expect 2.5 seconds
$out=$tock - $tick;
is_bad (($out < 2300) or ($out > 2800));	# 458
print "<2500> elapsed time=$out\n";

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok(1 == $ob->user_msg);			# 459
is_zero(scalar $ob->user_msg(0));		# 460
is_ok(1 == $ob->user_msg(1));			# 461
is_ok(1 == $ob->error_msg);			# 462
is_zero(scalar $ob->error_msg(0));		# 463
is_ok(1 == $ob->error_msg(1));			# 464

# 465 - 516 Test and Normal "lookclear"

is_ok ($ob->stty_echo(0) == 0);			# 465
is_ok ($ob->lookclear("Before\nAfter") == 1);	# 466
is_ok ($ob->lookfor eq "Before");		# 467

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "\n");				# 468
is_ok ($out eq "After");			# 469
is_ok ($patt eq "\n");				# 470
is_ok ($instead eq "");				# 471

is_ok ($ob->lookfor eq "");			# 472
($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "");				# 473
is_ok ($patt eq "");				# 474
is_ok ($instead eq "After");			# 475

@opts = $ob->are_match ("B*e","ab..ef","-re","12..56","END");
is_ok ($#opts == 4);				# 476
is_ok ($opts[2] eq "-re");			# 477
is_ok ($ob->lookclear("Good Bye, the END, Hello") == 1);	# 478
is_ok ($ob->lookfor eq "Good Bye, the ");	# 479

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "END");				# 480
is_ok ($out eq ", Hello");			# 481
is_ok ($patt eq "END");				# 482
is_ok ($instead eq "");				# 483

is_ok ($ob->lookclear("Good Bye, the END, Hello") == 1);	# 484
is_ok ($ob->streamline eq "Good Bye, the ");	# 485

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "END");				# 486
is_ok ($out eq ", Hello");			# 487
is_ok ($patt eq "END");				# 488
is_ok ($instead eq "");				# 489

is_ok ($ob->lookclear("Good B*e, abcdef, 123456") == 1);	# 490
is_ok ($ob->lookfor eq "Good ");		# 491

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "B*e");				# 492
is_ok ($out eq ", abcdef, 123456");		# 493
is_ok ($patt eq "B*e");				# 494
is_ok ($instead eq "");				# 495

is_ok ($ob->lookfor eq ", abcdef, ");		# 496

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "123456");			# 497
is_ok ($out eq "");				# 498
is_ok ($patt eq "12..56");			# 499
is_ok ($instead eq "");				# 500

is_ok ($ob->lookclear("Good B*e, abcdef, 123456") == 1);	# 501
is_ok ($ob->streamline eq "Good ");		# 502

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "B*e");				# 503
is_ok ($out eq ", abcdef, 123456");		# 504
is_ok ($patt eq "B*e");				# 505
is_ok ($instead eq "");				# 506

is_ok ($ob->streamline eq ", abcdef, ");	# 507

($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "123456");			# 508
is_ok ($out eq "");				# 509
is_ok ($patt eq "12..56");			# 510
is_ok ($instead eq "");				# 511

@necessary_param = Win32::SerialPort->set_test_mode_active(0);

is_bad ($ob->lookclear("Good\nBye"));		# 512
is_ok ($ob->lookfor eq "");			# 513
($in, $out, $patt, $instead) = $ob->lastlook;
is_ok ($in eq "");				# 514
is_ok ($out eq "");				# 515
is_ok ($patt eq "");				# 516

undef $ob;
