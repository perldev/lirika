#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../lib';
use Oper::Cash;
my $r=Oper::Cash->new();
$r->{cash}='kiev';
$r->run;

exit(0);
