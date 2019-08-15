#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use Data::Dumper;                                                                                                                                            
use lib '../lib';

use Oper::Index;
#die Dumper \%ENV; 
my $d = Oper::Index->new();
#die Dumper $d;
$d->run();

exit(0);
