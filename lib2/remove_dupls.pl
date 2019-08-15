#!/usr/bin/perl
use strict;
use SiteDB;
     



sub MyMatch($$){
  my ($t1,$t2)=@_;

  $t1=~s/["']//g;
  $t2=~s/["']//g;

  $t1=trim($t1);
  $t2=trim($t2);
  my @A=split /[, -]/,  $t1;
  my @B=split /[, -]/,  $t2;

  my (%A,%B);
  foreach(@A){
    $A{$_}=1;
  }
  foreach(@B){
    $B{$_}=1;
  }
    
  my $i=0;
  my $size=@B;
  return  1    unless($size); 
  foreach(@A){
    $i++    unless($B{$_});

  }
  return $i/$size;

    
 

}

sub trim {
    @_ = @_ ? @_ : $_ if defined wantarray;
    
    for (@_ ? @_ : $_) { s/\A\s+//; s/\s+\z// }

    return wantarray ? @_ : "@_";
}

my $ref=$dbh->selectall_arrayref(q[SELECT lcase(of_name),of_id FROM out_firms]);    
my ($tmp1,$lev,$len,$tmp2,$okpo1,$okpo2,$lev1);
$TIMER->start('fizzbin');
my %hash=();

foreach(@$ref){
    $tmp1=$_->[0];
    $tmp1=~/\(?(\d+)\)?/;
    
    $okpo1=$1;

    $tmp1=~s/\({0,1}\d+\){0,1}//g;



    ##print "$_->[0] -> $tmp \n";
     foreach my $t (@$ref){
                $tmp2=$t->[0];
                $tmp2=~/\(?(\d+)\)?/;
                $okpo2=$1;
                $tmp2=~s/\(?\d+\)?//g;
                
                next unless($tmp2);

                $lev=MyMatch($tmp1,$tmp2);
                $lev1=MyMatch($tmp2,$tmp1)
                if($_->[1]!=$t->[1]&&!$hash{$t->[1]}&&!$lev&!$lev&&($okpo1 ne $okpo2)){
                    print "$_->[0] $_->[1] ($lev) -> $t->[0] $t->[1]\n";
                    $hash{$t->[1]}=1;
                
                }
                    
            
            
    }

    

}
print $TIMER->stop();
print "\n";

    
    
    sub levenshtein{
  my @A=split //, lc shift;
  my @B=split //, lc shift;
  my @W=(0..@B);
  my ($i, $j, $cur, $next);
  for $i (0..$#A){
        $cur=$i+1;
        for $j (0..$#B){
                $next=min(
                        $W[$j+1]+1,
                        $cur+1,
                        ($A[$i] ne $B[$j])+$W[$j]
                );
                $W[$j]=$cur;
                $cur=$next;
        }
        $W[@B]=$next;
  }
  return $next;
}
sub min{
  if ($_[0] < $_[2]){ pop @_; } else { shift @_; }
  return $_[0] < $_[1]? $_[0]:$_[1];
}
    
    
    
    





