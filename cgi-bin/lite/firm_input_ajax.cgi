#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../../lib';
use Lite::FirmInput2;
#use Data::Dumper;
#die Dumper \%ENV;
my $r=Lite::FirmInput2->new();
$r->{endTemplate} = 'firm_input_ok.html';
$r->run();
exit(0);
