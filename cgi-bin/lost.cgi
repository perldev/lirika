#/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
#use lib '../lib';

#use Oper::Lost;
Oper::Lost->new->run;

exit(0);
