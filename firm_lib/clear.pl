#!/usr/bin/perl

my $str=shift;
open(FL,">$str");
my @arr=<FL>;
close(FL);
open(FL,">$str__");
foreach(@arr)
{
    $_=~s/[\^M]//g;
    print  FL $_;

}
close(FL);


