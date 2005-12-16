#!perl -w

use strict;
use Win32::SerialPort 0.15;

#### variable declarations ####

my $help_text = <<"HELPME";

Usage: perl stty.plx [SETTING]... COMx
  or:  perl stty.plx OPTION COMx
Print or change terminal characteristics.

  -a, --all       print all current settings in human-readable form
  -g, --save      print all current settings in a stty-readable form
  -h, --help      display this help and exit
  -v, --version   output version information and exit

Optional - before SETTING indicates negation.  An * marks non-POSIX
settings.

Special characters:
  eof CHAR      CHAR will send an end of file (terminate the input)
  eol CHAR      CHAR will end the line
  erase CHAR    CHAR will erase the last character typed
  intr CHAR     CHAR will send an interrupt signal
  kill CHAR     CHAR will erase the current line
  quit CHAR     CHAR will send a quit signal
  start CHAR    CHAR will restart the output after stopping it
  stop CHAR     CHAR will stop the output

Special settings:
  N             set the input and output speeds to N bauds

Control settings:
  [-]clocal     disable modem control signals
* [-]crtscts    enable RTS/CTS handshaking
  csN           set character size to N bits, N in [5..8]
  [-]cstopb     use two stop bits per character (one with `-')
  [-]parenb     generate parity bit in output and expect parity bit in input

Input settings:
  [-]icrnl      translate carriage return to newline
  [-]igncr      ignore carriage return
  [-]inlcr      translate newline to carriage return
  [-]inpck      enable input parity checking
  [-]istrip     clear high (8th) bit of input characters
  [-]ixoff      enable sending of start/stop characters
  [-]ixon       enable XON/XOFF flow control

Output settings:
* [-]ocrnl      translate carriage return to newline
* [-]onlcr      translate newline to carriage return-newline
  [-]opost      postprocess output

Local settings:
* [-]echoctl    echo control characters in hat notation (`^c')
  [-]echo       echo input characters
  [-]echoe      same as [-]crterase
  [-]echok      echo a newline after a kill character
* [-]echoke     same as [-]crtkill
  [-]echonl     echo newline even if not echoing other characters
  [-]icanon     enable erase, kill, werase, and rprnt special characters
  [-]isig       enable interrupt, quit, and suspend special characters


Handle the COMx line specified.  Without arguments, prints baud rate and
'line = 0;'. Other line disciplines are not supported.  In settings,
CHAR is taken literally, or coded as in ^c, 0x37, 0177 or 127;
special values ^- or undef used to disable special characters.
HELPME

my @settings; # array returned by stty()
my $all_settings = 0;
my $current;
my $token;
my $arg = "stty";

########### command line argument processing ##################

if (@ARGV) {
    $arg = $ARGV[0];
    if (($arg eq "-a")|($arg eq "--all")) {
        $all_settings++;
	shift @ARGV;
    }
    elsif (($arg eq "-g")|($arg eq "--save")) {
	$arg = "-g";
        $all_settings++;
	shift @ARGV;
    }
    elsif (($arg eq "-h")|($arg eq "--help")) {
        print "$help_text\n";
	exit;
    }
    elsif (($arg eq "-v")|($arg eq "--version")) {
        print "Win32::SerialPort Version = $Win32::SerialPort::VERSION\n";
	exit;
    }
    else {
        $arg = "";
    }
}

my $port = pop @ARGV;
if (defined $port) {
    chomp $port;
    unless ($port =~ /^COM[1-4]$/) {
        warn "\nInvalid port: only COM1, COM2, COM3, or COM4 allowed\n";
        $port = "";
    }
} else { $port = ""; }
unless ($port) {
    warn "\nUsage: perl stty.plx [-a|-g|-h|-v|--all|--save|--help|--version] COMx\n";
    die    "   or: perl stty.plx [[-]setting] [[-]setting2] ... COMx\n";
}

die "\nstty_settings not permitted with option $arg\n" if ($arg && @ARGV);

########### SerialPort code starts here ##################

my $ob = Win32::SerialPort->new ("$port") || die "Can't open port $port: $!\n";

my $baud = $ob->baudrate;

if ($baud) { $ob->baudrate($baud)	|| die "fail setting baud"; }
else { defined $ob->baudrate(9600)	|| die "fail setting baud after 0"; }

$current = $ob->parity;
$ob->parity($current)		|| die "fail setting parity";
$current = $ob->databits;
$ob->databits($current)		|| die "fail setting databits";
$current = $ob->stopbits;
$ob->stopbits($current)		|| die "fail setting stopbits";
$current = $ob->handshake;
$ob->handshake($current)	|| die "fail setting handshake";

$ob->write_settings || die "no settings";

if (@ARGV) {
    $ob->stty(@ARGV);
}
elsif ($arg ne "-g") {
    $baud = $ob->baudrate;
    print "\nspeed $baud baud; line = 0;\n";
}

if ($all_settings) {
    @settings = $ob->stty();
}

my $count = 0;
my $cchars = 1;
if ($arg eq "-g") {
    foreach $token (@settings) {
        print "$token ";
        if (++$count > 8) {
            print "\n";
            $count = 0;
        }
    }
    print "\n";
}
elsif ($arg eq "-a") {
    $token = shift (@settings); # baudrate already printed
    while ($cchars) {
        $token = shift (@settings);
        $current = shift (@settings);
        print "$token = $current; ";
        if (++$count > 3) {
            print "\n";
            $count = 0;
        }
        if ($token eq "stop") {
	    $cchars = 0;
            print "\n" if ($count);
            $count = 0;
        }
    }
    foreach $token (@settings) {
        print "$token ";
        if (++$count > 8) {
            print "\n";
            $count = 0;
        }
    }
    print "\n";
}
## printf "DEBUG: intr = %s;\n", Win32::SerialPort::cntl_char($ob->stty_intr);

$ob->close;
undef $ob;
