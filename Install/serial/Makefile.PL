####    use ExtUtils::MakeMaker;
####    # See lib/ExtUtils/MakeMaker.pm for details of how to influence
####    # the contents of the Makefile that is written.
####    WriteMakefile(
####        'NAME'	=> 'SerialPort',
####        'VERSION_FROM' => 'SerialPort.pm', # finds $VERSION
####    );

my $version = "0.19";
my $file = "COM1";
if (@ARGV) {
    $file = shift @ARGV;
}

my $dfile = "t/DefaultPort.pm";
unlink $dfile;
print "\nCreating new $dfile\n";
open (DEFAULT, "> $dfile") or die "Can't create $dfile: $!\n";
print DEFAULT <<EOF;
package SerialJunk;
# Created by Makefile.PL

\$Makefile_Test_Port = "$file";
EOF

close DEFAULT;

print "\n             Win32::SerialPort and Win32API::CommPort\n";
print "                           VERSION $version\n";
print "                  No 'Makefile' will be created\n";
print "                  Test with:    perl test.pl\n";
print "                  Install with: perl install.pl\n\n";
print "              Test with nothing connected to $file\n";
print "           or for different port: perl test.pl PORT\n";
print "         Timeout tests can take up to 30 seconds per test\n\n";

$dfile = "test.pl";
unlink $dfile;
print "Creating new $dfile\n";
open (DEFAULT, "> $dfile") or die "Can't create $dfile: $!\n";

if ( $] < 5.004 ) { print DEFAULT <<TEST3;
# Created by Makefile.PL
# VERSION $version

print "On ActiveState Build 3xx, test results will print to 'test.txt'\\n\\n";
    
open(TXT, ">test.txt") || die "Can't open 'test.txt': \$!\\n";
print TXT "\\nWelcome to the Poor Man's Test::Harness\\n\\n";

my \$junk = \$Win32::API::VERSION;
\$junk = \$Win32::API::pack;

sub summary {
    my \$test = shift;
    print "....\$test";
    print TXT "....\$test";
    my \$testout = `perl \$test`;
        # assumes the perl 5.003 executable is in your path as "perl"
    if (index(\$testout, "not ok") > -1) {
	print "....errors found\\n";
	print TXT "....errors found\\n\$testout\\n";
	return 1;
    }
    print "....ok\\n";
    print TXT "....ok\\n\$testout\\n";
    return 0;
}

my \$fault = summary ("t/test1.t");
\$fault +=   summary ("t/test2.t");
\$fault +=   summary ("t/test3.t");
\$fault +=   summary ("t/test4.t");
\$fault +=   summary ("t/test5.t");
\$fault +=   summary ("t/test6.t");

print "All tests OK\\n" unless (\$fault);
close TXT;

print "\\nTo run individual tests, type:\\n";
print "    C:\\> perl t/test1.t Page_Pause_Time (0..5) [ $file ]\\n";
print "\\nContinue with 'perl t/test2.t' through 'perl t/test6.t'\\n";
print "See README and other documentation for additional information.\\n\\n";
TEST3

}
else { print DEFAULT <<TEST4;
# Created by Makefile.PL
# VERSION $version

use Test::Harness;
runtests ("t/test1.t", "t/test2.t", "t/test3.t", "t/test4.t",
	  "t/test5.t", "t/test6.t", "t/test7.t");

print "\\nTo run individual tests, type:\\n";
print "    C:\\> perl t/test1.t Page_Pause_Time (0..5) [ $file ]\\n";
print "\\nContinue with 'perl t/test2.t' through 'perl t/test7.t'\\n";
print "See README and other documentation for additional information.\\n\\n";
TEST4

}
close DEFAULT;

$dfile = "install.pl";
unlink $dfile;
print "Creating new $dfile\n";
open (DEFAULT, "> $dfile") or die "Can't create $dfile: $!\n";

if ( $] < 5.004 ) { print DEFAULT <<INST3;
# Created by Makefile.PL
# VERSION $version

#   ActiveState Build 3xx Install script for Win32::SerialPort
#   Adapted from Win32::API version 0.011 Install Program
#   by Aldo Calpini <dada\@divinf.it>

BEGIN { die "wrong version" unless (\$] =~ /^5\.003/); }

use Win32::Registry;
use File::Copy;

sub CheckDir {
    my(\$dir) = \@_;
    if(! -d \$dir) {
        print "Creating directory \$dir...\\n";
        mkdir(\$dir, 0) or die "ERROR: (\$!)\\n";
    }
}    

\$MODULE  = "Win32::SerialPort";

print "\\n   \$MODULE version $version Install Program for Build 3xx\\n";
print   "   Adapted from Win32::API Install Program\n";
print   "   by Aldo Calpini <dada\\\@divinf.it>\n\n";

\$KEY = "SOFTWARE\\\\ActiveWare\\\\Perl5";

\$HKEY_LOCAL_MACHINE->Open(\$KEY, \$hkey)
  or die "ERROR: Can't open Perl registry key: \$KEY\\n";

\$hkey->GetValues(\$values);
\$hkey->Close();

\$PRIVLIB = \$values->{'PRIVLIB'}->[2];

die "ERROR: Can't get PRIVLIB registry value!\\n" unless \$PRIVLIB;

CheckDir("\$PRIVLIB\\\\Win32");
CheckDir("\$PRIVLIB\\\\Win32API");

if (copy "lib\\\\Win32\\\\SerialPort.pm","\$PRIVLIB\\\\Win32\\\\SerialPort.pm") {
    print "Copied Win32::SerialPort.pm to \$PRIVLIB\\\\Win32...\\n";
}
else {
    die "Could not copy Win32::SerialPort.pm to \$PRIVLIB\\\\Win32...\\n";
}

if (copy "lib\\\\Win32API\\\\CommPort.pm","\$PRIVLIB\\\\Win32API\\\\CommPort.pm") {
    print "Copied Win32API::CommPort.pm to \$PRIVLIB\\\\Win32API...\\n";
}
else {
    die "Could not copy Win32API::CommPort.pm to \$PRIVLIB\\\\Win32API...\\n";
}

print "Installation done\\n";
INST3

}
else { print DEFAULT <<INST4;
# Created by Makefile.PL
# VERSION $version

BEGIN { require 5.004; }

use Config qw(\%Config);
use strict;
use ExtUtils::Install qw( install );

my \$FULLEXT = "Win32/SerialPort";
my \$INST_LIB = "./lib";
my \$HTML_LIB = "./html";

my \$html_dest = "";	# edit real html base here if autodetect fails

if (exists \$Config{installhtmldir} ) {
    \$html_dest = "\$Config{installhtmldir}";
}
elsif (exists \$Config{installprivlib} ) {
    \$html_dest = "\$Config{installprivlib}";
    \$html_dest =~ s%\\\\lib%\\\\html%;
}

if ( length (\$html_dest) ) {
    \$html_dest .= '\\lib\\site';
}
else {
    die "Can't find html base directory. Edit install.pl manually.\\n";
}

install({
	   read => "\$Config{sitearchexp}/auto/\$FULLEXT/.packlist",
	   write => "\$Config{installsitearch}/auto/\$FULLEXT/.packlist",
	   \$INST_LIB => "\$Config{installsitelib}",
	   \$HTML_LIB => "\$html_dest"
	  },1,0,0);

__END__
INST4

}
close DEFAULT;
