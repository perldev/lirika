#/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
#use lib '../lib';
#use Oper::Firewall;
Oper::Firewall->new->run;

exit(0);
