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
die Dumper \%ENV;
my $aid = $cgi->param('a_id');
$aid = 407 unless($aid);                        

print "start $aid ...<br>\n";


my %used_tids = ();


my $sth0=$dbh->prepare("SELECT date(ct_date), date(ct_date) FROM accounts_reports WHERE ct_aid=? GROUP BY date(ct_date) ORDER BY ct_date");
$sth0->execute($aid);
while(my $row0 = $sth0->fetchrow_arrayref)
{          

  #my $sql = qq[select ('$start' + interval $i day), DATE_FORMAT(('$start' + interval $i day), '%d.%m.%Y')];
  #my $row = $dbh->selectrow_arrayref($sql,undef);
  my $date = $row0->[0];
  my $date_text = $row0->[1];

  #last if($date eq $finish);

  print "=======================================<br>\n";
  print "$date_text...<br>\n";
  

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

       push @cur_tids, $row2->{ct_tid} if($row2->{ct_tid});
       push @cur_tids, $row2->{ct_tid2} if($row2->{ct_tid2});       
       push @cur_tids, $row2->{ct_tid2_comis} if($row2->{ct_tid2_comis});
       push @cur_tids, $row2->{ct_tid2_ext_com} if($row2->{ct_tid2_ext_com});
     }elsif($row->{ct_ex_comis_type} eq 'simple'){
       my $row2 = $dbh->selectrow_hashref("SELECT * FROM exchange WHERE e_id=?", undef, $row->{ct_eid});

       push @cur_tids, $row2->{e_tid1} if($row2->{e_tid1});
       push @cur_tids, $row2->{e_tid2} if($row2->{e_tid2});       
     }

     print "-----------------<br>\n";
     print_hash($row);
     foreach my $tid(@cur_tids){
       my $row2 = $dbh->selectrow_hashref("SELECT * FROM transactions WHERE t_id=?", undef, $tid);

       print "<br><br>\n\n";
       print_hash($row2, "&nbsp;&nbsp;&nbsp;");

       $used_tids{$tid} = 1;
     }
     print "<br><br>\n\n";
      
   }
   $sth->finish();

}

print "/////////////////<br>\n";

   my $sth=$dbh->prepare("SELECT * FROM transactions WHERE ? in (t_aid1, t_aid2) ORDER BY t_id");
   $sth->execute($aid);
   while(my $row = $sth->fetchrow_hashref)
   {          
     next if($used_tids{$row->{t_id}});
     print_hash($row, "&nbsp;&nbsp;&nbsp;");
     print "<br>\n\n";
   }
   $sth->finish();



sub print_hash{
  my $hashref = shift;
  my $prefix = shift;

  foreach my $key(sort {$a cmp $b} (keys %$hashref)){
    print $prefix."$key = '$hashref->{$key}'<br>\n";
  }
}


