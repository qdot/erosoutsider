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
#         Package to interface with the ESTIM via a serial port                       #
#######################################################################################

package IO::estim;
use strict;
use Win32::SerialPort;


###################### methods ##################################
#
#
#  my $et  = IO::estim->new($port, $file, $DEBUG);   # new object, opens COMM port, syncs with ESTIM
#                                               $port:  1=COM 1, 2=COM 2, etc
#                                               $file:  if not empty string, used to save the MOD char
#                                                    so that ESTIM does not have to be power cycled
#                                                    each time the program starts.
#
#  my $val = $et->get_routine();                # get the number of the routine running on the device
#        76=waves     77=stroke    78=climb     79=combo    7A=intense    7B=rhythm     7C=audio1
#        7D=audio2    7E=audio3    7F=split     80=random1  81=random2    82=toggle     83=orgasm 
#        84=torment   85=phase1    86=phase2    87=phase3   88=user1      89=user2      8A=user3
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

   my $p = "COM" . $port;
   $comm = new Win32::SerialPort($p, 1);

   if( $comm ) {                      # if open succeeded, set COMM parms
       $comm->baudrate(19200);
       $comm->parity("none");
       $comm->databits(8);
       $comm->stopbits(1);
       $comm->read_interval(10);
       $comm->read_char_time(1);
       $comm->read_const_time(50);
       $comm->handshake("none");
       $comm->write_settings();
       }
    else {
       if( $DEBUG > 0 ) { print "ESTIM serial port: $port  failed to open\n"; }
       return 0;
       }
    my $self = {};           # create an empty object
    $self->{DEBUG} = $DEBUG; # save DEBUG setting
    $self->{COMM} = $comm;   # save COMM variable in new object

    ################# Assume the DEVICE was power cycled ##############################
    if( $DEBUG > 0 ) { print "Sending HELLO message to ESTIM\n"; }
    my $s = 0;
    for( my $try=0; $try<5; $try++ ) {
        my $reply = &Comm( $self->{COMM}, "\x00", 0, $DEBUG );
        if( $reply eq "\x07" ) { $s++;  if( $s > 3 ) { last; } }
        else { $s = 0; }
        }
    if( $s > 3 ) { 
        if( $DEBUG > 0 ) { print "Success, ESTIM found\n\n";  }  
        if( $DEBUG > 0 ) { print "Syncing with ESTIM\n"; }
        my $reply = &Comm( $self->{COMM}, "\x2f\x00\x2f", 0, $DEBUG );
        my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
        if( $sum > 256 ) { $sum -= 256; }
        if( ( substr($reply, 0, 1 ) ne "\x21" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
            if( $DEBUG > 0 ) { printf("sum = 0x%02X\nUnable to sync with ESTIM\n", $sum); }
            return 0;
            }
        $self->{MOD} = ord(substr($reply, 1, 1 ));
        if( $DEBUG > 0 ) { printf( "Success, modification char is: 0x%02X\n", $self->{MOD} ); }
        if( length($file) > 0 ) {            # if $file was supplied, save the MOD byte in the file
            open( FILE, "> $file" );
            print FILE $self->{MOD};
            close FILE;
            }
        bless $self;
        return $self;            # return new object to caller
        }
    if( $DEBUG > 0 ) { print "Hello messages failed.  Try MOD file\n"; }
    ################### See if we can use a MOD file  ###############################
    if( length($file) > 0 ) {            # if $file was supplied, save the MOD byte in the file
        open( FILE, "< $file" );
        $self->{MOD} = <FILE>;
        if( $DEBUG > 0 ) { printf( "Modification char from file is: 0x%02X\n", $self->{MOD} ); }
        close FILE;
        my $s = 0; 
        for( my $try=0; $try<10; $try++ ) {        # try and get a 0x07 from DEVICE
            my $reply = &Comm( $self->{COMM}, "\x00", 0, $DEBUG );
            if( $reply eq "\x07" ) { $s=1;  last; }
            }
        if( $s < 1 ) { 
            if( $DEBUG > 0 ) { print "Could not get a response, failure to open DEVICE\n"; }
            return 0;
            }
        bless $self;
        my $val = $self->get_routine();
        if( $val != -1 ) {
            if( $DEBUG > 0 ) { printf( "Success, DEVICE was re-openned\n" ); }
            return $self;            # return new object to caller
            }     
        if( $DEBUG > 0 ) { print "Invalid response, failure to open DEVICE\n"; }
        return 0;
        }
    if( $DEBUG > 0 ) { print "No MOD file specified, failure to open DEVICE\n"; }
    return 0;
    }


########################################################################################################
#  get the time options channel A: NN, return (-1,-1) if error
########################################################################################################
sub get_A_time_options {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x15\xcf\x43", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel A time options\n"); }
        return (-1,-1);
        }
my $j = ord(substr( $reply, 1, 1 ));
my $on = $j & 15;            # on options are in lower nibble
my $off = $j >> 4;           # off options are in upper nibble
return ($on, $off);
}

########################################################################################################
#  get the level options channel A: NN, return (-1,-1) if error
########################################################################################################
sub get_A_level_options {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x15\xf9\x7d", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel A level options\n"); }
        return (-1,-1);
        }
my $j = ord(substr( $reply, 1, 1 ));
my $min = $j & 15;            # min options are in lower nibble
my $rate = $j >> 4;           # rate options are in upper nibble
$rate--;                      # adjust so codes match channel B codes
return ($min, $rate);
}

########################################################################################################
#  get the freq options channel A: NN, return (-1,-1) if error
########################################################################################################
sub get_A_freq_options {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x15\xe0\x64", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel A level options\n"); }
        return (-1,-1);
        }
my $j = ord(substr( $reply, 1, 1 ));
my $val = $j & 15;            # val options are in lower nibble
my $rate = $j >> 4;           # rate options are in upper nibble
return ($val, $rate);
}


########################################################################################################
#  get the width options channel A: NN, return (-1,-1) if error
########################################################################################################
sub get_A_width_options {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x15\xeb\x6f", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel A width options\n"); }
        return (-1,-1);
        }
my $j = ord(substr( $reply, 1, 1 ));
my $val = $j & 15;            # val options are in lower nibble
my $rate = $j >> 4;           # rate options are in upper nibble
return ($val, $rate);
}


########################################################################################################
#  get the routine number: NN, return -1 if error
########################################################################################################
sub get_routine {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x15\x2e\xa2", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel A level\n"); }
        return -1;
        }
my $j = ord(substr( $reply, 1, 1 ));
return $j;
}


########################################################################################################
#  get the level of channel A: 0-127, return -1 if error
########################################################################################################
sub get_A_level {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x15\xf0\x74", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel A level\n"); }
        return -1;
        }
my $j = ord(substr( $reply, 1, 1 )) - 128;
return $j;
}

########################################################################################################
#  get the mimimum level of channel A: 0-127, return -1 if error
########################################################################################################
sub get_A_min_level {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x15\xf3\x77", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel A min\n"); }
        return -1;
        }
my $j = ord(substr( $reply, 1, 1 )) - 128;
return $j;
}

########################################################################################################
#  get the maximum level of channel A: 0-127, return -1 if error
########################################################################################################
sub get_A_max_level {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x15\xf2\x76", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel A max\n"); }
        return -1;
        }
my $j = ord(substr( $reply, 1, 1 )) - 128;
return $j;
}

########################################################################################################
#  get the pulse width of channel A: 0-127, return -1 if error
########################################################################################################
sub get_A_width {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x15\xe2\x66", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel A width\n"); }
        return -1;
        }
my $j = ord(substr( $reply, 1, 1 )) - 64;
return $j;
}

########################################################################################################
#  get the min pulse width of channel A: 0-127, return -1 if error
########################################################################################################
sub get_A_min_width {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x15\xed\x61", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel A min width\n"); }
        return -1;
        }
my $j = ord(substr( $reply, 1, 1 )) - 64;
return $j;
}

########################################################################################################
#  get the max pulse width of channel A: 0-127, return -1 if error
########################################################################################################
sub get_A_max_width {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x15\xec\x60", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel A max width\n"); }
        return -1;
        }
my $j = ord(substr( $reply, 1, 1 )) - 64;
return $j;
}

########################################################################################################
#  get the pulse width rate of channel A: 0-255, return -1 if error
########################################################################################################
sub get_A_width_rate {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x15\xef\x63", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel A width rate\n"); }
        return -1;
        }
my $j = ord(substr( $reply, 1, 1 ));
return $j;
}


########################################################################################################
#  get the frequency of channel A: 0-247, return -1 if error
########################################################################################################
sub get_A_freq {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x15\xfb\x7f", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel A freq\n"); }
        return -1;
        }
my $j = 255 - ord(substr( $reply, 1, 1 ));
return $j;
}

########################################################################################################
#  get the min frequency of channel A: 0-247, return -1 if error
########################################################################################################
sub get_A_min_freq {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x15\xe5\x79", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel A min freq\n"); }
        return -1;
        }
my $j = 255 - ord(substr( $reply, 1, 1 ));
return $j;
}

########################################################################################################
#  get the max frequency of channel A: 0-247, return -1 if error
########################################################################################################
sub get_A_max_freq {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x15\xfa\x7e", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel A max freq\n"); }
        return -1;
        }
my $j = 255 - ord(substr( $reply, 1, 1 ));
return $j;
}

########################################################################################################
#  get the frequency rate of channel A: 0-255, return -1 if error
########################################################################################################
sub get_A_freq_rate {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x15\xe4\x78", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel A freq rate\n"); }
        return -1;
        }
my $j = ord(substr( $reply, 1, 1 ));
return $j;
}

########################################################################################################
#  get the level rate of channel A: 0-255, return -1 if error
########################################################################################################
sub get_A_level_rate {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x15\xfd\x71", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel A freq\n"); }
        return -1;
        }
my $j = ord(substr( $reply, 1, 1 ));
return $j;
}

########################################################################################################
#  get the TIME ON of channel A: 0-255, return -1 if error
########################################################################################################
sub get_A_time_on {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x15\xcd\x41", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel A time on\n"); }
        return -1;
        }
my $j = ord(substr( $reply, 1, 1 ));
return $j;
}

########################################################################################################
#  get the TIME OFF of channel A: 0-255, return -1 if error
########################################################################################################
sub get_A_time_off {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x15\xcc\x40", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel A time off\n"); }
        return -1;
        }
my $j = ord(substr( $reply, 1, 1 ));
return $j;
}

########################################################################################################
#  set the channel A time options
########################################################################################################
sub set_A_time_options {

my %tbl    = (                         #  sumcheck table, use after combining and ^0x55                                                                                 
     0x54, 0x7d,  0x5C, 0x65,  0x50, 0x79,  
     0x14, 0x3d,  0x1C, 0x25,  0x10, 0x39,  
     0x74, 0x1d,  0x7C, 0x05,  0x70, 0x19); 

my $self = shift;  # get the object
my $on   = shift;
my $off  = shift;

if( $self->{DEBUG} > 0 ) { printf( "Set channel A time options on=%d, off=%d\n", $on, $off); } 
my $l = $on + ( $off * 16 );    # combine and shift off up 4 bits
$l ^= 0x55;
if( !defined( $tbl{ $l } ) ) { return 0; }    # failure
my $msg = "\x18\x15\xcf" . chr( $l ) . chr( $tbl{ $l } );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

########################################################################################################
#  set the channel A level options
########################################################################################################
sub set_A_level_options {

my %tbl    = (                         #  sumcheck table, use after combining and ^0x55                                                                                 
     0x44, 0x1f,  0x04, 0xdf,  0x64, 0x3f,  
     0x40, 0x1b,  0x60, 0x3b,  0x00, 0xdb); 

my $self = shift;  # get the object
my $min  = shift;
my $rate = shift;
$rate++;      # adjust to match channel B codes

if( $self->{DEBUG} > 0 ) { printf( "Set channel A level options min=%d, rate=%d\n", $min, $rate); } 
my $l = $min + ( $rate * 16 );    # combine and shift rate up 4 bits
$l ^= 0x55;
if( !defined( $tbl{ $l } ) ) { return 0; }    # failure
my $msg = "\x18\x15\xf9" . chr( $l ) . chr( $tbl{ $l } );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

########################################################################################################
#  set the channel A freq options
########################################################################################################
sub set_A_freq_options {

my %tbl    = (                         #  sumcheck table, use after combining and ^0x55                                                                                 
     0x54, 0x16,   0x5d, 0x1f,    0x51, 0x13,    0x5c, 0x1e,    0x50, 0x12,  
     0x14, 0xd6,   0x1d, 0xdf,    0x11, 0xd3,    0x1c, 0xde,    0x10, 0xd2,  
     0x74, 0x36,   0x7d, 0x3f,    0x71, 0x33,    0x7c, 0x3e,    0x70, 0x32);  

my $self = shift;  # get the object
my $val  = shift;
my $rate = shift;

if( $self->{DEBUG} > 0 ) { printf( "Set channel A freq options val=%d, rate=%d\n", $val, $rate); } 
my $l = $val + ( $rate * 16 );    # combine and shift rate up 4 bits
$l ^= 0x55;
if( !defined( $tbl{ $l } ) ) { return 0; }    # failure
my $msg = "\x18\x15\xe0" . chr( $l ) . chr( $tbl{ $l } );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}


########################################################################################################
#  set the channel A width options
########################################################################################################
sub set_A_width_options {

my %tbl    = (                         #  sumcheck table, use after combining and ^0x55                                                                                 
     0x10, 0xc5,   0x11, 0xda,    0x14, 0xd9,    0x50, 0x05,    0x51, 0x1a,  
     0x54, 0x19,   0x70, 0x25,    0x71, 0x3a,    0x74, 0x39);

my $self = shift;  # get the object
my $val  = shift;
my $rate = shift;

if( $self->{DEBUG} > 0 ) { printf( "Set channel A width options val=%d, rate=%d\n", $val, $rate); } 
my $l = $val + ( $rate * 16 );    # combine and shift rate up 4 bits
$l ^= 0x55;
if( !defined( $tbl{ $l } ) ) { return 0; }    # failure
my $msg = "\x18\x15\xeb" . chr( $l ) . chr( $tbl{ $l } );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}



########################################################################################################
#  set the level of channel A to the specified value:  0-127
########################################################################################################
sub set_A_level {

my @tbl    = (                         #  sumcheck table,   $tbl[0] = sumcheck for 0x80                                                                                   
#     0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
   0x52, 0x53, 0x5C, 0x5D, 0x56, 0x57, 0x50, 0x51, 0x5A, 0x5B, 0x44, 0x45, 0x5E, 0x5F, 0x58, 0x59,   # 8
   0xA2, 0xA3, 0xAC, 0xAD, 0xA6, 0xA7, 0xA0, 0xA1, 0xAA, 0xAB, 0x54, 0x55, 0xAE, 0xAF, 0xA8, 0xA9,   # 9
   0x72, 0x73, 0x7C, 0x7D, 0x76, 0x77, 0x70, 0x71, 0x7A, 0x7B, 0x64, 0x65, 0x7E, 0x7F, 0x78, 0x79,   # A
   0x42, 0x43, 0x4C, 0x4D, 0x46, 0x47, 0x40, 0x41, 0x4A, 0x4B, 0x74, 0x75, 0x4E, 0x4F, 0x48, 0x49,   # B
   0x92, 0x93, 0x9C, 0x9D, 0x96, 0x97, 0x90, 0x91, 0x9A, 0x9B, 0x84, 0x85, 0x9E, 0x9F, 0x98, 0x99,   # C
   0xE2, 0xE3, 0xEC, 0xED, 0xE6, 0xE7, 0xE0, 0xE1, 0xEA, 0xEB, 0x94, 0x95, 0xEE, 0xEF, 0xE8, 0xE9,   # D
   0xB2, 0xB3, 0xBC, 0xBD, 0xB6, 0xB7, 0xB0, 0xB1, 0xBA, 0xBB, 0xA4, 0xA5, 0xBE, 0xBF, 0xB8, 0xB9,   # E
   0x82, 0x83, 0x8C, 0x8D, 0x86, 0x87, 0x80, 0x81, 0x8A, 0x8B, 0xB4, 0xB5, 0x8E, 0x8F, 0x88, 0x89);  # F

my $self = shift;  # get the object
my $l = shift;     # level to set to:  0-127
$l = int( $l );    # make sure it's an integer
if( $l < 0 ) { $l = 0; }
if( $l > 127 ) { $l = 127; }
if( $self->{DEBUG} > 0 ) { printf( "Set channel A level=0x%02X\n", $l); }
$l ^= 0x55;        # adjust the requested level to match the send message spec
my $msg = "\x18\x15\xF0" . chr( $l + 128 ) . chr( $tbl[ $l ] );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

########################################################################################################
#  set the minimum level of channel A to the specified value:  0-127
########################################################################################################
sub set_A_min_level {

my @tbl    = (                         #  sumcheck table,   $tbl[0] = sumcheck for 0x80                                                                                   
#     0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
   0x5D, 0x52, 0x5F, 0x5C, 0x51, 0x56, 0x53, 0x50, 0x45, 0x5A, 0x47, 0x44, 0x59, 0x5E, 0x5B, 0x58,   # 8
   0xAD, 0xA2, 0xAF, 0xAC, 0xA1, 0xA6, 0xA3, 0xA0, 0x55, 0xAA, 0x57, 0x54, 0xA9, 0xAE, 0xAB, 0xA8,   # 9
   0x7D, 0x72, 0x7F, 0x7C, 0x71, 0x76, 0x73, 0x70, 0x65, 0x7A, 0x67, 0x64, 0x79, 0x7E, 0x7B, 0x78,   # A
   0x4D, 0x42, 0x4F, 0x4C, 0x41, 0x46, 0x43, 0x40, 0x75, 0x4A, 0x77, 0x74, 0x49, 0x4E, 0x4B, 0x48,   # B
   0x9D, 0x92, 0x9F, 0x9C, 0x91, 0x96, 0x93, 0x90, 0x85, 0x9A, 0x87, 0x84, 0x99, 0x9E, 0x9B, 0x98,   # C
   0xED, 0xE2, 0xEF, 0xEC, 0xE1, 0xE6, 0xE3, 0xE0, 0x95, 0xEA, 0x97, 0x94, 0xE9, 0xEE, 0xEB, 0xE8,   # D
   0xBD, 0xB2, 0xBF, 0xBC, 0xB1, 0xB6, 0xB3, 0xB0, 0xA5, 0xBA, 0xA7, 0xA4, 0xB9, 0xBE, 0xBB, 0xB8,   # E
   0x8D, 0x82, 0x8F, 0x8C, 0x81, 0x86, 0x83, 0x80, 0xB5, 0x8A, 0xB7, 0xB4, 0x89, 0x8E, 0x8B, 0x88);  # F

my $self = shift;  # get the object
my $l = shift;     # level to set to:  0-127
$l = int( $l );    # make sure it's an integer
if( $l < 0 ) { $l = 0; }
if( $l > 127 ) { $l = 127; }
if( $self->{DEBUG} > 0 ) { printf( "Set channel A min level=0x%02X\n", $l); }
$l ^= 0x55;        # adjust the requested level to match the send message spec
my $msg = "\x18\x15\xF3" . chr( $l + 128 ) . chr( $tbl[ $l ] );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

########################################################################################################
#  set the maximum level of channel A to the specified value:  0-127
########################################################################################################
sub set_A_max_level {

my @tbl    = (                         #  sumcheck table,   $tbl[0] = sumcheck for 0x80                                                                                   
#     0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
   0x5C, 0x5D, 0x5E, 0x5F, 0x50, 0x51, 0x52, 0x53, 0x44, 0x45, 0x46, 0x47, 0x58, 0x59, 0x5A, 0x5B,   # 8
   0xAC, 0xAD, 0xAE, 0xAF, 0xA0, 0xA1, 0xA2, 0xA3, 0x54, 0x55, 0x56, 0x57, 0xA8, 0xA9, 0xAA, 0xAB,   # 9
   0x7C, 0x7D, 0x7E, 0x7F, 0x70, 0x71, 0x72, 0x73, 0x64, 0x65, 0x66, 0x67, 0x78, 0x79, 0x7A, 0x7B,   # A
   0x4C, 0x4D, 0x4E, 0x4F, 0x40, 0x41, 0x42, 0x43, 0x74, 0x75, 0x76, 0x77, 0x48, 0x49, 0x4A, 0x4B,   # B
   0x9C, 0x9D, 0x9E, 0x9F, 0x90, 0x91, 0x92, 0x93, 0x84, 0x85, 0x86, 0x87, 0x98, 0x99, 0x9A, 0x9B,   # C
   0xEC, 0xED, 0xEE, 0xEF, 0xE0, 0xE1, 0xE2, 0xE3, 0x94, 0x95, 0x96, 0x97, 0xE8, 0xE9, 0xEA, 0xEB,   # D
   0xBC, 0xBD, 0xBE, 0xBF, 0xB0, 0xB1, 0xB2, 0xB3, 0xA4, 0xA5, 0xA6, 0xA7, 0xB8, 0xB9, 0xBA, 0xBB,   # E
   0x8C, 0x8D, 0x8E, 0x8F, 0x80, 0x81, 0x82, 0x83, 0xB4, 0xB5, 0xB6, 0xB7, 0x88, 0x89, 0x8A, 0x8B);  # F

my $self = shift;  # get the object
my $l = shift;     # level to set to:  0-127
$l = int( $l );    # make sure it's an integer
if( $l < 0 ) { $l = 0; }
if( $l > 127 ) { $l = 127; }
if( $self->{DEBUG} > 0 ) { printf( "Set channel A min level=0x%02X\n", $l); }
$l ^= 0x55;        # adjust the requested level to match the send message spec
my $msg = "\x18\x15\xF2" . chr( $l + 128 ) . chr( $tbl[ $l ] );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

########################################################################################################
#  set the pulse width of channel A to the specified value:  0-191
########################################################################################################
sub set_A_width {

my @tbl    = (                         #  sumcheck table                                                                               
#     0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
   0xCC, 0xCD, 0xCE, 0xCF, 0xC0, 0xC1, 0xC2, 0xC3, 0xF4, 0xF5, 0xF6, 0xF7, 0xC8, 0xC9, 0xCA, 0xCB,   # 0
   0xDC, 0xDD, 0xDE, 0xDF, 0xD0, 0xD1, 0xD2, 0xD3, 0xC4, 0xC5, 0xC6, 0xC7, 0xD8, 0xD9, 0xDA, 0xDB,   # 1
   0xEC, 0xED, 0xEE, 0xEF, 0xE0, 0xE1, 0xE2, 0xE3, 0x94, 0x95, 0x96, 0x97, 0xE8, 0xE9, 0xEA, 0xEB,   # 2
   0xFC, 0xFD, 0xFE, 0xFF, 0xF0, 0xF1, 0xF2, 0xF3, 0xE4, 0xE5, 0xE6, 0xE7, 0xF8, 0xF9, 0xFA, 0xFB,   # 3
#     0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,   # 4
#     0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,   # 5
#     0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,   # 6
#     0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,   # 7
   0x4C, 0x4D, 0x4E, 0x4F, 0x40, 0x41, 0x42, 0x43, 0x74, 0x75, 0x76, 0x77, 0x48, 0x49, 0x4A, 0x4B,   # 8
   0x5C, 0x5D, 0x5E, 0x5F, 0x50, 0x51, 0x52, 0x53, 0x44, 0x45, 0x46, 0x47, 0x58, 0x59, 0x5A, 0x5B,   # 9
   0x6C, 0x6D, 0x6E, 0x6F, 0x60, 0x61, 0x62, 0x63, 0x14, 0x15, 0x16, 0x17, 0x68, 0x69, 0x6A, 0x6B,   # A
   0x7C, 0x7D, 0x7E, 0x7F, 0x70, 0x71, 0x72, 0x73, 0x64, 0x65, 0x66, 0x67, 0x78, 0x79, 0x7A, 0x7B,   # B
   0x8C, 0x8D, 0x8E, 0x8F, 0x80, 0x81, 0x82, 0x83, 0xB4, 0xB5, 0xB6, 0xB7, 0x88, 0x89, 0x8A, 0x8B,   # C
   0x9C, 0x9D, 0x9E, 0x9F, 0x90, 0x91, 0x92, 0x93, 0x84, 0x85, 0x86, 0x87, 0x98, 0x99, 0x9A, 0x9B,   # D
   0xAC, 0xAD, 0xAE, 0xAF, 0xA0, 0xA1, 0xA2, 0xA3, 0x54, 0x55, 0x56, 0x57, 0xA8, 0xA9, 0xAA, 0xAB,   # E
   0xBC, 0xBD, 0xBE, 0xBF, 0xB0, 0xB1, 0xB2, 0xB3, 0xA4, 0xA5, 0xA6, 0xA7, 0xB8, 0xB9, 0xBA, 0xBB);  # F
my $self = shift;       # get the object
my $l = shift;          # level to set to:  0-191
if( $l < 0 ) { $l = 0; }
if( $l > 191 ) { $l = 191; }
$l = 64 + int( $l );    # make sure it's an integer
$l ^= 0x55;
my $indx = $l;
if( $indx >= 0x80 ) { $indx -= 0x40; }       # skip over unsed values to reduce table size
if( $self->{DEBUG} > 0 ) { printf( "Set channel A width=0x%02X\n", $l); }
my $msg = "\x18\x15\xE2" . chr( $l ) . chr( $tbl[ $indx ] );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

########################################################################################################
#  set the pulse min width of channel A to the specified value:  0-191
########################################################################################################
sub set_A_min_width {

my @tbl    = (                         #  sumcheck table                                                                               
#     0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
   0xCF, 0xCC, 0xC9, 0xCE, 0xC3, 0xC0, 0xCD, 0xC2, 0xF7, 0xF4, 0xF1, 0xF6, 0xCB, 0xC8, 0xF5, 0xCA,   # 0
   0xDF, 0xDC, 0xD9, 0xDE, 0xD3, 0xD0, 0xDD, 0xD2, 0xC7, 0xC4, 0xC1, 0xC6, 0xDB, 0xD8, 0xC5, 0xDA,   # 1
   0xEF, 0xEC, 0xE9, 0xEE, 0xE3, 0xE0, 0xED, 0xE2, 0x97, 0x94, 0x91, 0x96, 0xEB, 0xE8, 0x95, 0xEA,   # 2
   0xFF, 0xFC, 0xF9, 0xFE, 0xF3, 0xF0, 0xFD, 0xF2, 0xE7, 0xE4, 0xE1, 0xE6, 0xFB, 0xF8, 0xE5, 0xFA,   # 3
#    -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   # 4
#    -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   # 5
#    -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   # 6
#    -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   # 7
   0x4F, 0x4C, 0x49, 0x4E, 0x43, 0x40, 0x4D, 0x42, 0x77, 0x74, 0x71, 0x76, 0x4B, 0x48, 0x75, 0x4A,   # 8
   0x5F, 0x5C, 0x59, 0x5E, 0x53, 0x50, 0x5D, 0x52, 0x47, 0x44, 0x41, 0x46, 0x5B, 0x58, 0x45, 0x5A,   # 9
   0x6F, 0x6C, 0x69, 0x6E, 0x63, 0x60, 0x6D, 0x62, 0x17, 0x14, 0x11, 0x16, 0x6B, 0x68, 0x15, 0x6A,   # A
   0x7F, 0x7C, 0x79, 0x7E, 0x73, 0x70, 0x7D, 0x72, 0x67, 0x64, 0x61, 0x66, 0x7B, 0x78, 0x65, 0x7A,   # B
   0x8F, 0x8C, 0x89, 0x8E, 0x83, 0x80, 0x8D, 0x82, 0xB7, 0xB4, 0xB1, 0xB6, 0x8B, 0x88, 0xB5, 0x8A,   # C
   0x9F, 0x9C, 0x99, 0x9E, 0x93, 0x90, 0x9D, 0x92, 0x87, 0x84, 0x81, 0x86, 0x9B, 0x98, 0x85, 0x9A,   # D
   0xAF, 0xAC, 0xA9, 0xAE, 0xA3, 0xA0, 0xAD, 0xA2, 0x57, 0x54, 0x51, 0x56, 0xAB, 0xA8, 0x55, 0xAA,   # E
   0xBF, 0xBC, 0xB9, 0xBE, 0xB3, 0xB0, 0xBD, 0xB2, 0xA7, 0xA4, 0xA1, 0xA6, 0xBB, 0xB8, 0xA5, 0xBA);  # F
my $self = shift;       # get the object
my $l = shift;          # level to set to:  0-191
if( $l < 0 ) { $l = 0; }
if( $l > 191 ) { $l = 191; }
$l = 64 + int( $l );    # make sure it's an integer
$l ^= 0x55;
my $indx = $l;
if( $indx >= 0x80 ) { $indx -= 0x40; }       # skip over unsed values to reduce table size
if( $self->{DEBUG} > 0 ) { printf( "Set channel A min width=0x%02X\n", $l); }
my $msg = "\x18\x15\xED" . chr( $l ) . chr( $tbl[ $indx ] );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

########################################################################################################
#  set the pulse max width of channel A to the specified value:  0-191
########################################################################################################
sub set_A_max_width {

my @tbl    = (                         #  sumcheck table                                                                               
#     0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
   0xCE, 0xCF, 0xC8, 0xC9, 0xC2, 0xC3, 0xCC, 0xCD, 0xF6, 0xF7, 0xF0, 0xF1, 0xCA, 0xCB, 0xF4, 0xF5,   # 0
   0xDE, 0xDF, 0xD8, 0xD9, 0xD2, 0xD3, 0xDC, 0xDD, 0xC6, 0xC7, 0xC0, 0xC1, 0xDA, 0xDB, 0xC4, 0xC5,   # 1
   0xEE, 0xEF, 0xE8, 0xE9, 0xE2, 0xE3, 0xEC, 0xED, 0x96, 0x97, 0x90, 0x91, 0xEA, 0xEB, 0x94, 0x95,   # 2
   0xFE, 0xFF, 0xF8, 0xF9, 0xF2, 0xF3, 0xFC, 0xFD, 0xE6, 0xE7, 0xE0, 0xE1, 0xFA, 0xFB, 0xE4, 0xE5,   # 3
#    -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   # 4
#    -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   # 5
#    -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   # 6
#    -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   # 7
   0x4E, 0x4F, 0x48, 0x49, 0x42, 0x43, 0x4C, 0x4D, 0x76, 0x77, 0x70, 0x71, 0x4A, 0x4B, 0x74, 0x75,   # 8
   0x5E, 0x5F, 0x58, 0x59, 0x52, 0x53, 0x5C, 0x5D, 0x46, 0x47, 0x40, 0x41, 0x5A, 0x5B, 0x44, 0x45,   # 9
   0x6E, 0x6F, 0x68, 0x69, 0x62, 0x63, 0x6C, 0x6D, 0x16, 0x17, 0x10, 0x11, 0x6A, 0x6B, 0x14, 0x15,   # A
   0x7E, 0x7F, 0x78, 0x79, 0x72, 0x73, 0x7C, 0x7D, 0x66, 0x67, 0x60, 0x61, 0x7A, 0x7B, 0x64, 0x65,   # B
   0x8E, 0x8F, 0x88, 0x89, 0x82, 0x83, 0x8C, 0x8D, 0xB6, 0xB7, 0xB0, 0xB1, 0x8A, 0x8B, 0xB4, 0xB5,   # C
   0x9E, 0x9F, 0x98, 0x99, 0x92, 0x93, 0x9C, 0x9D, 0x86, 0x87, 0x80, 0x81, 0x9A, 0x9B, 0x84, 0x85,   # D
   0xAE, 0xAF, 0xA8, 0xA9, 0xA2, 0xA3, 0xAC, 0xAD, 0x56, 0x57, 0x50, 0x51, 0xAA, 0xAB, 0x54, 0x55,   # E
   0xBE, 0xBF, 0xB8, 0xB9, 0xB2, 0xB3, 0xBC, 0xBD, 0xA6, 0xA7, 0xA0, 0xA1, 0xBA, 0xBB, 0xA4, 0xA5);  # F
my $self = shift;       # get the object
my $l = shift;          # level to set to:  0-191
if( $l < 0 ) { $l = 0; }
if( $l > 191 ) { $l = 191; }
$l = 64 + int( $l );    # make sure it's an integer
$l ^= 0x55;
my $indx = $l;
if( $indx >= 0x80 ) { $indx -= 0x40; }       # skip over unsed values to reduce table size
if( $self->{DEBUG} > 0 ) { printf( "Set channel A max width=0x%02X\n", $l); }
my $msg = "\x18\x15\xEC" . chr( $l ) . chr( $tbl[ $indx ] );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

########################################################################################################
#  set the pulse width rate of channel A to the specified value:  0-255
########################################################################################################
sub set_A_width_rate {

my @tbl    = (                         #  sumcheck table                                                                               
#     0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
   0xC9, 0xCE, 0xCB, 0xC8, 0xCD, 0xC2, 0xCF, 0xCC, 0xF1, 0xF6, 0xF3, 0xF0, 0xF5, 0xCA, 0xF7, 0xF4,   # 0
   0xD9, 0xDE, 0xDB, 0xD8, 0xDD, 0xD2, 0xDF, 0xDC, 0xC1, 0xC6, 0xC3, 0xC0, 0xC5, 0xDA, 0xC7, 0xC4,   # 1
   0xE9, 0xEE, 0xEB, 0xE8, 0xED, 0xE2, 0xEF, 0xEC, 0x91, 0x96, 0x93, 0x90, 0x95, 0xEA, 0x97, 0x94,   # 2
   0xF9, 0xFE, 0xFB, 0xF8, 0xFD, 0xF2, 0xFF, 0xFC, 0xE1, 0xE6, 0xE3, 0xE0, 0xE5, 0xFA, 0xE7, 0xE4,   # 3
   0x09, 0x0E, 0x0B, 0x08, 0x0D, 0x02, 0x0F, 0x0C, 0x31, 0x36, 0x33, 0x30, 0x35, 0x0A, 0x37, 0x34,   # 4
   0x19, 0x1E, 0x1B, 0x18, 0x1D, 0x12, 0x1F, 0x1C, 0x01, 0x06, 0x03, 0x00, 0x05, 0x1A, 0x07, 0x04,   # 5
   0x29, 0x2E, 0x2B, 0x28, 0x2D, 0x22, 0x2F, 0x2C, 0xD1, 0xD6, 0xD3, 0xD0, 0xD5, 0x2A, 0xD7, 0xD4,   # 6
   0x39, 0x3E, 0x3B, 0x38, 0x3D, 0x32, 0x3F, 0x3C, 0x21, 0x26, 0x23, 0x20, 0x25, 0x3A, 0x27, 0x24,   # 7
   0x49, 0x4E, 0x4B, 0x48, 0x4D, 0x42, 0x4F, 0x4C, 0x71, 0x76, 0x73, 0x70, 0x75, 0x4A, 0x77, 0x74,   # 8
   0x59, 0x5E, 0x5B, 0x58, 0x5D, 0x52, 0x5F, 0x5C, 0x41, 0x46, 0x43, 0x40, 0x45, 0x5A, 0x47, 0x44,   # 9
   0x69, 0x6E, 0x6B, 0x68, 0x6D, 0x62, 0x6F, 0x6C, 0x11, 0x16, 0x13, 0x10, 0x15, 0x6A, 0x17, 0x14,   # A
   0x79, 0x7E, 0x7B, 0x78, 0x7D, 0x72, 0x7F, 0x7C, 0x61, 0x66, 0x63, 0x60, 0x65, 0x7A, 0x67, 0x64,   # B
   0x89, 0x8E, 0x8B, 0x88, 0x8D, 0x82, 0x8F, 0x8C, 0xB1, 0xB6, 0xB3, 0xB0, 0xB5, 0x8A, 0xB7, 0xB4,   # C
   0x99, 0x9E, 0x9B, 0x98, 0x9D, 0x92, 0x9F, 0x9C, 0x81, 0x86, 0x83, 0x80, 0x85, 0x9A, 0x87, 0x84,   # D
   0xA9, 0xAE, 0xAB, 0xA8, 0xAD, 0xA2, 0xAF, 0xAC, 0x51, 0x56, 0x53, 0x50, 0x55, 0xAA, 0x57, 0x54,   # E
   0xB9, 0xBE, 0xBB, 0xB8, 0xBD, 0xB2, 0xBF, 0xBC, 0xA1, 0xA6, 0xA3, 0xA0, 0xA5, 0xBA, 0xA7, 0xA4);  # F
my $self = shift;       # get the object
my $l = shift;          # level to set to:  0-255
if( $l < 0 ) { $l = 0; }
if( $l > 255 ) { $l = 255; }
$l = int( $l );    # make sure it's an integer
$l ^= 0x55;
if( $self->{DEBUG} > 0 ) { printf( "Set channel A width rate=0x%02X\n", $l); }
my $msg = "\x18\x15\xEF" . chr( $l ) . chr( $tbl[ $l ] );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}


########################################################################################################
#  set the frequency of channel A to the specified value:  0-247
########################################################################################################
sub set_A_freq {

my @tbl    = (                         #  sumcheck table                                                                               
#     0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
   0xC5, 0xDA, 0xC7, 0xC4, 0xD9, 0xDE, 0xDB, 0xD8, 0xCD, 0xC2, 0xCF, 0xCC, 0xC1, 0xC6, 0xC3, 0xC0,   # 0
   0xD5, 0x2A, 0xD7, 0xD4, 0x29, 0x2E, 0x2B, 0x28, 0xDD, 0xD2, 0xDF, 0xDC, 0xD1, 0xD6, 0xD3, 0xD0,   # 1
   0xE5, 0xFA, 0xE7, 0xE4, 0xF9, 0xFE, 0xFB, 0xF8, 0xED, 0xE2, 0xEF, 0xEC, 0xE1, 0xE6, 0xE3, 0xE0,   # 2
   0xF5, 0xCA, 0xF7, 0xF4, 0xC9, 0xCE, 0xCB, 0xC8, 0xFD, 0xF2, 0xFF, 0xFC, 0xF1, 0xF6, 0xF3, 0xF0,   # 3
   0x05, 0x1A, 0x07, 0x04, 0x19, 0x1E, 0x1B, 0x18, 0x0D, 0x02, 0x0F, 0x0C, 0x01, 0x06, 0x03, 0x00,   # 4
   0x15, 0x6A, 0x17, 0x14, 0x69, 0x6E, 0x6B, 0x68, 0x1D, 0x12, 0x1F, 0x1C, 0x11, 0x16, 0x13, 0x10,   # 5
   0x25, 0x3A, 0x27, 0x24, 0x39, 0x3E, 0x3B, 0x38, 0x2D, 0x22, 0x2F, 0x2C, 0x21, 0x26, 0x23, 0x20,   # 6
   0x35, 0x0A, 0x37, 0x34, 0x09, 0x0E, 0x0B, 0x08, 0x3D, 0x32, 0x3F, 0x3C, 0x31, 0x36, 0x33, 0x30,   # 7
   0x45, 0x5A, 0x47, 0x44, 0x59, 0x5E, 0x5B, 0x58, 0x4D, 0x42, 0x4F, 0x4C, 0x41, 0x46, 0x43, 0x40,   # 8
   0x55, 0xAA, 0x57, 0x54, 0xA9, 0xAE, 0xAB, 0xA8, 0x5D, 0x52, 0x5F, 0x5C, 0x51, 0x56, 0x53, 0x50,   # 9
   0x65, 0x7A, 0x67, 0x64, 0x79, 0x7E, 0x7B, 0x78, 0x6D, 0x62, 0x6F, 0x6C, 0x61, 0x66, 0x63, 0x60,   # A
   0x75, 0x4A, 0x77, 0x74, 0x49, 0x4E, 0x4B, 0x48, 0x7D, 0x72, 0x7F, 0x7C, 0x71, 0x76, 0x73, 0x70,   # B
   0x85, 0x9A, 0x87, 0x84, 0x99, 0x9E, 0x9B, 0x98, 0x8D, 0x82, 0x8F, 0x8C, 0x81, 0x86, 0x83, 0x80,   # C
   0x95, 0xEA, 0x97, 0x94, 0xE9, 0xEE, 0xEB, 0xE8, 0x9D, 0x92, 0x9F, 0x9C, 0x91, 0x96, 0x93, 0x90,   # D
   0xA5, 0xBA, 0xA7, 0xA4, 0xB9, 0xBE, 0xBB, 0xB8, 0xAD, 0xA2, 0xAF, 0xAC, 0xA1, 0xA6, 0xA3, 0xA0,   # E
   0xB5, 0x8A, 0xB7, 0xB4, 0x89, 0x8E, 0x8B, 0x88, 0xBD, 0xB2, 0xBF, 0xBC, 0xB1, 0xB6, 0xB3, 0xB0);  # F
my $self = shift;       # get the object
my $l = shift;          # freq to set to:  0-247
if( $l < 0 ) { $l = 8; }
if( $l > 247 ) { $l = 247; }
$l = 255 - int( $l );    # make sure it's an integer
$l ^= 0x55;
my $indx = $l;
if( $self->{DEBUG} > 0 ) { printf( "Set channel A freq=0x%02X\n", $l); }
my $msg = "\x18\x15\xFB" . chr( $l ) . chr( $tbl[ $indx ] );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

########################################################################################################
#  set the min frequency of channel A to the specified value:  0-247
########################################################################################################
sub set_A_min_freq {

my @tbl    = (                         #  sumcheck table                                                                               
#     0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
   0xC7, 0xC4, 0xC1, 0xC6, 0xDB, 0xD8, 0xC5, 0xDA, 0xCF, 0xCC, 0xC9, 0xCE, 0xC3, 0xC0, 0xCD, 0xC2,   # 0
   0xD7, 0xD4, 0xD1, 0xD6, 0x2B, 0x28, 0xD5, 0x2A, 0xDF, 0xDC, 0xD9, 0xDE, 0xD3, 0xD0, 0xDD, 0xD2,   # 1
   0xE7, 0xE4, 0xE1, 0xE6, 0xFB, 0xF8, 0xE5, 0xFA, 0xEF, 0xEC, 0xE9, 0xEE, 0xE3, 0xE0, 0xED, 0xE2,   # 2
   0xF7, 0xF4, 0xF1, 0xF6, 0xCB, 0xC8, 0xF5, 0xCA, 0xFF, 0xFC, 0xF9, 0xFE, 0xF3, 0xF0, 0xFD, 0xF2,   # 3
   0x07, 0x04, 0x01, 0x06, 0x1B, 0x18, 0x05, 0x1A, 0x0F, 0x0C, 0x09, 0x0E, 0x03, 0x00, 0x0D, 0x02,   # 4
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1, 0x1F, 0x1C, 0x19, 0x1E, 0x13, 0x10, 0x1D, 0x12,   # 5
   0x27, 0x24, 0x21, 0x26, 0x3B, 0x38, 0x25, 0x3A, 0x2F, 0x2C, 0x29, 0x2E, 0x23, 0x20, 0x2D, 0x22,   # 6
   0x37, 0x34, 0x31, 0x36, 0x0B, 0x08, 0x35, 0x0A, 0x3F, 0x3C, 0x39, 0x3E, 0x33, 0x30, 0x3D, 0x32,   # 7
   0x47, 0x44, 0x41, 0x46, 0x5B, 0x58, 0x45, 0x5A, 0x4F, 0x4C, 0x49, 0x4E, 0x43, 0x40, 0x4D, 0x42,   # 8
   0x57, 0x54, 0x51, 0x56, 0xAB, 0xA8, 0x55, 0xAA, 0x5F, 0x5C, 0x59, 0x5E, 0x53, 0x50, 0x5D, 0x52,   # 9
   0x67, 0x64, 0x61, 0x66, 0x7B, 0x78, 0x65, 0x7A, 0x6F, 0x6C, 0x69, 0x6E, 0x63, 0x60, 0x6D, 0x62,   # A
   0x77, 0x74, 0x71, 0x76, 0x4B, 0x48, 0x75, 0x4A, 0x7F, 0x7C, 0x79, 0x7E, 0x73, 0x70, 0x7D, 0x72,   # B
   0x87, 0x84, 0x81, 0x86, 0x9B, 0x98, 0x85, 0x9A, 0x8F, 0x8C, 0x89, 0x8E, 0x83, 0x80, 0x8D, 0x82,   # C
   0x97, 0x94, 0x91, 0x96, 0xEB, 0xE8, 0x95, 0xEA, 0x9F, 0x9C, 0x99, 0x9E, 0x93, 0x90, 0x9D, 0x92,   # D
   0xA7, 0xA4, 0xA1, 0xA6, 0xBB, 0xB8, 0xA5, 0xBA, 0xAF, 0xAC, 0xA9, 0xAE, 0xA3, 0xA0, 0xAD, 0xA2,   # E
   0xB7, 0xB4, 0xB1, 0xB6, 0x8B, 0x88, 0xB5, 0x8A, 0xBF, 0xBC, 0xB9, 0xBE, 0xB3, 0xB0, 0xBD, 0xB2);  # F
my $self = shift;       # get the object
my $l = shift;          # min freq to set to:  0-247
if( $l < 0 ) { $l = 0; }
if( $l > 247 ) { $l = 247; }
$l = 255 - int( $l );    # make sure it's an integer
$l ^= 0x55;
my $indx = $l;
if( $self->{DEBUG} > 0 ) { printf( "Set channel A min freq=0x%02X\n", $l); }
my $msg = "\x18\x15\xE5" . chr( $l ) . chr( $tbl[ $indx ] );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

########################################################################################################
#  set the max frequency of channel A to the specified value:  0-247
########################################################################################################
sub set_A_max_freq {

my @tbl    = (                         #  sumcheck table                                                                               
#     0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
   0xC4, 0xC5, 0xC6, 0xC7, 0xD8, 0xD9, 0xDA, 0xDB, 0xCC, 0xCD, 0xCE, 0xCF, 0xC0, 0xC1, 0xC2, 0xC3,   # 0
   0xD4, 0xD5, 0xD6, 0xD7, 0x28, 0x29, 0x2A, 0x2B, 0xDC, 0xDD, 0xDE, 0xDF, 0xD0, 0xD1, 0xD2, 0xD3,   # 1
   0xE4, 0xE5, 0xE6, 0xE7, 0xF8, 0xF9, 0xFA, 0xFB, 0xEC, 0xED, 0xEE, 0xEF, 0xE0, 0xE1, 0xE2, 0xE3,   # 2
   0xF4, 0xF5, 0xF6, 0xF7, 0xC8, 0xC9, 0xCA, 0xCB, 0xFC, 0xFD, 0xFE, 0xFF, 0xF0, 0xF1, 0xF2, 0xF3,   # 3
   0x04, 0x05, 0x06, 0x07, 0x18, 0x19, 0x1A, 0x1B, 0x0C, 0x0D, 0x0E, 0x0F, 0x00, 0x01, 0x02, 0x03,   # 4
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1, 0x1C, 0x1D, 0x1E, 0x1F, 0x10, 0x11, 0x12, 0x13,   # 5
   0x24, 0x25, 0x26, 0x27, 0x38, 0x39, 0x3A, 0x3B, 0x2C, 0x2D, 0x2E, 0x2F, 0x20, 0x21, 0x22, 0x23,   # 6
   0x34, 0x35, 0x36, 0x37, 0x08, 0x09, 0x0A, 0x0B, 0x3C, 0x3D, 0x3E, 0x3F, 0x30, 0x31, 0x32, 0x33,   # 7
   0x44, 0x45, 0x46, 0x47, 0x58, 0x59, 0x5A, 0x5B, 0x4C, 0x4D, 0x4E, 0x4F, 0x40, 0x41, 0x42, 0x43,   # 8
   0x54, 0x55, 0x56, 0x57, 0xA8, 0xA9, 0xAA, 0xAB, 0x5C, 0x5D, 0x5E, 0x5F, 0x50, 0x51, 0x52, 0x53,   # 9
   0x64, 0x65, 0x66, 0x67, 0x78, 0x79, 0x7A, 0x7B, 0x6C, 0x6D, 0x6E, 0x6F, 0x60, 0x61, 0x62, 0x63,   # A
   0x74, 0x75, 0x76, 0x77, 0x48, 0x49, 0x4A, 0x4B, 0x7C, 0x7D, 0x7E, 0x7F, 0x70, 0x71, 0x72, 0x73,   # B
   0x84, 0x85, 0x86, 0x87, 0x98, 0x99, 0x9A, 0x9B, 0x8C, 0x8D, 0x8E, 0x8F, 0x80, 0x81, 0x82, 0x83,   # C
   0x94, 0x95, 0x96, 0x97, 0xE8, 0xE9, 0xEA, 0xEB, 0x9C, 0x9D, 0x9E, 0x9F, 0x90, 0x91, 0x92, 0x93,   # D
   0xA4, 0xA5, 0xA6, 0xA7, 0xB8, 0xB9, 0xBA, 0xBB, 0xAC, 0xAD, 0xAE, 0xAF, 0xA0, 0xA1, 0xA2, 0xA3,   # E
   0xB4, 0xB5, 0xB6, 0xB7, 0x88, 0x89, 0x8A, 0x8B, 0xBC, 0xBD, 0xBE, 0xBF, 0xB0, 0xB1, 0xB2, 0xB3);  # F
my $self = shift;       # get the object
my $l = shift;          # max freq to set to:  0-247
if( $l < 0 ) { $l = 0; }
if( $l > 247 ) { $l = 247; }
$l = 255 - int( $l );    # make sure it's an integer
$l ^= 0x55;
my $indx = $l;
if( $self->{DEBUG} > 0 ) { printf( "Set channel A max freq=0x%02X\n", $l); }
my $msg = "\x18\x15\xFA" . chr( $l ) . chr( $tbl[ $indx ] );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

########################################################################################################
#  set the frequency rate of channel A to the specified value:  0-255
########################################################################################################
sub set_A_freq_rate {

my @tbl    = (                         #  sumcheck table                                                                               
#     0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
   0xC6, 0xC7, 0xC0, 0xC1, 0xDA, 0xDB, 0xC4, 0xC5, 0xCE, 0xCF, 0xC8, 0xC9, 0xC2, 0xC3, 0xCC, 0xCD,   # 0
   0xD6, 0xD7, 0xD0, 0xD1, 0x2A, 0x2B, 0xD4, 0xD5, 0xDE, 0xDF, 0xD8, 0xD9, 0xD2, 0xD3, 0xDC, 0xDD,   # 1
   0xE6, 0xE7, 0xE0, 0xE1, 0xFA, 0xFB, 0xE4, 0xE5, 0xEE, 0xEF, 0xE8, 0xE9, 0xE2, 0xE3, 0xEC, 0xED,   # 2
   0xF6, 0xF7, 0xF0, 0xF1, 0xCA, 0xCB, 0xF4, 0xF5, 0xFE, 0xFF, 0xF8, 0xF9, 0xF2, 0xF3, 0xFC, 0xFD,   # 3
   0x06, 0x07, 0x00, 0x01, 0x1A, 0x1B, 0x04, 0x05, 0x0E, 0x0F, 0x08, 0x09, 0x02, 0x03, 0x0C, 0x0D,   # 4
   0x16, 0x17, 0x10, 0x11, 0x6A, 0x6B, 0x14, 0x15, 0x1E, 0x1F, 0x18, 0x19, 0x12, 0x13, 0x1C, 0x1D,   # 5
   0x26, 0x27, 0x20, 0x21, 0x3A, 0x3B, 0x24, 0x25, 0x2E, 0x2F, 0x28, 0x29, 0x22, 0x23, 0x2C, 0x2D,   # 6
   0x36, 0x37, 0x30, 0x31, 0x0A, 0x0B, 0x34, 0x35, 0x3E, 0x3F, 0x38, 0x39, 0x32, 0x33, 0x3C, 0x3D,   # 7
   0x46, 0x47, 0x40, 0x41, 0x5A, 0x5B, 0x44, 0x45, 0x4E, 0x4F, 0x48, 0x49, 0x42, 0x43, 0x4C, 0x4D,   # 8
   0x56, 0x57, 0x50, 0x51, 0xAA, 0xAB, 0x54, 0x55, 0x5E, 0x5F, 0x58, 0x59, 0x52, 0x53, 0x5C, 0x5D,   # 9
   0x66, 0x67, 0x60, 0x61, 0x7A, 0x7B, 0x64, 0x65, 0x6E, 0x6F, 0x68, 0x69, 0x62, 0x63, 0x6C, 0x6D,   # A
   0x76, 0x77, 0x70, 0x71, 0x4A, 0x4B, 0x74, 0x75, 0x7E, 0x7F, 0x78, 0x79, 0x72, 0x73, 0x7C, 0x7D,   # B
   0x86, 0x87, 0x80, 0x81, 0x9A, 0x9B, 0x84, 0x85, 0x8E, 0x8F, 0x88, 0x89, 0x82, 0x83, 0x8C, 0x8D,   # C
   0x96, 0x97, 0x90, 0x91, 0xEA, 0xEB, 0x94, 0x95, 0x9E, 0x9F, 0x98, 0x99, 0x92, 0x93, 0x9C, 0x9D,   # D
   0xA6, 0xA7, 0xA0, 0xA1, 0xBA, 0xBB, 0xA4, 0xA5, 0xAE, 0xAF, 0xA8, 0xA9, 0xA2, 0xA3, 0xAC, 0xAD,   # E
   0xB6, 0xB7, 0xB0, 0xB1, 0x8A, 0x8B, 0xB4, 0xB5, 0xBE, 0xBF, 0xB8, 0xB9, 0xB2, 0xB3, 0xBC, 0xBD);  # F
my $self = shift;       # get the object
my $l = shift;          # freq to set to:  0-255
if( $l < 0 ) { $l = 0; }
if( $l > 255 ) { $l = 255; }
$l = int( $l );    # make sure it's an integer
$l ^= 0x55;
my $indx = $l;
if( $self->{DEBUG} > 0 ) { printf( "Set channel A freq rate=0x%02X\n", $l); }
my $msg = "\x18\x15\xe4" . chr( $l ) . chr( $tbl[ $indx ] );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}


########################################################################################################
#  set the level rate of channel A to the specified value:  0-255
########################################################################################################
sub set_A_level_rate {

my @tbl    = (                         #  sumcheck table                                                                               
#     0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
   0xDF, 0xDC, 0xD9, 0xDE, 0xD3, 0xD0, 0xDD, 0xD2, 0xC7, 0xC4, 0xC1, 0xC6, 0xDB, 0xD8, 0xC5, 0xDA,   # 0
   0x2F, 0x2C, 0x29, 0x2E, 0x23, 0x20, 0x2D, 0x22, 0xD7, 0xD4, 0xD1, 0xD6, 0x2B, 0x28, 0xD5, 0x2A,   # 1
   0xFF, 0xFC, 0xF9, 0xFE, 0xF3, 0xF0, 0xFD, 0xF2, 0xE7, 0xE4, 0xE1, 0xE6, 0xFB, 0xF8, 0xE5, 0xFA,   # 2
   0xCF, 0xCC, 0xC9, 0xCE, 0xC3, 0xC0, 0xCD, 0xC2, 0xF7, 0xF4, 0xF1, 0xF6, 0xCB, 0xC8, 0xF5, 0xCA,   # 3
   0x1F, 0x1C, 0x19, 0x1E, 0x13, 0x10, 0x1D, 0x12, 0x07, 0x04, 0x01, 0x06, 0x1B, 0x18, 0x05, 0x1A,   # 4
   0x6F, 0x6C, 0x69, 0x6E, 0x63, 0x60, 0x6D, 0x62, 0x17, 0x14, 0x11, 0x16, 0x6B, 0x68, 0x15, 0x6A,   # 5
   0x3F, 0x3C, 0x39, 0x3E, 0x33, 0x30, 0x3D, 0x32, 0x27, 0x24, 0x21, 0x26, 0x3B, 0x38, 0x25, 0x3A,   # 6
   0x0F, 0x0C, 0x09, 0x0E, 0x03, 0x00, 0x0D, 0x02, 0x37, 0x34, 0x31, 0x36, 0x0B, 0x08, 0x35, 0x0A,   # 7
   0x5F, 0x5C, 0x59, 0x5E, 0x53, 0x50, 0x5D, 0x52, 0x47, 0x44, 0x41, 0x46, 0x5B, 0x58, 0x45, 0x5A,   # 8
   0xAF, 0xAC, 0xA9, 0xAE, 0xA3, 0xA0, 0xAD, 0xA2, 0x57, 0x54, 0x51, 0x56, 0xAB, 0xA8, 0x55, 0xAA,   # 9
   0x7F, 0x7C, 0x79, 0x7E, 0x73, 0x70, 0x7D, 0x72, 0x67, 0x64, 0x61, 0x66, 0x7B, 0x78, 0x65, 0x7A,   # A
   0x4F, 0x4C, 0x49, 0x4E, 0x43, 0x40, 0x4D, 0x42, 0x77, 0x74, 0x71, 0x76, 0x4B, 0x48, 0x75, 0x4A,   # B
   0x9F, 0x9C, 0x99, 0x9E, 0x93, 0x90, 0x9D, 0x92, 0x87, 0x84, 0x81, 0x86, 0x9B, 0x98, 0x85, 0x9A,   # C
   0xEF, 0xEC, 0xE9, 0xEE, 0xE3, 0xE0, 0xED, 0xE2, 0x97, 0x94, 0x91, 0x96, 0xEB, 0xE8, 0x95, 0xEA,   # D
   0xBF, 0xBC, 0xB9, 0xBE, 0xB3, 0xB0, 0xBD, 0xB2, 0xA7, 0xA4, 0xA1, 0xA6, 0xBB, 0xB8, 0xA5, 0xBA,   # E
   0x8F, 0x8C, 0x89, 0x8E, 0x83, 0x80, 0x8D, 0x82, 0xB7, 0xB4, 0xB1, 0xB6, 0x8B, 0x88, 0xB5, 0x8A);  # F
my $self = shift;       # get the object
my $l = shift;          # level rate to set to:  0-255
if( $l < 0 ) { $l = 0; }
if( $l > 255 ) { $l = 255; }
$l = int( $l );    # make sure it's an integer
$l ^= 0x55;
my $indx = $l;
if( $self->{DEBUG} > 0 ) { printf( "Set channel A min level=0x%02X\n", $l); }
my $msg = "\x18\x15\xFD" . chr( $l ) . chr( $tbl[ $indx ] );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

########################################################################################################
#  set the TIME ON of channel A to the specified value:  0-255
########################################################################################################
sub set_A_time_on {

my @tbl    = (                         #  sumcheck table                                                                               
#     0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
   0x2F, 0x2C, 0x29, 0x2E, 0x23, 0x20, 0x2D, 0x22, 0xD7, 0xD4, 0xD1, 0xD6, 0x2B, 0x28, 0xD5, 0x2A,   # 0
   0x3F, 0x3C, 0x39, 0x3E, 0x33, 0x30, 0x3D, 0x32, 0x27, 0x24, 0x21, 0x26, 0x3B, 0x38, 0x25, 0x3A,   # 1
   0xCF, 0xCC, 0xC9, 0xCE, 0xC3, 0xC0, 0xCD, 0xC2, 0xF7, 0xF4, 0xF1, 0xF6, 0xCB, 0xC8, 0xF5, 0xCA,   # 2
   0xDF, 0xDC, 0xD9, 0xDE, 0xD3, 0xD0, 0xDD, 0xD2, 0xC7, 0xC4, 0xC1, 0xC6, 0xDB, 0xD8, 0xC5, 0xDA,   # 3
   0x6F, 0x6C, 0x69, 0x6E, 0x63, 0x60, 0x6D, 0x62, 0x17, 0x14, 0x11, 0x16, 0x6B, 0x68, 0x15, 0x6A,   # 4
   0x7F, 0x7C, 0x79, 0x7E, 0x73, 0x70, 0x7D, 0x72, 0x67, 0x64, 0x61, 0x66, 0x7B, 0x78, 0x65, 0x7A,   # 5
   0x0F, 0x0C, 0x09, 0x0E, 0x03, 0x00, 0x0D, 0x02, 0x37, 0x34, 0x31, 0x36, 0x0B, 0x08, 0x35, 0x0A,   # 6
   0x1F, 0x1C, 0x19, 0x1E, 0x13, 0x10, 0x1D, 0x12, 0x07, 0x04, 0x01, 0x06, 0x1B, 0x18, 0x05, 0x1A,   # 7
   0xAF, 0xAC, 0xA9, 0xAE, 0xA3, 0xA0, 0xAD, 0xA2, 0x57, 0x54, 0x51, 0x56, 0xAB, 0xA8, 0x55, 0xAA,   # 8
   0xBF, 0xBC, 0xB9, 0xBE, 0xB3, 0xB0, 0xBD, 0xB2, 0xA7, 0xA4, 0xA1, 0xA6, 0xBB, 0xB8, 0xA5, 0xBA,   # 9
   0x4F, 0x4C, 0x49, 0x4E, 0x43, 0x40, 0x4D, 0x42, 0x77, 0x74, 0x71, 0x76, 0x4B, 0x48, 0x75, 0x4A,   # A
   0x5F, 0x5C, 0x59, 0x5E, 0x53, 0x50, 0x5D, 0x52, 0x47, 0x44, 0x41, 0x46, 0x5B, 0x58, 0x45, 0x5A,   # B
   0xEF, 0xEC, 0xE9, 0xEE, 0xE3, 0xE0, 0xED, 0xE2, 0x97, 0x94, 0x91, 0x96, 0xEB, 0xE8, 0x95, 0xEA,   # C
   0xFF, 0xFC, 0xF9, 0xFE, 0xF3, 0xF0, 0xFD, 0xF2, 0xE7, 0xE4, 0xE1, 0xE6, 0xFB, 0xF8, 0xE5, 0xFA,   # D
   0x8F, 0x8C, 0x89, 0x8E, 0x83, 0x80, 0x8D, 0x82, 0xB7, 0xB4, 0xB1, 0xB6, 0x8B, 0x88, 0xB5, 0x8A,   # E
   0x9F, 0x9C, 0x99, 0x9E, 0x93, 0x90, 0x9D, 0x92, 0x87, 0x84, 0x81, 0x86, 0x9B, 0x98, 0x85, 0x9A);  # F
my $self = shift;       # get the object
my $l = shift;          # TIME ON:  0-255
if( $l < 0 ) { $l = 0; }
if( $l > 255 ) { $l = 255; }
$l = int( $l );    # make sure it's an integer
$l ^= 0x55;
my $indx = $l;
if( $self->{DEBUG} > 0 ) { printf( "Set channel A TIME ON=0x%02X\n", $l); }
my $msg = "\x18\x15\xCD" . chr( $l ) . chr( $tbl[ $indx ] );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}


########################################################################################################
#  set the TIME OFF of channel A to the specified value:  0-255
########################################################################################################
sub set_A_time_off {

my @tbl    = (                         #  sumcheck table                                                                               
#     0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
   0x2E, 0x2F, 0x28, 0x29, 0x22, 0x23, 0x2C, 0x2D, 0xD6, 0xD7, 0xD0, 0xD1, 0x2A, 0x2B, 0xD4, 0xD5,   # 0
   0x3E, 0x3F, 0x38, 0x39, 0x32, 0x33, 0x3C, 0x3D, 0x26, 0x27, 0x20, 0x21, 0x3A, 0x3B, 0x24, 0x25,   # 1
   0xCE, 0xCF, 0xC8, 0xC9, 0xC2, 0xC3, 0xCC, 0xCD, 0xF6, 0xF7, 0xF0, 0xF1, 0xCA, 0xCB, 0xF4, 0xF5,   # 2
   0xDE, 0xDF, 0xD8, 0xD9, 0xD2, 0xD3, 0xDC, 0xDD, 0xC6, 0xC7, 0xC0, 0xC1, 0xDA, 0xDB, 0xC4, 0xC5,   # 3
   0x6E, 0x6F, 0x68, 0x69, 0x62, 0x63, 0x6C, 0x6D, 0x16, 0x17, 0x10, 0x11, 0x6A, 0x6B, 0x14, 0x15,   # 4
   0x7E, 0x7F, 0x78, 0x79, 0x72, 0x73, 0x7C, 0x7D, 0x66, 0x67, 0x60, 0x61, 0x7A, 0x7B, 0x64, 0x65,   # 5
   0x0E, 0x0F, 0x08, 0x09, 0x02, 0x03, 0x0C, 0x0D, 0x36, 0x37, 0x30, 0x31, 0x0A, 0x0B, 0x34, 0x35,   # 6
   0x1E, 0x1F, 0x18, 0x19, 0x12, 0x13, 0x1C, 0x1D, 0x06, 0x07, 0x00, 0x01, 0x1A, 0x1B, 0x04, 0x05,   # 7
   0xAE, 0xAF, 0xA8, 0xA9, 0xA2, 0xA3, 0xAC, 0xAD, 0x56, 0x57, 0x50, 0x51, 0xAA, 0xAB, 0x54, 0x55,   # 8
   0xBE, 0xBF, 0xB8, 0xB9, 0xB2, 0xB3, 0xBC, 0xBD, 0xA6, 0xA7, 0xA0, 0xA1, 0xBA, 0xBB, 0xA4, 0xA5,   # 9
   0x4E, 0x4F, 0x48, 0x49, 0x42, 0x43, 0x4C, 0x4D, 0x76, 0x77, 0x70, 0x71, 0x4A, 0x4B, 0x74, 0x75,   # A
   0x5E, 0x5F, 0x58, 0x59, 0x52, 0x53, 0x5C, 0x5D, 0x46, 0x47, 0x40, 0x41, 0x5A, 0x5B, 0x44, 0x45,   # B
   0xEE, 0xEF, 0xE8, 0xE9, 0xE2, 0xE3, 0xEC, 0xED, 0x96, 0x97, 0x90, 0x91, 0xEA, 0xEB, 0x94, 0x95,   # C
   0xFE, 0xFF, 0xF8, 0xF9, 0xF2, 0xF3, 0xFC, 0xFD, 0xE6, 0xE7, 0xE0, 0xE1, 0xFA, 0xFB, 0xE4, 0xE5,   # D
   0x8E, 0x8F, 0x88, 0x89, 0x82, 0x83, 0x8C, 0x8D, 0xB6, 0xB7, 0xB0, 0xB1, 0x8A, 0x8B, 0xB4, 0xB5,   # E
   0x9E, 0x9F, 0x98, 0x99, 0x92, 0x93, 0x9C, 0x9D, 0x86, 0x87, 0x80, 0x81, 0x9A, 0x9B, 0x84, 0x85);  # F
my $self = shift;       # get the object
my $l = shift;          # TIME OFF:  0-255
if( $l < 0 ) { $l = 0; }
if( $l > 255 ) { $l = 255; }
$l = int( $l );    # make sure it's an integer
$l ^= 0x55;
my $indx = $l;
if( $self->{DEBUG} > 0 ) { printf( "Set channel A TIME ON=0x%02X\n", $l); }
my $msg = "\x18\x15\xCC" . chr( $l ) . chr( $tbl[ $indx ] );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}


########################################################################################################
#  get the time options channel B: NN, return (-1,-1) if error
########################################################################################################
sub get_B_time_options {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x14\xcf\x42", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel B time options\n"); }
        return (-1,-1);
        }
my $j = ord(substr( $reply, 1, 1 ));
my $on = $j & 15;            # on options are in lower nibble
my $off = $j >> 4;           # off options are in upper nibble
return ($on, $off);
}

########################################################################################################
#  get the level options channel B: NN, return (-1,-1) if error
########################################################################################################
sub get_B_level_options {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x14\xf9\x7c", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel B level options\n"); }
        return (-1,-1);
        }
my $j = ord(substr( $reply, 1, 1 ));
my $min = $j & 15;            # min options are in lower nibble
my $rate = $j >> 4;           # rate options are in upper nibble
return ($min, $rate);
}

########################################################################################################
#  get the freq options channel B: NN, return (-1,-1) if error
########################################################################################################
sub get_B_freq_options {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x14\xe0\x67", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel A level options\n"); }
        return (-1,-1);
        }
my $j = ord(substr( $reply, 1, 1 ));
my $val = $j & 15;            # val options are in lower nibble
my $rate = $j >> 4;           # rate options are in upper nibble
return ($val, $rate);
}

########################################################################################################
#  get the width options channel B: NN, return (-1,-1) if error
########################################################################################################
sub get_B_width_options {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x14\xeb\x6e", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel B width options\n"); }
        return (-1,-1);
        }
my $j = ord(substr( $reply, 1, 1 ));
my $val = $j & 15;            # val options are in lower nibble
my $rate = $j >> 4;           # rate options are in upper nibble
return ($val, $rate);
}


########################################################################################################
#  get the level of channel B: 0-127, return -1 if error
########################################################################################################
sub get_B_level {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x14\xf0\x77", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel B level\n"); }
        return -1;
        }
my $j = ord(substr( $reply, 1, 1 )) - 128;
return $j;
}

########################################################################################################
#  get the minimum level of channel B: 0-127, return -1 if error
########################################################################################################
sub get_B_min_level {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x14\xf3\x76", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel B level min\n"); }
        return -1;
        }
my $j = ord(substr( $reply, 1, 1 )) - 128;
return $j;
}

########################################################################################################
#  get the maximum level of channel B: 0-127, return -1 if error
########################################################################################################
sub get_B_max_level {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x14\xf2\x71", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel B level max\n"); }
        return -1;
        }
my $j = ord(substr( $reply, 1, 1 )) - 128;
return $j;
}

########################################################################################################
#  get the pulse width of channel B: 0-127, return -1 if error
########################################################################################################
sub get_B_width {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x14\xe2\x61", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel B width\n"); }
        return -1;
        }
my $j = ord(substr( $reply, 1, 1 )) - 64;
return $j;
}

########################################################################################################
#  get the min pulse width of channel B: 0-127, return -1 if error
########################################################################################################
sub get_B_min_width {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x14\xed\x60", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel B min width\n"); }
        return -1;
        }
my $j = ord(substr( $reply, 1, 1 )) - 64;
return $j;
}

########################################################################################################
#  get the max pulse width of channel B: 0-127, return -1 if error
########################################################################################################
sub get_B_max_width {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x14\xec\x63", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel B max width\n"); }
        return -1;
        }
my $j = ord(substr( $reply, 1, 1 )) - 64;
return $j;
}

########################################################################################################
#  get the pulse width rate of channel B: 0-255, return -1 if error
########################################################################################################
sub get_B_width_rate {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x14\xef\x62", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel B width rate\n"); }
        return -1;
        }
my $j = ord(substr( $reply, 1, 1 ));
return $j;
}
########################################################################################################
#  get the frequency of channel B: 0-247, return -1 if error
########################################################################################################
sub get_B_freq {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x14\xfb\x7e", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel B freq\n"); }
        return -1;
        }
my $j = 255 - ord(substr( $reply, 1, 1 ));
return $j;
}

########################################################################################################
#  get the min frequency of channel B: 0-247, return -1 if error
########################################################################################################
sub get_B_min_freq {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x14\xe5\x78", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel B min freq\n"); }
        return -1;
        }
my $j = 255 - ord(substr( $reply, 1, 1 ));
return $j;
}

########################################################################################################
#  get the max frequency of channel B: 0-247, return -1 if error
########################################################################################################
sub get_B_max_freq {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x14\xfa\x79", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel B max freq\n"); }
        return -1;
        }
my $j = 255 - ord(substr( $reply, 1, 1 ));
return $j;
}

########################################################################################################
#  get the frequency rate of channel B: 0-255, return -1 if error
########################################################################################################
sub get_B_freq_rate {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x14\xe4\x7b", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel B freq rate\n"); }
        return -1;
        }
my $j = ord(substr( $reply, 1, 1 ));
return $j;
}


########################################################################################################
#  get the level rate of channel B: 0-255, return -1 if error
########################################################################################################
sub get_B_level_rate {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x14\xfd\x70", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel B level rate\n"); }
        return -1;
        }
my $j = ord(substr( $reply, 1, 1 ));
return $j;
}

########################################################################################################
#  get the TIME ON of channel B: 0-255, return -1 if error
########################################################################################################
sub get_B_time_on {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x14\xcd\x40", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel B time on\n"); }
        return -1;
        }
my $j = ord(substr( $reply, 1, 1 ));
return $j;
}


########################################################################################################
#  get the TIME OFF of channel B: 0-255, return -1 if error
########################################################################################################
sub get_B_time_off {
my $self = shift;  # get the object
my $reply = &Comm( $self->{COMM}, "\x69\x14\xcc\x43", $self->{MOD}, $self->{DEBUG} );
my $sum =  ord(substr($reply, 0, 1 ) ) + ord(substr($reply, 1, 1 ) );
if( $sum > 255 ) { $sum -= 256; }
if( ( substr($reply, 0, 1 ) ne "\x22" ) || ( $sum != ord(substr($reply, 2, 1 ) ) ) ) { 
    if( $self->{DEBUG} > 0 ) { printf("unable to get channel B time off\n"); }
        return -1;
        }
my $j = ord(substr( $reply, 1, 1 ));
return $j;
}

########################################################################################################
#  set the channel B time options
########################################################################################################
sub set_B_time_options {

my %tbl    = (                         #  sumcheck table, use after combining and ^0x55                                                                                 
     0x54, 0x7c,  0x5C, 0x64,  0x50, 0x78,  
     0x14, 0x3c,  0x1C, 0x24,  0x10, 0x38,  
     0x74, 0x1c,  0x7C, 0x04,  0x70, 0x18); 

my $self = shift;  # get the object
my $on   = shift;
my $off  = shift;

if( $self->{DEBUG} > 0 ) { printf( "Set channel B time options on=%d, off=%d\n", $on, $off); } 
my $l = $on + ( $off * 16 );    # combine and shift off up 4 bits
$l ^= 0x55;
if( !defined( $tbl{ $l } ) ) { return 0; }    # failure
my $msg = "\x18\x14\xcf" . chr( $l ) . chr( $tbl{ $l } );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

########################################################################################################
#  set the channel B level options
########################################################################################################
sub set_B_level_options {

my %tbl    = (                         #  sumcheck table, use after combining and ^0x55                                                                                 
     0x54, 0x6e,  0x14, 0x2e,  0x74, 0x0e,  
     0x50, 0x6a,  0x70, 0x0a,  0x10, 0x2a); 

my $self = shift;  # get the object
my $min  = shift;
my $rate = shift;

if( $self->{DEBUG} > 0 ) { printf( "Set channel B level options min=%d, rate=%d\n", $min, $rate); } 
my $l = $min + ( $rate * 16 );    # combine and shift rate up 4 bits
$l ^= 0x55;
if( !defined( $tbl{ $l } ) ) { return 0; }    # failure
my $msg = "\x18\x14\xf9" . chr( $l ) . chr( $tbl{ $l } );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

########################################################################################################
#  set the channel B freq options
########################################################################################################
sub set_B_freq_options {

my %tbl    = (                         #  sumcheck table, use after combining and ^0x55                                                                                 
     0x54, 0x11,   0x5d, 0x1e,    0x51, 0x12,    0x5c, 0x19,    0x50, 0x1d,  
     0x14, 0xd1,   0x1d, 0xde,    0x11, 0xd2,    0x1c, 0xd9,    0x10, 0xdd,  
     0x74, 0x31,   0x7d, 0x3e,    0x71, 0x32,    0x7c, 0x39,    0x70, 0x3d);  

my $self = shift;  # get the object
my $val  = shift;
my $rate = shift;

if( $self->{DEBUG} > 0 ) { printf( "Set channel B freq options val=%d, rate=%d\n", $val, $rate); } 
my $l = $val + ( $rate * 16 );    # combine and shift rate up 4 bits
$l ^= 0x55;
if( !defined( $tbl{ $l } ) ) { return 0; }    # failure
my $msg = "\x18\x14\xe0" . chr( $l ) . chr( $tbl{ $l } );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

########################################################################################################
#  set the channel B width options
########################################################################################################
sub set_B_width_options {

my %tbl    = (                         #  sumcheck table, use after combining and ^0x55                                                                                 
     0x10, 0xc4,   0x11, 0xc5,    0x14, 0xd8,    0x50, 0x04,    0x51, 0x05,  
     0x54, 0x18,   0x70, 0x24,    0x71, 0x25,    0x74, 0x38);

my $self = shift;  # get the object
my $val  = shift;
my $rate = shift;

if( $self->{DEBUG} > 0 ) { printf( "Set channel B width options val=%d, rate=%d\n", $val, $rate); } 
my $l = $val + ( $rate * 16 );    # combine and shift rate up 4 bits
$l ^= 0x55;
if( !defined( $tbl{ $l } ) ) { return 0; }    # failure
my $msg = "\x18\x14\xeb" . chr( $l ) . chr( $tbl{ $l } );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}



########################################################################################################
#  set the level of channel B to the specified value:  0-127
########################################################################################################
sub set_B_level {

my @tbl    = (                         #  sumcheck table,   $tbl[0] = sumcheck for 0x80                                                                                   
#     0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
   0x5D, 0x52, 0x5F, 0x5C, 0x51, 0x56, 0x53, 0x50, 0x45, 0x5A, 0x47, 0x44, 0x59, 0x5E, 0x5B, 0x58,   # 8
   0xAD, 0xA2, 0xAF, 0xAC, 0xA1, 0xA6, 0xA3, 0xA0, 0x55, 0xAA, 0x57, 0x54, 0xA9, 0xAE, 0xAB, 0xA8,   # 9
   0x7D, 0x72, 0x7F, 0x7C, 0x71, 0x76, 0x73, 0x70, 0x65, 0x7A, 0x67, 0x64, 0x79, 0x7E, 0x7B, 0x78,   # A
   0x4D, 0x42, 0x4F, 0x4C, 0x41, 0x46, 0x43, 0x40, 0x75, 0x4A, 0x77, 0x74, 0x49, 0x4E, 0x4B, 0x48,   # B
   0x9D, 0x92, 0x9F, 0x9C, 0x91, 0x96, 0x93, 0x90, 0x85, 0x9A, 0x87, 0x84, 0x99, 0x9E, 0x9B, 0x98,   # C
   0xED, 0xE2, 0xEF, 0xEC, 0xE1, 0xE6, 0xE3, 0xE0, 0x95, 0xEA, 0x97, 0x94, 0xE9, 0xEE, 0xEB, 0xE8,   # D
   0xBD, 0xB2, 0xBF, 0xBC, 0xB1, 0xB6, 0xB3, 0xB0, 0xA5, 0xBA, 0xA7, 0xA4, 0xB9, 0xBE, 0xBB, 0xB8,   # E
   0x8D, 0x82, 0x8F, 0x8C, 0x81, 0x86, 0x83, 0x80, 0xB5, 0x8A, 0xB7, 0xB4, 0x89, 0x8E, 0x8B, 0x88);  # F
my $self = shift;  # get the object
my $l = shift;     # level to set to:  0-127
$l = int( $l );    # make sure it's an integer
if( $l < 0 ) { $l = 0; }
if( $l > 127 ) { $l = 127; }
if( $self->{DEBUG} > 0 ) { printf( "Set channel B level=0x%02X\n", $l); }
$l ^= 0x55;        # adjust the requested level to match the send message spec
my $msg = "\x18\x14\xF0" . chr( $l + 128 ) . chr( $tbl[ $l ] );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

########################################################################################################
#  set the max level of channel B to the specified value:  0-127
########################################################################################################
sub set_B_max_level {

my @tbl    = (                         #  sumcheck table,   $tbl[0] = sumcheck for 0x80                                                                                   
#     0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
   0x5F, 0x5C, 0x59, 0x5E, 0x53, 0x50, 0x5D, 0x52, 0x47, 0x44, 0x41, 0x46, 0x5B, 0x58, 0x45, 0x5A,   # 8
   0xAF, 0xAC, 0xA9, 0xAE, 0xA3, 0xA0, 0xAD, 0xA2, 0x57, 0x54, 0x51, 0x56, 0xAB, 0xA8, 0x55, 0xAA,   # 9
   0x7F, 0x7C, 0x79, 0x7E, 0x73, 0x70, 0x7D, 0x72, 0x67, 0x64, 0x61, 0x66, 0x7B, 0x78, 0x65, 0x7A,   # A
   0x4F, 0x4C, 0x49, 0x4E, 0x43, 0x40, 0x4D, 0x42, 0x77, 0x74, 0x71, 0x76, 0x4B, 0x48, 0x75, 0x4A,   # B
   0x9F, 0x9C, 0x99, 0x9E, 0x93, 0x90, 0x9D, 0x92, 0x87, 0x84, 0x81, 0x86, 0x9B, 0x98, 0x85, 0x9A,   # C
   0xEF, 0xEC, 0xE9, 0xEE, 0xE3, 0xE0, 0xED, 0xE2, 0x97, 0x94, 0x91, 0x96, 0xEB, 0xE8, 0x95, 0xEA,   # D
   0xBF, 0xBC, 0xB9, 0xBE, 0xB3, 0xB0, 0xBD, 0xB2, 0xA7, 0xA4, 0xA1, 0xA6, 0xBB, 0xB8, 0xA5, 0xBA,   # E
   0x8F, 0x8C, 0x89, 0x8E, 0x83, 0x80, 0x8D, 0x82, 0xB7, 0xB4, 0xB1, 0xB6, 0x8B, 0x88, 0xB5, 0x8A);  # F
my $self = shift;  # get the object
my $l = shift;     # level to set to:  0-127
$l = int( $l );    # make sure it's an integer
if( $l < 0 ) { $l = 0; }
if( $l > 127 ) { $l = 127; }
if( $self->{DEBUG} > 0 ) { printf( "Set channel B level max=0x%02X\n", $l); }
$l ^= 0x55;        # adjust the requested level to match the send message spec
my $msg = "\x18\x14\xF2" . chr( $l + 128 ) . chr( $tbl[ $l ] );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

########################################################################################################
#  set the min level of channel B to the specified value:  0-127
########################################################################################################
sub set_B_min_level {

my @tbl    = (                         #  sumcheck table,   $tbl[0] = sumcheck for 0x80                                                                                   
#     0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
   0x5C, 0x5D, 0x5E, 0x5F, 0x50, 0x51, 0x52, 0x53, 0x44, 0x45, 0x46, 0x47, 0x58, 0x59, 0x5A, 0x5B,   # 8
   0xAC, 0xAD, 0xAE, 0xAF, 0xA0, 0xA1, 0xA2, 0xA3, 0x54, 0x55, 0x56, 0x57, 0xA8, 0xA9, 0xAA, 0xAB,   # 9
   0x7C, 0x7D, 0x7E, 0x7F, 0x70, 0x71, 0x72, 0x73, 0x64, 0x65, 0x66, 0x67, 0x78, 0x79, 0x7A, 0x7B,   # A
   0x4C, 0x4D, 0x4E, 0x4F, 0x40, 0x41, 0x42, 0x43, 0x74, 0x75, 0x76, 0x77, 0x48, 0x49, 0x4A, 0x4B,   # B
   0x9C, 0x9D, 0x9E, 0x9F, 0x90, 0x91, 0x92, 0x93, 0x84, 0x85, 0x86, 0x87, 0x98, 0x99, 0x9A, 0x9B,   # C
   0xEC, 0xED, 0xEE, 0xEF, 0xE0, 0xE1, 0xE2, 0xE3, 0x94, 0x95, 0x96, 0x97, 0xE8, 0xE9, 0xEA, 0xEB,   # D
   0xBC, 0xBD, 0xBE, 0xBF, 0xB0, 0xB1, 0xB2, 0xB3, 0xA4, 0xA5, 0xA6, 0xA7, 0xB8, 0xB9, 0xBA, 0xBB,   # E
   0x8C, 0x8D, 0x8E, 0x8F, 0x80, 0x81, 0x82, 0x83, 0xB4, 0xB5, 0xB6, 0xB7, 0x88, 0x89, 0x8A, 0x8B);  # F
my $self = shift;  # get the object
my $l = shift;     # level to set to:  0-127
$l = int( $l );    # make sure it's an integer
if( $l < 0 ) { $l = 0; }
if( $l > 127 ) { $l = 127; }
if( $self->{DEBUG} > 0 ) { printf( "Set channel B level min=0x%02X\n", $l); }
$l ^= 0x55;        # adjust the requested level to match the send message spec
my $msg = "\x18\x14\xF3" . chr( $l + 128 ) . chr( $tbl[ $l ] );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}


########################################################################################################
#  set the pulse width of channel B to the specified value:  0-191
########################################################################################################
sub set_B_width {

my @tbl    = (                         #  sumcheck table                                                                            
#     0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
   0xCF, 0xCC, 0xC9, 0xCE, 0xC3, 0xC0, 0xCD, 0xC2, 0xF7, 0xF4, 0xF1, 0xF6, 0xCB, 0xC8, 0xF5, 0xCA,   # 0
   0xDF, 0xDC, 0xD9, 0xDE, 0xD3, 0xD0, 0xDD, 0xD2, 0xC7, 0xC4, 0xC1, 0xC6, 0xDB, 0xD8, 0xC5, 0xDA,   # 1
   0xEF, 0xEC, 0xE9, 0xEE, 0xE3, 0xE0, 0xED, 0xE2, 0x97, 0x94, 0x91, 0x96, 0xEB, 0xE8, 0x95, 0xEA,   # 2
   0xFF, 0xFC, 0xF9, 0xFE, 0xF3, 0xF0, 0xFD, 0xF2, 0xE7, 0xE4, 0xE1, 0xE6, 0xFB, 0xF8, 0xE5, 0xFA,   # 3
#    -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   # 4
#    -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   # 5
#    -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   # 6
#    -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   # 7
   0x4F, 0x4C, 0x49, 0x4E, 0x43, 0x40, 0x4D, 0x42, 0x77, 0x74, 0x71, 0x76, 0x4B, 0x48, 0x75, 0x4A,   # 8
   0x5F, 0x5C, 0x59, 0x5E, 0x53, 0x50, 0x5D, 0x52, 0x47, 0x44, 0x41, 0x46, 0x5B, 0x58, 0x45, 0x5A,   # 9
   0x6F, 0x6C, 0x69, 0x6E, 0x63, 0x60, 0x6D, 0x62, 0x17, 0x14, 0x11, 0x16, 0x6B, 0x68, 0x15, 0x6A,   # A
   0x7F, 0x7C, 0x79, 0x7E, 0x73, 0x70, 0x7D, 0x72, 0x67, 0x64, 0x61, 0x66, 0x7B, 0x78, 0x65, 0x7A,   # B
   0x8F, 0x8C, 0x89, 0x8E, 0x83, 0x80, 0x8D, 0x82, 0xB7, 0xB4, 0xB1, 0xB6, 0x8B, 0x88, 0xB5, 0x8A,   # C
   0x9F, 0x9C, 0x99, 0x9E, 0x93, 0x90, 0x9D, 0x92, 0x87, 0x84, 0x81, 0x86, 0x9B, 0x98, 0x85, 0x9A,   # D
   0xAF, 0xAC, 0xA9, 0xAE, 0xA3, 0xA0, 0xAD, 0xA2, 0x57, 0x54, 0x51, 0x56, 0xAB, 0xA8, 0x55, 0xAA,   # E
   0xBF, 0xBC, 0xB9, 0xBE, 0xB3, 0xB0, 0xBD, 0xB2, 0xA7, 0xA4, 0xA1, 0xA6, 0xBB, 0xB8, 0xA5, 0xBA);  # F
my $self = shift;       # get the object
my $l = shift;          # level to set to:  0-191
if( $l < 0 ) { $l = 0; }
if( $l > 191 ) { $l = 191; }
$l = 64 + int( $l );    # make sure it's an integer
$l ^= 0x55;
my $indx = $l;
if( $indx >= 0x80 ) { $indx -= 0x40; }       # skip over unsed values to reduce table size
if( $self->{DEBUG} > 0 ) { printf( "Set channel B width=0x%02X\n", $l); }
my $msg = "\x18\x14\xE2" . chr( $l ) . chr( $tbl[ $indx ] );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

########################################################################################################
#  set the pulse min width of channel B to the specified value:  0-191
########################################################################################################
sub set_B_min_width {

my @tbl    = (                         #  sumcheck table                                                                               
#     0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
   0xCE, 0xCF, 0xC8, 0xC9, 0xC2, 0xC3, 0xCC, 0xCD, 0xF6, 0xF7, 0xF0, 0xF1, 0xCA, 0xCB, 0xF4, 0xF5,   # 0
   0xDE, 0xDF, 0xD8, 0xD9, 0xD2, 0xD3, 0xDC, 0xDD, 0xC6, 0xC7, 0xC0, 0xC1, 0xDA, 0xDB, 0xC4, 0xC5,   # 1
   0xEE, 0xEF, 0xE8, 0xE9, 0xE2, 0xE3, 0xEC, 0xED, 0x96, 0x97, 0x90, 0x91, 0xEA, 0xEB, 0x94, 0x95,   # 2
   0xFE, 0xFF, 0xF8, 0xF9, 0xF2, 0xF3, 0xFC, 0xFD, 0xE6, 0xE7, 0xE0, 0xE1, 0xFA, 0xFB, 0xE4, 0xE5,   # 3
#    -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   # 4
#    -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   # 5
#    -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   # 6
#    -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   # 7
   0x4E, 0x4F, 0x48, 0x49, 0x42, 0x43, 0x4C, 0x4D, 0x76, 0x77, 0x70, 0x71, 0x4A, 0x4B, 0x74, 0x75,   # 8
   0x5E, 0x5F, 0x58, 0x59, 0x52, 0x53, 0x5C, 0x5D, 0x46, 0x47, 0x40, 0x41, 0x5A, 0x5B, 0x44, 0x45,   # 9
   0x6E, 0x6F, 0x68, 0x69, 0x62, 0x63, 0x6C, 0x6D, 0x16, 0x17, 0x10, 0x11, 0x6A, 0x6B, 0x14, 0x15,   # A
   0x7E, 0x7F, 0x78, 0x79, 0x72, 0x73, 0x7C, 0x7D, 0x66, 0x67, 0x60, 0x61, 0x7A, 0x7B, 0x64, 0x65,   # B
   0x8E, 0x8F, 0x88, 0x89, 0x82, 0x83, 0x8C, 0x8D, 0xB6, 0xB7, 0xB0, 0xB1, 0x8A, 0x8B, 0xB4, 0xB5,   # C
   0x9E, 0x9F, 0x98, 0x99, 0x92, 0x93, 0x9C, 0x9D, 0x86, 0x87, 0x80, 0x81, 0x9A, 0x9B, 0x84, 0x85,   # D
   0xAE, 0xAF, 0xA8, 0xA9, 0xA2, 0xA3, 0xAC, 0xAD, 0x56, 0x57, 0x50, 0x51, 0xAA, 0xAB, 0x54, 0x55,   # E
   0xBE, 0xBF, 0xB8, 0xB9, 0xB2, 0xB3, 0xBC, 0xBD, 0xA6, 0xA7, 0xA0, 0xA1, 0xBA, 0xBB, 0xA4, 0xA5);  # F
my $self = shift;       # get the object
my $l = shift;          # level to set to:  0-191
if( $l < 0 ) { $l = 0; }
if( $l > 191 ) { $l = 191; }
$l = 64 + int( $l );    # make sure it's an integer
$l ^= 0x55;
my $indx = $l;
if( $indx >= 0x80 ) { $indx -= 0x40; }       # skip over unsed values to reduce table size
if( $self->{DEBUG} > 0 ) { printf( "Set channel B min width=0x%02X\n", $l); }
my $msg = "\x18\x14\xED" . chr( $l ) . chr( $tbl[ $indx ] );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

########################################################################################################
#  set the pulse max width of channel B to the specified value:  0-191
########################################################################################################
sub set_B_max_width {

my @tbl    = (                         #  sumcheck table                                                                               
#     0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
   0xC9, 0xCE, 0xCB, 0xC8, 0xCD, 0xC2, 0xCF, 0xCC, 0xF1, 0xF6, 0xF3, 0xF0, 0xF5, 0xCA, 0xF7, 0xF4,   # 0
   0xD9, 0xDE, 0xDB, 0xD8, 0xDD, 0xD2, 0xDF, 0xDC, 0xC1, 0xC6, 0xC3, 0xC0, 0xC5, 0xDA, 0xC7, 0xC4,   # 1
   0xE9, 0xEE, 0xEB, 0xE8, 0xED, 0xE2, 0xEF, 0xEC, 0x91, 0x96, 0x93, 0x90, 0x95, 0xEA, 0x97, 0x94,   # 2
   0xF9, 0xFE, 0xFB, 0xF8, 0xFD, 0xF2, 0xFF, 0xFC, 0xE1, 0xE6, 0xE3, 0xE0, 0xE5, 0xFA, 0xE7, 0xE4,   # 3
#    -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   # 4
#    -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   # 5
#    -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   # 6
#    -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   # 7
   0x49, 0x4E, 0x4B, 0x48, 0x4D, 0x42, 0x4F, 0x4C, 0x71, 0x76, 0x73, 0x70, 0x75, 0x4A, 0x77, 0x74,   # 8
   0x59, 0x5E, 0x5B, 0x58, 0x5D, 0x52, 0x5F, 0x5C, 0x41, 0x46, 0x43, 0x40, 0x45, 0x5A, 0x47, 0x44,   # 9
   0x69, 0x6E, 0x6B, 0x68, 0x6D, 0x62, 0x6F, 0x6C, 0x11, 0x16, 0x13, 0x10, 0x15, 0x6A, 0x17, 0x14,   # A
   0x79, 0x7E, 0x7B, 0x78, 0x7D, 0x72, 0x7F, 0x7C, 0x61, 0x66, 0x63, 0x60, 0x65, 0x7A, 0x67, 0x64,   # B
   0x89, 0x8E, 0x8B, 0x88, 0x8D, 0x82, 0x8F, 0x8C, 0xB1, 0xB6, 0xB3, 0xB0, 0xB5, 0x8A, 0xB7, 0xB4,   # C
   0x99, 0x9E, 0x9B, 0x98, 0x9D, 0x92, 0x9F, 0x9C, 0x81, 0x86, 0x83, 0x80, 0x85, 0x9A, 0x87, 0x84,   # D
   0xA9, 0xAE, 0xAB, 0xA8, 0xAD, 0xA2, 0xAF, 0xAC, 0x51, 0x56, 0x53, 0x50, 0x55, 0xAA, 0x57, 0x54,   # E
   0xB9, 0xBE, 0xBB, 0xB8, 0xBD, 0xB2, 0xBF, 0xBC, 0xA1, 0xA6, 0xA3, 0xA0, 0xA5, 0xBA, 0xA7, 0xA4);  # F
my $self = shift;       # get the object
my $l = shift;          # level to set to:  0-191
if( $l < 0 ) { $l = 0; }
if( $l > 191 ) { $l = 191; }
$l = 64 + int( $l );    # make sure it's an integer
$l ^= 0x55;
my $indx = $l;
if( $indx >= 0x80 ) { $indx -= 0x40; }       # skip over unsed values to reduce table size
if( $self->{DEBUG} > 0 ) { printf( "Set channel B max width=0x%02X\n", $l); }
my $msg = "\x18\x14\xEC" . chr( $l ) . chr( $tbl[ $indx ] );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

########################################################################################################
#  set the pulse width rate of channel B to the specified value:  0-255
########################################################################################################
sub set_B_width_rate {

my @tbl    = (                         #  sumcheck table                                                                               
#     0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
   0xC8, 0xC9, 0xCA, 0xCB, 0xCC, 0xCD, 0xCE, 0xCF, 0xF0, 0xF1, 0xF2, 0xF3, 0xF4, 0xF5, 0xF6, 0xF7,   # 0
   0xD8, 0xD9, 0xDA, 0xDB, 0xDC, 0xDD, 0xDE, 0xDF, 0xC0, 0xC1, 0xC2, 0xC3, 0xC4, 0xC5, 0xC6, 0xC7,   # 1
   0xE8, 0xE9, 0xEA, 0xEB, 0xEC, 0xED, 0xEE, 0xEF, 0x90, 0x91, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97,   # 2
   0xF8, 0xF9, 0xFA, 0xFB, 0xFC, 0xFD, 0xFE, 0xFF, 0xE0, 0xE1, 0xE2, 0xE3, 0xE4, 0xE5, 0xE6, 0xE7,   # 3
   0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,   # 4
   0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,   # 5
   0x28, 0x29, 0x2A, 0x2B, 0x2C, 0x2D, 0x2E, 0x2F, 0xD0, 0xD1, 0xD2, 0xD3, 0xD4, 0xD5, 0xD6, 0xD7,   # 6
   0x38, 0x39, 0x3A, 0x3B, 0x3C, 0x3D, 0x3E, 0x3F, 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27,   # 7
   0x48, 0x49, 0x4A, 0x4B, 0x4C, 0x4D, 0x4E, 0x4F, 0x70, 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77,   # 8
   0x58, 0x59, 0x5A, 0x5B, 0x5C, 0x5D, 0x5E, 0x5F, 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47,   # 9
   0x68, 0x69, 0x6A, 0x6B, 0x6C, 0x6D, 0x6E, 0x6F, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17,   # A
   0x78, 0x79, 0x7A, 0x7B, 0x7C, 0x7D, 0x7E, 0x7F, 0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67,   # B
   0x88, 0x89, 0x8A, 0x8B, 0x8C, 0x8D, 0x8E, 0x8F, 0xB0, 0xB1, 0xB2, 0xB3, 0xB4, 0xB5, 0xB6, 0xB7,   # C
   0x98, 0x99, 0x9A, 0x9B, 0x9C, 0x9D, 0x9E, 0x9F, 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87,   # D
   0xA8, 0xA9, 0xAA, 0xAB, 0xAC, 0xAD, 0xAE, 0xAF, 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x56, 0x57,   # E
   0xB8, 0xB9, 0xBA, 0xBB, 0xBC, 0xBD, 0xBE, 0xBF, 0xA0, 0xA1, 0xA2, 0xA3, 0xA4, 0xA5, 0xA6, 0xA7);  # F
my $self = shift;       # get the object
my $l = shift;          # level to set to:  0-191
if( $l < 0 ) { $l = 0; }
if( $l > 255 ) { $l = 255; }
$l = int( $l );    # make sure it's an integer
$l ^= 0x55;
if( $self->{DEBUG} > 0 ) { printf( "Set channel B width rate=0x%02X\n", $l); }
my $msg = "\x18\x14\xEF" . chr( $l ) . chr( $tbl[ $l ] );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}


########################################################################################################
#  set the frequency of channel B to the specified value:  0-247
########################################################################################################
sub set_B_freq {

my @tbl    = (                         #  sumcheck table                                                                               
#     0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
   0xC4, 0xC5, 0xC6, 0xC7, 0xD8, 0xD9, 0xDA, 0xDB, 0xCC, 0xCD, 0xCE, 0xCF, 0xC0, 0xC1, 0xC2, 0xC3,   # 0
   0xD4, 0xD5, 0xD6, 0xD7, 0x28, 0x29, 0x2A, 0x2B, 0xDC, 0xDD, 0xDE, 0xDF, 0xD0, 0xD1, 0xD2, 0xD3,   # 1
   0xE4, 0xE5, 0xE6, 0xE7, 0xF8, 0xF9, 0xFA, 0xFB, 0xEC, 0xED, 0xEE, 0xEF, 0xE0, 0xE1, 0xE2, 0xE3,   # 2
   0xF4, 0xF5, 0xF6, 0xF7, 0xC8, 0xC9, 0xCA, 0xCB, 0xFC, 0xFD, 0xFE, 0xFF, 0xF0, 0xF1, 0xF2, 0xF3,   # 3
   0x04, 0x05, 0x06, 0x07, 0x18, 0x19, 0x1A, 0x1B, 0x0C, 0x0D, 0x0E, 0x0F, 0x00, 0x01, 0x02, 0x03,   # 4
   0x14, 0x15, 0x16, 0x17, 0x68, 0x69, 0x6A, 0x6B, 0x1C, 0x1D, 0x1E, 0x1F, 0x10, 0x11, 0x12, 0x13,   # 5
   0x24, 0x25, 0x26, 0x27, 0x38, 0x39, 0x3A, 0x3B, 0x2C, 0x2D, 0x2E, 0x2F, 0x20, 0x21, 0x22, 0x23,   # 6
   0x34, 0x35, 0x36, 0x37, 0x08, 0x09, 0x0A, 0x0B, 0x3C, 0x3D, 0x3E, 0x3F, 0x30, 0x31, 0x32, 0x33,   # 7
   0x44, 0x45, 0x46, 0x47, 0x58, 0x59, 0x5A, 0x5B, 0x4C, 0x4D, 0x4E, 0x4F, 0x40, 0x41, 0x42, 0x43,   # 8
   0x54, 0x55, 0x56, 0x57, 0xA8, 0xA9, 0xAA, 0xAB, 0x5C, 0x5D, 0x5E, 0x5F, 0x50, 0x51, 0x52, 0x53,   # 9
   0x64, 0x65, 0x66, 0x67, 0x78, 0x79, 0x7A, 0x7B, 0x6C, 0x6D, 0x6E, 0x6F, 0x60, 0x61, 0x62, 0x63,   # A
   0x74, 0x75, 0x76, 0x77, 0x48, 0x49, 0x4A, 0x4B, 0x7C, 0x7D, 0x7E, 0x7F, 0x70, 0x71, 0x72, 0x73,   # B
   0x84, 0x85, 0x86, 0x87, 0x98, 0x99, 0x9A, 0x9B, 0x8C, 0x8D, 0x8E, 0x8F, 0x80, 0x81, 0x82, 0x83,   # C
   0x94, 0x95, 0x96, 0x97, 0xE8, 0xE9, 0xEA, 0xEB, 0x9C, 0x9D, 0x9E, 0x9F, 0x90, 0x91, 0x92, 0x93,   # D
   0xA4, 0xA5, 0xA6, 0xA7, 0xB8, 0xB9, 0xBA, 0xBB, 0xAC, 0xAD, 0xAE, 0xAF, 0xA0, 0xA1, 0xA2, 0xA3,   # E
   0xB4, 0xB5, 0xB6, 0xB7, 0x88, 0x89, 0x8A, 0x8B, 0xBC, 0xBD, 0xBE, 0xBF, 0xB0, 0xB1, 0xB2, 0xB3);  # F
my $self = shift;       # get the object
my $l = shift;          # freq to set to:  0-247
if( $l < 0 ) { $l = 0; }
if( $l > 247 ) { $l = 247; }
$l = 255 - int( $l );    # make sure it's an integer
$l ^= 0x55;
my $indx = $l;
if( $self->{DEBUG} > 0 ) { printf( "Set channel B freq=0x%02X\n", $l); }
my $msg = "\x18\x14\xFB" . chr( $l ) . chr( $tbl[ $indx ] );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

########################################################################################################
#  set the min frequency of channel B to the specified value:  0-247
########################################################################################################
sub set_B_min_freq {

my @tbl    = (                         #  sumcheck table                                                                               
#     0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
   0xC6, 0xC7, 0xC0, 0xC1, 0xDA, 0xDB, 0xC4, 0xC5, 0xCE, 0xCF, 0xC8, 0xC9, 0xC2, 0xC3, 0xCC, 0xCD,   # 0
   0xD6, 0xD7, 0xD0, 0xD1, 0x2A, 0x2B, 0xD4, 0xD5, 0xDE, 0xDF, 0xD8, 0xD9, 0xD2, 0xD3, 0xDC, 0xDD,   # 1
   0xE6, 0xE7, 0xE0, 0xE1, 0xFA, 0xFB, 0xE4, 0xE5, 0xEE, 0xEF, 0xE8, 0xE9, 0xE2, 0xE3, 0xEC, 0xED,   # 2
   0xF6, 0xF7, 0xF0, 0xF1, 0xCA, 0xCB, 0xF4, 0xF5, 0xFE, 0xFF, 0xF8, 0xF9, 0xF2, 0xF3, 0xFC, 0xFD,   # 3
   0x06, 0x07, 0x00, 0x01, 0x1A, 0x1B, 0x04, 0x05, 0x0E, 0x0F, 0x08, 0x09, 0x02, 0x03, 0x0C, 0x0D,   # 4
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1, 0x1E, 0x1F, 0x18, 0x19, 0x12, 0x13, 0x1C, 0x1D,   # 5
   0x26, 0x27, 0x20, 0x21, 0x3A, 0x3B, 0x24, 0x25, 0x2E, 0x2F, 0x28, 0x29, 0x22, 0x23, 0x2C, 0x2D,   # 6
   0x36, 0x37, 0x30, 0x31, 0x0A, 0x0B, 0x34, 0x35, 0x3E, 0x3F, 0x38, 0x39, 0x32, 0x33, 0x3C, 0x3D,   # 7
   0x46, 0x47, 0x40, 0x41, 0x5A, 0x5B, 0x44, 0x45, 0x4E, 0x4F, 0x48, 0x49, 0x42, 0x43, 0x4C, 0x4D,   # 8
   0x56, 0x57, 0x50, 0x51, 0xAA, 0xAB, 0x54, 0x55, 0x5E, 0x5F, 0x58, 0x59, 0x52, 0x53, 0x5C, 0x5D,   # 9
   0x66, 0x67, 0x60, 0x61, 0x7A, 0x7B, 0x64, 0x65, 0x6E, 0x6F, 0x68, 0x69, 0x62, 0x63, 0x6C, 0x6D,   # A
   0x76, 0x77, 0x70, 0x71, 0x4A, 0x4B, 0x74, 0x75, 0x7E, 0x7F, 0x78, 0x79, 0x72, 0x73, 0x7C, 0x7D,   # B
   0x86, 0x87, 0x80, 0x81, 0x9A, 0x9B, 0x84, 0x85, 0x8E, 0x8F, 0x88, 0x89, 0x82, 0x83, 0x8C, 0x8D,   # C
   0x96, 0x97, 0x90, 0x91, 0xEA, 0xEB, 0x94, 0x95, 0x9E, 0x9F, 0x98, 0x99, 0x92, 0x93, 0x9C, 0x9D,   # D
   0xA6, 0xA7, 0xA0, 0xA1, 0xBA, 0xBB, 0xA4, 0xA5, 0xAE, 0xAF, 0xA8, 0xA9, 0xA2, 0xA3, 0xAC, 0xAD,   # E
   0xB6, 0xB7, 0xB0, 0xB1, 0x8A, 0x8B, 0xB4, 0xB5, 0xBE, 0xBF, 0xB8, 0xB9, 0xB2, 0xB3, 0xBC, 0xBD);  # F
my $self = shift;       # get the object
my $l = shift;          # min freq to set to:  0-247
if( $l < 0 ) { $l = 0; }
if( $l > 247 ) { $l = 247; }
$l = 255 - int( $l );    # make sure it's an integer
$l ^= 0x55;
my $indx = $l;
if( $self->{DEBUG} > 0 ) { printf( "Set channel B min freq=0x%02X\n", $l); }
my $msg = "\x18\x14\xE5" . chr( $l ) . chr( $tbl[ $indx ] );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

########################################################################################################
#  set the max frequency of channel B to the specified value:  0-247
########################################################################################################
sub set_B_max_freq {

my @tbl    = (                         #  sumcheck table                                                                               
#     0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
   0xC7, 0xC4, 0xC1, 0xC6, 0xDB, 0xD8, 0xC5, 0xDA, 0xCF, 0xCC, 0xC9, 0xCE, 0xC3, 0xC0, 0xCD, 0xC2,   # 0
   0xD7, 0xD4, 0xD1, 0xD6, 0x2B, 0x28, 0xD5, 0x2A, 0xDF, 0xDC, 0xD9, 0xDE, 0xD3, 0xD0, 0xDD, 0xD2,   # 1
   0xE7, 0xE4, 0xE1, 0xE6, 0xFB, 0xF8, 0xE5, 0xFA, 0xEF, 0xEC, 0xE9, 0xEE, 0xE3, 0xE0, 0xED, 0xE2,   # 2
   0xF7, 0xF4, 0xF1, 0xF6, 0xCB, 0xC8, 0xF5, 0xCA, 0xFF, 0xFC, 0xF9, 0xFE, 0xF3, 0xF0, 0xFD, 0xF2,   # 3
   0x07, 0x04, 0x01, 0x06, 0x1B, 0x18, 0x05, 0x1A, 0x0F, 0x0C, 0x09, 0x0E, 0x03, 0x00, 0x0D, 0x02,   # 4
     -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1, 0x1F, 0x1C, 0x19, 0x1E, 0x13, 0x10, 0x1D, 0x12,   # 5
   0x27, 0x24, 0x21, 0x26, 0x3B, 0x38, 0x25, 0x3A, 0x2F, 0x2C, 0x29, 0x2E, 0x23, 0x20, 0x2D, 0x22,   # 6
   0x37, 0x34, 0x31, 0x36, 0x0B, 0x08, 0x35, 0x0A, 0x3F, 0x3C, 0x39, 0x3E, 0x33, 0x30, 0x3D, 0x32,   # 7
   0x47, 0x44, 0x41, 0x46, 0x5B, 0x58, 0x45, 0x5A, 0x4F, 0x4C, 0x49, 0x4E, 0x43, 0x40, 0x4D, 0x42,   # 8
   0x57, 0x54, 0x51, 0x56, 0xAB, 0xA8, 0x55, 0xAA, 0x5F, 0x5C, 0x59, 0x5E, 0x53, 0x50, 0x5D, 0x52,   # 9
   0x67, 0x64, 0x61, 0x66, 0x7B, 0x78, 0x65, 0x7A, 0x6F, 0x6C, 0x69, 0x6E, 0x63, 0x60, 0x6D, 0x62,   # A
   0x77, 0x74, 0x71, 0x76, 0x4B, 0x48, 0x75, 0x4A, 0x7F, 0x7C, 0x79, 0x7E, 0x73, 0x70, 0x7D, 0x72,   # B
   0x87, 0x84, 0x81, 0x86, 0x9B, 0x98, 0x85, 0x9A, 0x8F, 0x8C, 0x89, 0x8E, 0x83, 0x80, 0x8D, 0x82,   # C
   0x97, 0x94, 0x91, 0x96, 0xEB, 0xE8, 0x95, 0xEA, 0x9F, 0x9C, 0x99, 0x9E, 0x93, 0x90, 0x9D, 0x92,   # D
   0xA7, 0xA4, 0xA1, 0xA6, 0xBB, 0xB8, 0xA5, 0xBA, 0xAF, 0xAC, 0xA9, 0xAE, 0xA3, 0xA0, 0xAD, 0xA2,   # E
   0xB7, 0xB4, 0xB1, 0xB6, 0x8B, 0x88, 0xB5, 0x8A, 0xBF, 0xBC, 0xB9, 0xBE, 0xB3, 0xB0, 0xBD, 0xB2);  # F
my $self = shift;       # get the object
my $l = shift;          # max freq to set to:  0-247
if( $l < 0 ) { $l = 0; }
if( $l > 247 ) { $l = 247; }
$l = 255 - int( $l );    # make sure it's an integer
$l ^= 0x55;
my $indx = $l;
if( $self->{DEBUG} > 0 ) { printf( "Set channel B max freq=0x%02X\n", $l); }
my $msg = "\x18\x14\xFA" . chr( $l ) . chr( $tbl[ $indx ] );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}


########################################################################################################
#  set the frequency rate of channel B to the specified value:  0-255
########################################################################################################
sub set_B_freq_rate {

my @tbl    = (                         #  sumcheck table                                                                               
#     0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
   0xC1, 0xC6, 0xC3, 0xC0, 0xC5, 0xDA, 0xC7, 0xC4, 0xC9, 0xCE, 0xCB, 0xC8, 0xCD, 0xC2, 0xCF, 0xCC,   # 0
   0xD1, 0xD6, 0xD3, 0xD0, 0xD5, 0x2A, 0xD7, 0xD4, 0xD9, 0xDE, 0xDB, 0xD8, 0xDD, 0xD2, 0xDF, 0xDC,   # 1
   0xE1, 0xE6, 0xE3, 0xE0, 0xE5, 0xFA, 0xE7, 0xE4, 0xE9, 0xEE, 0xEB, 0xE8, 0xED, 0xE2, 0xEF, 0xEC,   # 2
   0xF1, 0xF6, 0xF3, 0xF0, 0xF5, 0xCA, 0xF7, 0xF4, 0xF9, 0xFE, 0xFB, 0xF8, 0xFD, 0xF2, 0xFF, 0xFC,   # 3
   0x01, 0x06, 0x03, 0x00, 0x05, 0x1A, 0x07, 0x04, 0x09, 0x0E, 0x0B, 0x08, 0x0D, 0x02, 0x0F, 0x0C,   # 4
   0x11, 0x16, 0x13, 0x10, 0x15, 0x6A, 0x17, 0x14, 0x19, 0x1E, 0x1B, 0x18, 0x1D, 0x12, 0x1F, 0x1C,   # 5
   0x21, 0x26, 0x23, 0x20, 0x25, 0x3A, 0x27, 0x24, 0x29, 0x2E, 0x2B, 0x28, 0x2D, 0x22, 0x2F, 0x2C,   # 6
   0x31, 0x36, 0x33, 0x30, 0x35, 0x0A, 0x37, 0x34, 0x39, 0x3E, 0x3B, 0x38, 0x3D, 0x32, 0x3F, 0x3C,   # 7
   0x41, 0x46, 0x43, 0x40, 0x45, 0x5A, 0x47, 0x44, 0x49, 0x4E, 0x4B, 0x48, 0x4D, 0x42, 0x4F, 0x4C,   # 8
   0x51, 0x56, 0x53, 0x50, 0x55, 0xAA, 0x57, 0x54, 0x59, 0x5E, 0x5B, 0x58, 0x5D, 0x52, 0x5F, 0x5C,   # 9
   0x61, 0x66, 0x63, 0x60, 0x65, 0x7A, 0x67, 0x64, 0x69, 0x6E, 0x6B, 0x68, 0x6D, 0x62, 0x6F, 0x6C,   # A
   0x71, 0x76, 0x73, 0x70, 0x75, 0x4A, 0x77, 0x74, 0x79, 0x7E, 0x7B, 0x78, 0x7D, 0x72, 0x7F, 0x7C,   # B
   0x81, 0x86, 0x83, 0x80, 0x85, 0x9A, 0x87, 0x84, 0x89, 0x8E, 0x8B, 0x88, 0x8D, 0x82, 0x8F, 0x8C,   # C
   0x91, 0x96, 0x93, 0x90, 0x95, 0xEA, 0x97, 0x94, 0x99, 0x9E, 0x9B, 0x98, 0x9D, 0x92, 0x9F, 0x9C,   # D
   0xA1, 0xA6, 0xA3, 0xA0, 0xA5, 0xBA, 0xA7, 0xA4, 0xA9, 0xAE, 0xAB, 0xA8, 0xAD, 0xA2, 0xAF, 0xAC,   # E
   0xB1, 0xB6, 0xB3, 0xB0, 0xB5, 0x8A, 0xB7, 0xB4, 0xB9, 0xBE, 0xBB, 0xB8, 0xBD, 0xB2, 0xBF, 0xBC);  # F
my $self = shift;       # get the object
my $l = shift;          # max freq to set to:  0-255
if( $l < 0 ) { $l = 0; }
if( $l > 255 ) { $l = 255; }
$l = int( $l );    # make sure it's an integer
$l ^= 0x55;
my $indx = $l;
if( $self->{DEBUG} > 0 ) { printf( "Set channel B freq rate=0x%02X\n", $l); }
my $msg = "\x18\x14\xe4" . chr( $l ) . chr( $tbl[ $indx ] );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

########################################################################################################
#  set the level rate of channel B to the specified value:  0-255
########################################################################################################
sub set_B_level_rate {

my @tbl    = (                         #  sumcheck table                                                                               
#     0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
   0xDE, 0xDF, 0xD8, 0xD9, 0xD2, 0xD3, 0xDC, 0xDD, 0xC6, 0xC7, 0xC0, 0xC1, 0xDA, 0xDB, 0xC4, 0xC5,   # 0
   0x2E, 0x2F, 0x28, 0x29, 0x22, 0x23, 0x2C, 0x2D, 0xD6, 0xD7, 0xD0, 0xD1, 0x2A, 0x2B, 0xD4, 0xD5,   # 1
   0xFE, 0xFF, 0xF8, 0xF9, 0xF2, 0xF3, 0xFC, 0xFD, 0xE6, 0xE7, 0xE0, 0xE1, 0xFA, 0xFB, 0xE4, 0xE5,   # 2
   0xCE, 0xCF, 0xC8, 0xC9, 0xC2, 0xC3, 0xCC, 0xCD, 0xF6, 0xF7, 0xF0, 0xF1, 0xCA, 0xCB, 0xF4, 0xF5,   # 3
   0x1E, 0x1F, 0x18, 0x19, 0x12, 0x13, 0x1C, 0x1D, 0x06, 0x07, 0x00, 0x01, 0x1A, 0x1B, 0x04, 0x05,   # 4
   0x6E, 0x6F, 0x68, 0x69, 0x62, 0x63, 0x6C, 0x6D, 0x16, 0x17, 0x10, 0x11, 0x6A, 0x6B, 0x14, 0x15,   # 5
   0x3E, 0x3F, 0x38, 0x39, 0x32, 0x33, 0x3C, 0x3D, 0x26, 0x27, 0x20, 0x21, 0x3A, 0x3B, 0x24, 0x25,   # 6
   0x0E, 0x0F, 0x08, 0x09, 0x02, 0x03, 0x0C, 0x0D, 0x36, 0x37, 0x30, 0x31, 0x0A, 0x0B, 0x34, 0x35,   # 7
   0x5E, 0x5F, 0x58, 0x59, 0x52, 0x53, 0x5C, 0x5D, 0x46, 0x47, 0x40, 0x41, 0x5A, 0x5B, 0x44, 0x45,   # 8
   0xAE, 0xAF, 0xA8, 0xA9, 0xA2, 0xA3, 0xAC, 0xAD, 0x56, 0x57, 0x50, 0x51, 0xAA, 0xAB, 0x54, 0x55,   # 9
   0x7E, 0x7F, 0x78, 0x79, 0x72, 0x73, 0x7C, 0x7D, 0x66, 0x67, 0x60, 0x61, 0x7A, 0x7B, 0x64, 0x65,   # A
   0x4E, 0x4F, 0x48, 0x49, 0x42, 0x43, 0x4C, 0x4D, 0x76, 0x77, 0x70, 0x71, 0x4A, 0x4B, 0x74, 0x75,   # B
   0x9E, 0x9F, 0x98, 0x99, 0x92, 0x93, 0x9C, 0x9D, 0x86, 0x87, 0x80, 0x81, 0x9A, 0x9B, 0x84, 0x85,   # C
   0xEE, 0xEF, 0xE8, 0xE9, 0xE2, 0xE3, 0xEC, 0xED, 0x96, 0x97, 0x90, 0x91, 0xEA, 0xEB, 0x94, 0x95,   # D
   0xBE, 0xBF, 0xB8, 0xB9, 0xB2, 0xB3, 0xBC, 0xBD, 0xA6, 0xA7, 0xA0, 0xA1, 0xBA, 0xBB, 0xA4, 0xA5,   # E
   0x8E, 0x8F, 0x88, 0x89, 0x82, 0x83, 0x8C, 0x8D, 0xB6, 0xB7, 0xB0, 0xB1, 0x8A, 0x8B, 0xB4, 0xB5);  # F
my $self = shift;       # get the object
my $l = shift;          # level rate to set to:  0-255
if( $l < 0 ) { $l = 0; }
if( $l > 255 ) { $l = 255; }
$l = int( $l );    # make sure it's an integer
$l ^= 0x55;
my $indx = $l;
if( $self->{DEBUG} > 0 ) { printf( "Set channel B level rate=0x%02X\n", $l); }
my $msg = "\x18\x14\xFD" . chr( $l ) . chr( $tbl[ $indx ] );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}


########################################################################################################
#  set the TIME ON of channel B to the specified value:  0-255
########################################################################################################
sub set_B_time_on {

my @tbl    = (                         #  sumcheck table                                                                               
#     0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
   0x2E, 0x2F, 0x28, 0x29, 0x22, 0x23, 0x2C, 0x2D, 0xD6, 0xD7, 0xD0, 0xD1, 0x2A, 0x2B, 0xD4, 0xD5,   # 0
   0x3E, 0x3F, 0x38, 0x39, 0x32, 0x33, 0x3C, 0x3D, 0x26, 0x27, 0x20, 0x21, 0x3A, 0x3B, 0x24, 0x25,   # 1
   0xCE, 0xCF, 0xC8, 0xC9, 0xC2, 0xC3, 0xCC, 0xCD, 0xF6, 0xF7, 0xF0, 0xF1, 0xCA, 0xCB, 0xF4, 0xF5,   # 2
   0xDE, 0xDF, 0xD8, 0xD9, 0xD2, 0xD3, 0xDC, 0xDD, 0xC6, 0xC7, 0xC0, 0xC1, 0xDA, 0xDB, 0xC4, 0xC5,   # 3
   0x6E, 0x6F, 0x68, 0x69, 0x62, 0x63, 0x6C, 0x6D, 0x16, 0x17, 0x10, 0x11, 0x6A, 0x6B, 0x14, 0x15,   # 4
   0x7E, 0x7F, 0x78, 0x79, 0x72, 0x73, 0x7C, 0x7D, 0x66, 0x67, 0x60, 0x61, 0x7A, 0x7B, 0x64, 0x65,   # 5
   0x0E, 0x0F, 0x08, 0x09, 0x02, 0x03, 0x0C, 0x0D, 0x36, 0x37, 0x30, 0x31, 0x0A, 0x0B, 0x34, 0x35,   # 6
   0x1E, 0x1F, 0x18, 0x19, 0x12, 0x13, 0x1C, 0x1D, 0x06, 0x07, 0x00, 0x01, 0x1A, 0x1B, 0x04, 0x05,   # 7
   0xAE, 0xAF, 0xA8, 0xA9, 0xA2, 0xA3, 0xAC, 0xAD, 0x56, 0x57, 0x50, 0x51, 0xAA, 0xAB, 0x54, 0x55,   # 8
   0xBE, 0xBF, 0xB8, 0xB9, 0xB2, 0xB3, 0xBC, 0xBD, 0xA6, 0xA7, 0xA0, 0xA1, 0xBA, 0xBB, 0xA4, 0xA5,   # 9
   0x4E, 0x4F, 0x48, 0x49, 0x42, 0x43, 0x4C, 0x4D, 0x76, 0x77, 0x70, 0x71, 0x4A, 0x4B, 0x74, 0x75,   # A
   0x5E, 0x5F, 0x58, 0x59, 0x52, 0x53, 0x5C, 0x5D, 0x46, 0x47, 0x40, 0x41, 0x5A, 0x5B, 0x44, 0x45,   # B
   0xEE, 0xEF, 0xE8, 0xE9, 0xE2, 0xE3, 0xEC, 0xED, 0x96, 0x97, 0x90, 0x91, 0xEA, 0xEB, 0x94, 0x95,   # C
   0xFE, 0xFF, 0xF8, 0xF9, 0xF2, 0xF3, 0xFC, 0xFD, 0xE6, 0xE7, 0xE0, 0xE1, 0xFA, 0xFB, 0xE4, 0xE5,   # D
   0x8E, 0x8F, 0x88, 0x89, 0x82, 0x83, 0x8C, 0x8D, 0xB6, 0xB7, 0xB0, 0xB1, 0x8A, 0x8B, 0xB4, 0xB5,   # E
   0x9E, 0x9F, 0x98, 0x99, 0x92, 0x93, 0x9C, 0x9D, 0x86, 0x87, 0x80, 0x81, 0x9A, 0x9B, 0x84, 0x85);  # F
my $self = shift;       # get the object
my $l = shift;          # TIME ON:  0-255
if( $l < 0 ) { $l = 0; }
if( $l > 255 ) { $l = 255; }
$l = int( $l );    # make sure it's an integer
$l ^= 0x55;
my $indx = $l;
if( $self->{DEBUG} > 0 ) { printf( "Set channel B TIME ON=0x%02X\n", $l); }
my $msg = "\x18\x14\xCD" . chr( $l ) . chr( $tbl[ $indx ] );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}

########################################################################################################
#  set the TIME OFF of channel B to the specified value:  0-255
########################################################################################################
sub set_B_time_off {

my @tbl    = (                         #  sumcheck table                                                                               
#     0     1     2     3     4     5     6     7     8     9     A     B     C     D     E     F
   0x29, 0x2E, 0x2B, 0x28, 0x2D, 0x22, 0x2F, 0x2C, 0xD1, 0xD6, 0xD3, 0xD0, 0xD5, 0x2A, 0xD7, 0xD4,   # 0
   0x39, 0x3E, 0x3B, 0x38, 0x3D, 0x32, 0x3F, 0x3C, 0x21, 0x26, 0x23, 0x20, 0x25, 0x3A, 0x27, 0x24,   # 1
   0xC9, 0xCE, 0xCB, 0xC8, 0xCD, 0xC2, 0xCF, 0xCC, 0xF1, 0xF6, 0xF3, 0xF0, 0xF5, 0xCA, 0xF7, 0xF4,   # 2
   0xD9, 0xDE, 0xDB, 0xD8, 0xDD, 0xD2, 0xDF, 0xDC, 0xC1, 0xC6, 0xC3, 0xC0, 0xC5, 0xDA, 0xC7, 0xC4,   # 3
   0x69, 0x6E, 0x6B, 0x68, 0x6D, 0x62, 0x6F, 0x6C, 0x11, 0x16, 0x13, 0x10, 0x15, 0x6A, 0x17, 0x14,   # 4
   0x79, 0x7E, 0x7B, 0x78, 0x7D, 0x72, 0x7F, 0x7C, 0x61, 0x66, 0x63, 0x60, 0x65, 0x7A, 0x67, 0x64,   # 5
   0x09, 0x0E, 0x0B, 0x08, 0x0D, 0x02, 0x0F, 0x0C, 0x31, 0x36, 0x33, 0x30, 0x35, 0x0A, 0x37, 0x34,   # 6
   0x19, 0x1E, 0x1B, 0x18, 0x1D, 0x12, 0x1F, 0x1C, 0x01, 0x06, 0x03, 0x00, 0x05, 0x1A, 0x07, 0x04,   # 7
   0xA9, 0xAE, 0xAB, 0xA8, 0xAD, 0xA2, 0xAF, 0xAC, 0x51, 0x56, 0x53, 0x50, 0x55, 0xAA, 0x57, 0x54,   # 8
   0xB9, 0xBE, 0xBB, 0xB8, 0xBD, 0xB2, 0xBF, 0xBC, 0xA1, 0xA6, 0xA3, 0xA0, 0xA5, 0xBA, 0xA7, 0xA4,   # 9
   0x49, 0x4E, 0x4B, 0x48, 0x4D, 0x42, 0x4F, 0x4C, 0x71, 0x76, 0x73, 0x70, 0x75, 0x4A, 0x77, 0x74,   # A
   0x59, 0x5E, 0x5B, 0x58, 0x5D, 0x52, 0x5F, 0x5C, 0x41, 0x46, 0x43, 0x40, 0x45, 0x5A, 0x47, 0x44,   # B
   0xE9, 0xEE, 0xEB, 0xE8, 0xED, 0xE2, 0xEF, 0xEC, 0x91, 0x96, 0x93, 0x90, 0x95, 0xEA, 0x97, 0x94,   # C
   0xF9, 0xFE, 0xFB, 0xF8, 0xFD, 0xF2, 0xFF, 0xFC, 0xE1, 0xE6, 0xE3, 0xE0, 0xE5, 0xFA, 0xE7, 0xE4,   # D
   0x89, 0x8E, 0x8B, 0x88, 0x8D, 0x82, 0x8F, 0x8C, 0xB1, 0xB6, 0xB3, 0xB0, 0xB5, 0x8A, 0xB7, 0xB4,   # E
   0x99, 0x9E, 0x9B, 0x98, 0x9D, 0x92, 0x9F, 0x9C, 0x81, 0x86, 0x83, 0x80, 0x85, 0x9A, 0x87, 0x84);  # F
my $self = shift;       # get the object
my $l = shift;          # TIME OFF:  0-255
if( $l < 0 ) { $l = 0; }
if( $l > 255 ) { $l = 255; }
$l = int( $l );    # make sure it's an integer
$l ^= 0x55;
my $indx = $l;
if( $self->{DEBUG} > 0 ) { printf( "Set channel B TIME OFF=0x%02X\n", $l); }
my $msg = "\x18\x14\xCC" . chr( $l ) . chr( $tbl[ $indx ] );   # concatenate the level and sumcheck chars

my $reply = &Comm( $self->{COMM}, $msg, $self->{MOD}, $self->{DEBUG} );
if( $reply eq "\x06" ) { return 1; }     # success
return 0;                                # failure
}


########################################################################################################
#  sed a message out the serial port, and get a reply
########################################################################################################
sub Comm() {
   my $comm = shift;            # COMM variable
   my $msg = shift;             # the message to send
   my $mod = shift;             # the midification char, use '0' if none
   my $opt = shift;             # set to '1' if messages wanted
   my $i;
   my $cnt;
   my $reply;

   if( $opt > 0 )  {  printf( "Send(%d): ", length($msg) ); }
   for( $i=0; $i<length($msg); $i++ ) {
        my $c = ord(substr( $msg, $i, 1 ));          # get decimal value of new message char
        if( $opt > 0 )  {  printf(" 0x%02X", $c ); }
        $c ^= $mod;                                  # convert with MOD before transmission
        substr( $msg, $i, 1 ) = chr( $c );           # put converted value back into the message
        }

   $comm->write($msg);                               # send the converted message out the serial port
  ($cnt, $reply) = $comm->read(100);                 # get the reply
   if( $opt > 0 )  {  
       printf( "     Recv(%d): ", $cnt ); 
       for( $i=0; $i<$cnt; $i++ ) {
           printf(" 0x%02X", ord( substr($reply, $i, 1 ) ) ); 
           }
       print "\n"; 
       }
   return $reply;
   }
1;
