#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../lib';
use Oper::PlugIn;
my $r=Oper::PlugIn->new();
$r->run;
exit(0);
