#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);

use lib '../../lib';

use Lite::FirmOutput;
Lite::FirmOutput->new->run;

exit(0);
