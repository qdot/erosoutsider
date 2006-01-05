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
#          script to test the ESTIM package, version 4.00           #
#####################################################################

use strict;
use IO::estim;

$| = 1;	#unbuffered output

my $port = 1;       # serial port index

my $et = IO::estim->new( $port, "mod", 0 );
if( $et == 0 ) { die "ESTIM was not able to be openned\n"; }


####################### width options
foreach my $val (5, 4, 1 ) {
       foreach my $rate (4, 2, 0 ) {
           printf( "Set A width options val=%d rate=%d", $val, $rate);
           my $cc = $et->set_A_width_options( $val, $rate );
           if( $cc < 1 ) { die "   --Completion code was $cc"; }
           my ($val2, $rate2) = $et->get_A_width_options();
           if( ( $val == $val2 ) && ( $rate == $rate2 )  ) { printf("     result was: val=%d  rate=%d\n", $val2, $rate2); }
           else { printf("     result was: val=%d  rate=%d -- error\n", $val2, $rate); }
           } 
       }
print "\n";
sleep(1);

foreach my $val (5, 4, 1 ) {
       foreach my $rate (4, 2, 0 ) {
           printf( "Set B width options val=%d rate=%d", $val, $rate);
           my $cc = $et->set_B_width_options( $val, $rate );
           if( $cc < 1 ) { die "   --Completion code was $cc"; }
           my ($val2, $rate2) = $et->get_B_width_options();
           if( ( $val == $val2 ) && ( $rate == $rate2 )  ) { printf("     result was: val=%d  rate=%d\n", $val2, $rate2); }
           else { printf("     result was: val=%d  rate=%d -- error\n", $val2, $rate); }
           } 
       }
print "\n";
sleep(1);


######################## levels
for( my $i=0; $i<128; $i++ ) {
       printf( "Set channel A level=0x%02X", $i);
       my $cc = $et->set_A_level( $i );
       if( $cc < 1 ) { die "   --Completion code was $cc"; }

       my $j = $et->get_A_level();
       if( $j == $i  ) { printf("     result was: 0x%02X\n", $j); }
       else { printf("     result was: 0x%02X -- error\n", $j); }
       }
print "\n";
sleep(1);

for( my $i=0; $i<128; $i++ ) {
       printf( "Set channel B level=0x%02X", $i);
       my $cc = $et->set_B_level( $i );
       if( $cc < 1 ) { die "   --Completion code was $cc"; }

       my $j = $et->get_B_level();
       if( $j == $i  ) { printf("     result was: 0x%02X\n", $j); }
       else { printf("     result was: 0x%02X -- error\n", $j); }
       }
print "\n";
sleep(1);



######################## level minimums
for( my $i=0; $i<128; $i++ ) {
       printf( "Set channel A min level=0x%02X", $i);
       my $cc = $et->set_A_min_level( $i );
       if( $cc < 1 ) { die "   --Completion code was $cc"; }

       my $j = $et->get_A_min_level();
       if( $j == $i  ) { printf("     result was: 0x%02X\n", $j); }
       else { printf("     result was: 0x%02X -- error\n", $j); }
       }
print "\n";
sleep(1);

for( my $i=0; $i<128; $i++ ) {
       printf( "Set channel B min level=0x%02X", $i);
       my $cc = $et->set_B_min_level( $i );
       if( $cc < 1 ) { die "   --Completion code was $cc"; }

       my $j = $et->get_B_min_level();
       if( $j == $i  ) { printf("     result was: 0x%02X\n", $j); }
       else { printf("     result was: 0x%02X -- error\n", $j); }
       }
print "\n";
sleep(1);



######################## level maximums
for( my $i=0; $i<128; $i++ ) {
       printf( "Set channel A max level=0x%02X", $i);
       my $cc = $et->set_A_max_level( $i );
       if( $cc < 1 ) { die "   --Completion code was $cc"; }

       my $j = $et->get_A_max_level();
       if( $j == $i  ) { printf("     result was: 0x%02X\n", $j); }
       else { printf("     result was: 0x%02X -- error\n", $j); }
       }
print "\n";
sleep(1);

for( my $i=0; $i<128; $i++ ) {
       printf( "Set channel B max level=0x%02X", $i);
       my $cc = $et->set_B_max_level( $i );
       if( $cc < 1 ) { die "   --Completion code was $cc"; }

       my $j = $et->get_B_max_level();
       if( $j == $i  ) { printf("     result was: 0x%02X\n", $j); }
       else { printf("     result was: 0x%02X -- error\n", $j); }
       }
print "\n";
sleep(1);


######################## level options
foreach my $min (5, 1 ) {
       foreach my $rate (4, 2, 0 ) {
           printf( "Set A level options min=%d rate=%d", $min, $rate);
           my $cc = $et->set_A_level_options( $min, $rate );
           if( $cc < 1 ) { die "   --Completion code was $cc"; }
           my ($min2, $rate2) = $et->get_A_level_options();
           if( ( $min == $min2 ) && ( $rate == $rate2 )  ) { printf("     result was: min=%d  rate=%d\n", $min2, $rate2); }
           else { printf("     result was: min=%d  rate=%d -- error\n", $min2, $rate2); }
           } 
       }
print "\n";
sleep(1);

foreach my $min (5, 1 ) {
       foreach my $rate (4, 2, 0 ) {
           printf( "Set B level options min=%d rate=%d", $min, $rate);
           my $cc = $et->set_B_level_options( $min, $rate );
           if( $cc < 1 ) { die "   --Completion code was $cc"; }
           my ($min2, $rate2) = $et->get_B_level_options();
           if( ( $min == $min2 ) && ( $rate == $rate2 )  ) { printf("     result was: min=%d  rate=%d\n", $min2, $rate2); }
           else { printf("     result was: min=%d  rate=%d -- error\n", $min2, $rate2); }
           } 
       }
print "\n";



print "Put ESTIM in Waves mode, then hit 'return' key\n";
<STDIN>;

printf( "Verify that routine is Waves....");
my $j = $et->get_routine();
if( $j != 0x76 )  { printf("error, value returned was 0x%02X\n\n", $j); }
else              { printf("it is\n\n"); }
sleep(1);

######################## width min
for( my $i=0; $i<192; $i++ ) {
       printf( "Set channel A width min=0x%02X", $i);
       my $cc = $et->set_A_min_width( $i );
       if( $cc < 1 ) { die "   --Completion code was $cc"; }
       my $j = $et->get_A_min_width();
       if( $j == $i  ) { printf("     result was: 0x%02X\n", $j); }
       else { printf("     result was: 0x%02X -- error\n", $j); }
       }
print "\n";
sleep(1);

for( my $i=0; $i<192; $i++ ) {
       printf( "Set channel B width min=0x%02X", $i);
       my $cc = $et->set_B_min_width( $i );
       if( $cc < 1 ) { die "   --Completion code was $cc"; }
       my $j = $et->get_B_min_width();
       if( $j == $i  ) { printf("     result was: 0x%02X\n", $j); }
       else { printf("     result was: 0x%02X -- error\n", $j); }
       }
print "\n";
sleep(1);


######################## width max
for( my $i=0; $i<192; $i++ ) {
       printf( "Set channel A width max=0x%02X", $i);
       my $cc = $et->set_A_max_width( $i );
       if( $cc < 1 ) { die "   --Completion code was $cc"; }
       my $j = $et->get_A_max_width();
       if( $j == $i  ) { printf("     result was: 0x%02X\n", $j); }
       else { printf("     result was: 0x%02X -- error\n", $j); }
       }
print "\n";
sleep(1);

for( my $i=0; $i<192; $i++ ) {
       printf( "Set channel B width max=0x%02X", $i);
       my $cc = $et->set_B_max_width( $i );
       if( $cc < 1 ) { die "   --Completion code was $cc"; }
       my $j = $et->get_B_max_width();
       if( $j == $i  ) { printf("     result was: 0x%02X\n", $j); }
       else { printf("     result was: 0x%02X -- error\n", $j); }
       }

print "\n";
sleep(1);


######################## freq options
foreach my $val (9, 8, 5, 4, 1 ) {
       foreach my $rate (4, 2, 0 ) {
           printf( "Set A freq options val=%d rate=%d", $val, $rate);
           my $cc = $et->set_A_freq_options( $val, $rate );
           if( $cc < 1 ) { die "   --Completion code was $cc"; }
           my ($val2, $rate2) = $et->get_A_freq_options();
           if( ( $val == $val2 ) && ( $rate == $rate2 )  ) { printf("     result was: val=%d  rate=%d\n", $val2, $rate2); }
           else { printf("     result was: val=%d  rate=%d -- error\n", $val2, $rate2); }
           } 
       }
print "\n";
sleep(1);

foreach my $val (9, 8, 5, 4, 1 ) {
       foreach my $rate (4, 2, 0 ) {
           printf( "Set B freq options val=%d rate=%d", $val, $rate);
           my $cc = $et->set_B_freq_options( $val, $rate );
           if( $cc < 1 ) { die "   --Completion code was $cc"; }
           my ($val2, $rate2) = $et->get_B_freq_options();
           if( ( $val == $val2 ) && ( $rate == $rate2 )  ) { printf("     result was: val=%d  rate=%d\n", $val2, $rate2); }
           else { printf("     result was: val=%d  rate=%d -- error\n", $val2, $rate2); }
           } 
       }
print "\n";
sleep(1);



######################## freq min
for( my $i=0; $i<247; $i++ ) {
       printf( "Set channel A freq min=0x%02X", $i);
       my $cc = $et->set_A_min_freq( $i );
       if( $cc <  1  ) { die "   --Completion code was $cc\n"; }
       my $j = $et->get_A_min_freq();
       if( $j == $i  ) { printf("     result was: 0x%02X\n", $j); }
       else { printf("     result was: 0x%02X -- error\n", $j); }
       }
print "\n";
sleep(1);

for( my $i=0; $i<247; $i++ ) {
       printf( "Set channel B freq min=0x%02X", $i);
       my $cc = $et->set_B_min_freq( $i );
       if( $cc <  1  ) { die "   --Completion code was $cc\n"; }
       my $j = $et->get_B_min_freq();
       if( $j == $i  ) { printf("     result was: 0x%02X\n", $j); }
       else { printf("     result was: 0x%02X -- error\n", $j); }
       }
print "\n";
sleep(1);


######################## freq max
for( my $i=0; $i<247; $i++ ) {
       printf( "Set channel A freq max=0x%02X", $i);
       my $cc = $et->set_A_max_freq( $i );
       if( $cc <  1  ) { die "   --Completion code was $cc\n"; }
       my $j = $et->get_A_max_freq();
       if( $j == $i  ) { printf("     result was: 0x%02X\n", $j); }
       else { printf("     result was: 0x%02X -- error\n", $j); }
       }
print "\n";
sleep(1);

for( my $i=0; $i<247; $i++ ) {
       printf( "Set channel B freq max=0x%02X", $i);
       my $cc = $et->set_B_max_freq( $i );
       if( $cc <  1  ) { die "   --Completion code was $cc\n"; }
       my $j = $et->get_B_max_freq();
       if( $j == $i  ) { printf("     result was: 0x%02X\n", $j); }
       else { printf("     result was: 0x%02X -- error\n", $j); }
       }
print "\n";



print "Put ESTIM in Stroke mode, then hit 'return' key\n";
<STDIN>;

printf( "Verify that routine is Strokes....");
my $j = $et->get_routine();
if( $j != 0x77 )  { printf("error, value returned was 0x%02X\n\n", $j); }
else              { printf("it is\n\n"); }
sleep(1);


######################## width
for( my $i=0; $i<192; $i++ ) {
       printf( "Set channel A width=0x%02X", $i);
       my $cc = $et->set_A_width( $i );
       if( $cc == -1 )  { print "     skipped\n";  next; }
       if( $cc ==  0  ) { die "   --Completion code was $cc\n"; }
       my $j = $et->get_A_width();
       if( $j == $i  ) { printf("     result was: 0x%02X\n", $j); }
       else { printf("     result was: 0x%02X -- error\n", $j); }
       }
print "\n";
sleep(1);

for( my $i=0; $i<192; $i++ ) {
       printf( "Set channel B width=0x%02X", $i);
       my $cc = $et->set_B_width( $i );
       if( $cc == -1 )  { print "     skipped\n";  next; }
       if( $cc ==  0  ) { die "   --Completion code was $cc\n"; }
       my $j = $et->get_B_width();
       if( $j == $i  ) { printf("     result was: 0x%02X\n", $j); }
       else { printf("     result was: 0x%02X -- error\n", $j); }
       }
print "\n";
sleep(1);


######################## freq
for( my $i=0; $i<247; $i++ ) {
       printf( "Set channel A freq=0x%02X", $i);
       my $cc = $et->set_A_freq( $i );
       if( $cc == -1 )  { print "     skipped\n";  next; }
       if( $cc ==  0  ) { die "   --Completion code was $cc\n"; }
       my $j = $et->get_A_freq();
       if( $j == $i  ) { printf("     result was: 0x%02X\n", $j); }
       else { printf("     result was: 0x%02X -- error\n", $j); }
       }
print "\n";
sleep(1);

for( my $i=0; $i<247; $i++ ) {
       printf( "Set channel B freq=0x%02X", $i);
       my $cc = $et->set_B_freq( $i );
       if( $cc == -1 )  { print "     skipped\n";  next; }
       if( $cc ==  0  ) { die "   --Completion code was $cc\n"; }
       my $j = $et->get_B_freq();
       if( $j == $i  ) { printf("     result was: 0x%02X\n", $j); }
       else { printf("     result was: 0x%02X -- error\n", $j); }
       }
print "\n";



print "Put ESTIM in Combo mode, then hit 'return' key\n";
<STDIN>;

printf( "Verify that routine is Combo....");
my $j = $et->get_routine();
if( $j != 0x79 )  { printf("error, value returned was 0x%02X\n\n", $j); }
else              { printf("it is\n\n"); }
sleep(1);


######################## freq rate
for( my $i=0; $i<256; $i++ ) {
       printf( "Set channel A freq rate=0x%02X", $i);
       my $cc = $et->set_A_freq_rate( $i );
       if( $cc <  1  ) { die "   --Completion code was $cc\n"; }
       my $j = $et->get_A_freq_rate();
       if( $j == $i  ) { printf("     result was: 0x%02X\n", $j); }
       else { printf("     result was: 0x%02X -- error\n", $j); }
       }
print "\n";
sleep(1);

for( my $i=0; $i<256; $i++ ) {
       printf( "Set channel B freq rate=0x%02X", $i);
       my $cc = $et->set_B_freq_rate( $i );
       if( $cc <  1  ) { die "   --Completion code was $cc\n"; }
       my $j = $et->get_B_freq_rate();
       if( $j == $i  ) { printf("     result was: 0x%02X\n", $j); }
       else { printf("     result was: 0x%02X -- error\n", $j); }
       }
print "\n";



print "Put ESTIM in Rhythm mode, then hit 'return' key\n";
<STDIN>;

printf( "Verify that routine is Rhythm....");
my $j = $et->get_routine();
if( $j != 0x7B )  { printf("error, value returned was 0x%02X\n\n", $j); }
else              { printf("it is\n\n"); }
sleep(1);

######################## level rate
for( my $i=0; $i<256; $i++ ) {
       printf( "Set channel A level rate=0x%02X", $i);
       my $cc = $et->set_A_level_rate( $i );
       if( $cc == -1 )  { print "     skipped\n";  next; }
       if( $cc ==  0  ) { die "   --Completion code was $cc\n"; }
       my $j = $et->get_A_level_rate();
       if( $j == $i  ) { printf("     result was: 0x%02X\n", $j); }
       else { printf("     result was: 0x%02X -- error\n", $j); }
       }
print "\n";
sleep(1);

for( my $i=0; $i<256; $i++ ) {
       printf( "Set channel B level rate=0x%02X", $i);
       my $cc = $et->set_B_level_rate( $i );
       if( $cc == -1 )  { print "     skipped\n";  next; }
       if( $cc ==  0  ) { die "   --Completion code was $cc\n"; }
       my $j = $et->get_B_level_rate();
       if( $j == $i  ) { printf("     result was: 0x%02X\n", $j); }
       else { printf("     result was: 0x%02X -- error\n", $j); }
       }
print "\n";



print "Put ESTIM in Ramdom2 mode, then hit 'return' key (may be a few mismatches)\n";
<STDIN>;

printf( "Verify that routine is Ramdom2....");
my $j = $et->get_routine();
if( $j != 0x81 )  { printf("error, value returned was 0x%02X\n\n", $j); }
else              { printf("it is\n\n"); }
sleep(1);

######################## width rate
for( my $i=0; $i<256; $i++ ) {
       printf( "Set channel A width rate=0x%02X", $i);
       my $cc = $et->set_A_width_rate( $i );
       if( $cc < 1 ) { die "   --Completion code was $cc"; }
       my $j = $et->get_A_width_rate();
       if( $j == $i  ) { printf("     result was: 0x%02X\n", $j); }
       else { printf("     result was: 0x%02X -- error\n", $j); }
       }
print "\n";
sleep(1);

for( my $i=0; $i<256; $i++ ) {
       printf( "Set channel B width rate=0x%02X", $i);
       my $cc = $et->set_B_width_rate( $i );
       if( $cc < 1 ) { die "   --Completion code was $cc"; }
       my $j = $et->get_B_width_rate();
       if( $j == $i  ) { printf("     result was: 0x%02X\n", $j); }
       else { printf("     result was: 0x%02X -- error\n", $j); }
       }
print "\n";



print "Put ESTIM in USER 1 mode, then hit 'return' key\n";
<STDIN>;

printf( "Verify that routine is User1....");
my $j = $et->get_routine();
if( $j != 0x88 )  { printf("error, value returned was 0x%02X\n\n", $j); }
else              { printf("it is\n\n"); }
sleep(1);

######################## time on
for( my $i=0; $i<256; $i++ ) {
       printf( "Set channel A TIME ON=0x%02X", $i);
       my $cc = $et->set_A_time_on( $i );
       if( $cc == -1 )  { print "     skipped\n";  next; }
       if( $cc ==  0  ) { die "   --Completion code was $cc\n"; }
       my $j = $et->get_A_time_on();
       if( $j == $i  ) { printf("     result was: 0x%02X\n", $j); }
       else { printf("     result was: 0x%02X -- error\n", $j); }
       }
print "\n";
sleep(1);

for( my $i=0; $i<256; $i++ ) {
       printf( "Set channel B TIME ON=0x%02X", $i);
       my $cc = $et->set_B_time_on( $i );
       if( $cc == -1 )  { print "     skipped\n";  next; }
       if( $cc ==  0  ) { die "   --Completion code was $cc\n"; }
       my $j = $et->get_B_time_on();
       if( $j == $i  ) { printf("     result was: 0x%02X\n", $j); }
       else { printf("     result was: 0x%02X -- error\n", $j); }
       }
print "\n";
sleep(1);


######################## time off
for( my $i=0; $i<256; $i++ ) {
       printf( "Set channel A TIME OFF=0x%02X", $i);
       my $cc = $et->set_A_time_off( $i );
       if( $cc == -1 )  { print "     skipped\n";  next; }
       if( $cc ==  0  ) { die "   --Completion code was $cc\n"; }
       my $j = $et->get_A_time_off();
       if( $j == $i  ) { printf("     result was: 0x%02X\n", $j); }
       else { printf("     result was: 0x%02X -- error\n", $j); }
       }
print "\n";
sleep(1);

for( my $i=0; $i<256; $i++ ) {
       printf( "Set channel B TIME OFF=0x%02X", $i);
       my $cc = $et->set_B_time_off( $i );
       if( $cc == -1 )  { print "     skipped\n";  next; }
       if( $cc ==  0  ) { die "   --Completion code was $cc\n"; }
       my $j = $et->get_B_time_off();
       if( $j == $i  ) { printf("     result was: 0x%02X\n", $j); }
       else { printf("     result was: 0x%02X -- error\n", $j); }
       }
print "\n";
sleep(1);


######################## time options
foreach my $on (9, 5, 1 ) {
       foreach my $off (4, 2, 0 ) {
           printf( "Set A time options on=%d off=%d", $on, $off);
           my $cc = $et->set_A_time_options( $on, $off );
           if( $cc < 1 ) { die "   --Completion code was $cc"; }
           my ($on2, $off2) = $et->get_A_time_options();
           if( ( $on == $on2 ) && ( $off == $off2 )  ) { printf("     result was: on=%d  off=%d\n", $on2, $off2); }
           else { printf("     result was: on=%d  off=%d -- error\n", $on2, $off2); }
           } 
       }

print "\n";
sleep(1);

foreach my $on (9, 5, 1 ) {
       foreach my $off (4, 2, 0 ) {
           printf( "Set B time options on=%d off=%d", $on, $off);
           my $cc = $et->set_B_time_options( $on, $off );
           if( $cc < 1 ) { die "   --Completion code was $cc"; }
           my ($on2, $off2) = $et->get_B_time_options();
           if( ( $on == $on2 ) && ( $off == $off2 )  ) { printf("     result was: on=%d  off=%d\n", $on2, $off2); }
           else { printf("     result was: on=%d  off=%d -- error\n", $on2, $off2); }
           } 
       }



