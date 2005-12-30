#####################################################################
# 
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
# 
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
# 
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#
#####################################################################


use strict;
print "This program will install the ESTIM scripting package\n";
print "You must be connected to the Internet to run this script\n";
print "Do you wish to continue (yes/no) ?\n";
my $r = <STDIN>;
if( !  $r =~ /y/i ) { goto skip; }


print "installing Win32::API this will take a few minutes...\n";
system( "ppm install Win32-API" );
print "Win32::API installed\n\n";


print "installing Win32::SerialPort...\n";
chdir("serial");
&pdir();  
system ("perl MakeFile.pl");
system ("perl install.pl");
chdir("..");
print "Win32::SerialPort installed\n\n";


chdir("wxperl");
&pdir();
print "installing WxPerl, this will take a few minutes...\n";
system("ppm install Wx-0.26.ppd");
print "WxPerl installed\n\n";
chdir("..");
&pdir();


if( ! -e "c:/perl/site/lib/ipc/udpmsg.pm" ) {
   print "installing UDPmsg...\n";
   if( ! -e "c:/perl/site/lib/ipc" ) {
       if( -e "c:/perl/site/lib" ) {
           if( ! mkdir( "c:/perl/site/lib/ipc" ) ) {
               die "could not create IPC directory\n";
               }
           }
       else {
           die "Perl is not installed properly\n";
           }
        }
   # directory already exists, or does now

   system( "copy /Y udpmsg.pm  c:\\perl\\site\\lib\\ipc" );
   print "UDPmsg is installed\n\n";
   }

print "installing estim...\n";
if( ! -e "c:/perl/site/lib/io" ) {
      die "Perl is not installed properly\n";
      }

# directory already exists

system( "copy /Y estim.pm  c:\\perl\\site\\lib\\io" );
print "estim.pm is installed\n\n";

skip:
  exit;

sub pdir {
my $d = `cd`;
print "The current directory is $d\n";
}
