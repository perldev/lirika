#!/usr/bin/perl 
use FCGI;
use lib q(../lib);
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
#close(0);
#close(1);
#close(2);
  
use CGI::Carp qw(fatalsToBrowser);
require Oper::Accounts;
require Oper::Cash;
require Oper::DocsPayments;
require Oper::FirmInput2;
require Oper::FirmTrans;
require Oper::Transfers;
require Oper::CashierInputBefore;
require Oper::Rates;
require Oper::Class;
require Oper::Docs;
require Oper::FirmInput;
require Oper::FirmTransUSD;
require Oper::Transit;
require Oper::AccountsReports;
require Oper::CashierInput;
require Oper::Correctings;
require Oper::FirmOutput;
require Oper::EmailSettings;
require Oper::Index;
require Oper::Trans;
require Oper::AccountsReportsUSD;
require Oper::CashierOutput2;
require Oper::CreditLogs;
require Oper::Exchange;
require Oper::FirmsConv;
require Oper::Joke;
require Oper::Reports;
require Oper::Credits_Objections;
require Oper::FirmServices;
require Oper::Lost;
require Oper::CashierOutput;
require Oper::Credits;
require Oper::FactDocs;
require Oper::Firms;
require Oper::Notes;
require Oper::ReqFirms;
require Oper::Ajax;
require Oper::DayFirm;
require Oper::Operators;
require Oper::Settings;
require Lite::Ajax;
require Lite::FirmInput2;
require Lite::FirmOutput;
require Lite::InputDoc;


##using SCRIPT_NAME
my %REGISTER_HASH=(
	'/cgi-bin/lite/ajax.cgi'=>\&lite_ajax,
        '/cgi-bin/lite/firm_input2.cgi'=>\&lite_firm_input2,
        '/cgi-bin/lite/firm_output.cgi'=>\&lite_firm_output,
        '/cgi-bin/lite/inputdoc.cgi'=>\&lite_inputdoc,
	'/cgi-bin/notes.cgi'=>\&notes,
	'/cgi-bin/accounts.cgi'=>\&accounts,
	'/cgi-bin/accounts_reports.cgi'=>\&accounts_reports,
	'/cgi-bin/acusd.cgi'=>\&acusd,
	'/cgi-bin/ajax.cgi'=>\&ajax,
	'/cgi-bin/all_firms_list.cgi'=>\&all_firms_list,
	'/cgi-bin/cash.cgi'=>\&cash,
	'/cgi-bin/cashier_input_before.cgi'=>\&cashier_input_before,
	'/cgi-bin/cashier_input.cgi'=>\&cashier_input,
	'/cgi-bin/cashier_output2.cgi'=>\&cashier_output2,
	'/cgi-bin/cashier_output.cgi'=>\&cashier_output,
	'/cgi-bin/class.cgi'=>\&class,
	'/cgi-bin/conv.cgi'=>\&conv,
	'/cgi-bin/correctings.cgi'=>\&correctings,
	'/cgi-bin/credit_logs.cgi'=>\&credit_logs,
	'/cgi-bin/credits.cgi'=>\&credits,
	'/cgi-bin/credits_objections.cgi'=>\&credits_objections,
	'/cgi-bin/docs.cgi'=>\&docs,
	'/cgi-bin/docs_payments.cgi'=>\&docs_payments,
	'/cgi-bin/emails.cgi'=>\&emails,
	'/cgi-bin/exc.cgi'=>\&exc,
	'/cgi-bin/factdocs.cgi'=>\&factdocs,
	'/cgi-bin/firm_input2.cgi'=>\&firm_input2,
	'/cgi-bin/firm_input.cgi'=>\&firm_input,
	'/cgi-bin/firm_output.cgi'=>\&firm_output,
	'/cgi-bin/firms.cgi'=>\&firms,
	'/cgi-bin/firm_services.cgi'=>\&firm_services,
	'/cgi-bin/firmsusd.cgi'=>\&firmsusd,
	'/cgi-bin/firm_trans.cgi'=>\&firm_trans,
	'/cgi-bin/index.cgi'=>\&privet,
	'/cgi-bin/joke.cgi'=>\&joke,
	'/cgi-bin/login.cgi'=>\&login,
	'/cgi-bin/lost.cgi'=>\&lost,
	'/cgi-bin/operators.cgi'=>\&operators,
	'/cgi-bin/oper.cgi'=>\&oper,
	'/cgi-bin/rates.cgi'=>\&rates,
	'/cgi-bin/reports.cgi'=>\&reports,
	'/cgi-bin/req_firms.cgi'=>\&req_firms,
	'/cgi-bin/settings.cgi'=>\&settings,
	'/cgi-bin/trans.cgi'=>\&trans,
	'/cgi-bin/transit.cgi'=>\&transit,
	);

##close sockets and kill the child processes
my $socket =undef;
$SIG{INT}=\&parent_handler;
$socket = FCGI::OpenSocket(":2000", 5); 

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
for(;$pid;){
        $pids_hash{$pid}=1;
        print "start work $pid \n";
        delete $pids_hash{$kid};
        $kid=wait;
        print "finishing work of $kid \n";
        defined($pid = fork) or &parent_handler("не могу создать процесс: $! \n");
}

###child process register their int handler
$SIG{INT}=\&chld_handler;
##the code of recieving the connections
my $TIMER;
$TIMER  = RHP::Timer->new();
if($request->Accept() >= 0) {
   $TIMER->start('fizzbin');
   $mutex_var=1;
   eval{ $REGISTER_HASH{ $ENV{SCRIPT_NAME} }->() };
  #  eval { Oper::CashierInputBefore->new->run };
	if($@){
	        print "Content-type: text/html; charset=cp1251\n\n";
		print $@;
		print "<br/>";
	        print "$_ => $ENV{$_} <br/>" foreach(keys %ENV);

	}
    if($ENV{SCRIPT_NAME} ne  '/cgi-bin/ajax.cgi'&&$ENV{SCRIPT_NAME} ne  '/cgi-bin/lite/ajax.cgi'){
        print 'working time -';
        print  $TIMER->stop;
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

sub cashier_input_before{
    my $fd=Oper::CashierInputBefore->new();
    $fd->run;
    $fd=undef;
}

sub lite_ajax{
    my $fd=Lite::Ajax->new();
    $fd->run();
     undef($fd);
    
}
sub lite_firm_input2{
    my $fd=Lite::FirmInput2->new();
    $fd->run;
    undef($fd);
    
}
sub lite_firm_output{
     my $fd=Lite::FirmOutput->new();
    $fd->run;
     undef($fd);
}
sub lite_inputdoc{
    my $fd=Lite::InputDoc->new();
    $fd->run;
     undef($fd);
}
sub privet{
	my $fd=Oper::Index->new();
	$fd->run;
    undef($fd);
}
sub notes{
	my $fd=Oper::Notes->new();
	$fd->run;
    undef($fd);
	
}
sub accounts{

	my $fd=Oper::Accounts->new();
	$fd->run;
undef($fd);
}
sub accounts_reports{
	my $fd=Oper::AccountsReports->new();
	$fd->run;
    undef($fd);
}
sub acusd{
	my $fd=Oper::AccountsReportsUSD->new();
	$fd->run;
undef($fd);
}
sub ajax{
	my $fd=Oper::Ajax->new();
	$fd->run;
undef($fd);
}
sub all_firms_list{
	my $fd=Oper::DayFirm->new();
	$fd->run;
undef($fd);
}
sub cash{
	my $fd=Oper::Cash->new();
	$fd->run;
undef($fd);
}

sub cashier_input{
	my $fd=Oper::CashierInput->new();
	$fd->run;
undef($fd);
}
sub cashier_output2{
	my $fd=Oper::CashierOutput2->new();
	$fd->run;
    undef($fd);
}
sub cashier_output{
	my $fd=Oper::CashierOutput->new();
	$fd->run;
    undef($fd);
}
sub class{
	my $fd=Oper::Class->new();
	$fd->run;
    undef($fd);
}
sub conv{
	my $fd=Oper::FirmsConv->new();
	$fd->run;
    undef($fd);
}
sub  correctings{
	
	my $fd=Oper::Correctings->new();
	$fd->run;
    undef($fd);
}
sub credit_logs{
	my $fd=Oper::CreditLogs->new();
	$fd->run;
    undef($fd);
}
sub credits{
	my $fd=Oper::Credits->new();
	$fd->run;
    undef($fd);
}
sub credits_objections{
	my $fd=Oper::Credits_Objections->new();
	$fd->run;
    undef($fd);
}
sub docs{
	my $fd=Oper::Docs->new();
	$fd->run;
    undef($fd);
}
sub docs_payments{
	
	my $fd=Oper::DocsPayments->new();
	$fd->run;
    undef($fd);
}
sub emails{
	my $fd=Oper::EmailSettings->new();
	$fd->run;
    undef($fd);
}
sub exc{

	my $fd=Oper::Exchange->new();
	$fd->run;
    undef($fd);
}
sub factdocs{
	my $fd=Oper::FactDocs->new();
	$fd->run;
    undef($fd);

}
sub firm_input2{
	my $fd=Oper::FirmInput2->new();
	$fd->run;
    undef($fd);
}
sub firm_input{
	my $fd=Oper::FirmInput->new();
	$fd->run;
    undef($fd);
}
sub firm_output{
	my $fd=Oper::FirmOutput->new();
    $fd->run;
    undef($fd);

}
sub  firms{
	my $fd=Oper::Firms->new;
    $fd->run();
    undef($fd);
}
    
sub  firm_services{
	my $fd=Oper::FirmServices->new;
    $fd->run();
    undef($fd);
}	
sub  firmsusd{
	my $fd=Oper::FirmTransUSD->new();
    $fd->run();
    undef($fd);
}
sub  firm_trans{
	my $fd=Oper::FirmTrans->new;
    $fd->run();
    undef($fd);

}
sub joke{
    my $fd=Oper::Joke->new;
    $fd->run();
    undef($fd);
}
sub lost{
	my $fd=Oper::Lost->new;
    $fd->run(); 
    undef($fd);
}
sub operators{
	my $fd=Oper::Operators->new;
    $fd->run();
    undef($fd);
}
sub oper{
	my $r=Oper::Trans->new();
	$r->run();
    undef($r);
}
sub plugin{
	my $fd=Oper::PlugIn->new;
    $fd->run();
    undef($fd);
}
sub rates{
	my $fd=Oper::Rates->new;
    $fd->run();
    undef($fd);

}
sub reports{
	my $fd=Oper::Reports->new;
    $fd->run();
    undef($fd);
}
sub req_firms{
	my $fd=Oper::ReqFirms->new;
    $fd->run();
    undef($fd);
}
sub settings{
	my $fd=Oper::Settings->new;
    $fd->run();
    undef($fd);

}
sub trans{
	my $fd=Oper::Transfers->new;
    $fd->run();
    undef($fd);
}
sub transit{
	my $fd=Oper::Transit->new;
    $fd->run();
    undef($fd);
}


1;
