README.TXT


This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

---

This is a Beta release, there are cerainly bugs that need to be found and fixed.  
Please report bugs and requests for new features to the private email box of 
"erosoutsider" in the SmartStim web site.  When requesting features, remember
that this is a volinteer effort, that we are limited based on what the device is
capable of doing, and that our goal is scripting not interactive control.

This package is not ready for general use.  It is presently only suitable
for experienced computer geek types, preferrable familar with the Perl programming
language. At a minimum you have to be willing and able to install ActivePerl and to 
use command line windows.  You will need a serial cable like the one ErosTek provides
with their ErosLink product, and preferrably you will need the ErosLink product.
See manual.doc for the cable details.

If you are planning to convert this package to another language, but still 
support a scripting language, it would be a good idea to use the same script syntax
as presented here, so that folks can share their scripts with others.

---

You should find the following files in this .zip

readme.txt     This file
test.pl        A Perl script that puts estim.pm through its paces
script.pl      A Perl script that adds a GUI front end and a script engine 
Waves.txt      An example script that implements a "wave" like routine
Stroke.txt     An example script that implements a "stroke" like routine
View.txt       An example script for viewing device parms, without changing any
Idle.eis       A "do-nothing" ErosLink script 

install\install.bat    A batch file to install the ET-312 packages, used in step 2
install\install.pl     A Perl script to complete the installation process
install\UPDmsg.pm      A Perl package that enables interprocess communication
install\manual.doc     A WORD file that describes the communications protocol
install\estim.pm       A Perl package that impliments the communications protocol
install\estim.inc      A Perl package that contains environment variables
install\serial\*       files for the Win32::SerialPort Perl package
install\wxperl\*       files and directories for the WxPerl package

contrib\*              scripts contributed by others
---

Installation notes:

1) Begin by installing ActivePerl on your machine.  ActivePerl is a free package, 
you can get it from ActiveState at:  

       http://aspn.activestate.com/ASPN/Downloads/ActivePerl/

I recommend you use the Windows MSI method to install.  After downloading and 
saving to disk, click on the file to start the installer running.  The default 
options should be fine.


2) Create a directory called C:\eros and unzip all of ESTIM.ZIP into it.  Make sure to let 
unzip recreate the subdirectories.


3) Go to the directory C:\eros\install   and double click on the file install.bat
This script will:

    install Win32-API unless already installed.
    install Win32::SerialPort
    install WxPerl
    install IPC::UDPmsg.pm
    install IO::estim.pm
    install IO::estim.inc

4) Manually edit install\estim.inc as needed, and then place it in 
c:\perl\site\lib\io or another directory as appropriate.


5) Using ErosLink, install the session  Idle.eis  as User 1.


6) To run the test program, connect the ESTIM device to your serial port, the 
software assumes you are using port 1, and you will need to adjust the source
code if using something different. Look for the line where $port is set.
The waves.txt script works best if the device is runnning the idle.eis installed 
in step 4. Power cycle the ESTIM device. Open a command window, and type:

     cd c:\eros
     perl test.pl

7) To run the GUI, connect up the ESTIM device to your serial port, the 
software assumes you are using port 1, and you will need to adjust the source
code if using something different. Look for the line where $port is set.
Power cycle the ET-312 (unless you just ran test.pl).  Open a command window, 
and type:

    cd c:\eros
    perl    script.pl


In the FILE menu, open the file  "waves.txt", then select "run" also from the 
file menu.  The waves.txt script works best if the device is runnning the
idle.eis installed in step 4. 

Note that script.pl and test.pl use the special feature that makes it not
necessary to repower the ESTIM device each time the program is started, as long
as it's only used with them.  Any time other software, such as ErosLink, is
used to communicate with the device, you will need to power cycle the device 
before these scripts will work. 

----------------------------------Version Log----------------------------------
4.00             new function added: my $val = $et->get_byte($adr);
                         gets the byte at the given address, $val=0-255, -1=error
                 misc syntax errors fixed in script.pl
                 dump.pl  script added, provides hex dump of device locations
                         as if they were memory locations.

3.00  12/29/2005 Checksum is now calculated instead of being looked up in a table
                 estim.inc has been added to contain installation dependant 'stuff'
                 manual.doc updated to reflect better understanding of protocol

2.00  12/21/2005 Added 'dramp' command to script
                 Changed rate values so that higher values result in faster ramps
                 Added 'get' commands to script

1.00  12/16/2005 Initial release
