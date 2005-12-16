#!perl -w
#
# a perl/Tk based simple chat program
# demonstrates use of non-blocking I/O with event loop
# uses same setup as other demo?.plx programs in SerialPort distribution
#
# Send-Button does not add "\n", <Return> = <Enter> does

BEGIN { require 5.004; }
use Tk;
use Tk::ROText;
use Tk::LabEntry;
use Win32::SerialPort 0.14;

## use subs qw/newline sendline/;
use strict;

my $cfgfile = "COM1_test.cfg";
my $ob = Win32::SerialPort->start ($cfgfile) or die "Can't start $cfgfile\n";
    # next test will die at runtime unless $ob

my $poll = 0;
my $polltime = 200;	# milliseconds
my $maxpoll = 150;	# 30 seconds
my $msg = "";
my $send = "";
my $senttext = "";

my $mw= MainWindow->new('-title' => 'Win32::SerialPort Chat Demo7');

my $f = $mw->Frame;
my $s = $f->LabEntry(-label => 'Local: ', -width => 60,
                     -labelPack => [qw/-side left -anchor w/],
                     -textvariable => \$send)->pack(qw/-side left/);
$s->Subwidget('entry')->focus;

my $sendret = sub { $send .= "\n"; &sendline; };
my $sendcmd = \&sendline;
my $b = $f->Button(-text => 'Send');
$b->pack(qw/-side left/);
$b->configure(-command => $sendcmd);
$s->bind('<Return>' => $sendret);

$f->pack(qw/-side bottom -fill x/);

my $t = $mw->Scrolled(qw/ROText -setgrid true -height 20 -scrollbars e/);
$t->pack(qw/-expand yes -fill both/);
$t->tagConfigure(qw/Win32 -foreground black -background white/);
$t->tagConfigure(qw/Serial -foreground white -background red/);
$t->insert('end',"        Welcome to the Tk SerialPort Demo\n", 'Win32');
$t->insert('end',"                REMOTE messages\n", 'Serial');
$t->insert('end',"                LOCAL messages\n\n", 'Win32');

$ob->stty_onlcr(1);			# on my terminal
$ob->stty_opost(1);			# on my terminal
$ob->stty_icrnl(1);			# but you might change
$ob->stty_echo(1);
$ob->are_match("\n");			# possible end strings
$ob->lookclear;				# empty buffer
$ob->write("\nSerialPort Demo\n");	# "write" first to init "write_done"
$msg = "\nTalking to Tk\n";		# initial prompt
$ob->is_prompt("Again?");		# new prompt after "kill" char

&newline;
MainLoop();

sub newline {
    my $gotit = "";		# poll until data ready
    if ($ob->write_done(0)) {
        $gotit = $ob->lookfor;		# poll until data ready
    }
    die "Aborted without match\n" unless (defined $gotit);
    if ("" ne $gotit) {
        $t->insert('end',"$gotit\n",'Serial');
        $poll = 0;
        $t->see('end');
    }
    if ($maxpoll < $poll++) {
        $t->insert('end',"\nCOUNTER: long time with no input\n",'Win32');
        $poll = 0;
        $msg = "\nAnybody there?\n";
    }
    if ($senttext) {
        $t->insert('end',"\n$senttext",'Win32');
        $senttext = "";
    }
    if ($msg && $ob->write_done(0)) {
        if ($ob->stty_onlcr) { $msg =~ s/\n/\r\n/osg; }
        $ob->write_bg($msg);
        $msg = "";
        $t->see('end');
    }
    $mw->after($polltime, \&newline);
}

sub sendline {
    $msg .= "\n$send";
    $senttext = "$send";
    $send = "";
}
