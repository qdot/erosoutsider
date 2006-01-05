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
###############  Program description ################################
#
#  This program impliments a script language for controlling the ESTIM.  The script is 
#  written using any text editor, such #  as notepad (windows) or pico (linux).  The user 
#  interface is a GUI, created using wxPerl.
#
#  Version 4.00
################  Script Syntax ######################################
#
#   COMMENTS        ->  any text that follows a '#', on a line by itself or following a command
#
#   LABEL:          ->  an optional LABEL can be placed as the first item on a line, it is an alphanumeric
#                       word followed by a colon, each label name must be unique, labels mark lines that can
#                       be jumped to using a "goto" or simliar command. A command can optionaly follow the label
#                       Note that:  "sub", "end", "checkbox", "slider", "box" have special meanings and should
#                       not be used as ordinary labels.
#  
#### special purpose label-like statements, these words cannot be used as ordinary labels.  These statments take effect
#       when the script is loading, not while it's running, they can be placed anywhere in the script, but are usually
#       placed near the top since they are in effect for the entire time the script is loaded.
#
#   sub: <name>     -> see subroutines topic below
#   end: return     -> see subroutines topic below
#   include: filename -> inserts the lines of another file where the 'include' line appears. unless the given name contains the
#                        char ':' the path from the current file is prepended, so that the 'include' can just be a filename 
#                        (assuming both files in the same directory).  'includes' can be nested.
#
####
#
#   goto <label>    ->  jumps to the line containing the named label, can go forward or backwards
#
#   call <label> <parms>    ->  calls the named subroutine, passing the optional parmeters to it
#
#   return          ->  returns control to the caller
#
#   if [not] xx <label>  ->  jumps/calls to the line immediately after a label, can go forward or backwards, based on the completions code
#                       If calling a subroutine, parms can be given
#                         xx can be any of the following:  eq, ne, gt, lt, ge, le,
#                         ii  meaning any of the various variables (true if value is > 0 )
#
#   when rr <label> -> if((rr > 0) && (rr < t)) jump/call to "label", and set "rr" = 0
#                       If calling a subroutine, parms can be given
#                         for example, init v4 as follows:                   v4 = t + h1
#                         inside loop, put:                                  when v4 timesup
#                         you get a one time branch after a 1 hour delay
####
#
#   msg             ->  output the given message on the screen, msg text is not quoted
#                         variables can be displayed, for example  v5   will cause the present
#                         value of v5 to be inserted into the message text, global variables
#                         can be displayed the same way. multiple white space 
#                         chars are reduced to a single space char, however \s, \t, and \n are 
#                         converted as expected.  The char '#' cannot be included in a message.
#                         messages are sent to the command line window, not the GUI.
#
####
#
#   ESTIM set <ch> time <ON> <OFF>  set the time-on and time-off values on channel <ch> to the fixed amount given, <ch> = 'A' or 'B', 
#                              <ON>=0-100   <OFF>=0-100
#   ESTIM set <ch> level <NN>   set the level on channel <ch> to the fixed amount given, <ch> = 'A' or 'B', <NN>=0-100
#   ESTIM set <ch> freq  <NN>   set the frequency on channel <ch> to the fixed amount given, <ch> = 'A' or 'B', <NN>=0-100
#   ESTIM set <ch> width <NN>   set the pulse width on channel <ch> to the fixed amount given, <ch> = 'A' or 'B', <NN>=0-100

#   ESTIM get <ch> time         v1 = <TIME ON>   v2 = <TIME OFF>
#   ESTIM get <ch> level        v1 = <LEVEL>
#   ESTIM get <ch> freq         v1 = <FREQ>
#   ESTIM get <ch> width        v1 = <WIDTH>
#
#   ESTIM ramp <ch> level <min> <max> <rate>   start an ongoing ramp on channel <ch>, <ch> = 'A' or 'B', <min>,<max>,& <rate>=0-100
#   ESTIM ramp <ch> freq  <min> <max> <rate>   start an ongoing ramp on channel <ch>, <ch> = 'A' or 'B', <min>,<max>,& <rate>=0-100
#   ESTIM ramp <ch> width <min> <max> <rate>   start an ongoing ramp on channel <ch>, <ch> = 'A' or 'B', <min>,<max>,& <rate>=0-100
#   ESTIM dramp <ch> level <min> <max> <rate>  start an ongoing ramp on channel <ch>, <ch> = 'A' or 'B', <min>,<max>,& <rate>=0-100
#   ESTIM dramp <ch> freq  <min> <max> <rate>  start an ongoing ramp on channel <ch>, <ch> = 'A' or 'B', <min>,<max>,& <rate>=0-100
#   ESTIM dramp <ch> width <min> <max> <rate>  start an ongoing ramp on channel <ch>, <ch> = 'A' or 'B', <min>,<max>,& <rate>=0-100
#
#   ESTIM options <ch> time  <on>  <off>       set time options on channel <ch>, <ch> = 'A' or 'B', 
#                                                  on:     1=none   5=EFFECT        9=MA     
#                                                  off:    0=none   2=TEMPO         4=MA
#   ESTIM options <ch> level <min> <rate>      set level options on channel <ch>, <ch> = 'A' or 'B', 
#                                                  min:    1=none   5=DEPTH               
#                                                  rate:   0=none   2=TEMPO         4=MA
#   ESTIM options <ch> freq  <val> <rate>      set freq options on channel <ch>, <ch> = 'A' or 'B', 
#                                                  val:    1=none   4=val/freq      5=max/freq      8=val/MA      9=max/MA
#                                                  rate:   0=none   2=rate/effect   4=rate/MA
#   ESTIM options <ch> width <val> <rate>      set width options on channel <ch>, <ch> = 'A' or 'B', 
#                                                  val:    1=none   4=val/width     5=min/width
#                                                  rate:   0=none   2=pace          4=MA
####
#   notes/hints/ideas:
#      1) Setting freq to MA, means that the MA control has direct control of the frequency setting. if the MA control
#         is set full clockwise, the freq will be 100.  Full counterclockwise, it will be 0.  At the middle setting
#         it will read around 77.
#      2) When setting up ramps, a higher value for 'rate' will cause the value to change faster.
#      3) a 'ramp' starts at the 'min' setting and rises to the 'max' setting, time permitting, it will then reverse direction
#      4) a 'dramp' starts at the 'max' setting and falls to the 'min' setting, time permitting, it will then reverse direction
####
#
#   run  <name> <name>    -> stops execution of the current script, and runs the named script(s)
#                       'run' is not allow to be used inside a subroutine
#   end                   -> end the program.  'end" is not allowed at the subroutine level
####
#
#   rr = ii         ->  set a variable to a given value, completion code is not changed
#   rr = ii ? ii    ->  set a variable to the given values, creating a range. completion code is not changed
#   rr = ii + ii    ->  set a variable to the sum of the two given values, completion code is to the result
#   rr = ii - ii    ->  set a variable to the difference of the two given values, completion code is to the result
#   rr = ii * ii    ->  set a variable to the product of the two given values, completion code is to the result
#   rr = ii / ii    ->  set a variable to the division of the two given values, completion code is to the result
#   rr = ii % ii    ->  set a variable to the remainder of the division of the two given values, completion code is to the result
#   ii =?  ii       ->  compare the given values, completion code is set to the result
#
#   link s1  g5     ->  links a slider to a global such that when the slider changes value the global is also adjusted
#                       also overrides any previous link.  each slider can have only one active link at a time
#   unlink s1       ->  removes a slider's link, if one exists, to a global 
####
#
#   usleep ii       ->  delays running approximately the given number of microseconds
#   sleep  ii       ->  delays running approximately the given number of seconds
#
#
####
#
#      When a command accepts a value 'ii' any of the following can be used:
#
#           15     -  a integer number  (for example 15)
#           2?10   -  a random number  (for example 2?10  means use a random number from 2 to 10)
#           v5     -  the value of a local variable  (for example  v5  means use the present value in variable 'v5')
#                     note there is no limit to the number of variables that can be used in a script, the
#                     'run' command undefines all 'v' variables. 
#           g5     -  the value of a global variable, global variables are not erased by the 'run' command
#           p5     -  the value of a parameter variable, parameter variables passed to subroutines by value
#           r5     -  the value of a return variable, return variables passed back to caller by value
#
#                     A reference to a 'v' or 'g' variable can include an 'adornment' of 'H' or 'L' or be unadorned.  
#                     For example 'v4H'  'v4L'  'v4'  respectively.
#                     Variables can contain an integer value or a range value. When a variable contains an integer
#                     value, that value is returned regardless of any adornment.
#                     If a variable contains a range (ie '2 ? 5') then an unadorned reference (except in a 'msg' command)
#                     is resolved to a random number between the given limits. Putting an 'H' or 'L' after the variable 
#                     reference returns either the variable's higher or lower limits. 
#                                      
#           c5     -  the value of a checkbox, either 1 or 0  checkboxes are numbered from 1-14, from top to bottom
#           s5     -  the value of a slider, from min-max.  sliders are numbered from 1-9, from top to bottom
#
#           t      -  seconds since epoc (used to limit a loop by duration measured in seconds )
#           m30.2  -  computes the number of seconds for the given number of minutes, fractions are allowed
#           h2.5   -  computes the number of seconds for the given number of hours, fractions are allowed
#
#      When a command accepts a value 'rr' either of the following can be used:
#
#           v5     -  a local variable
#           v5-8   -  a range of local variables all set to the same value 
#           g5     -  a global variable
#           s5     -  a slider's value.  Setting an 's' variable also changes the GUI slider's setting
#
#
#   Subroutines:
#
#     a subroutine definition begins with:  "sub: <name>"
#     and ends with:                        "end: return <optional return values>"
#     subroutine names must be unique and not match any ordinary labels at the top most level
#     subroutines can call other subroutines, including themselves (recursive call)
#     each subroutine has it's own: label name space, completion code, and 'v' variables
#     a return statement within a subroutine, will return control to the caller
#     global items: global variables, Aux relay, venus speed, slider values and checkbox values
# 
#   Execution of a script begins with the first line unless a label "main" has been declared at the top level
#     if the script begins with a subroutine, you must declare a "main" label, or the program will likely 
#     fail.
#




use strict;

use Win32::SerialPort;
use Wx;
use Wx::Event;
use IPC::UDPmsg;
use Time::HiRes;        # included with ActiveState install
use IO::estim;


###########################################################
# Extend the Frame class to our needs                     #
###########################################################
package MyFrame;
 
use Wx::Event qw( EVT_BUTTON  EVT_IDLE EVT_MENU  EVT_CHECKBOX  EVT_SCROLL_THUMBRELEASE 
    EVT_TOGGLEBUTTON  EVT_SCROLL_THUMBTRACK EVT_SCROLL_BOTTOM  EVT_SCROLL_LINEUP
    EVT_SCROLL_LINEDOWN EVT_SCROLL_PAGEUP EVT_SCROLL_PAGEDOWN );
   
  

use Wx qw(:filedialog);
use Wx qw(:frame);
use Wx qw(:id);
use Wx qw(:slider);
use Wx qw(:gauge);
use Wx qw(:checkbox);
use Wx qw(:statictext);
use Wx qw(:textctrl);
use Wx qw(wxBITMAP_TYPE_BMP);
use Wx qw(wxBITMAP_TYPE_JPEG);
use Wx qw(wxHIDE_READONLY);
use Wx qw(wxSIMPLE_BORDER);

use base qw/Wx::Frame/;         # Inherit from Wx::Frame

my ($LOAD_SCRIPT, $RUN_SCRIPT, $STOP_SCRIPT, $APP_QUIT, $EDIT_CUT, $EDIT_COPY, $EDIT_PASTE) = (101..125);       # menu IDs
my $INIT_PARM  = 124;   # ten items numbered: 125 - 134

sub new {
   my $class = shift;
  
   my $self = $class->SUPER::new(@_);  # call the superclass' constructor

   
   ############### Set up the menu bar.
   my $file_menu = Wx::Menu->new();
   $file_menu->Append( $LOAD_SCRIPT, "Load\tCtrl-L", "Load a Script");
   $file_menu->AppendSeparator();
   $file_menu->Append( $RUN_SCRIPT,  "Run\tCtrl-R",  "Run the Script");
   $file_menu->Append( $STOP_SCRIPT, "Stop\tCtrl-S", "Stop the Script");
   $file_menu->AppendSeparator();
   $file_menu->Append ($APP_QUIT,    "Exit\tCtrl-X", "Exit Application");

   $file_menu->Enable( $RUN_SCRIPT, 0 );
   $file_menu->Enable( $STOP_SCRIPT, 0 );
   $self->{FILE_MENU} = $file_menu;

   EVT_MENU($self, $LOAD_SCRIPT, \&OnFileLoad);
   EVT_MENU($self, $RUN_SCRIPT,  \&OnFileRun);
   EVT_MENU($self, $STOP_SCRIPT, \&OnFileStop);
   EVT_MENU($self, $APP_QUIT,     sub {$_[0]->Close( 1 )});

   my $edit_menu = Wx::Menu->new();
   
   $edit_menu->Append( $EDIT_CUT,   "&Cut\tCtrl-X");
   $edit_menu->Enable( $EDIT_CUT, 0 );
   $edit_menu->Append( $EDIT_COPY,  "&Copy\tCtrl-C");
   $edit_menu->Enable( $EDIT_COPY, 0 );
   $edit_menu->AppendSeparator();
   $edit_menu->Append( $EDIT_PASTE, "&Paste\tCtrl-V");
   $edit_menu->Enable( $EDIT_PASTE, 0 );

   my $menubar= Wx::MenuBar->new();
   $menubar->Append ($file_menu, "&File");
   $menubar->Append ($edit_menu, "&Edit");
   $self->SetMenuBar($menubar);


   ############## Status Bar
   $self->{STATUS_BAR} = $self->CreateStatusBar(4, 0, -1);
   $self->{STATUS_BAR}->SetStatusWidths( 125, 187, 280, 312 ); 
   $self->{STATUS_BAR}->SetStatusText( "Status:", 1 ); 
   $self->{STATUS_BAR}->SetStatusText( "File:", 2 ); 

  

   ############## Box 1 Sliders        IDs = 601 - 605  
   my ($x, $y, $w, $h) = ( 15, 15, 320, 25 );                                   
   $self->{BOX}[2] = Wx::StaticBox->new( $self, -1, "Channel A", [$x, $y], [565, 230] );
   my @names = ("Time On", "Time Off", "Level", "Frequency", "Width" );
   for( my $i=1; $i<6; $i++ ) {
       $y += 35;
       $self->{SLIDER}[$i] = Wx::Gauge->new( $self, -1, 100, [$x+200, $y], [$w, 20], wxGA_HORIZONTAL); 
       $self->{SLIDER}[$i]->SetValue( 0 ); 
       $self->{SLIDER_TXT}[$i] = Wx::StaticText->new ( $self, -1, $names[$i-1],  [$x+19,  $y] );
       $self->{SLIDER_MIN}[$i] = Wx::StaticText->new ( $self, -1,"  0",  [$x+181, $y] );
       $self->{SLIDER_MAX}[$i] = Wx::StaticText->new ( $self, -1,"100",  [$x+530, $y] );
       $self->{SLIDER_VAL}[$i] = Wx::TextCtrl->new ( $self, -1,"  0",  [$x+110, $y], [36,25], wxTE_READONLY );
       }


   ############## Box 2 Sliders        IDs = 606 - 610
   $y = 266;                                   
   $self->{BOX}[3] = Wx::StaticBox->new( $self, -1, "Channel B", [$x, $y], [ 565, 230 ] );

   for( my $i=6; $i<11; $i++ ) {
       $y += 35;
       $self->{SLIDER}[$i] = Wx::Gauge->new( $self, -1, 100, [$x+200, $y], [$w, 20], wxGA_HORIZONTAL); 
       $self->{SLIDER}[$i]->SetValue( 0 ); 
       $self->{SLIDER_TXT}[$i] = Wx::StaticText->new ( $self, -1, $names[$i-6],  [$x+19, $y] );
       $self->{SLIDER_MIN}[$i] = Wx::StaticText->new ( $self, -1,"  0",  [$x+181, $y] );
       $self->{SLIDER_MAX}[$i] = Wx::StaticText->new ( $self, -1,"100",  [$x+530, $y] );
       $self->{SLIDER_VAL}[$i] = Wx::TextCtrl->new ( $self, -1,"  0",  [$x+110, $y], [36,25], wxTE_READONLY );
       }


   ############## File Dialog
   $self->{DIALOG} = Wx::FileDialog->new( $self,            # Parent window
                   "Chose a Script or Profile to Load",     # message
                                                    "",     # Default Directory
                                                    "",     # Default File
        "Scripts (*.txt)|*.txt|Profiles (*.pro)|*.pro",     # Wildcards
                                                wxOPEN,     # style
                                              [-1,-1]);     # Position  N/A

   ############## Init Dialog
   $self->{INIT} = Wx::TextEntryDialog->new( $self,         # Parent window
                          "Please Enter The New Value",     # message
                                                    "");    # caption


   EVT_IDLE( $self, \&Idle);      # setup the idle process
   return $self;
   }
   

   ############## Event Handling Subroutines
sub OnLoad  { 
   my( $self ) = @_; 
   if( $self->{DIALOG}->ShowModal() == wxID_OK ) {
       $self->{FILE_MENU}->Enable( $LOAD_SCRIPT, 0 );
       $self->{FILE_MENU}->Enable( $RUN_SCRIPT,  0 );
       $self->{FILE_MENU}->Enable( $STOP_SCRIPT, 0 );

       my $fname = $self->{DIALOG}->GetPath();
       $self->{IPC}->write( 9001, "open $fname" );   # notify child
       }
   } 

sub OnRun  { 
   my ($self) = @_; 
   $self->{IPC}->write( 9001, "run" );   # notify child
   $self->{FILE_MENU}->Enable( $LOAD_SCRIPT, 0 );
   $self->{FILE_MENU}->Enable( $RUN_SCRIPT,  0 );
   } 

sub OnStop  { 
   my ($self ) = @_; 
   $self->{IPC}->write( 9001, "stop" );   # notify child
   $self->{FILE_MENU}->Enable( $STOP_SCRIPT, 0 );
   for(my $i=1; $i<6; $i++) {
       if( defined( $self->{MENU}->{DESC}[$i] ) ) { 
           $self->{INIT_MENU}->Enable( $i+124, 1 );
           } 
       }
   } 


sub OnFileLoad  { 
   my( $self, $event ) = @_; 
   &OnLoad( $self );
   } 

sub OnFileRun  { 
   my( $self, $event ) = @_; 
   &OnRun( $self );
   } 

sub OnFileStop  { 
   my( $self, $event ) = @_; 
   &OnStop( $self );
   } 


sub OnSlider  { 
   my( $self, $event ) = @_;
   my $id = $event->GetId() - 600;
   my $v = 0 + $self->{SLIDER}[$id]->GetValue(); 
   $self->{SLIDER_VAL}[$id]->SetValue( sprintf("%3d", $v )); 
   $self->{IPC}->write( 9001, "slider $id $v" );   # notify child
   } 

sub Idle  { 
   my $self  = shift;
   Wx::WakeUpIdle();             # make sure the idles keep coming
   main::Adj();
   } 


###########################################################
# Define our EngineApp class that extends Wx::App         #
###########################################################
package EngineApp;
use base qw(Wx::App);   # Inherit from Wx::App
use Wx qw(:frame);
   
sub OnInit    {
   my $self = shift;
   my $frame = MyFrame->new( undef,         # Parent window
                                -1,         # Window id
          'Script Controlled ESTIM',         # Window Title
                            [10,10],        # position X, Y
                         [610, 586],       # size X, Y
              wxDEFAULT_FRAME_STYLE);       # style
   $self->SetTopWindow($frame);             # Define the toplevel window
   $self->{FRAME} = $frame;

   my $IPC = IPC::UDPmsg->new( 9000 );      # open a channel to speak to the child
   $self->{FRAME}->{IPC} = $IPC;            # save it at the frame level, where the action is

#   my $color = Wx::Colour->new( 192, 192, 192 );  
#   $frame->SetBackgroundColour( $color );

   $frame->Show(1);                         # Show the frame


   bless $self;
   }

   
###########################################################
# The main program                                        #
###########################################################
package main;
use Wx::Event qw( EVT_CHECKBOX );
use Wx qw(:window);
use Wx qw(:statictext);
use Wx qw(:font);

my ($wxobj, @picture_files, $next_picture_file, $picture_shuffle);
my (@user_button);                    #  the four Wx::Bitmap for the 4 states each button can be
                                      #  0=normal, 1=pushed, 2=needed, 3=received (needed+pushed)
my $STATUS_TEXT = "";          # save of status text, when commanded
my ($text_xpos, $text_ypos) = (-1,-1);  # -2 means random positioning;  -1 mean default positioning; other means place at given location

sub Adj {    ################### decode messages from command line process ###################
   my $DEBUG = 0;

   Time::HiRes::usleep(1000);    # avoid using all CPU cycles
   if( my $msg = $wxobj->{FRAME}->{IPC}->read() ) {
       if( $DEBUG > 0 ) {print "parent got: $msg\n";}

       if( $msg =~ /^progress (\d+)$/ ) {                                      # progress <value: 0-100>
           $wxobj->{FRAME}->{PROGRESS}->SetValue( $1 );
           }
       elsif( $msg =~ /^gvar (\d+) (\d+)$/ ) {                                 # update to global variable                                                                                 
           $wxobj->{FRAME}->{MENU}->{VALUE}[$1] = $2;                            # "gvar $1  $2"
           }                                                                     #       ##  val
       elsif( $msg =~ /^Status: .*$/ ) { 
           $wxobj->{FRAME}->{STATUS_BAR}->SetStatusText( $msg, 1 );
           if( $msg =~ /^Status: Script Loaded$/ ) { 
               $wxobj->{FRAME}->{FILE_MENU}->Enable( $LOAD_SCRIPT, 1 );
               $wxobj->{FRAME}->{FILE_MENU}->Enable( $RUN_SCRIPT,  1 );
               }
           if( $msg =~ /^Status: Script Running$/ ) { 
               $wxobj->{FRAME}->{FILE_MENU}->Enable( $STOP_SCRIPT, 1 );
               }
           if( $msg =~ /^Status: Script Stopped$/ ) { 
               $wxobj->{FRAME}->{FILE_MENU}->Enable( $LOAD_SCRIPT, 1 );
               $wxobj->{FRAME}->{FILE_MENU}->Enable( $RUN_SCRIPT,  1 );
               }
           }
       elsif( $msg =~ /^slider (\d+) (\d+)$/ ) {                               # slider value update from the script
           if( $DEBUG > 0 ) {print "slider[$1] = $2\n"; }                        # "slider $1  $2"
           $wxobj->{FRAME}->{SLIDER}[$1]->SetValue( $2 );                        #         ##  val
           $wxobj->{FRAME}->{SLIDER_VAL}[$1]->SetValue( sprintf("%3d", $2 )); 
           }
       elsif( $msg =~ /^File: .*$/ ) { 
           $wxobj->{FRAME}->{STATUS_BAR}->SetStatusText( $msg, 2 );
           }

       elsif( $msg =~ /^end$/ ) {                                               # "end" from script 
           $wxobj->{FRAME}->Close(1);
           }

       } # if( my $msg = $wxobj->{FRAME}->{IPC}->read() ) 
   } # sub Adj()

if( my $pid = fork ) {                # parent
    my $DEBUG = 0;
    $wxobj = EngineApp->new();        # New EngineApp application
    $wxobj->MainLoop;                 # run until window is closed

    if( $DEBUG > 0 ) { print "We are ending, signaling the child\n";}
    $wxobj->{FRAME}->{IPC}->write( 9001, "exit" );
    $wxobj->{FRAME}->{IPC}->write( 9002, "nova exit" );
    wait;                             # wait for children to quit
    exit;
    }





#########################################################################
#                  first child process - run script                     #
#########################################################################
srand();                          # set the ramdom seed

my @G = ();                       # no global variables have values initually
my $subdef = undef;               # subroutine currently being defined, none to start

my %TAGS = ();                    # no tags are defined initially
my %LINK = ();                    # no slider links are defined initially
my @script = ();                  # memory copy of user's script
my @CB = ();                      # check boxes, hold as global variables, values = (0,1)
my @SR = ();                      # sliders, hold as global variables, values = (min,max)

our $line_no = 1;                 # script line number
our $CC   = 0;                    # initial value of completion code
our @V = ();                      # no variables have values initually, only the globals survive
our @P = ();                      # parameters to subroutines
our @R = ();                      # return values from subroutines
our $et = ();                     # object for ESTIM communication
our @SV = (1, -1, -1, -1, -1, -1, -1,  -1, -1, -1, -1);   # saved values from device
our @SVi =(0,  0,  0,  0,  0,  0,  0,   0,  0,  0,  0);            # saved values from device, rationalized 0-100
my $port = 1;                     # the SerialPort to use, IE COM-1, etc

#################### decode messages from GUI ##############################

my $IPC = IPC::UDPmsg->new( 9001 );                                    # open a channel to speak to the parent

$et = IO::estim->new( $port, "c:/eros/mod", 0 );                           # open the ESTIM device
if( $et == 0 ) { die "The E-stim device was not able to be openned\n"; }


while(1) {
    my $DEBUG = 0;
    if( my $msg = $IPC->read() ) {
        if( $msg eq "exit" ) { 
            exit 0; 
            }
        elsif( $msg =~ /open (.+)$/ ) { 
            if( $DEBUG > 0 ) {print "open received: $1\n";}
            $IPC->write( 9000, "Status: Script Loading" );
            $IPC->write( 9000, "File: $1" );

            %TAGS = ();                    # no tags are defined initially
            %LINK = ();                    # no slider links are defined initially
            @script = ();                  # memory copy of user's script
            $line_no = 1;                  # script line number
            @V = ();                       # no variables have values initually, only the globals survive
            @CB = ();                      # check boxes have no initial values
            @SR = ();                      # sliders have no initial values
            $subdef = undef;               # subroutine currently being defined, none to start

            &loadscript( $1 );

            $IPC->write( 9000, "Status: Script Loaded" );
            if( $DEBUG > 1 ) {
                my $i;
                print "\n---LINES---\n";
                for( $i = 1; $i < @script; $i++ ) {
                    print "$i $script[$i]\n";
                    }
                print "\n---TAGS---\n";
                foreach  $i ( sort(keys( %TAGS )))  {
                    print "$i $TAGS{$i}\n";
                    }
                }
            }
        elsif( $msg =~ /run$/ ) { 
            if( $DEBUG > 0 ) {print "run received\n";}
          restart:
            $IPC->write( 9000, "Status: Script Running" );
            $CC   = 0;                     # initial value of completion code
            my $ret = &runscript;
            if( defined( $ret ) && ( $ret eq "exit pgm" ) ) {            #  see if an exit message
                exit 0; 
                } 
            if( defined( $ret ) && ( $ret eq "restart" ))  {       #  script issued a "run <name> <name>" command
                $IPC->write( 9000, "Status: Script Loading" );
                my $file;
                foreach $file (@ARGV) {
                    $IPC->write( 9000, "File: $file" );
                    &loadscript( $file );
                    }
                goto restart;
                }
            $IPC->write( 9000, "Status: Script Stopped" );
            for( my $i=1; $i<11; $i++ ) {
                $IPC->write( 9000, "gvar $i $G[$i]" );             # send updates to GUI, incase of init menu
                }
            }
        elsif( $msg =~ /^init (\d+) (\d+)$/ ) {                                   # init value from menu
            $G[ $1 ] = $2;
            if( $DEBUG > 0 ) {print "global variable $1 set to: $G[ $1 ]\n";}
            }
        elsif( $msg =~ /^checkbox (\d+) (\d)$/ ) {                                # check box values can be set after loading
            $CB[ $1 ] = $2;
            if( $DEBUG > 0 ) {print "checkbox $1 set to: $CB[ $1 ]\n";}
            }
        elsif( $msg =~ /^slider (\d+) (\d+)$/ ) {                                 # slider values can be set after loading
            $SR[ $1 ] = $2;
            if( $DEBUG > 0 ) {print "slider $1 set to: $SR[ $1 ]\n";}
            }
        }
    Time::HiRes::usleep(1000);
    }



###################################################################################
#               read in all the script lines and store in an array                #
###################################################################################
sub loadscript {
my $DEBUG = 0;
my $fname = shift;             # filename is passed as a parameter

if( $DEBUG > 0 ) {print "loadscript() called for '$fname'\n";}
open( my $SFILE, "< $fname" );
while (<$SFILE>) {
    if( $DEBUG > 2 ) { print("read: '$_'"); }
    my ($pos);

    if( $DEBUG > 2 ) { print "$line_no $_"; }
    if( /.*\n$/ ) { chop( $_ ); }     # remove end of line char, if any (last line may not have EOL)
    $pos = index( $_, "#" );          # find first # char, if any
    if( $pos >= 0 ) {                 # negative is returned if none found
        if( $pos == 0 ) {             # if located in column 1, then entire line is a comment
            if( $DEBUG > 2 ) { print "  -- comment line, skipped\n"; }
            next;                     # skip over comment lines
            } # if( $pos == 0 )
        $_ = substr( $_, 0, $pos );   # if located later, strip off the comment
        if( $DEBUG > 2 ) { print "  |$_|  -- comment removed\n"; }
        }  # if( $pos >= 0 )
    s/\s+/ /g;                        # remove multiple spaces in a row
    s/^\s+//;                         # remove leading spaces
    s/\s+$//;                         # remove trailing spaces
    if( $DEBUG > 2 ) { print "|$_| - after trimming\n"; }
    if( /^(\w+):\s*(.*)$/ ) {         # if the line has a label 
        my $lab;
        if( defined( $subdef  ) )  { $lab = $subdef . ":" . $1; }   # labels within a subroutine are stored as "subname:label"
        else                       { $lab = $1; }                # labels outside a subroutine are stored as "label"

        if( $1 eq "sub" ) {           # a subroutine definition is starting
            if( $DEBUG > 2 ) { print "  |$_|  -- subroutine defined\n"; }
            if( defined($subdef) ) {                             # trying to define a subroutine inside another one
                print "  --Subroutine definitions nested at: $subdef, script terminated\n"; 
                exit;
                }
            if( $2 =~ /^(\w+)$/ ) {                # subroutine names are stored like labels, but with a negative line number 
                $TAGS{ $1 } = -$line_no;           # save as negative number to indicate a subroutine
                $subdef = $1;                         # subroutine names are stores as just the name, no ":"
                next;
                }
            else {
                print "  --unnamed subroutine definition, script terminated\n"; 
                exit;                              # subroutines must be named
                }
            }

        if( $1 eq "end" ) {           # subroutine definition ends
            if( ! defined($subdef) ) {
                print "  --'end' encountered outside of a subroutine definition, script terminated\n"; 
                exit;
                }
            my $ret = $2;
            if( $ret =~ /^return/ )  {
                $TAGS{ $lab } = $line_no;            # save the tag's name
                if( $DEBUG > 0 ) { print "TAGS{ $lab } = $line_no\n"; }
                $script[ $line_no++ ] = $ret;    # save the script line, icr $line_no only for lines that are stored
                $subdef = undef;
                next;
                }
            print "  --'end' encountered without a return command, script terminated\n"; 
            exit;
            }


        if( $1 eq "include" ) {           # include another file
            my $incfile;
            if( index( $2, ":" ) < 0 ) {
                $incfile = $fname;
                my $pos = rindex( $incfile, "\\");
                substr( $incfile, $pos+1 ) = $2;
                }
            else {
                $incfile = $2;
                }
            &loadscript( $incfile );
            next;
            }

        if( $TAGS{ $lab } ) {
            print "  --Duplicate LABEL: '$lab', script terminated\n"; 
            exit;
            }

        $TAGS{ $lab } = $line_no;   # save the tag's name
        $_ = $2;                    # strip off the label
        if( $DEBUG > 2 ) { print "|$_| - after stripping label\n"; }
        }

    if( /^\s*$/ ) {                 # the line now has only blanks
        if( $DEBUG > 2 ) { print "  -- blank line, skipped\n"; }
        next;                       # skip over blank lines
        }
    $script[ $line_no++ ] = $_;     # save the script line, icr $line_no only for lines that are stored
    }
close($SFILE);
}


###################################################################################
#          second pass control loop - execute the script                          #
###################################################################################
sub runscript {
#   globals: $G,  %TAGS, $aux_on, $venus_speed, $pport_out, $hwd_out, $hwd_in, $stroke_sns, @script, @SR, @CB
    local( $line_no );
    local( $CC ) = 0;
    local( @V, @P, @R ) = (undef, undef, undef);

    my $DEBUG = 0;

    my ( $k, $len, $jmp );
    my ( $me ) = undef;

    if( defined @_ ) {                                                    # running in a subroutine
        $me = $_[0];                                                           # save my subroutine name
        @P = @_;                                                               # tranfer the parms to an array, $P[0] = name, but it does not hurt

    if( $DEBUG > 0 ) {
        print "subroutine called\n";
        foreach my $i ( 0 .. $#P ) {
            print "parm $1 = $P[$i]\n";
            }
        }

        $line_no = -$TAGS{ $me };                                              # start with first line of subroutine
        if( $DEBUG > 0 ) { print "starting subroutine $_[0], line_no=$line_no\n"; }
        }
    else {                                                                # running at mainline level
        $line_no = 1;                                                          # assume we start script at line 1
        if( defined($TAGS{"main"} ) ) { $line_no = $TAGS{"main"}; }            # if a label of 'main' start there
        if( $DEBUG > 0 ) { print "running at mainline level, line_no=$line_no\n"; }
        }


    while(1) {
        if( my $msg = $IPC->read() ) {                                    #  if a message has been receive from the GUI
            $jmp = &onMsg($msg);                                                #  go process the message
            if( defined( $jmp ) ) {  return ($jmp);   }                         #  see if a branch is needed
            }
        &get_values();

    $_ = $script[ $k = $line_no++ ];                                           #  get next script line

    if( defined($me) ) {                         ########################## running at a subroutine level
        my $myname;
        if( $DEBUG > 1 ) { print "$myname $k |$_|\n"; }
        if( $DEBUG > 1 ) { print "checking subroutine only commands\n"; }
        if( /^return\s?(.*)$/ ) {                                             #  exit from subroutine, possible return values
            my $str = $1;
            my @RET = undef;
            while ( $str =~ /^([cghmprstvHL0-9\?\.]+)\s?/ ) {
                my $val = $1;
                $str = substr( $str, length($&) );
                push( @RET, &number( $val ) );
                } 
            if( $DEBUG > 0 ) {
                print "subroutine returning\n";
                foreach my $i ( 1 .. $#RET ) {
                    print "ret value $i = $RET[$i]\n";
                    }
                }
            return (@RET);
            }
        }

    else {                                       ######################## running at mainline level
        if( $DEBUG > 1 ) { print "$k |$_|\n"; }
        if( $DEBUG > 1 ) { print "checking mainline only commands\n"; }
        if( /^run (.+)$/ ) {                                                   #  run <filename> <filename> ...
            @ARGV = split( / /, $1);                                           #  run is not supported while in a subroutine
            return ("restart");                                                #  return indicating a restart is needed
            }
        if( /^end$/ ) {                                                        #  end
            $IPC->write( 9000, "end" );                                        #  signal GUI
            return ("stop pgm");                                               #  pass message up to caller
            }
        }
    my @RET = &process( $me );                                          #  process the next commend, commands valid anywhere
    if( defined( $RET[0] ) ) {                                                 #  see if a branch is needed
        if( $RET[0] eq "exit pgm" ) { return ("exit pgm"); }                   # if so, pass message up to caller
        if( $RET[0] eq "stop pgm" ) { return ("stop pgm"); }                   # if so, pass message up to caller
        if( $TAGS{ $RET[0] } < 0 )  { 
            @R  = &runscript( @RET );                                   #  a negative line number means target is subroutine
            if( defined( $R[0] ) ) {                                           #  see if an exit or stop message
                if( $R[0] eq "exit pgm" ) { return ("exit pgm"); }             # if so, pass message up to caller
                if( $R[0] eq "stop pgm" ) { return ("stop pgm"); }             # if so, pass message up to caller
                }
            }
        else  { 
            $line_no = $TAGS{ $RET[0] };                                #  otherwise an ordinary label at present level
            }
        }
    }    
}




###################################################################################
#        process a single command line                                            #
###################################################################################
sub process {                   #   $_[0]  is undef or the name of the currently executing subroutine

#   globals: $G,  %TAGS, $aux_on, $venus_speed, $aDOTS, $nDOTS, $pport_out, $hwd_out, $hwd_in, $stroke_sns, @SR, @CB
#   GLOBAL AT CURRENT LEVEL:  $V, $CC, $line_no
#   return value, if any, is jump/call string

    my $DEBUG = 0;

    my ( $prefix );

    if( defined($_[0] ) ) { $prefix = $_[0] . ":"; }
    else                  { $prefix = ""; }


    if( /^ESTIM get ([AB]) time$/ ) {                                       #  "ESTIM get A time"
        if( $1 eq "A" ) {  $V[1] = $SVi[1];  $V[2] = $SVi[2];  }
        else            {  $V[1] = $SVi[6];  $V[2] = $SVi[7];   }
        return;
        } 

    if( /^ESTIM get ([AB]) level$/ ) {                                      #  "ESTIM get A level"
        if( $1 eq "A" ) {  $V[1] = $SVi[3];  }
        else            {  $V[1] = $SVi[8];  }
        return;
        } 

    if( /^ESTIM get ([AB]) freq$/ ) {                                       #  "ESTIM get A freq"
        if( $1 eq "A" ) {  $V[1] = $SVi[4];  }
        else            {  $V[1] = $SVi[9];  }
        return;
        } 

    if( /^ESTIM get ([AB]) width$/ ) {                                      #  "ESTIM get A width"
        if( $1 eq "A" ) {  $V[1] = $SVi[5];  }
        else            {  $V[1] = $SVi[10];  }
        return;
        } 

    if( /^ESTIM set ([AB]) level ([cghmprstvHL0-9\?\.]+)$/ ) {              #  "ESTIM set A level 25"
        my $val = int( 0.50 + 127 * &number( $2 ) / 100 );
        my $cc;
        if( $1 eq "A" ) {  
            $cc = $et->set_A_max_level( $val ); 
            $cc += $et->set_A_min_level( $val ); 
            $cc += $et->set_A_level( $val ); 
            }
        else            {  
            $cc = $et->set_B_max_level( $val ); 
            $cc += $et->set_B_min_level( $val ); 
            $cc += $et->set_B_level( $val ); 
            }
        if( $cc != 3 ) { die "ESTIM level not able to be set\n"; }
        return;
        } 

    if( /^ESTIM set ([AB]) freq ([cghmprstvHL0-9\?\.]+)$/ ) {               #  "ESTIM set A freq 25"
        my $val = int( 0.50 + 247 * &number( $2 ) / 100 );
        my $cc;
        if( $1 eq "A" ) {  
            $cc = $et->set_A_max_freq( $val ); 
            $cc += $et->set_A_min_freq( $val ); 
            $cc += $et->set_A_freq( $val ); 
            }
        else            {  
            $cc = $et->set_B_max_freq( $val ); 
            $cc += $et->set_B_min_freq( $val ); 
            $cc += $et->set_B_freq( $val ); 
            }
        if( $cc != 3 ) { die "ESTIM freq not able to be set\n"; }
        return;
        } 

    if( /^ESTIM set ([AB]) width ([cghmprstvHL0-9\?\.]+)$/ ) {               #  "ESTIM set A width 25"
        my $val = int( 0.50 + 191 * &number( $2 ) / 100 );
        my $cc;
        if( $1 eq "A" ) {  
            $cc = $et->set_A_max_width( $val ); 
            $cc += $et->set_A_min_width( $val ); 
            $cc += $et->set_A_width( $val ); 
            }
        else            {  
            $cc = $et->set_B_max_width( $val ); 
            $cc += $et->set_B_min_width( $val ); 
            $cc += $et->set_B_width( $val ); 
            }
        if( $cc != 3 ) { die "ESTIM width not able to be set\n"; }
        return;
        } 

    if( /^ESTIM set ([AB]) time ([cghmprstvHL0-9\?\.]+) ([cghmprstvHL0-9\?\.]+)$/ ) {  #  "ESTIM set A time 50 50"
        my $on = int( 0.50 + 255 * &number( $2 ) / 100 );
        my $off = int( 0.50 + 255 * &number( $3 ) / 100 );
        my $cc;
        if( $1 eq "A" ) {  
            $cc = $et->set_A_time_on( $on ); 
            if( $cc == 0 ) { die "ESTIM time on not able to be set\n"; }
            $cc = $et->set_A_time_off( $off ); 
            if( $cc == 0 ) { die "ESTIM time off not able to be set\n"; }
            }
        else            {  
            $cc = $et->set_B_time_on( $on ); 
            if( $cc == 0 ) { die "ESTIM time on not able to be set\n"; }
            $cc = $et->set_B_time_off( $off ); 
            if( $cc == 0 ) { die "ESTIM time off not able to be set\n"; }
            }
        return;
        } 

    if( /^ESTIM ramp ([AB]) level ([cghmprstvHL0-9\?\.]+) ([cghmprstvHL0-9\?\.]+) ([cghmprstvHL0-9\?\.]+)$/ ) { #  "ESTIM ramp A level 25 50 20"
        my $min  = int( 0.50 + 127 * &number( $2 ) / 100 );
        my $max  = int( 0.50 + 127 * &number( $3 ) / 100 );
        my $rate = int( 0.50 + 255 * &number( $4 ) / 100 );
        my $cc;
        if( $1 eq "A" ) {  
            $cc = $et->set_A_max_level( $max ); 
            $cc += $et->set_A_min_level( $min ); 
            $cc += $et->set_A_level( $min ); 
            $cc += $et->set_A_level_rate( $rate ); 
            }
        else            {  
            $cc = $et->set_B_max_level( $max ); 
            $cc += $et->set_B_min_level( $min ); 
            $cc += $et->set_B_level( $min ); 
            $cc += $et->set_B_level_rate( $rate ); 
            }
        if( $cc != 4 ) { die "ESTIM level not able to be set\n"; }
        return;
        } 

    if( /^ESTIM ramp ([AB]) freq ([cghmprstvHL0-9\?\.]+) ([cghmprstvHL0-9\?\.]+) ([cghmprstvHL0-9\?\.]+)$/ ) {  #  "ESTIM ramp A freq 25 50 20"
        my $min  = int( 0.50 + 247 * &number( $2 ) / 100 );
        my $max  = int( 0.50 + 247 * &number( $3 ) / 100 );
        my $rate = int( 0.50 + 255 * &number( $4 ) / 100 );
        my $cc;
        if( $1 eq "A" ) {  
            $cc = $et->set_A_max_freq( $max ); 
            $cc += $et->set_A_min_freq( $min ); 
            $cc += $et->set_A_freq( $min ); 
            $cc += $et->set_A_freq_rate( $rate ); 
            }
        else            {  
            $cc = $et->set_B_max_freq( $max ); 
            $cc += $et->set_B_min_freq( $min ); 
            $cc += $et->set_B_freq( $min ); 
            $cc += $et->set_B_freq_rate( $rate ); 
            }
        if( $cc != 4 ) { die "ESTIM freq not able to be set\n"; }
        return;
        } 

    if( /^ESTIM ramp ([AB]) width ([cghmprstvHL0-9\?\.]+) ([cghmprstvHL0-9\?\.]+) ([cghmprstvHL0-9\?\.]+)$/ ) {  #  "ESTIM ramp A width 25 50 20"
        my $min  = int( 0.50 + 191 * &number( $2 ) / 100 );
        my $max  = int( 0.50 + 191 * &number( $3 ) / 100 );
        my $rate = int( 0.50 + 255 * &number( $4 ) / 100 );
        my $cc;
        if( $1 eq "A" ) {  
            $cc = $et->set_A_max_width( $max ); 
            $cc += $et->set_A_min_width( $min ); 
            $cc += $et->set_A_width( $min ); 
            $cc += $et->set_A_width_rate( $rate ); 
            }
        else            {  
            $cc = $et->set_B_max_width( $max ); 
            $cc += $et->set_B_min_width( $min ); 
            $cc += $et->set_B_width( $min ); 
            $cc += $et->set_B_width_rate( $rate ); 
            }
        if( $cc != 4 ) { die "ESTIM width not able to be set\n"; }
        return;
        } 

    if( /^ESTIM dramp ([AB]) level ([cghmprstvHL0-9\?\.]+) ([cghmprstvHL0-9\?\.]+) ([cghmprstvHL0-9\?\.]+)$/ ) { #  "ESTIM ramp A level 25 50 20"
        my $min  = int( 0.50 + 127 * &number( $2 ) / 100 );
        my $max  = int( 0.50 + 127 * &number( $3 ) / 100 );
        my $rate = int( 0.50 + 255 * &number( $4 ) / 100 );
        my $cc;
        if( $1 eq "A" ) {  
            $cc = $et->set_A_max_level( $max ); 
            $cc += $et->set_A_min_level( $min ); 
            $cc += $et->set_A_level( $max ); 
            $cc += $et->set_A_level_rate( $rate ); 
            }
        else            {  
            $cc = $et->set_B_max_level( $max ); 
            $cc += $et->set_B_min_level( $min ); 
            $cc += $et->set_B_level( $max ); 
            $cc += $et->set_B_level_rate( $rate ); 
            }
        if( $cc != 4 ) { die "ESTIM level not able to be set\n"; }
        return;
        } 

    if( /^ESTIM dramp ([AB]) freq ([cghmprstvHL0-9\?\.]+) ([cghmprstvHL0-9\?\.]+) ([cghmprstvHL0-9\?\.]+)$/ ) {  #  "ESTIM ramp A freq 25 50 20"
        my $min  = int( 0.50 + 247 * &number( $2 ) / 100 );
        my $max  = int( 0.50 + 247 * &number( $3 ) / 100 );
        my $rate = int( 0.50 + 255 * &number( $4 ) / 100 );
        my $cc;
        if( $1 eq "A" ) {  
            $cc = $et->set_A_max_freq( $max ); 
            $cc += $et->set_A_min_freq( $min ); 
            $cc += $et->set_A_freq( $max ); 
            $cc += $et->set_A_freq_rate( $rate ); 
            }
        else            {  
            $cc = $et->set_B_max_freq( $max ); 
            $cc += $et->set_B_min_freq( $min ); 
            $cc += $et->set_B_freq( $max ); 
            $cc += $et->set_B_freq_rate( $rate ); 
            }
        if( $cc != 4 ) { die "ESTIM freq not able to be set\n"; }
        return;
        } 

    if( /^ESTIM dramp ([AB]) width ([cghmprstvHL0-9\?\.]+) ([cghmprstvHL0-9\?\.]+) ([cghmprstvHL0-9\?\.]+)$/ ) {  #  "ESTIM ramp A width 25 50 20"
        my $min  = int( 0.50 + 191 * &number( $2 ) / 100 );
        my $max  = int( 0.50 + 191 * &number( $3 ) / 100 );
        my $rate = int( 0.50 + 255 * &number( $4 ) / 100 );
        my $cc;
        if( $1 eq "A" ) {  
            $cc = $et->set_A_max_width( $max ); 
            $cc += $et->set_A_min_width( $min ); 
            $cc += $et->set_A_width( $max ); 
            $cc += $et->set_A_width_rate( $rate ); 
            }
        else            {  
            $cc = $et->set_B_max_width( $max ); 
            $cc += $et->set_B_min_width( $min ); 
            $cc += $et->set_B_width( $max ); 
            $cc += $et->set_B_width_rate( $rate ); 
            }
        if( $cc != 4 ) { die "ESTIM width not able to be set\n"; }
        return;
        } 


    if( /^ESTIM options ([AB]) time ([cghmprstvHL0-9\?\.]+) ([cghmprstvHL0-9\?\.]+)$/ ) {  #  "ESTIM options A time 1 0"
        my $on  = &number( $2 );
        my $off = &number( $3 );
        my $cc;
        if( $1 eq "A" ) {  
            $cc  = $et->set_A_time_options( $on, $off );  # set the time options of channel A
            }
        else            {  
            $cc  = $et->set_B_time_options( $on, $off );  # set the time options of channel B
            }
        if( $cc != 1 ) { die "ESTIM time options not able to be set\n"; }
        return;
        } 
    if( /^ESTIM options ([AB]) level ([cghmprstvHL0-9\?\.]+) ([cghmprstvHL0-9\?\.]+)$/ ) {  #  "ESTIM options A level 1 0"
        my $min  = &number( $2 );
        my $rate = &number( $3 );
        my $cc;
        if( $1 eq "A" ) {  
            $cc  = $et->set_A_level_options( $min, $rate );  # set the level options of channel A
            }
        else            {  
            $cc  = $et->set_B_level_options( $min, $rate );  # set the level options of channel B
            }
        if( $cc != 1 ) { die "ESTIM level options not able to be set\n"; }
        return;
        } 
    if( /^ESTIM options ([AB]) freq ([cghmprstvHL0-9\?\.]+) ([cghmprstvHL0-9\?\.]+)$/ ) {  #  "ESTIM options A freq 1 0"
        my $val  = &number( $2 );
        my $rate = &number( $3 );
        my $cc;
        if( $1 eq "A" ) {  
            $cc  = $et->set_A_freq_options( $val, $rate );  # set the frequency options of channel A
            }
        else            {  
            $cc  = $et->set_B_freq_options( $val, $rate );  # set the frequency options of channel B
            }
        if( $cc != 1 ) { die "ESTIM freq options not able to be set\n"; }
        return;
        } 
    if( /^ESTIM options ([AB]) width ([cghmprstvHL0-9\?\.]+) ([cghmprstvHL0-9\?\.]+)$/ ) {  #  "ESTIM options A width 1 0"
        my $val  = &number( $2 );
        my $rate = &number( $3 );
        my $cc;
        if( $1 eq "A" ) {  
            $cc  = $et->set_A_width_options( $val, $rate );  # set the width options of channel A
            }
        else            {  
            $cc  = $et->set_B_width_options( $val, $rate );  # set the width options of channel B
            }
        if( $cc != 1 ) { die "ESTIM width options not able to be set\n"; }
        return;
        } 


    if( /^([gsv]\d+\-?\d*) = ([cghmprstvHL0-9\?\.]+)$/ ) {                             #    rr = ii  
        &set( $1, &number($2) );
        return;
        }

    if( /^([gsv]\d+\-?\d*) = ([cghmprstvHL0-9\?\.]+) \? ([cghmprstvHL0-9\?\.]+)$/ ) {   #    rr = ii ? ii
        my ($i, $j);
        $i = &number($2);
        $j = &number($3);
        if( $i == $j ) { &set( $1, $i ); }
        else           { &set( $1, sprintf("%d ? %d", $i, $j) ); }
        return;
        }

    if( /^([gsv]\d+\-?\d*) = ([cghmprstvHL0-9\?\.]+) \+ ([cghmprstvHL0-9\?\.]+)$/ ) {   #    rr = ii + ii
        $CC = &set( $1, &number($2) + &number($3) );
        return;
        }

    if( /^([gsv]\d+\-?\d*) = ([cghmprstvHL0-9\?\.]+) \- ([cghmprstvHL0-9\?\.]+)$/ ) {   #    rr = ii - ii
        $CC = &set( $1, &number($2) - &number($3) );
        return;
        }

    if( /^([gsv]\d+\-?\d*) = ([cghmprstvHL0-9\?\.]+) \* ([cghmprstvHL0-9\?\.]+)$/ ) {   #    rr = ii * ii
        $CC = &set( $1, &number($2) * &number($3) );
        return;
        }

    if( /^([gsv]\d+\-?\d*) = ([cghmprstvHL0-9\?\.]+) \/ ([cghmprstvHL0-9\?\.]+)$/ ) {   #    rr = ii / ii
        $CC = &set( $1, int( &number($2) / &number($3) ) );
        return;
        }

    if( /^([gsv]\d+\-?\d*) = ([cghmprstvHL0-9\?\.]+) \% ([cghmprstvHL0-9\?\.]+)$/ ) {   #    rr = ii % ii   (remainder of the division)
        $CC = &set( $1, ( &number($2) % &number($3) ) );
        return;
        }

    if( /^([cghmprstvHL0-9\?\.]+) \=\? ([cghmprstvHL0-9\?\.]+)$/ ) {             #    ii =? ii
        $CC = &number($1) - &number($2);
        if( $DEBUG > 2 ) { print "CC = $CC\n"; }
        return;
        }

    if( /^progress ([cghmprstvHL0-9\?\.]+)$/ ) {                                #    progress ii 
        my $k = &number( $1 );
        $k = &limit( $k, 0, 100 );
        $IPC->write( 9000, "progress $k" ); 
        return;
        }

    if( /^progresstext (.*)$/ ) {                                              #    progresstext <text> 
        my ($i); 
        $i = $1;
        $i =~ s/v(\d+)/$V[$1]/ge;                                              # convert variable references to values
        $i =~ s/g(\d+)/$G[$1]/ge;                                              # convert global variable references to values
        $IPC->write( 9000, "progresstext $i" ); 
        return;
        }

    if( /^count ([cghmprstvHL0-9\?\.]+) (\w+) (\w+)$/ ) {                      # count <value: 0-100> <text1> <text2>
        my $k = &number( $1 );
        my ($text1, $text2) = ($2, $3);
        $text1 =~ s/v(\d+)/$V[$1]/ge;                                              # convert variable references to values
        $text1 =~ s/g(\d+)/$G[$1]/ge;                                              # convert global variable references to values
        $text2 =~ s/v(\d+)/$V[$1]/ge;                                              # convert variable references to values
        $text2 =~ s/g(\d+)/$G[$1]/ge;                                              # convert global variable references to values      
        $k = &limit( $k, 0, 100 );
        $IPC->write( 9000, "count $k $text1 $text2" ); 
        return;
        }


    if( /^statusbar (.*)$/ ) {                                                 #    statusbar <text> 
        my ($i); 
        $i = $1;
        $i =~ s/v(\d+)/$V[$1]/ge;                                              # convert variable references to values
        $i =~ s/g(\d+)/$G[$1]/ge;                                              # convert global variable references to values
        $IPC->write( 9000, "statusbar $i" ); 
        return;
        }

    if( /^sleep ([cghmprstvHL0-9\?\.]+)$/ ) {                           #    sleep ii
        my ($dur, $i, $j, $k);
        $dur = 64 * &number( $1 );              # number of seconds to delay, approx 64 loops per second

        for( $i=0; $i < $dur; $i++ ) {
            if( my $msg = $IPC->read() ) {                                          #  if a message has been receive from the GUI
                $k = &onMsg($msg);                                                  #  go process the message
                if( defined($k) ) {  return ($k); }
                }
            &get_values();
            }
        return;                         # count <value: 0-100> <text1> <text2>
        }


    if( /^usleep ([cghmprstvHL0-9\?\.]+)$/ ) {                     #    usleep ii 
        my ($dur, $i, $j, $k);
        $dur = &number( $1 ) / 16000;         # the present value of the variable

        for( $i=0; $i < $dur; $i++ ) {
            if( my $msg = $IPC->read() ) {                                          #  if a message has been receive from the GUI
                $k = &onMsg($msg);                                                  #  go process the message
                if( defined($k) ) {  return ($k); }
                }
            &get_values();
            }
        return;
        }


    
    if( /^msg (.+)/ ) {                                                   #    msg <text>
        my ($i); 
        $i = $1;
        $i =~ s/v(\d+)/$V[$1]/ge;                                              # convert variable references to values
        $i =~ s/g(\d+)/$G[$1]/ge;                                              # convert global variable references to values
        $i =~ s/r(\d+)/$R[$1]/ge;                                              # convert return variable references to values
        $i =~ s/p(\d+)/$P[$1]/ge;                                              # convert parm variable references to values
        $i =~ s/\\n/\n/g;                                                      # convert \n to newlines
        $i =~ s/\\s/ /g;                                                       # convert \s to spaces
        $i =~ s/\\t/	/g;                                                    # convert \t to tabs
        print  "$i\n"; 
        return;
        }
    
    if( /^goto (.+)$/ ) {                                                 #    goto <label>
        if( $TAGS{ $prefix . $1 } )  { return ($prefix . $1); }                  #  if the label exists at the current level
        else  { die "$_ jumping to an unknown LABEL"; }
        }

    if( /^(call) (.+)$/ ) {                                                 #    call <label> <parms>
        my $str = $2;
        $str =~ /^(\w+)\s?/;
        my @RET = ( $1 );                     # strip out the LABEL or subroutine name
        $str = substr( $str, length($&) );
        while ( $str =~ /^([cghmprstvHL0-9\?\.]+)\s?/ ) {
            my $val = $1;
            $str = substr( $str, length($&) );
            push( @RET, &number( $val ) );
            } 

        if( $TAGS{ $RET[0] } < 0 )     {                              #  if exists as a subroutine
            if( $DEBUG > 0 ) {
                print "calling subroutine with:\n";
                foreach my $i ( 0 .. $#RET ) {
                    print "parm value $i = $RET[$i]\n";
                    }
                }
            return  (@RET); 
            }                             
        else  { die "$_ jumping to an unknown LABEL"; }
        }


    if( /^(if|if not) (eq|ne|gt|ge|lt|le|[cghmprstvHL0-9\?\.]+) (.+)$/ ) {       #    if [not] xx <label>
        if( $DEBUG > 2 ) { print "2nd if is evaluating $_$_:  1='$1', 2='$2', 3='$3'\n"; }
        my $cm   = 0;                                                 #    when invoking a subroutine, parms can be given
        my $met  = 1;                                           
        if( $1 eq "if not" )  {  $met = 0; }
        my $cond = $2;
        my $str  = $3;
        if   ( $cond eq "eq" )      { if( $CC == 0 ) { $cm = 1; } }
        elsif( $cond eq "ne" )      { if( $CC != 0 ) { $cm = 1; } }
        elsif( $cond eq "gt" )      { if( $CC >  0 ) { $cm = 1; } }
        elsif( $cond eq "ge" )      { if( $CC >= 0 ) { $cm = 1; } }
        elsif( $cond eq "lt" )      { if( $CC <  0 ) { $cm = 1; } }
        elsif( $cond eq "le" )      { if( $CC <= 0 ) { $cm = 1; } }
        elsif( $cond =~ /^([cghmprstvHL0-9\?\.]+)$/ ) {
            my $val = &number( $1 );
            if( $DEBUG > 2 ) { print "evaluating '$1' gave '$val'\n"; }
            if( $val > 0 ) { $cm = 1; }
            }
        else { die "illegal condition: $cond"; }

        if( $cm != $met ) { return; }

        $str =~ /^(\w+)\s?/;
        my @RET = ( $1 );                     # strip out the LABEL or subroutine name
        $str = substr( $str, length($&) );
        while ( $str =~ /^([cghmprstvHL0-9\?\.]+)\s?/ ) {
            my $val = $1;
            $str = substr( $str, length($&) );
            push( @RET, &number( $val ) );
            } 
        if( $TAGS{ $prefix . $RET[0] } > 0 )  { return $prefix . $RET[0]; }          #  if the label exists at the current level

        elsif( $TAGS{ $RET[0] } < 0 )     {                              #  if exists as a subroutine
            if( $DEBUG > 0 ) {
                print "calling subroutine with:\n";
                foreach my $i ( 0 .. $#RET ) {
                    print "ret value $i = $RET[$i]\n";
                    }
                }
            return  (@RET); 
            }                             
        else  { die "$_ jumping to an unknown LABEL"; }
        }



    if( /^when ([gsv]\d+) (.+)$/ ) {                                     #    when rr <label>
        my ($rr) = &number($1); 
        if(( $rr == 0 ) || ( time() < $rr )) { return; }                         #  if cleared, or time not reached
        &set( $1, 0 );                                                           #  clear rr, so it's a one time event 
        my $str = $2;
        $str =~ /^(\w+)\s?/;
        my @RET = ( $1 );                     # strip out the LABEL or subroutine name
        $str = $2;
        $str =~ /^(\w+)\s?/;
        @RET = ( $1 );                        # strip out the LABEL or subroutine name
        $str = substr( $str, length($&) );
        while ( $str =~ /^([cghmprstvHL0-9\?\.]+)\s?/ ) {
            my $val = $1;
            $str = substr( $str, length($&) );
            push( @RET, &number( $val ) );
            } 
        if( $TAGS{ $prefix . $RET[0] } > 0 )  { return $prefix . $RET[0]; }          #  if the label exists at the current level

        elsif( $TAGS{ $RET[0] } < 0 )     {                              #  if exists as a subroutine
            if( $DEBUG > 0 ) {
                print "calling subroutine with:\n";
                foreach my $i ( 0 .. $#RET ) {
                    print "ret value $i = $RET[$i]\n";
                    }
                }
            return  (@RET); 
            }                             
        else  { die "$_ jumping to an unknown LABEL"; }
        }


    die "$_ unknown line/command encountered"; 
    } 




###################################################################################
#           convert 'ii' references to a value.  called by &process               #
###################################################################################
sub number {
   my ( $v );

   if( $_[0] =~ m/^v(\d+)$/ ) {                # variable reference, unadorned
      $v = $V[ $1 ];
      if( $v =~ /^(\d+) \? (\d+)$/ ) { 
          if( $1 < $2 )  { return int( $1 + 0.5 + rand( $2 - $1 )); }
          return $1;
          }
      return $v;          
      }
   if( $_[0] =~ m/^p(\d+)$/ ) {                # parm reference, unadorned
      $v = $P[ $1 ];
      if( $v =~ /^(\d+) \? (\d+)$/ ) { 
          if( $1 < $2 )  { return int( $1 + 0.5 + rand( $2 - $1 )); }
          return $1;
          }
      return $v;          
      }
   if( $_[0] =~ m/^r(\d+)$/ ) {                # return value reference, unadorned
      $v = $R[ $1 ];
      if( $v =~ /^(\d+) \? (\d+)$/ ) { 
          if( $1 < $2 )  { return int( $1 + 0.5 + rand( $2 - $1 )); }
          return $1;
          }
      return $v;          
      }
   if( $_[0] =~ m/^c(\d+)$/ ) {                # checkbox reference
      $v = $CB[ $1 ];
      return $v;          
      }
   if( $_[0] =~ m/^s(\d+)$/ ) {                # slider reference
      $v = $SR[ $1 ];
      return $v;          
      }
   elsif( $_[0] =~ m/^v(\d+)H$/ ) {            # variable reference, adorned with 'H'
      $v = $V[ $1 ];
      if( $v =~ /^(\d+) \? (\d+)$/ ) { return $1; }
      return $v;          
      }
   elsif( $_[0] =~ m/^v(\d+)L$/ ) {            # variable reference, adorned with 'L'
      $v = $V[ $1 ];
      if( $v =~ /^(\d+) \? (\d+)$/ ) { return $2; }
      return $v;          
      }
   elsif( $_[0] =~ m/^g(\d+)$/ ) {             # global variable reference, unadorned
      $v = $G[ $1 ];
      if( $v =~ /^(\d+) \? (\d+)$/ ) { 
          if( $1 < $2 )  { return int( $1 + 0.5 + rand( $2 - $1 )); }
          return $1;
          }
      return $v;          
      }
   elsif( $_[0] =~ m/^g(\d+)H$/ ) {            # global variable reference, adorned with 'H'
      $v = $G[ $1 ];
      if( $v =~ /^(\d+) \? (\d+)$/ ) { return $1; }
      return $v;          
      }
   elsif( $_[0] =~ m/^g(\d+)L$/ ) {            # global variable reference, adorned with 'L'
      $v = $G[ $1 ];
      if( $v =~ /^(\d+) \? (\d+)$/ ) { return $2; }
      return $v;          
      }
   elsif( $_[0] =~ m/^(\d+)\?(\d+)$/ ) {       # random number
      if( $1 < $2 ) { return( $1 + int( rand( 1 + $2 - $1 ) ) ); }
      else { return $1; }
      }
   elsif( $_[0] =~ m/^(\d+)$/ ) {              # integer given
      $1;
      }
   elsif( $_[0] =~ m/^t$/ ) {                  # elasped time in seconds
      time();
      }
   elsif( $_[0] =~ m/^m(\d+\.?\d*)$/)  {       # convert minutes to seconds (fractional values allowed)
      int( $1 * 60 );
      }
   elsif( $_[0] =~ m/^h(\d+\.?\d*)$/)  {       # convert hours to seconds (fractional values allowed)
      int( $1 * 3600 );
      }

   else {
      die "illegal variable/number: $_[0]";
      }
   }



###################################################################################
#     process a message from GUI while running                                    #
###################################################################################
sub onMsg {
  my $DEBUG = 0;

  my $msg = $_[0];                                #  message that was received
  if( $DEBUG > 0 ) {print "received: $msg\n"; }

  if( $msg =~ /^slider (\d+) (\d+)$/ ) {                                     # slider values can be set while running
      $SR[ $1 ] = $2;
      if( $DEBUG > 0 ) {print "slider $1 set to: $SR[ $1 ]\n";}
      my $val = $2;
      if( $LINK{ "s$1" } =~ /^g(\d+)$/ ) { $G[ $1 ] = $val; }
      }
  elsif( $msg =~ /^checkbox (\d+) (\d+)$/ ) {                                # check box values can be set while running
      $CB[ $1 ] = $2;
      if( $DEBUG > 0 ) {print "checkbox $1 set to: $CB[ $1 ]\n";}
      }
  elsif( $msg eq "exit" )   {  return "exit pgm"; }
  elsif( $msg eq "stop" )   {  return "stop pgm"; }

  return undef;
  }
  

###################################################################################
#     set the value of a global or local variable                                 #
###################################################################################
sub set {
  my ($gv);

  if(  $_[0] =~ /^([gsv]{1})(\d+)$/  ) {    
      if( $1 eq "g" ) {
          $G[ $2 ] = $_[1];
          }
      elsif( $1 eq "v" ) { 
          $V[ $2 ] = $_[1];
          }
      elsif( $1 eq "s" ) { 
          $SR[ $2 ] = $_[1];
          $IPC->write( 9000, "slider $2 $_[1]" );        # send updated value to GUI
          my $val = $_[1];
          if( $LINK{ "s$2" } =~ /^g(\d+)$/ ) { $G[ $1 ] = $val; }
          }
      }

  elsif(  $_[0] =~ /^v(\d+)\-(\d+)$/  ) {                # a range of local variables
      my $i;
      for( $i=$1; $i<=$2; $i++ ) {
          $V[ $i ] = $_[1];
          }
      }

  else {
      die "Invalid variable destination specified: $_[0]";
      }
  }


#########################################################################
#           keep the values from the ESTIM uptodate on GUI              #
#########################################################################
sub get_values {
my $val;

if( ! defined($et)  ) {   return; }

my $DEBUG = $et->{DEBUG};   # save debug value
$et->{DEBUG} = 0;           # turn off during polling

if( $SV[0] == 1 ) {
   $val = $et->get_A_time_on();                    # get the TIME ON for channel A, $val=0-255, -1=error
   if(( $val >= 0 ) && ( $val != $SV[1] )) {
       $SV[1] = $val;
       $SVi[1] = $val = int( 0.50 + 100 * $val / 255 );
       $IPC->write( 9000, "slider 1 $val" );       # notify GUI
       }
   }
if( $SV[0] == 2 ) {
   $val = $et->get_A_time_off();                   # get the TIME OFF for channel A, $val=0-255, -1=error
   if(( $val >= 0 ) && ( $val != $SV[2] )) {
       $SV[2] = $val;
       $SVi[2] = $val = int( 0.50 + 100 * $val / 255 );
       $IPC->write( 9000, "slider 2 $val" );       # notify GUI
       }
   }
if( $SV[0] == 3 ) {
   $val = $et->get_A_level();                      # get the level of channel A, $val=0-127, -1=error
   if(( $val >= 0 ) && ( $val != $SV[3] )) {
       $SV[3] = $val;
       $SVi[3] = $val = int( 0.50 + 100 * $val / 127 );
       $IPC->write( 9000, "slider 3 $val" );       # notify GUI
       }
   }
if( $SV[0] == 4 ) {
   $val = $et->get_A_freq();                       # get the frequency for channel A, $val=8-255, -1=error
   if(( $val >= 0 ) && ( $val != $SV[4] )) {
       $SV[4] = $val;
       $SVi[4] = $val = int( 0.50 + (100 * $val / 247) );
       $IPC->write( 9000, "slider 4 $val" );       # notify GUI
       }
   }
if( $SV[0] == 5 ) {
   $val = $et->get_A_width();                      # get the pulse width for channel A, $val=0-191, -1=error
   if(( $val >= 0 ) && ( $val != $SV[5] )) {
       $SV[5] = $val;
       $SVi[5] = $val = int( 0.50 + 100 * $val / 191 );
       $IPC->write( 9000, "slider 5 $val" );       # notify GUI
       }


   }
if( $SV[0] == 6 ) {
   $val = $et->get_B_time_on();                 # get the TIME ON for channel B, $val=0-255, -1=error             
   if(( $val >= 0 ) && ( $val != $SV[6] )) {
       $SV[6] = $val;
       $SVi[6] = $val = int( 0.50 + 100 * $val / 255 );
       $IPC->write( 9000, "slider 6 $val" );       # notify GUI
       }
   }
if( $SV[0] == 7 ) {
   $val = $et->get_B_time_off();                 # get the TIME OFF for channel B, $val=0-255, -1=error             
   if(( $val >= 0 ) && ( $val != $SV[7] )) {
       $SV[7] = $val;
       $SVi[7] = $val = int( 0.50 + 100 * $val / 255 );
       $IPC->write( 9000, "slider 7 $val" );       # notify GUI
       }
   }
if( $SV[0] == 8 ) {
   $val = $et->get_B_level();                      # get the level of channel B, $val=0-127, -1=error
   if(( $val >= 0 ) && ( $val != $SV[8] )) {
       $SV[8] = $val;
       $SVi[8] = $val = int( 0.50 + 100 * $val / 127 );
       $IPC->write( 9000, "slider 8 $val" );       # notify GUI
       }
   }
if( $SV[0] == 9 ) {
   $val = $et->get_B_freq();                       # get the frequency for channel B, $val=8-255, -1=error
   if(( $val >= 0 ) && ( $val != $SV[9] )) {
       $SV[9] = $val;
       $SVi[9] = $val = int( 0.50 + 100 * $val / 247 );
       $IPC->write( 9000, "slider 9 $val" );       # notify GUI
       }
   }
if( $SV[0] == 10 ) {
   $val = $et->get_B_width();                      # get the pulse width for channel B, $val=0-191, -1=error
   if(( $val >= 0 ) && ( $val != $SV[10] )) {
       $SV[10] = $val;
       $SVi[10] = $val = int( 0.50 + 100 * $val / 191 );
       $IPC->write( 9000, "slider 10 $val" );       # notify GUI
       }
   }
$SV[0] += 1;
if( $SV[0] > 10 )  { $SV[0] = 1; }
$et->{DEBUG} = $DEBUG;   # restore debug value
}




