#!/usr/bin/perl
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use Data::Dumper;
use strict;

my $lib_path;
BEGIN{
  $lib_path="../lib";    
  $lib_path = $1.$lib_path if($0 =~ /^(.*[\\\/])/);
}
use lib "$lib_path";

use SiteDB;
use SiteCommon;
use CGIBase;

#####################################

print "Content-Type: text/html\n\n";


my $cgi = new CGI;
#my $aid = $cgi->param('a_id');
                        

my $out;


my $stha=$dbh->prepare("SELECT * FROM accounts ORDER BY a_id");
$stha->execute();
while(my $rowa = $stha->fetchrow_hashref)
{          

print ".";

my $aid = $rowa->{a_id};

$out = "";
$out .= "<br>**********************************************************<br>\nstart $aid ...<br>\n";


my %used_tids = ();
my %used_ctids = ();


my $sth0=$dbh->prepare("SELECT date(ct_date), date(ct_date) FROM accounts_reports WHERE ct_aid=? GROUP BY date(ct_date) ORDER BY ct_date");
$sth0->execute($aid);

my $out2="";

while(my $row0 = $sth0->fetchrow_arrayref)
{          

  #my $sql = qq[select ('$start' + interval $i day), DATE_FORMAT(('$start' + interval $i day), '%d.%m.%Y')];
  #my $row = $dbh->selectrow_arrayref($sql,undef);
  my $date = $row0->[0];
  my $date_text = $row0->[1];

  #last if($date eq $finish);

  $out2 .= "=======================================<br>\n";
  $out2 .= "$date_text...<br>\n";
  

   my $sth=$dbh->prepare("SELECT * FROM accounts_reports WHERE ct_aid=? and date(ct_date)=? ORDER BY ct_date");
   $sth->execute($aid, $date);
   while(my $row = $sth->fetchrow_hashref)
   {          
     my $type = $row->{ct_ex_comis_type};

     my @cur_tids = ();
     if($row->{ct_ex_comis_type} eq 'transaction'){
       push @cur_tids, $row->{ct_id};
     }elsif($row->{ct_ex_comis_type} eq 'input'){
       my $row2 = $dbh->selectrow_hashref("SELECT * FROM cashier_transactions WHERE ct_id=?", undef, $row->{ct_id});

       $used_ctids{$row->{ct_id}} = 1;

       push @cur_tids, $row2->{ct_tid} if($row2->{ct_tid});
       push @cur_tids, $row2->{ct_tid2} if($row2->{ct_tid2});       
       push @cur_tids, $row2->{ct_tid2_comis} if($row2->{ct_tid2_comis});
       push @cur_tids, $row2->{ct_tid2_ext_com} if($row2->{ct_tid2_ext_com});


       $row2 = $dbh->selectrow_hashref("SELECT * FROM exchange WHERE e_id=?", undef, $row->{ct_eid});
       if($row2){
         push @cur_tids, $row2->{e_tid1} if($row2->{e_tid1});
         push @cur_tids, $row2->{e_tid2} if($row2->{e_tid2});
       }

     }elsif($row->{ct_ex_comis_type} eq 'simple'){
       my $row2 = $dbh->selectrow_hashref("SELECT * FROM exchange WHERE e_id=?", undef, $row->{ct_eid});

       push @cur_tids, $row2->{e_tid1} if($row2->{e_tid1});
       push @cur_tids, $row2->{e_tid2} if($row2->{e_tid2});       
     }

     $out2 .= "-----------------<br>\n";
     $out2 .= print_hash($row);
     foreach my $tid(@cur_tids){
       my $row2 = $dbh->selectrow_hashref("SELECT * FROM transactions WHERE t_id=?", undef, $tid);

       $out2 .= "<br><br>\n\n";
       $out2 .= print_hash($row2, "&nbsp;&nbsp;&nbsp;");

       $used_tids{$tid} = 1;
     }
     $out2 .= "<br><br>\n\n";
      
   }
   $sth->finish();

}

my $out3="";
$out3 .= "// lost cashier_transactions ////////////<br>\n";


   my $sth=$dbh->prepare("SELECT * FROM cashier_transactions WHERE ct_aid=? ORDER BY ct_id");
   $sth->execute($aid);
   my $was_lct = 0;
   while(my $row2 = $sth->fetchrow_hashref)
   {          
     next if($used_ctids{$row2->{ct_id}});
     $out3 .= print_hash($row2);
     $out3 .= print "<br>\n\n";


     my @cur_tids; 
     push @cur_tids, $row2->{ct_tid} if($row2->{ct_tid});
     push @cur_tids, $row2->{ct_tid2} if($row2->{ct_tid2});       
     push @cur_tids, $row2->{ct_tid2_comis} if($row2->{ct_tid2_comis});
     push @cur_tids, $row2->{ct_tid2_ext_com} if($row2->{ct_tid2_ext_com});

     my $sum=0;
     foreach my $tid(@cur_tids){
       my $row3 = $dbh->selectrow_hashref("SELECT * FROM transactions WHERE t_id=?", undef, $tid);

       $out3 .= "<br><br>\n\n";
       $out3 .= print_hash($row3, "&nbsp;&nbsp;&nbsp;");

       if($row3->{t_aid1} == $aid){
         $sum -= $row3->{t_amnt};
       }else{
         $sum += $row3->{t_amnt};
       }

       $used_tids{$tid} = 1;
     }
     $out3 .= "<br>sum = <b>$sum</b><br><br>\n\n";

     $was_lct=1 if($sum != 0);

   }
   $sth->finish();

my $out4 = "";
$out4 .= "// lost transactions ///////////////<br>\n";

   my $sth=$dbh->prepare("SELECT * FROM transactions WHERE ? in (t_aid1, t_aid2) ORDER BY t_id");
   $sth->execute($aid);
   my $sum=0;
   while(my $row = $sth->fetchrow_hashref)
   {          
     next if($used_tids{$row->{t_id}});
     $out4 .= print_hash($row, "&nbsp;&nbsp;&nbsp;");
     $out4 .= "<br>\n\n";

       if($row->{t_aid1} == $aid){
         $sum -= $row->{t_amnt};
       }else{
         $sum += $row->{t_amnt};
       }       

   }
   $sth->finish();

   $out4 .= "<br>sum = <b>$sum</b><br><br>\n\n";


   print $out  if($sum!=0 || $was_lct);
   print $out3 if($was_lct);
   print $out4 if($sum!=0);


}
$stha->finish();



sub print_hash{
  my $hashref = shift;
  my $prefix = shift;

  my $res = "";

  foreach my $key(sort {$a cmp $b} (keys %$hashref)){
    $res .= $prefix."$key = '$hashref->{$key}'<br>\n";
  }

  return $res;
}


