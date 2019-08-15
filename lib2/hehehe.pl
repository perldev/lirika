#!/usr/bin/perl
use SiteDB;
use strict;
my $ref=$dbh->selectall_arrayref(q[SELECT 
    dr_id,dr_aid,sum(dp_amnt) FROM documents_requests,documents_payments  WHERE 
    dr_status='processed'  AND dp_drid=dr_id AND dr_close_tid=0
    GROUP BY dr_id
    ]);


foreach(@$ref)
{
    my $ref1=$dbh->selectall_arrayref(q[SELECT t_id,t_comment 
    FROM transactions WHERE t_aid2=?],undef,$_->[1]);
    
    print " \n FOR dr_id => $_->[0],dr_aid=>$_->[1],dr_amnt=>$_->[2]- ";    
    foreach my $tmp (@$ref1)
    {
       if( $tmp->[1]=~/[ ]?закрытие сделки[^#]+#([\d]+)[^\d]+$/&&$_->[0]==$1)
       {
            print " $tmp->[0] $1 ";
            $dbh->do(q[UPDATE documents_requests SET dr_close_tid=? WHERe dr_id=?],undef,$tmp->[0],$1);
            last;
            

       }

    }



}
print " \n ";   