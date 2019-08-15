#!/usr/bin/perl
use strict;
use lib '../lib';
use SiteDB;
my (%hash_uah_usd,%hash_eur_usd);

get_hash_of_rates(\%hash_uah_usd,\%hash_eur_usd);
my $str=q(INSERT INTO system_rates(sr_uah_nal,sr_eur_nal,sr_eur_domi,sr_date) VALUES);

foreach(keys %hash_uah_usd)
{
    
    $str="$str($hash_uah_usd{$_},$hash_eur_usd{$_},$hash_eur_usd{$_},'$_'),";

}
chop($str);
$dbh->do(qq($str));

exit(0);

sub get_hash_of_rates
{
    my ($hash_uah_usd,$hash_eur_usd)=@_;

    my @u;

    open(FL,'usd');

    @u=<FL>;

    close(FL);

    my @debug;
    foreach(@u)
    {
    
        my $tmp=$_;
        next unless($tmp);

        $tmp=~s/[ ]+|\t/ /g;
        $tmp=~s/[ ]+/ /g;
        push @debug,$tmp;
    
        my @t=split(/ /,$tmp);
     
        get_date(\$t[0]);
        get_rate(\$t[2]);
         unless($t[2])
         {
             die $_;
             die "inner $_";
         }
        

        $hash_uah_usd->{$t[0]}=1/$t[2];
       }  
       #  print (@debug == keys %$hash_uah_usd);
       
        @u=();
        @debug=();

        open(FL,'eur');

        @u=<FL>;

          close(FL);
          foreach(@u)
          {
        
                my $tmp=$_;

                $tmp=~s/[ ]+|\t/ /g;

                $tmp=~s/[ ]+/ /g;

                push @debug,$tmp;
                next unless($tmp);
                my @t=split(/ /,$tmp);
            
                get_date(\$t[0]);
                get_rate(\$t[2]);
                unless($t[2])
                {
                 
                    die "inner $_";
                }
                $hash_eur_usd->{$t[0]}=($hash_uah_usd->{$t[0]}/(1/$t[2]) );
                #print "$t[0] - $t[2] - $hash_eur_usd->{$t[0]} \n";
           }  
      
       # print (@debug == keys %$hash_eur_usd);
}
sub get_rate
{
    my $ref=shift;
    my $tmp=$ref;
    $$ref=~/\((.+)\)/;
    $$ref=$1;
    

}
sub get_date
{
    my $d=shift;

    $$d=~/(\d+)\.(\d+)\.(\d+)|(\d+)\/(\d+)\/(\d+)/;
        my $tmp;

    if($1)
    {
         $tmp+=$3;
         $tmp+=2000 if($tmp<1900);
         $$d="$tmp-$2-$1";
        return ;    

    }
    
    if($4)
    {
        $tmp=$6;

        $tmp+=2000 if($tmp<1900);

        $$d="$tmp-$5-$4";
        return ;

    }

}
