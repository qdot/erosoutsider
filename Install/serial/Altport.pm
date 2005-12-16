package AltPort;
# Inheritance test for test3.t and test4.t only

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK %EXPORT_TAGS);
$VERSION = '0.19';
require Exporter;
use Win32::SerialPort qw( :STAT :PARAM 0.19 );
@ISA = qw( Exporter Win32::SerialPort );
@EXPORT= qw();
@EXPORT_OK= @Win32::SerialPort::EXPORT_OK;
%EXPORT_TAGS = %Win32::SerialPort::EXPORT_TAGS;

my $in = BM_fCtsHold;
print "AltPort import=$in\n";
1;
