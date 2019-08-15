#!/usr/bin/perl 
use FCGI;
use lib q(./lib);
use strict;
use RHP::Timer;
use Data::Dumper;

use POSIX 'setsid';
use POSIX ":sys_wait_h";
my $count = shift;
close(0);
close(1);
close(2);
exit(0) if(fork());
setsid();

use CGI::Carp qw(fatalsToBrowser);
require Oper::Ajax;

##using SCRIPT_NAME

        

##close sockets and kill the child processes
my $socket =undef;
$SIG{INT}=\&parent_handler;
$socket = FCGI::OpenSocket(":2013", 5); 

my $request = FCGI::Request(\*STDIN, \*STDOUT, \*STDERR, \%ENV, $socket);
my $kid;
my %pids_hash;
my $mutex_var=0;
##infin cycle for forking 
my $pid=1;

##creating number of processes in count 

print "Creating number of processes - $count \n";

for(my $i=0;($i<$count)&&$pid;$i++){
    defined($pid = fork) or &parent_handler("Не могу создать указанное количество процессов $!\n");
    $pids_hash{$pid}=1;
}


=pod
for(;$pid;){
        $pids_hash{$pid}=1;
        print "start work $pid \n";
        delete $pids_hash{$kid};
        $kid=wait;
        print "finishing work of $kid \n";
        defined($pid = fork) or &parent_handler("не могу создать процесс: $! \n");
}
=cut

###child process register their int handler
$SIG{INT}=\&chld_handler;
##the code of recieving the connections
my $TIMER;
$TIMER  = RHP::Timer->new();
if($request->Accept() >= 0) {
   $TIMER->start('fizzbin');
   $mutex_var=1;
   eval{ &ajax() };
  #  eval { Oper::CashierInputBefore->new->run };
	if($@){
	        print "Content-type: text/xml; charset=utf8\n\n";
		print $@;
		print "<br/>";
	        print "$_ => $ENV{$_} <br/>" foreach(keys %ENV);

	}
  
}

exit(0);

sub chld_handler{
  
   print "child destroer \n";
   exit(0) unless($mutex_var);
}

##for closing sockets
sub parent_handler{
   my $str=shift;
   FCGI::CloseSocket($socket) if($socket);
  
   print "$str \n"    if($str);
   print "My intepreter handler \n";
   $pids_hash{$pid}=1;
   print Dumper \%pids_hash;
   delete $pids_hash{$kid} if($kid);
   my $aa=kill(9,keys %pids_hash) if(keys %pids_hash);
   print "number of  killed processes $aa ,and number of started processes $count \n";
   print "if this number arent equel you shoud check and kill zombie processes by your self \n";
   print "finishing \n";
   exit(0);
}


sub ajax{
	my $fd=Oper::Ajax->new();
	$fd->run;
        undef($fd);
}


1;
