#/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
#use lib '../lib';
#use Oper::Chat;
Oper::Chat->new->run;

exit(0);
