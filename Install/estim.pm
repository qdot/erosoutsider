# IO::estim.pm

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



#######################################################################################
#       Package to interface with the ESTIM via a serial port, version 4.00           #
#######################################################################################

package IO::estim;
use strict;
require "IO/estim.inc";       # configuration dependant information


###################### methods ##################################
#
#
#  my $et  = IO::estim->new($port, $file, $DEBUG);   # new object, opens COMM port, syncs with ESTIM
#                                               $port:  1-n  index into port list, from estim.inc
#                                               $file:  if not empty string, used to save the MOD char
#                                                    so that ESTIM does not have to be power cycled
#                                                    each time the program starts.
#                                               $DEBUG:  0=normal,  
#                                                        .... ...1 = print debug messages, 
#                                                        .... ..1. = write outgoing traffic to file 'traffic'
#  my $val = $et->get_routine();                # get the number of the routine running on the device
#        76=waves     77=stroke    78=climb     79=combo    7A=intense    7B=rhythm     7C=audio1
#        7D=audio2    7E=audio3    7F=split     80=random1  81=random2    82=toggle     83=orgasm 
#        84=torment   85=phase1    86=phase2    87=phase3   88=user1      89=user2      8A=user3
#  my $val = $et->get_byte($adr);               # get the byte at the given address, $val=0-255, -1=error
#-------
#  my $val = $et->get_A_time_on();              # get the TIME ON for channel A, $val=0-255, -1=error
#  my $val = $et->get_A_time_off();             # get the TIME OFF for channel A, $val=0-255, -1=error
#  my ($on,$off) = $et->get_A_time_options();         # get the TIME OPTIONS for channel A, (-1,-1)=error
#                $on:   1=normal, 5=EFFECT,  9=MA        $off:  0=normal, 2=TEMPO,   4=MA
#
#  my $val = $et->get_A_level();                # get the level of channel A, $val=0-127, -1=error
#  my $val = $et->get_A_min_level();            # get the minimum level for channel A, $val=0-127, -1=error
#  my $val = $et->get_A_max_level();            # get the maximum level for channel A, $val=0-127, -1=error
#  my $val = $et->get_A_level_rate();           # get the level rate for channel A, $val=0-255, -1=error
#  my ($min,$rate) = $et->get_A_level_options();         # get the LEVEL OPTIONS for channel A, (-1,-1)=error
#                $min:   1=normal, 5=DEPTH               $rate:  0=normal,  2=TEMPO,   4=MA
#
#  my $val = $et->get_A_freq();                 # get the frequency for channel A, $val=0-247, -1=error
#  my $val = $et->get_A_min_freq();             # get the min frequency for channel A, $val=0-247, -1=error
#  my $val = $et->get_A_max_freq();             # get the max frequency for channel A, $val=0-247, -1=error
#  my $val = $et->get_A_freq_rate();            # get the frequency rate for channel A, $val=0-255, -1=error
#  my ($val, $rate) = $et->get_A_freq_options( $val, $rate );  # get the frequency options of channel A
#                $val:  1=none     4=val/freq     5=max/freq      8=val/MA      9=max/MA
#                $rate: 0=none     2=rate/effect  4=rate/MA
#
#  my $val = $et->get_A_width();                # get the pulse width for channel A, $val=0-191, -1=error
#  my $val = $et->get_A_min_width();            # get the min pulse width for channel A, $val=0-191, -1=error
#  my $val = $et->get_A_max_width();            # get the max pulse width for channel A, $val=0-191, -1=error
#  my $val = $et->get_A_width_rate();           # get the pulse width rate for channel A, $val=0-255, -1=error
#  my ($val, $rate) = $et->get_A_width_options();        # get the pulse width options for channel A
#                $val:    1=none   4=val/width     5=min/width
#                $rate:   0=none   2=pace          4=MA
#--------
#  my $cc  = $et->set_A_time_on( $i );          # set the TIME ON for channel A, $i=0-255
#  my $cc  = $et->set_A_time_off( $i );         # set the TIME OFF for channel A, $i=0-255
#  my $cc  = $et->set_A_time_options( $on, $off );    # set the TIME OPTIONS for channel A
#                $on:   1=normal, 5=EFFECT,  9=MA        $off:  0=normal, 2=TEMPO,   4=MA
#
#  my $cc  = $et->set_A_level( $i );            # set the level of channel A, $i=0-127
#  my $cc  = $et->set_A_min_level( $i );        # set the min level of channel A, $i=0-127
#  my $cc  = $et->set_A_max_level( $i );        # set the max level of channel A, $i=0-127
#  my $cc  = $et->set_A_level_rate( $i );       # set the level rate of channel A, $i=0-255
#  my $cc  = $et->set_A_level_options( $min, $rate );    # set the LEVEL OPTIONS for channel A
#                $min:   1=normal, 5=DEPTH               $rate:  0=normal, 2=TEMPO,   4=MA
#
#  my $cc  = $et->set_A_freq( $i );             # set the frequency of channel A, $i=0-247
#  my $cc  = $et->set_A_min_freq( $i );         # set the min frequency of channel A, $i=0-247
#  my $cc  = $et->set_A_max_freq( $i );         # set the max frequency of channel A, $i=0-247
#  my $cc  = $et->set_A_freq_rate( $i );        # set the frequency rate of channel A, $i=0-255
#  my $cc  = $et->set_A_freq_options( $val, $rate );  # set the frequency options of channel A
#                $val:  1=none     4=val/freq     5=max/freq      8=val/MA      9=max/MA
#                $rate: 0=none     2=rate/effect  4=rate/MA
#  my $cc  = $et->set_A_width( $i );            # set the pulse width of channel A, $i=0-191
#  my $cc  = $et->set_A_min_width( $i );        # set the pulse min width of channel A, $i=0-191
#  my $cc  = $et->set_A_max_width( $i );        # set the pulse max width of channel A, $i=0-191
#  my $cc  = $et->set_A_width_rate( $i );       # set the pulse width rate of channel A, $i=0-255
#  my $cc  = $et->set_A_width_options( $val, $rate );  # set the width options of channel A
#                $val:    1=none   4=val/width     5=min/width
#                $rate:   0=none   2=pace          4=MA
#-------
#  my $val = $et->get_B_time_on();              # get the TIME ON for channel B, $val=0-255, -1=error
#  my $val = $et->get_B_time_off();             # get the TIME OFF for channel B, $val=0-255, -1=error
#  my ($on,$off) = $et->get_B_time_options();         # get the TIME OPTIONS for channel B, (-1,-1)=error
#                $on:   1=normal, 5=EFFECT,  9=MA        $off:  0=normal, 2=TEMPO,   4=MA
#
#  my $val = $et->get_B_level();                # get the level of channel B, $val=0-127, -1=error
#  my $val = $et->get_B_min();                  # get the minimum level of channel B, $val=0-127, -1=error
#  my $val = $et->get_B_max();                  # get the maximum level of channel B, $val=0-127, -1=error
#  my $val = $et->get_B_level_rate();           # get the level rate for channel B, $val=0-255, -1=error
#  my ($min,$rate) = $et->get_B_level_options();         # get the LEVEL OPTIONS for channel B, (-1,-1)=error
#                $min:   1=normal, 5=DEPTH               $rate:  0=normal,  2=TEMPO,   4=MA
#
#  my $val = $et->get_B_freq();                 # get the frequency for channel B, $val=8=255, -1=error
#  my $val = $et->get_B_min_freq();             # get the min frequency for channel B, $val=0-247, -1=error
#  my $val = $et->get_B_max_freq();             # get the max frequency for channel B, $val=0-247, -1=error
#  my $val = $et->get_B_freq_rate();            # get the frequency rate for channel B, $val=0-255, -1=error
#  my ($val, $rate) = $et->get_B_freq_options( $val, $rate );  # get the frequency options of channel B
#                $val:  1=none     4=val/freq     5=max/freq      8=val/MA      9=max/MA
#                $rate: 0=none     2=rate/effect  4=rate/MA
#
#  my $val = $et->get_B_width();                # get the pulse width for channel B, $val=0-191, -1=error
#  my $val = $et->get_B_max_width();            # get the max pulse width for channel B, $val=0-191, -1=error
#  my $val = $et->get_B_min_width();            # get the min pulse width for channel B, $val=0-191, -1=error
#  my $val = $et->get_B_width_rate();           # get the pulse width rate for channel B, $val=0-255, -1=error
#  my ($val, $rate) = $et->get_B_width_options();        # get the pulse width options for channel B
#                $val:    1=none   4=val/width     5=min/width
#                $rate:   0=none   2=pace          4=MA
#-------
#  my $cc  = $et->set_B_time_on( $i );          # set the TIME ON for channel B, $i=0-255
#  my $cc  = $et->set_B_time_off( $i );         # set the TIME OFF for channel B, $i=0-255
#  my $cc  = $et->set_B_time_options( $on, $off );    # set the TIME OPTIONS for channel B
#                $on:   1=normal, 5=EFFECT,  9=MA        $off:  0=normal, 2=TEMPO,   4=MA
#  my $cc  = $et->set_B_level( $i );            # set the level of channel B, $i=0-127
#  my $cc  = $et->set_B_max_level( $i );        # set the level of channel B, $i=0-127
#  my $cc  = $et->set_B_min_level( $i );        # set the level of channel B, $i=0-127
#  my $cc  = $et->set_B_level_rate( $i );       # set the level rate of channel B, $i=0-255
#  my $cc  = $et->set_B_level_options( $min, $rate );    # set the LEVEL OPTIONS for channel B
#                $min:   1=normal, 5=DEPTH               $rate:  0=normal, 2=TEMPO,   4=MA
#
#  my $cc  = $et->set_B_freq( $i );             # set the frequency of channel B, $i=0-247
#  my $val = $et->set_B_min_freq( $i );         # set the min frequency for channel B, $val=0-247, -1=error
#  my $val = $et->set_B_max_freq( $i );         # set the max frequency for channel B, $val=0-247, -1=error
#  my $cc  = $et->set_B_freq_rate( $i );        # set the frequency rate of channel B, $i=0-255
#  my $cc  = $et->set_B_freq_options( $val, $rate );  # set the frequency options of channel B
#                $val:  1=none     4=val/freq     5=max/freq      8=val/MA      9=max/MA
#                $rate: 0=none     2=rate/effect  4=rate/MA
#
#  my $cc  = $et->set_B_width( $i );            # set the pulse width of channel B, $i=0-191
#  my $cc  = $et->set_B_min_width( $i );        # set the pulse min width of channel B, $i=0-191
#  my $cc  = $et->set_B_max_width( $i );        # set the pulse max width of channel B, $i=0-191
#  my $cc  = $et->set_B_width_rate( $i );       # set the pulse width rate of channel B, $i=0-255
#  my $cc  = $et->set_B_width_options( $val, $rate );  # set the width options of channel B
#                $val:    1=none   4=val/width     5=min/width
#                $rate:   0=none   2=pace          4=MA

our $TRAFFIC;                                   # filehandle if traffic option is used

########################################################################################################
#  create a new object, open comm port, sync with ESTIM
#  returns:  0 if error, object if successful
########################################################################################################
sub new {
   shift;                   # first parm is package name
   my $port = shift;        # get COMM port number
   my $file = shift;        # get file to store the MOD byte in
   my $DEBUG = shift;       # set to '1' to get messages on console
   my $comm = 0;

   my $p = $IO::estim::CommPorts[ $port ];       # select one port from the list of ports

   if ($^O eq "MSWin32") {  $comm = new Win32::SerialPort($p, 1);    }
   else                  {  $comm = new Device::SerialPort($p, 1);   }

   if( $comm ) {                      # if open succeeded, set COMM parms
       $comm->baudrate(19200);
       $comm->parity("none");
       $comm->databits(8);
       $comm->stopbits(1);
       if( $IO::estim::SetReadInterval > 0 )  { $comm->read_interval(10); }
       $comm->read_char_time(1);
       $comm->read_const_time(50);
       $comm->handshake("none");
       $comm->write_settings();
       }
    else {
       if( $DEBUG & 1 ) { print "ESTIM serial port: $port  failed to open\n"; }
       return 0;
       }
    my $self = {};           # create an empty object
    $self->{DEBUG} = $DEBUG; # save DEBUG setting
    $self->{COMM} = $comm;   # save COMM variable in new object
    if( $DEBUG > 1 ) {
         open( $TRAFFIC, ">traffic" );    # open traffic file if requested
         }
    ################# Assume the DEVICE was power cycled ##############################
    if( $DEBUG & 1 ) { print "Sending HELLO message to ESTIM\n"; }
    my $s = 0;
    for( my $try=0; $try < $IO::estim::MaxHello; $try++ ) {
        my $reply = &CommPlus( $self->{COMM}, "\x00", 0, $DEBUG );
        if( $reply eq "\x07" ) { $s++;  if( $s > 3 ) { last; } }
        else { $s = 0; }
        }
    if( $s > 3 ) { 
        if( $DEBUG & 1 ) { print "Success, ESTIM found\n\n";  }  
        if( $DEBUG & 1 ) { print "Syncing with ESTIM\n"; }
        my $reply = &CommPlus( $self->{COMM}, "\x2f\x00", 0, $DEBUG );
        my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
        if( $sum > 256 ) { $sum -= 256; }
        if( ( substr($reply, 0, 1 ) ne "\x21" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
            if( $DEBUG & 1 ) { printf("sum = 0x%02X\nUnable to sync with ESTIM\n", $sum); }
            return 0;
            }
        $self->{MOD} = ord(substr($reply, 1, 1 ));
        $self->{MOD2} = $self->{MOD} ^ 0x55;
        if( $DEBUG & 1 ) { printf( "Success, modification char is: 0x%02X\n", $self->{MOD} ); }
        if( length($file) > 0 ) {            # if $file was supplied, save the MOD byte in the file
            open( FILE, "> $file" );
            print FILE $self->{MOD};
            close FILE;
            }
        bless $self;
        return $self;            # return new object to caller
        }
    if( $DEBUG & 1 ) { print "Hello messages failed.  Try MOD file\n"; }
    ################### See if we can use a MOD file  ###############################
    if( length($file) > 0 ) {            # if $file was supplied, save the MOD byte in the file
        open( FILE, "< $file" );
        $self->{MOD} = <FILE>;
        $self->{MOD2} = $self->{MOD} ^ 0x55;
        if( $DEBUG & 1 ) { printf( "Modification char from file is: 0x%02X\n", $self->{MOD} ); }
        close FILE;
        my $s = 0; 
        for( my $try=0; $try<10; $try++ ) {        # try and get a 0x07 from DEVICE
            my $reply = &CommPlus( $self->{COMM}, "\x00", 0, $DEBUG );
            if( $reply eq "\x07" ) { $s=1;  last; }
            }
        if( $s < 1 ) { 
            if( $DEBUG & 1 ) { print "Could not get a response, failure to open DEVICE\n"; }
            return 0;
            }
        bless $self;
        my $val = $self->get_routine();
        if( $val != -1 ) {
            if( $DEBUG & 1 ) { printf( "Success, DEVICE was re-openned\n" ); }
            return $self;            # return new object to caller
            }     
        if( $DEBUG & 1 ) { print "Invalid response, failure to open DEVICE\n"; }
        return 0;
        }
    if( $DEBUG & 1 ) { print "No MOD file specified, failure to open DEVICE\n"; }
    return 0;
    }


########################################################################################################
#  get the routine number: NN, return -1 if error
########################################################################################################
sub get_routine {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x40\x7B", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
return $j;
}


########################################################################################################
#  get the data byte from a given address, return -1 if error
########################################################################################################
sub get_byte {
my $self = shift;  # get the object
my $adr  = shift;  # get the address
$adr = int ( $adr );     # make sure it's a integer
if( ($adr < 0 ) || ($adr > 0xffff) ) { return -1; }
my $b1 = $adr >> 8;             # upper byte of address
my $b2 = $adr & 255;            # lower byte of address
my $msg = "\x3C" . chr( $b1 ) . chr( $b2 );   # build inquiry message
my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
return $j;
}

########################################################################################################
#  get the time options channel: NN, return (-1,-1) if error
########################################################################################################
sub get_A_time_options {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x40\x9A", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
if( $j < 0 ) { return (-1,-1); }
my $on = $j & 15;            # on options are in lower nibble
my $off = $j >> 4;           # off options are in upper nibble
return ($on, $off);
}

sub get_B_time_options {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x41\x9A", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
if( $j < 0 ) { return (-1,-1); }
my $on = $j & 15;            # on options are in lower nibble
my $off = $j >> 4;           # off options are in upper nibble
return ($on, $off);
}

########################################################################################################
#  get the level options channel: NN, return (-1,-1) if error
########################################################################################################
sub get_A_level_options {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x40\xAC", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
if( $j < 0 ) { return (-1,-1); }
my $min = $j & 15;            # min options are in lower nibble
my $rate = $j >> 4;           # rate options are in upper nibble
$rate--;                      # adjust so codes match channel B codes
return ($min, $rate);
}

sub get_B_level_options {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x41\xAC", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
if( $j < 0 ) { return (-1,-1); }
my $min = $j & 15;            # min options are in lower nibble
my $rate = $j >> 4;           # rate options are in upper nibble
return ($min, $rate);
}

########################################################################################################
#  get the freq options channel A: NN, return (-1,-1) if error
########################################################################################################
sub get_A_freq_options {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x40\xB5", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
if( $j < 0 ) { return (-1,-1); }
my $val = $j & 15;            # val options are in lower nibble
my $rate = $j >> 4;           # rate options are in upper nibble
return ($val, $rate);
}

sub get_B_freq_options {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x41\xB5", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
if( $j < 0 ) { return (-1,-1); }
my $val = $j & 15;            # val options are in lower nibble
my $rate = $j >> 4;           # rate options are in upper nibble
return ($val, $rate);
}


########################################################################################################
#  get the width options: NN, return (-1,-1) if error
########################################################################################################
sub get_A_width_options {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x40\xBE", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
if( $j < 0 ) { return (-1,-1); }
my $val = $j & 15;            # val options are in lower nibble
my $rate = $j >> 4;           # rate options are in upper nibble
return ($val, $rate);
}

sub get_B_width_options {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x41\xBE", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
if( $j < 0 ) { return (-1,-1); }
my $val = $j & 15;            # val options are in lower nibble
my $rate = $j >> 4;           # rate options are in upper nibble
return ($val, $rate);
}


########################################################################################################
#  get the level of channel: 0-127, return -1 if error
########################################################################################################
sub get_A_level {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x40\xA5", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
return $j - 128;
}

sub get_B_level {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x41\xA5", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
return $j - 128;
}


########################################################################################################
#  get the mimimum level of channel: 0-127, return -1 if error
########################################################################################################
sub get_A_min_level {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x40\xA6", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
return $j - 128;
}

sub get_B_min_level {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x41\xA6", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
return $j - 128;
}


########################################################################################################
#  get the maximum level of channel: 0-127, return -1 if error
########################################################################################################
sub get_A_max_level {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x40\xA7", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
return $j - 128;
}

sub get_B_max_level {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x41\xA7", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
return $j - 128;
}


########################################################################################################
#  get the pulse width of channel: 0-127, return -1 if error
########################################################################################################
sub get_A_width {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x40\xB7", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
if( $j < 0 ) { return $j; }
return $j - 64;
}

sub get_B_width {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x41\xB7", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
if( $j < 0 ) { return $j; }
return $j - 64;
}



########################################################################################################
#  get the min pulse width of channel: 0-127, return -1 if error
########################################################################################################
sub get_A_min_width {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x40\xB8", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
if( $j < 0 ) { return $j; }
return $j - 64;
}

sub get_B_min_width {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x41\xB8", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
if( $j < 0 ) { return $j; }
return $j - 64;
}


########################################################################################################
#  get the max pulse width of channel: 0-127, return -1 if error
########################################################################################################
sub get_A_max_width {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x40\xB9", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
if( $j < 0 ) { return $j; }
return $j - 64;
}

sub get_B_max_width {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x41\xB9", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
if( $j < 0 ) { return $j; }
return $j - 64;
}


########################################################################################################
#  get the pulse width rate of channel: 0-255, return -1 if error
########################################################################################################
sub get_A_width_rate {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x40\xBA", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
if( $j < 0 ) { return $j; }
return 255 - $j;           # higher numbers result in faster rates
}

sub get_B_width_rate {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x41\xBA", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
if( $j < 0 ) { return $j; }
return 255 - $j;           # higher numbers result in faster rates
}



########################################################################################################
#  get the frequency of channel: 0-247, return -1 if error
########################################################################################################
sub get_A_freq {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x40\xAE", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
if( $j < 0 ) { return $j; }
return 255 - $j;           # higher numbers result in faster freq
}

sub get_B_freq {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x41\xAE", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
if( $j < 0 ) { return $j; }
return 255 - $j;           # higher numbers result in faster freq
}

########################################################################################################
#  get the min frequency of channel: 0-247, return -1 if error
########################################################################################################
sub get_A_min_freq {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x40\xB0", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
if( $j < 0 ) { return $j; }
return 255 - $j;           # higher numbers result in faster freq
}

sub get_B_min_freq {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x41\xB0", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
if( $j < 0 ) { return $j; }
return 255 - $j;           # higher numbers result in faster freq
}


########################################################################################################
#  get the max frequency of channel: 0-247, return -1 if error
########################################################################################################
sub get_A_max_freq {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x40\xAF", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
if( $j < 0 ) { return $j; }
return 255 - $j;           # higher numbers result in faster freq
}

sub get_B_max_freq {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x41\xAF", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
if( $j < 0 ) { return $j; }
return 255 - $j;           # higher numbers result in faster freq
}

########################################################################################################
#  get the frequency rate of channel: 0-255, return -1 if error
########################################################################################################
sub get_A_freq_rate {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x40\xB1", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
if( $j < 0 ) { return $j; }
return 255 - $j;           # higher numbers result in faster rates
}

sub get_B_freq_rate {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x41\xB1", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
if( $j < 0 ) { return $j; }
return 255 - $j;           # higher numbers result in faster rates
}

########################################################################################################
#  get the level rate of channel: 0-255, return -1 if error
########################################################################################################
sub get_A_level_rate {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x40\xA8", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
if( $j < 0 ) { return $j; }
return 255 - $j;           # higher numbers result in faster rates
}

sub get_B_level_rate {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x41\xA8", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
if( $j < 0 ) { return $j; }
return 255 - $j;           # higher numbers result in faster rates
}

########################################################################################################
#  get the TIME ON of channel: 0-255, return -1 if error
########################################################################################################
sub get_A_time_on {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x40\x98", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
return $j;
}

sub get_B_time_on {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x41\x98", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
return $j;
}

########################################################################################################
#  get the TIME OFF of channel A: 0-255, return -1 if error
########################################################################################################
sub get_A_time_off {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x40\x99", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
return $j;
}

sub get_B_time_off {
my $self = shift;  # get the object
my $reply = &CommPlus( $self->{COMM}, "\x3C\x41\x99", $self->{MOD2}, $self->{DEBUG} );
my $j = &Check( $reply );
return $j;
}


########################################################################################################
#  set the channel time options
########################################################################################################
sub set_A_time_options {
my $self = shift;  # get the object
my $on   = shift;
my $off  = shift;
if( $self->{DEBUG} & 1 ) { printf( "Set channel A time options on=%d, off=%d\n", $on, $off); } 
my $l = $on + ( $off * 16 );    # combine and shift off up 4 bits
my $msg = "\x4D\x40\x9A" . chr( $l );    # concatenate the message and time option chars
my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

sub set_B_time_options {
my $self = shift;  # get the object
my $on   = shift;
my $off  = shift;
if( $self->{DEBUG} & 1 ) { printf( "Set channel B time options on=%d, off=%d\n", $on, $off); } 
my $l = $on + ( $off * 16 );    # combine and shift off up 4 bits
my $msg = "\x4D\x41\x9A" . chr( $l );    # concatenate the message and time option chars
my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}


########################################################################################################
#  set the channel level options
########################################################################################################
sub set_A_level_options {
my $self = shift;  # get the object
my $min  = shift;
my $rate = shift;
$rate++;      # adjust to match channel B codes
if( $self->{DEBUG} & 1 ) { printf( "Set channel A level options min=%d, rate=%d\n", $min, $rate); } 
my $l = $min + ( $rate * 16 );    # combine and shift rate up 4 bits
my $msg = "\x4D\x40\xAC" . chr( $l );   # concatenate the message and option chars
my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

sub set_B_level_options {
my $self = shift;  # get the object
my $min  = shift;
my $rate = shift;
if( $self->{DEBUG} & 1 ) { printf( "Set channel B level options min=%d, rate=%d\n", $min, $rate); } 
my $l = $min + ( $rate * 16 );    # combine and shift rate up 4 bits
my $msg = "\x4D\x41\xAC" . chr( $l );   # concatenate the message and option chars
my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}




########################################################################################################
#  set the channel freq options
########################################################################################################
sub set_A_freq_options {
my $self = shift;  # get the object
my $val  = shift;
my $rate = shift;
if( $self->{DEBUG} & 1 ) { printf( "Set channel A freq options val=%d, rate=%d\n", $val, $rate); } 
my $l = $val + ( $rate * 16 );    # combine and shift rate up 4 bits
my $msg = "\x4D\x40\xB5" . chr( $l );   # concatenate the message and freq options chars
my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

sub set_B_freq_options {
my $self = shift;  # get the object
my $val  = shift;
my $rate = shift;
if( $self->{DEBUG} & 1 ) { printf( "Set channel B freq options val=%d, rate=%d\n", $val, $rate); } 
my $l = $val + ( $rate * 16 );    # combine and shift rate up 4 bits
my $msg = "\x4D\x41\xB5" . chr( $l );   # concatenate the message and freq options chars
my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}



########################################################################################################
#  set the width options
########################################################################################################
sub set_A_width_options {
my $self = shift;  # get the object
my $val  = shift;
my $rate = shift;

if( $self->{DEBUG} & 1 ) { printf( "Set channel A width options val=%d, rate=%d\n", $val, $rate); } 
my $l = $val + ( $rate * 16 );           # combine and shift rate up 4 bits
my $msg = "\x4D\x40\xBE" . chr( $l );    # concatenate the message and level chars

my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

sub set_B_width_options {
my $self = shift;  # get the object
my $val  = shift;
my $rate = shift;

if( $self->{DEBUG} & 1 ) { printf( "Set channel B width options val=%d, rate=%d\n", $val, $rate); } 
my $l = $val + ( $rate * 16 );           # combine and shift rate up 4 bits
my $msg = "\x4D\x41\xBE" . chr( $l );    # concatenate the message and level chars

my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}



########################################################################################################
#  set the level of channel to the specified value:  0-127
########################################################################################################
sub set_A_level {
my $self = shift;  # get the object
my $l = shift;     # level to set to:  0-127
$l = int( $l );    # make sure it's an integer
if( $l < 0 ) { $l = 0; }
if( $l > 127 ) { $l = 127; }
if( $self->{DEBUG} & 1 ) { printf( "Set channel A level=0x%02X\n", $l); }
my $msg = "\x4D\x40\xA5" . chr( $l + 128 );   # concatenate the message and level chars

my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

sub set_B_level {
my $self = shift;  # get the object
my $l = shift;     # level to set to:  0-127
$l = int( $l );    # make sure it's an integer
if( $l < 0 ) { $l = 0; }
if( $l > 127 ) { $l = 127; }
if( $self->{DEBUG} & 1 ) { printf( "Set channel B level=0x%02X\n", $l); }
my $msg = "\x4D\x41\xA5" . chr( $l + 128 );   # concatenate the message and level chars

my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}



########################################################################################################
#  set the minimum level of channel to the specified value:  0-127
########################################################################################################
sub set_A_min_level {
my $self = shift;  # get the object
my $l = shift;     # level to set to:  0-127
$l = int( $l );    # make sure it's an integer
if( $l < 0 ) { $l = 0; }
if( $l > 127 ) { $l = 127; }
if( $self->{DEBUG} & 1 ) { printf( "Set channel A min level=0x%02X\n", $l); }
my $msg = "\x4D\x40\xA6" . chr( $l + 128 );   # concatenate the message and level chars

my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

sub set_B_min_level {
my $self = shift;  # get the object
my $l = shift;     # level to set to:  0-127
$l = int( $l );    # make sure it's an integer
if( $l < 0 ) { $l = 0; }
if( $l > 127 ) { $l = 127; }
if( $self->{DEBUG} & 1 ) { printf( "Set channel B min level=0x%02X\n", $l); }
my $msg = "\x4D\x41\xA6" . chr( $l + 128 );   # concatenate the message and level chars

my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}



########################################################################################################
#  set the maximum level of channel to the specified value:  0-127
########################################################################################################
sub set_A_max_level {
my $self = shift;  # get the object
my $l = shift;     # level to set to:  0-127
$l = int( $l );    # make sure it's an integer
if( $l < 0 ) { $l = 0; }
if( $l > 127 ) { $l = 127; }
if( $self->{DEBUG} & 1 ) { printf( "Set channel A max level=0x%02X\n", $l); }
my $msg = "\x4D\x40\xA7" . chr( $l + 128 );   # concatenate the message and level chars

my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

sub set_B_max_level {
my $self = shift;  # get the object
my $l = shift;     # level to set to:  0-127
$l = int( $l );    # make sure it's an integer
if( $l < 0 ) { $l = 0; }
if( $l > 127 ) { $l = 127; }
if( $self->{DEBUG} & 1 ) { printf( "Set channel B max level=0x%02X\n", $l); }
my $msg = "\x4D\x41\xA7" . chr( $l + 128 );   # concatenate the message and level chars

my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}



########################################################################################################
#  set the pulse width of channel to the specified value:  0-191
########################################################################################################
sub set_A_width {
my $self = shift;       # get the object
my $l = shift;          # level to set to:  0-191
if( $l < 0 ) { $l = 0; }
if( $l > 191 ) { $l = 191; }
$l = 64 + int( $l );    # make sure it's an integer
if( $self->{DEBUG} & 1 ) { printf( "Set channel A width=0x%02X\n", $l); }
my $msg = "\x4D\x40\xB7" . chr( $l );    # concatenate the message and width chars
my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

sub set_B_width {
my $self = shift;       # get the object
my $l = shift;          # level to set to:  0-191
if( $l < 0 ) { $l = 0; }
if( $l > 191 ) { $l = 191; }
$l = 64 + int( $l );    # make sure it's an integer
if( $self->{DEBUG} & 1 ) { printf( "Set channel B width=0x%02X\n", $l); }
my $msg = "\x4D\x41\xB7" . chr( $l );    # concatenate the message and width chars
my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}


########################################################################################################
#  set the pulse min width of channel to the specified value:  0-191
########################################################################################################
sub set_A_min_width {
my $self = shift;       # get the object
my $l = shift;          # level to set to:  0-191
if( $l < 0 ) { $l = 0; }
if( $l > 191 ) { $l = 191; }
$l = 64 + int( $l );    # make sure it's an integer
if( $self->{DEBUG} & 1 ) { printf( "Set channel A min width=0x%02X\n", $l); }
my $msg = "\x4D\x40\xB8" . chr( $l );   # concatenate the message and width min chars
my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

sub set_B_min_width {
my $self = shift;       # get the object
my $l = shift;          # level to set to:  0-191
if( $l < 0 ) { $l = 0; }
if( $l > 191 ) { $l = 191; }
$l = 64 + int( $l );    # make sure it's an integer
if( $self->{DEBUG} & 1 ) { printf( "Set channel B min width=0x%02X\n", $l); }
my $msg = "\x4D\x41\xB8" . chr( $l );   # concatenate the message and width min chars
my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}


########################################################################################################
#  set the pulse max width of channel to the specified value:  0-191
########################################################################################################
sub set_A_max_width {
my $self = shift;       # get the object
my $l = shift;          # level to set to:  0-191
if( $l < 0 ) { $l = 0; }
if( $l > 191 ) { $l = 191; }
$l = 64 + int( $l );    # make sure it's an integer
if( $self->{DEBUG} & 1 ) { printf( "Set channel A max width=0x%02X\n", $l); }
my $msg = "\x4D\x40\xB9" . chr( $l );   # concatenate the message and width max chars
my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

sub set_B_max_width {
my $self = shift;       # get the object
my $l = shift;          # level to set to:  0-191
if( $l < 0 ) { $l = 0; }
if( $l > 191 ) { $l = 191; }
$l = 64 + int( $l );    # make sure it's an integer
if( $self->{DEBUG} & 1 ) { printf( "Set channel B max width=0x%02X\n", $l); }
my $msg = "\x4D\x41\xB9" . chr( $l );   # concatenate the message and width max chars
my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}



########################################################################################################
#  set the pulse width rate of channel to the specified value:  0-255
########################################################################################################
sub set_A_width_rate {
my $self = shift;       # get the object
my $l = shift;          # level to set to:  0-255
if( $l < 0 ) { $l = 0; }
if( $l > 255 ) { $l = 255; }
$l = int( $l );    # make sure it's an integer
$l = 255 - $l;     # higher numbers result in a faster rate
if( $self->{DEBUG} & 1 ) { printf( "Set channel A width rate=0x%02X\n", $l); }
my $msg = "\x4D\x40\xBA" . chr( $l );    # concatenate the message and width rate chars
my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

sub set_B_width_rate {
my $self = shift;       # get the object
my $l = shift;          # level to set to:  0-255
if( $l < 0 ) { $l = 0; }
if( $l > 255 ) { $l = 255; }
$l = int( $l );    # make sure it's an integer
$l = 255 - $l;     # higher numbers result in a faster rate
if( $self->{DEBUG} & 1 ) { printf( "Set channel B width rate=0x%02X\n", $l); }
my $msg = "\x4D\x41\xBA" . chr( $l );    # concatenate the message and width rate chars
my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}


########################################################################################################
#  set the frequency of channel to the specified value:  0-247
########################################################################################################
sub set_A_freq {
my $self = shift;       # get the object
my $l = shift;          # freq to set to:  0-247
if( $l < 0 ) { $l = 8; }
if( $l > 247 ) { $l = 247; }
$l = 255 - int( $l );    # make sure it's an integer
if( $self->{DEBUG} & 1 ) { printf( "Set channel A freq=0x%02X\n", $l); }
my $msg = "\x4D\x40\xAE" . chr( $l );   # concatenate the message and freq chars
my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

sub set_B_freq {
my $self = shift;       # get the object
my $l = shift;          # freq to set to:  0-247
if( $l < 0 ) { $l = 8; }
if( $l > 247 ) { $l = 247; }
$l = 255 - int( $l );    # make sure it's an integer
if( $self->{DEBUG} & 1 ) { printf( "Set channel B freq=0x%02X\n", $l); }
my $msg = "\x4D\x41\xAE" . chr( $l );   # concatenate the message and freq chars
my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}



########################################################################################################
#  set the min frequency of channel to the specified value:  0-247
########################################################################################################
sub set_A_min_freq {
my $self = shift;       # get the object
my $l = shift;          # min freq to set to:  0-247
if( $l < 0 ) { $l = 0; }
if( $l > 247 ) { $l = 247; }
if( $self->{DEBUG} & 1 ) { printf( "Set channel A freq min=0x%02X\n", $l); }
$l = 255 - int( $l );    # make sure it's an integer
my $msg = "\x4D\x40\xB0" . chr( $l );   # concatenate the message and min freq chars
my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

sub set_B_min_freq {
my $self = shift;       # get the object
my $l = shift;          # min freq to set to:  0-247
if( $l < 0 ) { $l = 0; }
if( $l > 247 ) { $l = 247; }
if( $self->{DEBUG} & 1 ) { printf( "Set channel B freq min=0x%02X\n", $l); }
$l = 255 - int( $l );    # make sure it's an integer
my $msg = "\x4D\x41\xB0" . chr( $l );   # concatenate the message and min freq chars
my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}





########################################################################################################
#  set the max frequency of channel to the specified value:  0-247
########################################################################################################
sub set_A_max_freq {
my $self = shift;       # get the object
my $l = shift;          # min freq to set to:  0-247
if( $l < 0 ) { $l = 0; }
if( $l > 247 ) { $l = 247; }
if( $self->{DEBUG} & 1 ) { printf( "Set channel A freq max=0x%02X\n", $l); }
$l = 255 - int( $l );    # make sure it's an integer
my $msg = "\x4D\x40\xAF" . chr( $l );   # concatenate the message and min freq chars
my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

sub set_B_max_freq {
my $self = shift;       # get the object
my $l = shift;          # min freq to set to:  0-247
if( $l < 0 ) { $l = 0; }
if( $l > 247 ) { $l = 247; }
if( $self->{DEBUG} & 1 ) { printf( "Set channel B freq max=0x%02X\n", $l); }
$l = 255 - int( $l );    # make sure it's an integer
my $msg = "\x4D\x41\xAF" . chr( $l );   # concatenate the message and min freq chars
my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}



########################################################################################################
#  set the frequency rate of channel to the specified value:  0-255
########################################################################################################
sub set_A_freq_rate {
my $self = shift;       # get the object
my $l = shift;          # freq to set to:  0-255
if( $l < 0 ) { $l = 0; }
if( $l > 255 ) { $l = 255; }
$l = int( $l );    # make sure it's an integer
$l = 255 - $l;     # higher numbers result in a faster rate
if( $self->{DEBUG} & 1 ) { printf( "Set channel A freq rate=0x%02X\n", $l); }
my $msg = "\x4D\x40\xB1" . chr( $l );   # concatenate the message and freq rate chars
my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

sub set_B_freq_rate {
my $self = shift;       # get the object
my $l = shift;          # freq to set to:  0-255
if( $l < 0 ) { $l = 0; }
if( $l > 255 ) { $l = 255; }
$l = int( $l );    # make sure it's an integer
$l = 255 - $l;     # higher numbers result in a faster rate
if( $self->{DEBUG} & 1 ) { printf( "Set channel B freq rate=0x%02X\n", $l); }
my $msg = "\x4D\x41\xB1" . chr( $l );   # concatenate the message and freq rate chars
my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

########################################################################################################
#  set the level rate of channel to the specified value:  0-255
########################################################################################################
sub set_A_level_rate {
my $self = shift;       # get the object
my $l = shift;          # level rate to set to:  0-255
if( $l < 0 ) { $l = 0; }
if( $l > 255 ) { $l = 255; }
$l = int( $l );    # make sure it's an integer
$l = 255 - $l;     # higher numbers result in a faster rate
if( $self->{DEBUG} & 1 ) { printf( "Set channel A level rate=0x%02X\n", $l); }
my $msg = "\x4D\x40\xA8" . chr( $l );   # concatenate the message and level rate chars
my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

sub set_B_level_rate {
my $self = shift;       # get the object
my $l = shift;          # level rate to set to:  0-255
if( $l < 0 ) { $l = 0; }
if( $l > 255 ) { $l = 255; }
$l = int( $l );    # make sure it's an integer
$l = 255 - $l;     # higher numbers result in a faster rate
if( $self->{DEBUG} & 1 ) { printf( "Set channel B level rate=0x%02X\n", $l); }
my $msg = "\x4D\x41\xA8" . chr( $l );   # concatenate the message and level rate chars
my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}



########################################################################################################
#  set the TIME ON of channel to the specified value:  0-255
########################################################################################################
sub set_A_time_on {
my $self = shift;       # get the object
my $l = shift;          # TIME ON:  0-255
if( $l < 0 ) { $l = 0; }
if( $l > 255 ) { $l = 255; }
$l = int( $l );    # make sure it's an integer
if( $self->{DEBUG} & 1 ) { printf( "Set channel A TIME ON=0x%02X\n", $l); }
my $msg = "\x4D\x40\x98" . chr( $l );    # concatenate the message and time-on chars
my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

sub set_B_time_on {
my $self = shift;       # get the object
my $l = shift;          # TIME ON:  0-255
if( $l < 0 ) { $l = 0; }
if( $l > 255 ) { $l = 255; }
$l = int( $l );    # make sure it's an integer
if( $self->{DEBUG} & 1 ) { printf( "Set channel B TIME ON=0x%02X\n", $l); }
my $msg = "\x4D\x41\x98" . chr( $l );    # concatenate the message and time-on chars
my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}


########################################################################################################
#  set the TIME OFF of channel to the specified value:  0-255
########################################################################################################
sub set_A_time_off {
my $self = shift;       # get the object
my $l = shift;          # TIME OFF:  0-255
if( $l < 0 ) { $l = 0; }
if( $l > 255 ) { $l = 255; }
$l = int( $l );    # make sure it's an integer
if( $self->{DEBUG} & 1 ) { printf( "Set channel A TIME OFF=0x%02X\n", $l); }
my $msg = "\x4D\x40\x99" . chr( $l );    # concatenate the message and time-off chars
my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

sub set_B_time_off {
my $self = shift;       # get the object
my $l = shift;          # TIME OFF:  0-255
if( $l < 0 ) { $l = 0; }
if( $l > 255 ) { $l = 255; }
$l = int( $l );    # make sure it's an integer
if( $self->{DEBUG} & 1 ) { printf( "Set channel B TIME OFF=0x%02X\n", $l); }
my $msg = "\x4D\x41\x99" . chr( $l );    # concatenate the message and time-off chars
my $reply = &CommPlus( $self->{COMM}, $msg, $self->{MOD2}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}



########################################################################################################
#  calculate a sumcheck, send a message out the serial port, and get a reply
#  sumcheck suppressed if only one byte is being transmitted
########################################################################################################
sub CommPlus() {
   my $comm = shift;            # COMM variable
   my $msg = shift;             # the message to send
   my $mod = shift;             # the modification char, use '0' if none
   my $opt = shift;             # set to '1' if messages wanted
   my $i;
   my $cnt;
   my $reply;
   my $sum = 0;
   my $ln = length($msg);

   if( $opt & 1 )  {  
       if( $ln > 1 ) { printf( "Send(%d): ", $ln + 1 ); }
       else          { printf( "Send(%d): ", $ln ); }
       }
   for( $i=0; $i< $ln; $i++ ) {
        my $c = ord(substr( $msg, $i, 1 ));          # get decimal value of new message char
        $sum += $c;                                  # accumulate sumcheck
        if( $sum > 255 )  { $sum -= 256; }           # modulo 256
        if( $opt & 1 )  {  printf(" 0x%02X", $c ); }
        if( $opt & 2 )  {  printf($TRAFFIC " 0x%02X", $c ); }
        $c ^= $mod;                                  # convert with MOD before transmission
        substr( $msg, $i, 1 ) = chr( $c );           # put converted value back into the message
        }
   if( $ln > 1 ) {                                   # no sumcheck char if only 1 byte is transmitted
       if( $opt & 1 )  {  printf(" 0x%02X", $sum ); }
       if( $opt & 2 )  {  printf($TRAFFIC " 0x%02X\n", $sum ); }
       $msg .= chr( $sum ^ $mod);                        # concatonate sumcheck onto the end of the message
       }
   $comm->write($msg);                               # send the converted message out the serial port
  ($cnt, $reply) = $comm->read(100);                 # get the reply
   if( $opt & 1 )  {  
       printf( "     Recv(%d): ", $cnt ); 
       for( $i=0; $i<$cnt; $i++ ) {
           printf(" 0x%02X", ord( substr($reply, $i, 1 ) ) ); 
           }
       print "\n"; 
       }
   return $reply;
   }


########################################################################################################
#  verify the sumcheck char on a 3 byte receive message, return value or -1 on error
########################################################################################################
sub Check() {
   my $msg = shift;             # the 3 byte message to check
   if( length( $msg ) != 3 )  { return -1; }
   my $b1 =  ord(substr($msg, 0, 1 ) );
   my $b2 =  ord(substr($msg, 1, 1 ) );
   my $b3 =  ord(substr($msg, 2, 1 ) );
   my $sum =  $b1 + $b2;
   if( $sum > 255 ) { $sum -= 256; }
   if( ( $b1 != 0x22 ) || ( $sum != $b3 ) ) { 
       return -1;
       }
   return $b2;
   }

1;
