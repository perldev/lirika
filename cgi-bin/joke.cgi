#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);

use lib '../lib';

use Oper::Joke;
Oper::Joke->new->run;

exit(0);
