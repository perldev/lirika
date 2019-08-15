#!/usr/bin/perl
use strict;
use lib qw(../lib);
use CGI::Carp qw(fatalsToBrowser);
use Oper::Trans;
my $r=Oper::Trans->new();
$r->run();
