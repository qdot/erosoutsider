# estim.inc

#---------------------------------------------------------------------------------------
#   specify which package supports your serial port
#---------------------------------------------------------------------------------------

# Device::SerialPort;                  # MAC or Linux
use Win32::SerialPort;                 # Windows OS         


our $SetReadInterval = 1;              # change to 0 to omit the call to 'read_interval();
our $MaxHello = 5;                     # maximim number of "hello" messages to send before giving up

#---------------------------------------------------------------------------------------
#   specify which serial ports on your machine are available to use
#
#  $port in the new() call, selects which of these to use, an array is used so you 
#  can drive more than one ESTIM device if you wish.
#---------------------------------------------------------------------------------------

our @CommPorts = ( "COM0", "COM1", "COM2" );     #  Windows OS
#  our @CommPorts = ( "/dev/ttyS0", "/dev/ttyS1", "/dev/ttyS2" );     #  Linux or MAC, adjust as needed

1;

