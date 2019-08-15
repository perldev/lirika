#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use lib '../../lib';
use Lite::InputDoc;
#use Data::Dumper;
#die Dumper \%ENV;
my $r=Lite::InputDoc->new();
$r->run();

exit(0);
