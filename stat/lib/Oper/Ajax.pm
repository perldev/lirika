package Oper::Ajax;
use strict;
use base 'CGIBase';
use SiteConfig;
use SiteDB;
use SiteCommon;
#use lib $PMS_PATH;
use POSIX;
#this  package needing the checking of all params

sub setup
{
  my $self = shift;
  
  $self->run_modes(
    'firms_money_exchange'=>'firms_money_exchange',
    'delta_balance'=>'delta_balance',
    'delta_balance_spents'=>'delta_balance_spents',
    );
}
sub delta_balance_spents
{
  my $self=shift;
    my $year=$self->query->param('year');
    my $month=$self->query->param('month');
    my %months_count=(
		      1=>31,
		      2=>28,
		      3=>31,
		      4=>30,
		      5=>31,
		      6=>30,
		      7=>31,
		      8=>31,
		      9=>30,
		      10=>31,
		      11=>30,
		      12=>31
		      );
        $month=int($month);
	$year=int($year);
    return "<root></root>" if(!$year);
    my $month_obj;
    
    if($month){
      
      $month_obj="MONTH(cr_ts)=$month";
    }else{
      $month_obj=" 1 ";
    }
    
    
    my $sth=$dbh->prepare(" SELECT
			    DATE(cr_ts) as xxx,
			    TIMESTAMPDIFF(day,cr_last_ts,cr_ts) as c,
			      -1*(cr_delta_eur-cr_income_eur) as eur,
			      -1*(cr_delta_usd-cr_income_usd) as usd,
			      -1*(cr_delta_uah-cr_income_uah) as uah,
			     
			    DAY(cr_ts) as day
			    FROM
			    reports_without
			    WHERE
			    cr_status='created'
			    AND
			    $month_obj
			    AND YEAR(cr_ts)=?  ORDER BY cr_ts ASC ");
    
      if($month){
	my $count=$months_count{$month};
	return "<root></root>" unless($count);
	$month_obj="MONTH(sr_date)=$month"
    }
      
    my $rates=$dbh->selectall_hashref("SELECT * FROM system_rates WHERE $month_obj
			    AND YEAR(sr_date)=$year ",'sr_date');

    $sth->execute($year);
    
    
    if($month){
      my $count=$months_count{$month};
      return "<root></root>" unless($count);
      $month_obj="MONTH(sr_date)<=$month"
    }
    my @ar;
    my $prev_day=0;
    my $tmp=0;
    my $prev_rate=$dbh->selectrow_hashref(qq[SELECT sr_uah_nal,sr_uah_domi, sr_eur_nal,sr_eur_domi,sr_date
					  FROM system_rates WHERE
			    $month_obj
			    AND YEAR(sr_date)<=? AND DAY(sr_date)<=1
			    ORDER BY sr_id DESC LIMIT 1
			     ],
			     undef,$year);
    $rates->{$prev_rate->{sr_date}}=\$prev_rate;
    
    my $prev_date;

    while(my $row=$sth->fetchrow_hashref()){
        $tmp=$row->{day}-$prev_day;
	unless($rates->{$row->{xxx}})
	{
	  $prev_rate=$rates->{$row->{xxx}};
	  $row->{yyy}=$prev_rate->{sr_uah_domi}*$row->{uah}+$prev_rate->{sr_eur_domi}*$row->{eur}+$row->{usd};
	 
	}else{
	  $row->{yyy}=$prev_rate->{sr_uah_domi}*$row->{uah}+$prev_rate->{sr_eur_domi}*$row->{eur}+$row->{usd};
        }
	$row->{xxx}=date_add_day($row->{xxx},1)  if($prev_date eq $row->{xxx});
	
	
	$prev_date=$row->{xxx};
	##if($tmp>1){
	  ##  for(my $i=0;$i<$tmp;$i++){
	        
		push @ar,$row;
	   # }
	
#	}else{
#		push @ar,$row;
#	}
        
      
      
    }
    
=pod
    +-----------------+---------------------------+------+-----+---------------------+----------------+
| Field           | Type                      | Null | Key | Default             | Extra          |
+-----------------+---------------------------+------+-----+---------------------+----------------+
| cr_id           | int(11)                   | NO   | PRI | NULL                | auto_increment |
| cr_ts           | timestamp                 | NO   |     | CURRENT_TIMESTAMP   |                |
| cr_comments     | varchar(255)              | YES  |     | NULL                |                |
| cr_xml_detailes | mediumblob                | YES  |     | NULL                |                |
| cr_last_ts      | timestamp                 | NO   |     | 0000-00-00 00:00:00 |                |
| cr_tids         | text                      | YES  |     | NULL                |                |
| cr_status       | enum('created','deleted') | YES  |     | created             |                |
| cr_delta_usd    | double(12,2)              | YES  |     | 0.00                |                |
| cr_delta_eur    | double(12,2)              | YES  |     | 0.00                |                |
| cr_delta_uah    | double(12,2)              | YES  |     | 0.00                |                |
| cr_income_usd   | double(12,2)              | YES  |     | NULL                |                |
| cr_income_eur   | double(12,2)              | YES  |     | NULL                |                |
| cr_income_uah   | double(12,2)              | YES  |     | NULL                |                |
| cr_system_state | mediumblob                | YES  |     | NULL                |            
=cut

    my $tmpl=$self->load_tmpl('vector.xml');
    $self->{tpl_vars}->{rows}=\@ar;
    my $output;
    $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
    return $output;

}
sub delta_balance
{
    my $self=shift;
    my $year=$self->query->param('year');
    my $month=$self->query->param('month');
    my %months_count=(
		      1=>31,
		      2=>28,
		      3=>31,
		      4=>30,
		      5=>31,
		      6=>30,
		      7=>31,
		      8=>31,
		      9=>30,
		      10=>31,
		      11=>30,
		      12=>31
		      );
        $month=int($month);
	$year=int($year);
    return "<root></root>" if(!$year);
    my $month_obj;
    
    if($month){
      
      $month_obj="MONTH(cr_ts)=$month";
    }else{
      $month_obj=" 1 ";
    }
    my $sth=$dbh->prepare(" SELECT
			    DATE(cr_ts) as xxx,
			    TIMESTAMPDIFF(day,cr_last_ts,cr_ts) as c,
			    cr_delta_usd,
			    cr_delta_eur,
			    cr_delta_uah,
			    DAY(cr_ts) as day
			    FROM
			    reports_without
			    WHERE
			    cr_status='created'
			    AND
			    $month_obj
			    AND YEAR(cr_ts)=?  ORDER BY cr_ts ASC ");
    
     if($month){
	my $count=$months_count{$month};
	return "<root></root>" unless($count);
	$month_obj="MONTH(sr_date)=$month"
    }
      
    
    my $rates=$dbh->selectall_hashref("SELECT * FROM system_rates WHERE $month_obj
			    AND YEAR(sr_date)=$year ",'sr_date');

    $sth->execute($year);
  
    my @ar;
    my $prev_day=0;
    my $tmp=0;
	  
	if($month){
	  my $count=$months_count{$month};
	  return "<root></root>" unless($count);
	  $month_obj="MONTH(sr_date)<=$month"
	}
    
    my $prev_rate=$dbh->selectrow_hashref(qq[SELECT sr_uah_nal,sr_uah_domi, sr_eur_nal,sr_eur_domi,sr_date FROM system_rates WHERE
			    $month_obj
			    AND YEAR(sr_date)<=? AND DAY(sr_date)<=1
			    ORDER BY sr_id DESC LIMIT 1
			     ],
			     undef,$year);
    $rates->{$prev_rate->{sr_date}}=\$prev_rate;
    
    my $prev_date;

    while(my $row=$sth->fetchrow_hashref()){
        $tmp=$row->{day}-$prev_day;
	unless($rates->{$row->{xxx}})
	{
	  $prev_rate=$rates->{$row->{xxx}};
	  $row->{yyy}=$prev_rate->{sr_uah_domi}*$row->{cr_delta_uah}+$prev_rate->{sr_eur_domi}*$row->{cr_delta_eur}+$row->{cr_delta_usd};
	 
	}else{
	  $row->{yyy}=$prev_rate->{sr_uah_domi}*$row->{cr_delta_uah}+$prev_rate->{sr_eur_domi}*$row->{cr_delta_eur}+$row->{cr_delta_usd};
        }
	$row->{xxx}=date_add_day($row->{xxx},1)  if($prev_date eq $row->{xxx});
	
	
	$prev_date=$row->{xxx};
	##if($tmp>1){
	  ##  for(my $i=0;$i<$tmp;$i++){
	        
		push @ar,$row;
	   # }
	
#	}else{
#		push @ar,$row;
#	}
        
      
      
    }
    
=pod
    +-----------------+---------------------------+------+-----+---------------------+----------------+
| Field           | Type                      | Null | Key | Default             | Extra          |
+-----------------+---------------------------+------+-----+---------------------+----------------+
| cr_id           | int(11)                   | NO   | PRI | NULL                | auto_increment |
| cr_ts           | timestamp                 | NO   |     | CURRENT_TIMESTAMP   |                |
| cr_comments     | varchar(255)              | YES  |     | NULL                |                |
| cr_xml_detailes | mediumblob                | YES  |     | NULL                |                |
| cr_last_ts      | timestamp                 | NO   |     | 0000-00-00 00:00:00 |                |
| cr_tids         | text                      | YES  |     | NULL                |                |
| cr_status       | enum('created','deleted') | YES  |     | created             |                |
| cr_delta_usd    | double(12,2)              | YES  |     | 0.00                |                |
| cr_delta_eur    | double(12,2)              | YES  |     | 0.00                |                |
| cr_delta_uah    | double(12,2)              | YES  |     | 0.00                |                |
| cr_income_usd   | double(12,2)              | YES  |     | NULL                |                |
| cr_income_eur   | double(12,2)              | YES  |     | NULL                |                |
| cr_income_uah   | double(12,2)              | YES  |     | NULL                |                |
| cr_system_state | mediumblob                | YES  |     | NULL                |            
=cut

    my $tmpl=$self->load_tmpl('vector.xml');
    $self->{tpl_vars}->{rows}=\@ar;
    my $output;
    $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
    return $output;

      
   
   
}
sub get_right
{
	return 'index';
}

1;
