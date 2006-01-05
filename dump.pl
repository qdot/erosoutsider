#!/usr/bin/perl -w

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


#####################################################################
#          script to dump memory from the ESTIM device              #
#####################################################################

use strict;
use IO::estim;

$| = 1;	#unbuffered output

my $port = 1;       # serial port index

my $et = IO::estim->new( $port, "mod", 0 );
if( $et == 0 ) { die "ESTIM was not able to be openned\n"; }

#  407B      routine number

#  4098      time on
#  4099      time off
#  409A      time options

#  40A5      level
#  40A6      level min
#  40A7      level max
#  40A8      level rate
#  40A9
#  40AA
#  40AB
#  40AC      level options

#  40AE      freq
#  40AF      freq max
#  40B0      freq min
#  40B1      freq rate
#  40B2
#  40B3
#  40b4
#  40B5      freq options

#  40B7      width
#  40B8      width min
#  40B9      width max
#  40BA      width rate
#  40BB
#  40BC
#  40BD
#  40BE      width options


# &dump( 0x0000, 16 );     # memory repeats in 256 blocks from 0x0000 - 0x3fff
&dump( 0x4070,  2 );
# &dump( 0x4190,  4 );


sub dump {                    
   my $adr    = shift;                  # starting address of data to dump
   my $nlines = shift;

   for( my $lines=0; $lines<$nlines; $lines++ )  {   
       my @bytes;                    # array to store one line of data
       my $index = 0;                # index to bytes[]
       printf("%04X ", $adr);        # start first / or another line
       do {
           printf(" ");
           do  {                      # inner loop, 4 bytes
               my $val = $et->get_byte($adr++);
               $bytes[ $index++ ] = $val;            # save data for literal loop
               printf("%02x", $val );                # output one byte
               } while ( $index & 3);                # inner loop (one group) until all bytes in group displayed
           } while ($index < 16);                    # outer loop (one line) until end column reached, or all bytes total displayed
      
       printf("  *");                              # mark start of literal area
       $index = 0; 
       do {
           my $val = $bytes[ $index++ ];
           if( ($val > 127 ) || ( $val < 33 ) ) { printf("."); }   # use period if non-printable
           else                                 { printf( "%c", $val); }
           } while ( $index < 16 );
       printf("*\n");
       } 
   printf("\n");
   } 

