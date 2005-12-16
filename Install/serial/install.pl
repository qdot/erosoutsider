# Created by Makefile.PL
# VERSION 0.19

BEGIN { require 5.004; }

use Config qw(%Config);
use strict;
use ExtUtils::Install qw( install );

my $FULLEXT = "Win32/SerialPort";
my $INST_LIB = "./lib";
my $HTML_LIB = "./html";

my $html_dest = "";	# edit real html base here if autodetect fails

if (exists $Config{installhtmldir} ) {
    $html_dest = "$Config{installhtmldir}";
}
elsif (exists $Config{installprivlib} ) {
    $html_dest = "$Config{installprivlib}";
    $html_dest =~ s%\\lib%\\html%;
}

if ( length ($html_dest) ) {
    $html_dest .= '\lib\site';
}
else {
    die "Can't find html base directory. Edit install.pl manually.\n";
}

install({
	   read => "$Config{sitearchexp}/auto/$FULLEXT/.packlist",
	   write => "$Config{installsitearch}/auto/$FULLEXT/.packlist",
	   $INST_LIB => "$Config{installsitelib}",
	   $HTML_LIB => "$html_dest"
	  },1,0,0);

__END__
