#!perl -w

use lib './lib';
use Win32::SerialPort 0.17;
require 5.004;

use strict;

my $head	= "\r\n\r\n+++++++++++ Tied FileHandle Demo ++++++++++\r\n";
my $e="\r\n....Bye\r\n";

    # starts configuration created by test1.pl
my $cfgfile = "COM1_test.cfg";

# =============== execution begins here =======================

    # constructor = TIEHANDLE method
my $tie_ob = tie(*PORT,'Win32::SerialPort', $cfgfile)
                 || die "Can't start $cfgfile\n";

    # timeouts
$tie_ob->read_char_time(0);
$tie_ob->read_const_time(10000);
$tie_ob->read_interval(0);
$tie_ob->write_char_time(0);
$tie_ob->write_const_time(3000);

    # match parameters
$tie_ob->are_match("\n");
$tie_ob->lookclear;
$tie_ob->is_prompt("\r\nPrompt! ");

    # other parameters
$tie_ob->error_msg(1);		# use built-in error messages
$tie_ob->user_msg(1);
$tie_ob->handshake("xoff");
## $tie_ob->handshake("rts");   # will cause output timeouts if no connect
$tie_ob->stty_onlcr(1);		# depends on terminal
$tie_ob->stty_opost(1);		# depends on terminal
$tie_ob->stty_icrnl(1);		# depends on terminal
$tie_ob->stty_echo(0);		# depends on terminal

    # Print Prompts to Port and Main Screen
print $head;
print PORT $head;

    # tie to PRINT method
print PORT "\r\nEnter one character (10 seconds): "
    or print "PRINT timed out\n\n";

    # tie to GETC method
my $char = getc PORT;
if ($^E) {
    printf "GETC timed out:\n%s\n\n", $^E;
    print PORT "...GETC timed_out\r\n";
}
else {
    print PORT "$char\r\n";
}

    # tie to WRITE method
if ( $] < 5.005 ) {
    print "syswrite tie to WRITE not supported in this Perl\n\n";
}
else {
    my $out = "\r\nThis is a 'syswrite' test\r\n\r\n";
    syswrite PORT, $out, length($out), 0
        or print "WRITE timed out\n\n";
}


    # tie to READLINE method
$tie_ob->stty_echo(1);		# depends on terminal
print PORT "enter line: ";
my $line = <PORT>;
if (defined $line) {
    print "READLINE received: $line"; # no chomp
    print PORT "\r\nREADLINE received: $line\r";
}
else {
    print "READLINE timed out\n\n";
    print PORT "...READLINE timed out\r\n";
    my ($patt, $after, $match, $instead) = $tie_ob->lastlook;  ## NEW
    print "got_instead = $instead\n" if ($instead);             ## NEW
}

    # tie to READ method
my $in = "FIRST:12345, SECOND:67890, END";
$tie_ob->stty_echo(0);		# depends on terminal
print PORT "\r\nenter 5 char (no echo): ";
unless (defined sysread (PORT, $in, 5, 6)) {
    print "READ timed out:\n$^E\n\n";
    print PORT "...READ timed out\r\n";
}

$tie_ob->stty_echo(1);		# depends on terminal
print PORT "\r\nenter 5 more char (with echo): ";
unless (defined sysread (PORT, $in, 5, 20)) {
    print "READ timed out:\n";
    print PORT "...READ timed out\r\n";
}

    # tie to PRINTF method
printf PORT "\r\nreceived: %s\r\n", $in
    or print "PRINTF timed out\n\n";

    # PORT-specific versions of the $, and $\ variables
my $n1 = ".number1_";
my $n2 = ".number2_";
my $n3 = ".number3_";

print PORT $n1, $n2, $n3;
print PORT "\r\n";

$tie_ob->output_field_separator("COMMA");
print PORT $n1, $n2, $n3;
print PORT "\r\n";

$tie_ob->output_record_separator("RECORD");
print PORT $n1, $n2, $n3;
$tie_ob->output_record_separator("");
print PORT "\r\n";
    # the $, and $\ variables will also work

print PORT $e;

    # destructor = CLOSE method
if ( $] < 5.005 ) {
    print "close tie to CLOSE not supported in this Perl\n\n";
    $tie_ob->close || print "port close failed\n\n";
}
else {
    close PORT || print "CLOSE failed\n\n";
}

    # destructor = DESTROY method
undef $tie_ob;	# Don't forget this one!!
untie *PORT;

print $e;
