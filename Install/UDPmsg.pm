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

package IPC::UDPmsg;
use Socket;


#  new takes a single parm:  the port# we will listen on
sub new {
   shift;                  # first parm is package name
   my $port = shift;       # get the number of the port we listen on
   my $self = {};          # create an empty object
   my $proto  = getprotobyname('udp') ||  die "getprotobyname: cannot get proto : $!";
   $self->{PORT} = $port;
   $self->{IADDR} = Socket::inet_aton('127.0.0.1');
   socket($self->{SOCK}, AF_INET, SOCK_DGRAM, $proto)	|| die "socket: $!";
   my $servaddr = Socket::sockaddr_in( $port, $self->{IADDR} );
   bind($self->{SOCK}, $servaddr ) || die "bind: $!";
   bless $self;
   return $self;
   }


#  read will return a packet, if available, or undef.  read is non-blocking
sub read {
   my $self = shift;
   if( $self->canread() == 0 )  {
       return undef;
       }
   my $message;
   my $from = recv ($self->{SOCK}, $message, 320, 0);
   my $i = $! + 0; 
   if( $! && $i != 10054 )  {
        die "error receiving message: $i $!\n"; 
        }
   if( $i == 10054 ) { return undef; }
   my ($p, $adr) = Socket::sockaddr_in( $from );
   $self->{FROM} = $p;
   return $message;
   }


#  canread will test to see if a packet is available.  return >0 if yes
sub canread {
   my $self = shift;
   my ($rin, $win, $ein) = ('','','');
   vec($rin, fileno($self->{SOCK}), 1 ) = 1;
   $ein = $rin | $win;
   my $i = select( $rin, $win, $ein, 0);
   if( $i < 0 )  {
        my $j = $! + 0;        
        print "error receiving message: $j $!\n"; 
        next; 
        }
   return $i;
   }


# write will send a packet to another process, the parm is the port to send the packet to
sub write {
   my $self = shift;
   my $port = shift;
   my $xmsg = shift;
   my $servaddr = Socket::sockaddr_in($port, $self->{IADDR} );
   send ($self->{SOCK}, $xmsg, 0, $servaddr) || die "error sending message: $!";
   }


# from return the port number of who sent the last read packet
sub from {
   my $self = shift;
   return $self->{FROM};
   }
1;



