#!/usr/bin/perl
use strict;
use lib qw(../firm_lib);
use CGI::Carp qw(fatalsToBrowser);
=pod
use Template;
use CGI qw(:standard);
print header(-type=>'text/html',
             -charset=>'cp1251');
my $template = Template->new(
     {
       INCLUDE_PATH => '../tmpl',
	INTERPOLATE  => 1,               # expand "$var" in plain text
        POST_CHOMP   => 1,               # cleanup whitespace 
        EVAL_PERL    => 1,       
     }
   );
#$template->process('login.html');
#exit(0);
=cut
use Oper::Index;
my $r=Oper::Index->new();
$r->run();
