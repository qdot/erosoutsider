#! perl -w

use lib '.','./t','./lib','../lib';
# can run from here or distribution base

# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test?.t'
# `perl test?.t time' pauses `time' seconds (0..5) between pages

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..166\n"; }
END {print "not ok 1\n" unless $loaded;}
use Win32API::CommPort qw( :RAW :COMMPROP :DCB 0.12 );	# check misc. exports
use Win32;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

use strict;

my $tc = 2;		# next test number
my $null=0;
my $event=0;
my $ok=0;

sub is_ok {
    my $result = shift;
    printf (($result ? "" : "not ")."ok %d\n",$tc++);
    return $result;
}

my $naptime = 0;	# pause between output pages
if (@ARGV) {
    $naptime = shift @ARGV;
    unless ($naptime =~ /^[0-5]$/) {
	die "Usage: perl test?.t [ page_delay (0..5) ]";
    }
}


## 2 - 26 CommPort Win32::API objects

is_ok(defined &CloseHandle);		# 2
is_ok(defined &CreateFile);		# 3
is_ok(defined &GetCommState);		# 4
is_ok(defined &ReadFile);		# 5
is_ok(defined &SetCommState);		# 6
is_ok(defined &SetupComm);		# 7
is_ok(defined &PurgeComm);		# 8
is_ok(defined &CreateEvent);		# 9
is_ok(defined &GetCommTimeouts);	# 10
is_ok(defined &SetCommTimeouts);	# 11
is_ok(defined &GetCommProperties);	# 12
is_ok(defined &ClearCommBreak);		# 13
is_ok(defined &ClearCommError);		# 14
is_ok(defined &EscapeCommFunction);	# 15
is_ok(defined &GetCommConfig);		# 16
is_ok(defined &GetCommMask);		# 17
is_ok(defined &GetCommModemStatus);	# 18
is_ok(defined &SetCommBreak);		# 19
is_ok(defined &SetCommConfig);		# 20
is_ok(defined &SetCommMask);		# 21
is_ok(defined &TransmitCommChar);	# 22

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok(defined &WaitCommEvent);		# 23
is_ok(defined &WriteFile);		# 24
is_ok(defined &ResetEvent);		# 25
is_ok(defined &GetOverlappedResult);	# 26

is_ok(0x1 == PURGE_TXABORT);		# 27
is_ok(0x2 == PURGE_RXABORT);		# 28
is_ok(0x4 == PURGE_TXCLEAR);		# 29
is_ok(0x8 == PURGE_RXCLEAR);		# 30

is_ok(0x1 == SETXOFF);			# 31
is_ok(0x2 == SETXON);			# 32
is_ok(0x3 == SETRTS);			# 33
is_ok(0x4 == CLRRTS);			# 34
is_ok(0x5 == SETDTR);			# 35
is_ok(0x6 == CLRDTR);			# 36
is_ok(0x8 == SETBREAK);			# 37
is_ok(0x9 == CLRBREAK);			# 38

is_ok(0x1 == EV_RXCHAR);		# 39
is_ok(0x2 == EV_RXFLAG);		# 40
is_ok(0x4 == EV_TXEMPTY);		# 41
is_ok(0x8 == EV_CTS);			# 42
is_ok(0x10 == EV_DSR);			# 43
is_ok(0x20 == EV_RLSD);			# 44

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok(0x40 == EV_BREAK);		# 45
is_ok(0x80 == EV_ERR);			# 46
is_ok(0x100 == EV_RING);		# 47
is_ok(0x200 == EV_PERR);		# 48
is_ok(0x400 == EV_RX80FULL);		# 49
is_ok(0x800 == EV_EVENT1);		# 50
is_ok(0x1000 == EV_EVENT2);		# 51

is_ok(996 == ERROR_IO_INCOMPLETE);	# 52
is_ok(997 == ERROR_IO_PENDING);		# 53

is_ok(0x1 == BAUD_075);			# 54
is_ok(0x2 == BAUD_110);			# 55
is_ok(0x4 == BAUD_134_5);		# 56
is_ok(0x8 == BAUD_150);			# 57
is_ok(0x10 == BAUD_300);		# 58
is_ok(0x20 == BAUD_600);		# 59
is_ok(0x40 == BAUD_1200);		# 60
is_ok(0x80 == BAUD_1800);		# 61
is_ok(0x100 == BAUD_2400);		# 62
is_ok(0x200 == BAUD_4800);		# 63
is_ok(0x400 == BAUD_7200);		# 64
is_ok(0x800 == BAUD_9600);		# 65
is_ok(0x1000 == BAUD_14400);		# 66

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok(0x2000 == BAUD_19200);		# 67
is_ok(0x4000 == BAUD_38400);		# 68
is_ok(0x8000 == BAUD_56K);		# 69
is_ok(0x40000 == BAUD_57600);		# 70
is_ok(0x20000 == BAUD_115200);		# 71
is_ok(0x10000 == BAUD_128K);		# 72
is_ok(0x10000000 == BAUD_USER);		# 73

is_ok(0x21 == PST_FAX);			# 74
is_ok(0x101 == PST_LAT);		# 75
is_ok(0x6 == PST_MODEM);		# 76
is_ok(0x100 == PST_NETWORK_BRIDGE);	# 77
is_ok(0x2 == PST_PARALLELPORT);		# 78
is_ok(0x1 == PST_RS232);		# 79
is_ok(0x3 == PST_RS422);		# 80
is_ok(0x4 == PST_RS423);		# 81
is_ok(0x5 == PST_RS449);		# 82
is_ok(0x22 == PST_SCANNER);		# 83
is_ok(0x102 == PST_TCPIP_TELNET);	# 84
is_ok(0x0 == PST_UNSPECIFIED);		# 85
is_ok(0x103 == PST_X25);		# 86
is_ok(0x200 == PCF_16BITMODE);		# 87
is_ok(0x1 == PCF_DTRDSR);		# 88

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok(0x80 == PCF_INTTIMEOUTS);		# 89
is_ok(0x8 == PCF_PARITY_CHECK);		# 90
is_ok(0x4 == PCF_RLSD);			# 91
is_ok(0x2 == PCF_RTSCTS);		# 92
is_ok(0x20 == PCF_SETXCHAR);		# 93
is_ok(0x100 == PCF_SPECIALCHARS);	# 94
is_ok(0x40 == PCF_TOTALTIMEOUTS);	# 95
is_ok(0x10 == PCF_XONXOFF);		# 96

is_ok(0x1 == SP_SERIALCOMM);		# 97
is_ok(0x2 == SP_BAUD);			# 98
is_ok(0x4 == SP_DATABITS);		# 99
is_ok(0x10 == SP_HANDSHAKING);		# 100
is_ok(0x1 == SP_PARITY);		# 101
is_ok(0x20 == SP_PARITY_CHECK);		# 102
is_ok(0x40 == SP_RLSD);			# 103
is_ok(0x8 == SP_STOPBITS);		# 104

is_ok(0x1 == DATABITS_5);		# 105
is_ok(0x2 == DATABITS_6);		# 106
is_ok(0x4 == DATABITS_7);		# 107
is_ok(0x8 == DATABITS_8);		# 108
is_ok(0x10 == DATABITS_16);		# 109
is_ok(0x20 == DATABITS_16X);		# 110

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok(0x1 == STOPBITS_10);		# 111
is_ok(0x2 == STOPBITS_15);		# 112
is_ok(0x4 == STOPBITS_20);		# 113

is_ok(0x100 == PARITY_NONE);		# 114
is_ok(0x200 == PARITY_ODD);		# 115
is_ok(0x400 == PARITY_EVEN);		# 116
is_ok(0x800 == PARITY_MARK);		# 117
is_ok(0x1000 == PARITY_SPACE);		# 118

is_ok(0xe73cf52e == COMMPROP_INITIALIZED);	# 119

is_ok(110 == CBR_110);			# 120
is_ok(300 == CBR_300);			# 121
is_ok(600 == CBR_600);			# 122
is_ok(1200 == CBR_1200);		# 123
is_ok(2400 == CBR_2400);		# 124
is_ok(4800 == CBR_4800);		# 125
is_ok(9600 == CBR_9600);		# 126
is_ok(14400 == CBR_14400);		# 127
is_ok(19200 == CBR_19200);		# 128
is_ok(38400 == CBR_38400);		# 129
is_ok(56000 == CBR_56000);		# 130
is_ok(57600 == CBR_57600);		# 131
is_ok(115200 == CBR_115200);		# 132

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok(128000 == CBR_128000);		# 133
is_ok(256000 == CBR_256000);		# 134

is_ok(0x0 == DTR_CONTROL_DISABLE);	# 135
is_ok(0x1 == DTR_CONTROL_ENABLE);	# 136
is_ok(0x2 == DTR_CONTROL_HANDSHAKE);	# 137
is_ok(0x0 == RTS_CONTROL_DISABLE);	# 138
is_ok(0x1 == RTS_CONTROL_ENABLE);	# 139
is_ok(0x2 == RTS_CONTROL_HANDSHAKE);	# 140
is_ok(0x3 == RTS_CONTROL_TOGGLE);	# 141

is_ok(0x2 == EVENPARITY);		# 142
is_ok(0x3 == MARKPARITY);		# 143
is_ok(0x0 == NOPARITY);			# 144
is_ok(0x1 == ODDPARITY);		# 145
is_ok(0x4 == SPACEPARITY);		# 146

is_ok(0x0 == ONESTOPBIT);		# 147
is_ok(0x1 == ONE5STOPBITS);		# 148
is_ok(0x2 == TWOSTOPBITS);		# 149

is_ok(0x1 == FM_fBinary);		# 150
is_ok(0x2 == FM_fParity);		# 151
is_ok(0x4 == FM_fOutxCtsFlow);		# 152
is_ok(0x8 == FM_fOutxDsrFlow);		# 153
is_ok(0x30 == FM_fDtrControl);		# 154
is_ok(0x40 == FM_fDsrSensitivity);	# 155
is_ok(0x80 == FM_fTXContinueOnXoff);	# 156

if ($naptime) {
    print "++++ page break\n";
    sleep $naptime;
}

is_ok(0x100 == FM_fOutX);		# 157
is_ok(0x200 == FM_fInX);		# 158
is_ok(0x400 == FM_fErrorChar);		# 159
is_ok(0x800 == FM_fNull);		# 160
is_ok(0x3000 == FM_fRtsControl);	# 161
is_ok(0x4000 == FM_fAbortOnError);	# 162
is_ok(0xffff8000 == FM_fDummy2);	# 163

$event = CreateEvent($null,	# no security
		     1,		# explicit reset req
		     0,		# initial event reset
		     $null);	# no name

is_ok($event);				# 164
Win32API::CommPort->OS_Error unless ($event);

ResetEvent($event);
$ok = Win32::GetLastError;
is_ok(0 == $ok);			# 165
print "Should Pass: ";
Win32API::CommPort->OS_Error;

$ok = CloseHandle($event);	# $MS doesn't check return either

ResetEvent($event);
$ok = Win32::GetLastError;
is_ok($ok);				# 166
print "Should Fail: ";
Win32API::CommPort->OS_Error;

