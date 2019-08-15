#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../../lib';
use Lite::Ajax;
my $r=Lite::Ajax->new();
$r->run();
exit(0);
