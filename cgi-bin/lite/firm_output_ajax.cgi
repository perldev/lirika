#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../../lib';

use Lite::FirmOutput;
my $r=Lite::FirmOutput->new();
$r->{endTemplate} = 'firm_input_ok.html';
$r->run();
exit(0);
