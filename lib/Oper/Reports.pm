package Oper::Reports;
use strict;
use base 'CGIBase';
use SiteConfig;
use SiteDB;
use SiteCommon;
use GD; 
use CGI::Carp qw(fatalsToBrowser);
use Data::Dumper;
use POSIX;
use ReportsProcedures;
use Storable qw( &nfreeze &thaw );


my $Y_WIDTH_GRID=52;
my $MONTH_COUNT=12;

##cards k1,k2,k3
our @years=(
            {year=>2006},
            {year=>2007},
            {year=>2008},
            {year=>2009},
            {year=>2010},
            {year=>2011},
            {year=>2012},
  	    {year=>2013},
            {year=>2014},
            {year=>2015},
            {year=>2016},
            {year=>2017},
	    {year=>2018},
            {year=>2019},
            {year=>2020},
            {year=>2021},
            );
my %month=(
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
           12=>31,
            );


my $proto;
my $_POST={};
##classes used for static classes

sub get_right
{
        my $self=shift;
        $_POST={};
        map{$_POST->{$_}=trim($self->query->param($_))} $self->query->param();
        $_POST->{currencies}=$self->{tpl_vars}->{currencies};
        $proto={
        fields=>
        [
                                
                        {'field'=>"t_ts", "title"=>"Дата", 'filter'=>"time"},
                        {'field'=>"currency", "title"=>"Из валюты", "type"=>"select", "titles"=>[
                                        {'value'=>"UAH", 'title'=>"UAH",},
                                        {'value'=>"USD", 'title'=>"USD"},
                                        {'value'=>"EUR", 'title'=>"EUR"}
                                        ]
                        , 
                        'filter'=>"="
                        }
        
        ]
        };
        return 'report';
}

sub setup 
{
        my $self=shift;
       
        $self->start_mode('empty');
        $self->run_modes(
                        'AUTOLOAD'   =>'empty',
                        'users'   =>'users',
                        'firms'   =>'firms',
                        'services'=>'services',
                        'cash_table'=>'cash_table',
                        'get_image'=>'get_image',
                        'operators'=>'operators',
			'view_report'=>'view_report',
			'view_report_without'=>'view_report_without',
			'delete_report'=>'delete_report',
			'save_report_without'=>'save_report_without',
			'common_report_without'=>'common_report_without',
			'common_report_without_list'=>'common_report_without_list',
			'balance'=>'balance',
			'delete_report_without'=>'delete_report_without',
                        'recalc_report'=>'recalc_report',
                        'get_accounts_income'=>'get_accounts_income',
                        'get_list_accounts_income'=>'get_list_accounts_income',
       );      



}

sub get_list_accounts_income{
        my $self=shift;
        my ($sec,$min,$hour,$mday,$mon,$year1,$wday,$yday,$isdst) = localtime(time);

        my $month=$self->query->param('date_month');
        $month= $mon+1       unless($month);
        my $year=$self->query->param('date_year');
        $year=$year1+1900     unless($year);
        
        my $sort=$self->query->param('sort');

        require ReportsProcedures;
        my $non_us=$ReportsProcedures::non_usual_class;
        my $s=$dbh->selectall_hashref(qq[SELECT a_id FROM accounts_view WHERE a_class IN ($non_us)],'a_id');
        my $calc_aid=$dbh->selectall_hashref(qq[SELECT a_id,a_name 
                                                FROM accounts 
                                                WHERE a_acid=$MAIN_CLIENT_CATEGORY],'a_id');

        

        my $non_aid=join(',',keys %{$s});

        my $aid=join(',',keys %{$calc_aid});

        $month=int($month);

        my $filter=();
      
        my $sum_u=$dbh->selectall_hashref(qq[SELECT t_aid1 as d,sum(t_amnt) as m
                                            FROM transactions 
                                            WHERE t_currency='UAH' 
                                            AND t_aid1 IN ($aid)  AND t_aid2 IN ($non_aid)
                                            AND t_aid2 NOT IN ($firms_id,$exchange_id) AND t_aid2 NOT IN 
                                            (SELECT co_aid FROM cash_offices)
                                            AND MONTH(t_ts)=$month
                                            AND YEAR(t_ts)=$year
                                            GROUP BY d ORDER BY d DESC
                                            ],'d');





  


        my $sum_e=$dbh->selectall_hashref(qq[
                                            SELECT t_aid1 as d,sum(t_amnt) as m
                                            FROM transactions WHERE t_currency='USD' 
                                            AND t_aid1 IN ($aid)
                                            AND t_aid2 IN  ($non_aid) AND t_aid2 NOT IN 
                                            (SELECT co_aid FROM cash_offices)
                                            AND t_aid2 NOT IN ($firms_id,$exchange_id)    
                                            AND MONTH(t_ts)=$month
                                            AND YEAR(t_ts)=$year
                                            GROUP BY d ORDER BY d DESC
                                            ],'d');
    
        my $sum_sd=$dbh->selectall_hashref(qq[SELECT t_aid1 as d,sum(t_amnt) as m
                                            FROM transactions WHERE t_currency='EUR'
                                            AND t_aid1 IN ($aid)
                                            AND t_aid2 IN ($non_aid)
                                            AND t_aid2 NOT IN ($firms_id,$exchange_id) AND t_aid2 NOT IN 
                                            (SELECT co_aid FROM cash_offices)
                                            AND MONTH(t_ts)=$month
                                            AND YEAR(t_ts)=$year
                                            GROUP BY d ORDER BY DAYOFMONTH(t_ts) ASC
                                            ],'d');
    
        my $sum_u2=$dbh->selectall_hashref(qq[SELECT t_aid2 as d ,sum(t_amnt) as m
                                            FROM transactions WHERE t_currency='UAH'
                                            AND t_aid2 IN ($aid)
                                            AND t_aid1 IN ($non_aid)
                                            AND t_aid1 NOT IN ($firms_id,$exchange_id) AND t_aid1 NOT IN 
                                            (SELECT co_aid FROM cash_offices)
                                            AND MONTH(t_ts)=$month 
                                            AND YEAR(t_ts)=$year
                                            GROUP BY d ORDER BY DAYOFMONTH(t_ts) ASC
                                            ],'d');
    
        my $sum_e2=$dbh->selectall_hashref(qq[SELECT t_aid2 as d,sum(t_amnt) as m
                                            FROM transactions WHERE t_currency='USD' 
                                            AND t_aid2 IN ($aid)
                                            AND t_aid1 IN ($non_aid)
                                            AND t_aid1 NOT IN ($firms_id,$exchange_id) AND t_aid1 NOT IN 
                                            (SELECT co_aid FROM cash_offices)
                                            AND MONTH(t_ts)=$month
                                            AND YEAR(t_ts)=$year
                                            GROUP BY d ORDER BY DAYOFMONTH(t_ts) ASC
                                            ],'d');
    
        my $sum_sd2=$dbh->selectall_hashref(qq[SELECT t_aid2 as  d,sum(t_amnt) as m
                                                    FROM transactions WHERE 
                                                    t_currency='EUR'
                                                    AND t_aid2 IN ($aid)    
                                                    AND t_aid1 IN ($non_aid) 
                                                    AND t_aid1 NOT IN ($firms_id,$exchange_id) AND t_aid1 NOT IN 
                                                    (SELECT co_aid FROM cash_offices)
                                                    AND MONTH(t_ts)=$month
                                                    AND YEAR(t_ts)=$year
                                                    GROUP BY d ORDER BY DAYOFMONTH(t_ts) ASC
                                            ],'d');

        my $rates=$dbh->selectrow_hashref(qq[SELECT 
                                            sum(sr_uah_domi)/count(sr_uah_domi) as UAH,
                                            sum(sr_eur_domi)/count(sr_eur_domi) as EUR                                   
                                            FROM system_rates 
                                            WHERE 1 
                                            AND MONTH(sr_date)=$month 
                                            AND YEAR(sr_date)=YEAR(current_timestamp)]);
        my @a=();
        
        $rates=$dbh->selectrow_hashref(qq[SELECT sr_uah_domi as UAH,sr_eur_domi as EUR FROM system_rates  WHERE 1 AND MONTH(sr_date)<$month AND YEAR(sr_date)=$year ORDER BY sr_date ASC LIMIT 1]) unless($rates->{'UAH'});
        


        ###generate data for graph
        my $whole_sum=0;
        my @record;
        foreach my $d (keys %$calc_aid){
            my $sumu=0;
            my $day=$calc_aid->{$d};
            $sumu=-1*($sum_u2->{$d}->{m}-$sum_u->{$d}->{m})*$rates->{UAH};
            
            $sumu+=-1*($sum_e2->{$d}->{m}-$sum_e->{$d}->{m})*$rates->{EUR};
    
            $sumu+=-1*($sum_sd2->{$d}->{m}-$sum_sd->{$d}->{m});
    
            $whole_sum+=$sumu;
    
            push @record,{a_id=>$day->{a_id},a_name=>$day->{a_name},sum_real=>$sumu,sum=>format_float($sumu)}; 
        }

       if($sort){
            @record=sort { $a->{sum_real} <=> $b->{sum_real} }  @record ;
       }else{
            @record=sort { $b->{sum_real} <=> $a->{sum_real} }  @record ;
       }

        my @headers=(
         {run_mode=>'get_list_accounts_income','sort'=>($sort!=1),asc=>($sort==1),'name'=>'Сумма'},
        );


        $self->{tpl_vars}->{fields}=[{field=>'date','title'=>'Дата','filter'=>"date_month_year"}];
        $self->{tpl_vars}->{headers}=\@headers;
        $self->{tpl_vars}->{list}=\@record;

        $self->{tpl_vars}->{selected_year}=$year;
        $self->{tpl_vars}->{selected_month}=$month;

        $self->{tpl_vars}->{trans_list}->{'do'}->{value}='get_list_accounts_income';
     
        $self->{tpl_vars}->{title}='Статистика  дохода  по  карточкам';

        my $tmpl=$self->load_tmpl('reports_users_in.html');
        
        my $output='';
        $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
        return $output;

}

sub get_accounts_income{
    my $self=shift;
    my $aid=$self->query->param('a_id');
    my $month=$self->query->param('month');
    my $year=$self->query->param('year');

    require ReportsProcedures;
    my $non_us=$ReportsProcedures::non_usual_class;
    my $s=$dbh->selectall_hashref(qq[SELECT a_id FROM accounts_view WHERE a_class IN ($non_us)],'a_id');
    
    my $non_aid=join(',',keys %{$s});
    $aid=int($aid);
    $month=int($month);
    
    


    my $all_dates=$dbh->selectall_hashref(qq[SELECT 
                                            DAYOFMONTH(t_ts) as d,DAYOFWEEK(t_ts) as day_of_week,
                                            YEAR(t_ts) as year_of_ts,MONTH(t_ts) as month_of_ts,DATE(t_ts) as ts
                                            FROM transactions WHERE 1
                                            AND $aid IN (t_aid1,t_aid2)  
                                            AND MONTH(t_ts)=$month 
                                            AND YEAR(t_ts)=$year
                                            GROUP BY DAYOFMONTH(t_ts) ORDER BY DAYOFMONTH(t_ts) ASC
                                            ],'d');



    ##calculate only with USD exchanges
     my $exchanges=$dbh->selectall_hashref(qq[SELECT e_id,e_amnt1,e_amnt2,e_rate,e_currency1,e_currency2,
                                                     DAYOFMONTH(e_date) as d
                                                     FROM exchange_view 
                                                     WHERE a_id=$aid AND 
                                                     'USD' IN  (e_currency1,e_currency2)
                                                     AND e_status!='deleted'
                                                     AND e_type!='system'
                                                     AND MONTH(e_date)=$month
                                                     AND YEAR(e_date)=$year  
                                              ],'e_id');

     my $months=$dbh->selectall_hashref(qq[
                                            SELECT DAYOFMONTH(sr_date) as d,sr_uah_domi as UAH,sr_eur_domi as EUR FROM 
                                            system_rates 
                                            WHERE 1 
                                            AND MONTH(sr_date)=$month
                                            AND YEAR(sr_date)=$year
                                            ],'d');
      $months->{'1'}=$dbh->selectrow_hashref(qq[SELECT 1 as d,sr_uah_domi as UAH,sr_eur_domi as EUR FROM system_rates  WHERE 1 AND MONTH(sr_date)<$month AND YEAR(sr_date)<=$year ORDER BY sr_date ASC LIMIT 1]) unless($months->{'1'});
      my $prev=$months->{'1'};
      ##making rates  without empty fields
      foreach(1..$months_days{$month}){
              $months->{$_}=$prev   unless($months->{$_});
              $prev = $months->{$_};
      }
      #process exchanges separatly from other operations
      my $new_exchanges={};
     foreach(keys %$avail_currency){
                $new_exchanges->{$_}={};
     }

     foreach(keys %{$exchanges}){
            my $tmp=$exchanges->{$_};
            my $rates=$months->{ $tmp->{d} };

            if('UAH' eq $tmp->{e_currency1}){

                $new_exchanges->{UAH}->{ $tmp->{'d'} }+=abs( $tmp->{e_amnt1}*$rates->{UAH} - $tmp->{e_amnt1} * $tmp->{'e_rate'}  );
                
            }

            if('UAH' eq $tmp->{e_currency2}){
                
                $new_exchanges->{UAH}->{ $tmp->{'d'} }+=abs( $tmp->{e_amnt2}*$rates->{UAH} - $tmp->{e_amnt2} * (1/$tmp->{'e_rate'})  );

                
                
            }

            if('EUR' eq $tmp->{e_currency2}){
                
                $new_exchanges->{EUR}->{ $tmp->{'d'} }+=abs( $tmp->{e_amnt2}*(1/$rates->{EUR}) - $tmp->{e_amnt2} * $tmp->{'e_rate'}  );
                
                
            }
            if('EUR' eq $tmp->{e_currency1}){
                
                    
                $new_exchanges->{EUR}->{ $tmp->{'d'} }+=abs( $tmp->{e_amnt1}*$rates->{EUR} - $tmp->{e_amnt1} * $tmp->{'e_rate'}  );
                    
                
           }
    }

    my $sum_u=$dbh->selectall_hashref(qq[SELECT DAYOFMONTH(t_ts) as d,sum(t_amnt) as m
                                        FROM transactions WHERE t_currency='UAH' 
                                        AND t_aid1=$aid  AND t_aid2 IN ($non_aid)
                                        AND t_aid2 NOT IN ($firms_id,$exchange_id) AND t_aid2 NOT IN 
                                        (SELECT co_aid FROM cash_offices)
                                        AND MONTH(t_ts)=$month 
                                        AND YEAR(t_ts)=$year
                                        GROUP BY DAYOFMONTH(t_ts) ORDER BY DAYOFMONTH(t_ts) ASC    
                                        ],'d');

    my $sum_e=$dbh->selectall_hashref(qq[SELECT DAYOFMONTH(t_ts) as d,sum(t_amnt) as m
                                        FROM transactions WHERE t_currency='USD' 
                                        AND t_aid1=$aid AND t_aid2 IN ($non_aid) AND t_aid2 NOT IN 
                                        (SELECT co_aid FROM cash_offices)
                                        AND t_aid2 NOT IN ($firms_id,$exchange_id)    
                                        AND MONTH(t_ts)=$month
                                        AND YEAR(t_ts)=$year
                                         GROUP BY DAYOFMONTH(t_ts) ORDER BY DAYOFMONTH(t_ts) ASC
                                        ],'d');

    my $sum_sd=$dbh->selectall_hashref(qq[SELECT DAYOFMONTH(t_ts) as d,sum(t_amnt) as m
                                        FROM transactions WHERE t_currency='EUR'
                                        AND t_aid1=$aid AND t_aid2 IN ($non_aid)
                                        AND t_aid2 NOT IN ($firms_id,$exchange_id) AND t_aid2 NOT IN 
                                        (SELECT co_aid FROM cash_offices)
                                        AND MONTH(t_ts)=$month
                                        AND YEAR(t_ts)=$year
                                        GROUP BY DAYOFMONTH(t_ts) ORDER BY DAYOFMONTH(t_ts) ASC
                                        ],'d');
   
    my $sum_u2 = $dbh->selectall_hashref(qq[SELECT DAYOFMONTH(t_ts) as d ,sum(t_amnt) as m
                                        FROM transactions WHERE t_currency='UAH' 
                                        AND t_aid2=$aid  AND t_aid1 IN ($non_aid)
                                        AND t_aid1 NOT IN ($firms_id,$exchange_id) AND t_aid1 NOT IN 
                                        (SELECT co_aid FROM cash_offices)
                                        AND MONTH(t_ts)=$month 
                                        AND YEAR(t_ts)=$year
                                        GROUP BY DAYOFMONTH(t_ts) ORDER BY DAYOFMONTH(t_ts) ASC
                                        ],'d');

    my $sum_e2 = $dbh->selectall_hashref(qq[SELECT DAYOFMONTH(t_ts) as d,sum(t_amnt) as m
                                        FROM transactions WHERE t_currency='USD' 
                                        AND t_aid2=$aid AND t_aid1 IN ($non_aid)
                                        AND t_aid1 NOT IN ($firms_id,$exchange_id) AND t_aid1 NOT IN 
                                        (SELECT co_aid FROM cash_offices)
                                        AND MONTH(t_ts)=$month
                                        AND YEAR(t_ts)=$year
                                        GROUP BY DAYOFMONTH(t_ts) ORDER BY DAYOFMONTH(t_ts) ASC
                                        ],'d');

    my $sum_sd2=$dbh->selectall_hashref(qq[SELECT DAYOFMONTH(t_ts) as  d,sum(t_amnt) as m
                                                   FROM transactions WHERE t_currency='EUR'
                                                   AND t_aid2=$aid AND t_aid1 IN ($non_aid) 
                                                   AND t_aid1 NOT IN ($firms_id,$exchange_id) AND t_aid1 NOT IN 
                                                    (SELECT co_aid FROM cash_offices)
                                                   AND MONTH(t_ts)=$month
                                                   AND YEAR(t_ts)=$year
                                                   GROUP BY DAYOFMONTH(t_ts) ORDER BY DAYOFMONTH(t_ts) ASC
                                        ],'d');
    my $days=$months_days{$month};
        
    
    my @a=();
    
  
    
    ###generate data for graph
    my $whole_sum=0;
#    use Data::Dumper;
#    die Dumper $new_exchanges,$months;
    
    
    foreach my $day (1..$days){

           my @record=();
           next unless($all_dates->{$day});

           push @record,$day;
           my $rates=$months->{$day};


           my $sumu=0;

           $sumu=-1*($sum_u2->{$day}->{m}-$sum_u->{$day}->{m})*$rates->{UAH};
          
           $sumu+=-1*($sum_e2->{$day}->{m}-$sum_e->{$day}->{m})*$rates->{EUR};

           $sumu+=-1*($sum_sd2->{$day}->{m}-$sum_sd->{$day}->{m});
            
        
           $sumu+=$new_exchanges->{UAH}->{$day}*$rates->{UAH};
#
           $sumu+=$new_exchanges->{EUR}->{$day}*$rates->{EUR};

           $sumu+=$new_exchanges->{USD}->{$day};


           $whole_sum+=$sumu;

           push @record,$sumu; 
           push @record, $all_dates->{$day}->{day_of_week};
           push @record, $all_dates->{$day}->{year_of_ts};
           push @record, $all_dates->{$day}->{month_of_ts};
           push @a,\@record;

    }

    my $ref=month_graph(undef,undef,\@a);
    $whole_sum=format_float($whole_sum);
     my $ext_title="Vsego : $whole_sum";
    return $self->draw_image_rect($ref,{x=>680,y=>241,x_grid=>20,y_grid=>20},$ext_title);

}

sub recalc_report{
    my $self=shift;
    my $id=$self->query->param('id');
    my ($ts,$store,$tds)=$dbh->selectrow_array(q[SELECT DATE(cr_ts),cr_xml_detailes,cr_tids FROM reports_without  WHERE cr_status='created' AND cr_id=?],undef,$id);
    $self->header_type('redirect');

    unless($ts){
        return $self->header_add(-url=>'reports.cgi?do=common_report_without_list');
    }

    my @transes=split(/,/,$tds);
    foreach(@transes)
    {
        my $ref=$dbh->selectrow_hashref(q[SELECT * FROM transactions WHERE t_id=?],undef,$_);       
        my $tid = $self->add_trans({
        
                t_name1 =>$ref->{t_aid2},
                t_name2 =>$ref->{t_aid1},
                t_currency =>$ref->{t_currency}  ,
                t_amnt =>$ref->{t_amnt} ,
                t_comment =>"Откать :Распределение доходов между  основными карточками ",
            });
        $dbh->do(q[UPDATE  transactions SET t_status='no' WHERE t_id=?],undef,$_);
        $dbh->do(q[DELETE FROM accounts_reports_table WHERE ct_id=? AND ct_ex_comis_type='transaction'],undef,$_);

    }
    my %params = %{thaw($store)};
    my $rates=get_rates($ts);
    my $delta= { usd=> $params{delta_usd},eur=>$params{delta_eur},uah=>$params{delta_uah} };

    
    $delta->{incom_eur}=( $params{incom_eur} )*$rates->{eur};       
    $delta->{incom_uah}=( $params{incom_uah} )*$rates->{uah};
    $delta->{incom_usd}= $delta->{incom_eur} + $delta->{incom_uah} +$params{incom_usd} ;


    my $master_cards=$params{master_cards};

    my $conclusions_sum=$params{conclusions_sum};





    my $tids=$self->make_conclusion_without($conclusions_sum,$delta,{USD=>$master_cards->[1]->{USD},
    EUR=>$master_cards->[1]->{EUR},UAH=>$master_cards->[1]->{UAH} },681,$rates); 
    $delta->{usd}+=$delta->{eur}*$rates->{eur};                                                                             
    $delta->{usd}+=$delta->{uah}*$rates->{uah};  
    $dbh->do(q[UPDATE reports_without SET cr_tids=?,cr_delta_usd=?,cr_income_usd=? WHERE cr_id=?],undef,$tids,$delta->{usd},$delta->{incom_usd},$id);
    return $self->header_add(-url=>'reports.cgi?do=common_report_without_list');


}

sub balance
{
	my $self=shift;
  	my $tmpl=$self->load_tmpl('common_reports.html');
	my @last_ts=$dbh->selectrow_array(q[SELECT cr_ts FROM reports  WHERE cr_status='created' ORDER BY cr_id ASC LIMIT 1]);
 	my $permanent_cards=&get_permanent_cards();
	my $non_identifier=&get_non_identifier();
	my $firm_balances=&get_firms_balances();
	$self->{tpl_vars}->{permanent_cards}=$permanent_cards;	
	$self->{tpl_vars}->{non_identifier}=$non_identifier;
	$self->{tpl_vars}->{firm_balances}=$firm_balances;
# 	$self->{tpl_vars}->{work_money}=to_prec($firm_balances->[0]->{right_column}->{amnt});
	
# 	$self->{tpl_vars}->{whole_sum_with_commons}=to_prec($self->{tpl_vars}->{work_money}+0*$master_cards->[0]->{sum});
#	$self->{tpl_vars}->{last_sum_exc}=get_last_sum_exc_balance();
# 	$self->{tpl_vars}->{delta}= $firm_balances + $cash - $non_identifier - $permanent_cards;
        for my $c (@CURRENCIES){
            $self->{tpl_vars}->{"delta_".$c}= $firm_balances->[0]->{"amnt_".$c} + $firm_balances->[1]->{"amnt_".$c} - $permanent_cards->[0]->{"raw_sum_".$c} - $non_identifier->[0]->{"amnt_".$c};
 	}
	
	my $delta=$self->{tpl_vars}->{delta};
	$self->{tpl_vars}->{delta}=format_float($delta);
# 	my $conclusion_sums=get_concl_kcards($master_cards,$delta);
	$self->{tpl_vars}->{conclusions_sum}=0;
	


	
	my $page=$self->query->param('page');	
	
	$self->{tpl_vars}->{firms_balances}=format_float($firm_balances->[0]->{right_column}->{amnt});
# 	$self->{tpl_vars}->{non_ident}=format_float($non_identifier->[0]->{right_column}->{amnt});
# 	$self->{tpl_vars}->{cards}=format_float
# 	(
# 		$permanent_cards->[0]->{mines_column}->{amnt}+$permanent_cards->[0]->{plus_column}->{amnt}
# 	);


	##pages and others reports

		
	



	my $output='';
	my $date=$dbh->selectrow_array(q[SELECT current_timestamp]);
	$self->{tpl_vars}->{page_title}="Баланс за : $date, Баланс приведенный к USD: $delta";
	$self->{tpl_vars}->{date} = $date;
	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || 
        $tmpl->error();



        return $output;
}



sub common_report_list
{
	my $self=shift;
  	my $tmpl=$self->load_tmpl('common_reports_list.html');

		my $ref=$dbh->selectall_arrayref(qq[
				SELECT 
				SQL_CALC_FOUND_ROWS cr_id,cr_ts,	
				cr_comments,
				(
				DATEDIFF(cr_ts,cr_last_ts)-2*(
				WEEKOFYEAR(cr_ts) - 
				abs(52*( YEAR(cr_ts)-YEAR(cr_last_ts) ) - WEEKOFYEAR(cr_last_ts) ) )) as diff,cr_status,cr_delta
				FROM reports WHERE cr_status!='deleted' ORDER BY cr_id DESC
				]);

	my $count_pages=$dbh->selectrow_array('SELECT found_rows()');
	
	###other reports
	my @res;
	foreach(@$ref)
	{
		push @res,{
				id=>$_->[0],
				ts=>$_->[1],
				comments=>$_->[2],
				diff=>$_->[3],
				cr_status=>$_->[4],
				cr_delta=>format_float($_->[5])	
			  };	
			
	}	
	####
		$self->{tpl_vars}->{reports}=\@res;
	
	my $output='';
	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || 
        $tmpl->error();
        return $output;		

}

sub common_report_without_list
{
	my $self=shift;
  	my $tmpl=$self->load_tmpl('common_reports_without_list.html');
	my $ref=$dbh->selectall_arrayref(qq[
				SELECT 
				SQL_CALC_FOUND_ROWS cr_id,cr_ts,	
				cr_comments,
				(
				DATEDIFF(cr_ts,cr_last_ts)-2*(
				WEEKOFYEAR(cr_ts) - 
				abs(52*( YEAR(cr_ts)-YEAR(cr_last_ts) ) - WEEKOFYEAR(cr_last_ts) ) )) as diff,
				
				cr_status,cr_delta_usd,cr_delta_eur,cr_delta_uah,
				cr_income_usd,cr_income_eur,cr_income_uah
				FROM reports_without  WHERE cr_status='created'   ORDER BY cr_id DESC  
				]);

	my @res;
	my $od=1;
	foreach(@$ref)
	{
		push @res,{id=>$_->[0],
				ts=>format_date($_->[1]),
				comments=>$_->[2],
				diff=>$_->[3],
				cr_status=>$_->[4],
				cr_delta_usd=>format_float($_->[5]),	
				cr_delta_eur=>format_float($_->[6]),	
				cr_delta_uah=>format_float($_->[7]),
				cr_income_usd=>format_float($_->[8]),	
				cr_income_eur=>format_float($_->[9]),	
				cr_income_uah=>format_float($_->[10]),
				class=>$od=!$od,
				};	
			
	}	
	$self->{tpl_vars}->{reports}=\@res;
	
	my $output='';
	
	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || 
        
	$tmpl->error();
        
	return $output;
	
}


sub delete_report
{
	my $self=shift;
	my $id=$self->query->param('id');
	my $r=$dbh->selectrow_hashref(q[SELECT * FROM reports WHERE cr_id=? AND cr_status='created'],undef,$id);
	unless($r->{cr_status})
	{
		$self->header_type('redirect');
		return $self->header_add(-url=>'reports.cgi?do=common_report');
	}
	my @transes=split(/,/,$r->{cr_tids});
	foreach(@transes)
	{
		my $ref=$dbh->selectrow_hashref(q[SELECT * FROM transactions WHERE t_id=?],undef,$_);		
		my $tid = $self->add_trans({
		
			    t_name1 =>$ref->{t_aid2},
    			t_name2 =>$ref->{t_aid1},
      			t_currency =>$ref->{t_currency}  ,
      			t_amnt =>$ref->{t_amnt} ,
      			t_comment =>"Откать :Распределение доходов между  основными карточками ",
       		});
		$dbh->do(q[UPDATE  transactions SET t_status='no' WHERE t_id=?],undef,$_);
		$dbh->do(q[DELETE FROM accounts_reports_table WHERE ct_id=? AND ct_ex_comis_type='transaction'],undef,$_);

	}
	$dbh->do(q[UPDATE reports SET cr_status='deleted' WHERE cr_id=?],undef,$id);
	
	$self->header_type('redirect');
	return $self->header_add(-url=>'reports.cgi?do=common_report_list');

}

sub common_report_without
{
	my $self=shift;
  	my $tmpl=$self->load_tmpl('common_reports_without.html');
	my @last_ts=$dbh->selectrow_array(q[SELECT 
		cr_ts FROM reports_without  
		WHERE cr_status='created' ORDER BY cr_id DESC LIMIT 1]);
	my $state=restore_state();
	
         my $master_cards=&get_kcards_without($state,@last_ts);
	
	my $transfer_info=exclude_system_exchange(@last_ts);
	

#	my $transfer_info=get_transfer_operations_other_version(@last_ts);
	
	
	
	
#	my $permanent_cards=&get_permanent_cards_without();
#	die Dumper $permanent_cards;

	my $non_identifier=&get_non_identifier_without();

# 	my $pay_credits=&percent_payments();
	my $firm_balances=&get_firms_balances_without();
	
	my $permanent_cards=&get_permanent_cards_without();     
	
#	my $master_cards=&get_kcards_without(@last_ts);



	$self->{tpl_vars}->{permanent_cards}=$permanent_cards;
	$self->{tpl_vars}->{non_identifier}=$non_identifier;
#	$self->{tpl_vars}->{pay_credits}=$pay_credits;
	$self->{tpl_vars}->{firm_balances}=$firm_balances;
	$self->{tpl_vars}->{master_cards}=$master_cards;

	#work money splited into currencies
 	$self->{tpl_vars}->{work_money_usd}=to_prec(
	($permanent_cards->[0]->{plus_column}->{a_usd}+$permanent_cards->[0]->{mines_column}->{a_usd})-
	$non_identifier->[0]->{right_column}->{f_usd}+$firm_balances->[0]->{right_column}->{f_usd});
	
	$self->{tpl_vars}->{work_money_eur}=to_prec(
	($permanent_cards->[0]->{plus_column}->{a_eur}+$permanent_cards->[0]->{mines_column}->{a_eur})-
	$non_identifier->[0]->{right_column}->{f_eur}+$firm_balances->[0]->{right_column}->{f_eur});
	
	$self->{tpl_vars}->{work_money_uah}=to_prec(
	($permanent_cards->[0]->{plus_column}->{a_uah}+$permanent_cards->[0]->{mines_column}->{a_uah})-
	$non_identifier->[0]->{right_column}->{f_uah}+$firm_balances->[0]->{right_column}->{f_uah});
	#adding commons spencies 

	$self->{tpl_vars}->{whole_sum_with_commons_usd}=to_prec($self->{tpl_vars}->{work_money_usd}+$master_cards->[0]->{usd});
	$self->{tpl_vars}->{whole_sum_with_commons_uah}=to_prec($self->{tpl_vars}->{work_money_uah}+$master_cards->[0]->{uah});
	$self->{tpl_vars}->{whole_sum_with_commons_eur}=to_prec($self->{tpl_vars}->{work_money_eur}+$master_cards->[0]->{eur});
	###

	
	###
	$self->{tpl_vars}->{firms_balances_usd}=format_float($firm_balances->[0]->{right_column}->{f_usd});
	$self->{tpl_vars}->{firms_balances_eur}=format_float($firm_balances->[0]->{right_column}->{f_eur});
	$self->{tpl_vars}->{firms_balances_uah}=format_float($firm_balances->[0]->{right_column}->{f_uah});

	$self->{tpl_vars}->{non_ident_usd}=format_float($non_identifier->[0]->{right_column}->{f_usd});
	$self->{tpl_vars}->{non_ident_uah}=format_float($non_identifier->[0]->{right_column}->{f_uah});
	$self->{tpl_vars}->{non_ident_eur}=format_float($non_identifier->[0]->{right_column}->{f_eur});	
	$self->{tpl_vars}->{cards_usd}=format_float
	(
		$permanent_cards->[0]->{mines_column}->{a_usd}+$permanent_cards->[0]->{plus_column}->{a_usd}
	);
	$self->{tpl_vars}->{cards_eur}=format_float
	(
		$permanent_cards->[0]->{mines_column}->{a_eur}+$permanent_cards->[0]->{plus_column}->{a_eur}
	);
	$self->{tpl_vars}->{cards_uah}=format_float
	(
		$permanent_cards->[0]->{mines_column}->{a_uah}+$permanent_cards->[0]->{plus_column}->{a_uah}
	);



	$self->{tpl_vars}->{last_sum_exc}=get_last_sum_exc_without();



    $self->{tpl_vars}->{delta_usd}=to_prec($self->{tpl_vars}->{whole_sum_with_commons_usd}-$self->{tpl_vars}->{last_sum_exc}->{last_sum_exc_usd});
    $self->{tpl_vars}->{delta_uah}=to_prec($self->{tpl_vars}->{whole_sum_with_commons_uah}-$self->{tpl_vars}->{last_sum_exc}->{last_sum_exc_uah});
    $self->{tpl_vars}->{delta_eur}=to_prec($self->{tpl_vars}->{whole_sum_with_commons_eur}-$self->{tpl_vars}->{last_sum_exc}->{last_sum_exc_eur});
	
	

#	my $rates=get_rates();
	
	
#	use Data::Dumper;
#	die Dumper $transfer_info;
       $self->{tpl_vars}->{delta_usd}+=$transfer_info->{USD}; 
       $self->{tpl_vars}->{delta_eur}+=$transfer_info->{EUR};
       $self->{tpl_vars}->{delta_uah}+=$transfer_info->{UAH};

#       $self->{tpl_vars}->{delta_usd}+=$transfer_info->{comission}->{USD}; 
#       $self->{tpl_vars}->{delta_eur}+=$transfer_info->{comission}->{EUR};
#       $self->{tpl_vars}->{delta_uah}+=$transfer_info->{comission}->{UAH};
    
#	$self->{tpl_vars}->{delta_uah}=
#	$self->{tpl_vars}->{delta_eur}   
=pod	
	$self->{tpl_vars}->{delta_usd}+=$rates->{eur}*$self->{tpl_vars}->{delta_eur}+$rates->{uah}*$self->{tpl_vars}->{delta_uah};
	
        $self->{tpl_vars}->{delta_uah}=0;                                                                                      

        $self->{tpl_vars}->{delta_eur}=0;
=cut
	my $delta={ usd=> $self->{tpl_vars}->{delta_usd},eur=>$self->{tpl_vars}->{delta_eur},uah=>$self->{tpl_vars}->{delta_uah} };

	my ($conclusion_sums,$common)=get_concl_kcards_without($master_cards,$delta);
	                                                                                                                                                        
        $self->{tpl_vars}->{incom_usd}=format_float($self->{tpl_vars}->{delta_usd}+$common->{usd});                                                             
        $self->{tpl_vars}->{incom_eur}=format_float($self->{tpl_vars}->{delta_eur}+$common->{eur});                                                             
        $self->{tpl_vars}->{incom_uah}=format_float($self->{tpl_vars}->{delta_uah}+$common->{uah});                                                             
				          
				                                                                          
    


	$self->{tpl_vars}->{of_usd}=format_float($common->{usd});
	$self->{tpl_vars}->{of_eur}=format_float($common->{eur});
	$self->{tpl_vars}->{of_uah}=format_float($common->{uah});

	$self->{tpl_vars}->{conclusions_sum}=$conclusion_sums;				    	

	my $date=$dbh->selectrow_array(q[SELECT current_timestamp]);
	$self->{tpl_vars}->{page_title}="отчета за : $date,дельта : $self->{tpl_vars}->{delta_usd} USD,
	$self->{tpl_vars}->{delta_eur} EUR,дельта : $self->{tpl_vars}->{delta_uah} ГРН";
	$self->{tpl_vars}->{date}=$date;

	
	my $output='';
	
	
	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || 
        $tmpl->error();



        return $output;
}
sub save_report_without
{
	my $self=shift;
  	my $tmpl=$self->load_tmpl('common_reports_without.html');
	my @last_ts=$dbh->selectrow_array(q[SELECT 
		cr_ts FROM reports_without  
		WHERE cr_status='created' ORDER BY cr_id DESC LIMIT 1]);
   
        my $XML={};
        my $transfer_info=exclude_system_exchange(@last_ts);
#	my $transfer_info=get_transfer_operations_other_version(@last_ts);
#	map{ $XML->{$_}=$transfer_info->{$_} } keys %{$transfer_info};
	# my $static_cards=&get_static_cards(@last_ts);
 	my $permanent_cards=&get_permanent_cards_without();
	my $non_identifier=&get_non_identifier_without();
# 	my $pay_credits=&percent_payments();
	my $firm_balances=&get_firms_balances_without();
	my $state=restore_state();
        my $master_cards=&get_kcards_without($state,@last_ts);
	
	$XML->{permanent_cards}=$permanent_cards;
	$XML->{non_identifier}=$non_identifier;
#	$XML->{pay_credits}=$pay_credits;
	$XML->{firm_balances}=$firm_balances;
	$XML->{master_cards}=$master_cards;

	#work money splited into currencies
 	$XML->{work_money_usd}=to_prec(
	($permanent_cards->[0]->{plus_column}->{a_usd}+$permanent_cards->[0]->{mines_column}->{a_usd})-
	$non_identifier->[0]->{right_column}->{f_usd}+$firm_balances->[0]->{right_column}->{f_usd});
	
	$XML->{work_money_eur}=to_prec(
	($permanent_cards->[0]->{plus_column}->{a_eur}+$permanent_cards->[0]->{mines_column}->{a_eur})-
	$non_identifier->[0]->{right_column}->{f_eur}+$firm_balances->[0]->{right_column}->{f_eur});
	
	$XML->{work_money_uah}=to_prec(
	($permanent_cards->[0]->{plus_column}->{a_uah}+$permanent_cards->[0]->{mines_column}->{a_uah})-
	$non_identifier->[0]->{right_column}->{f_uah}+$firm_balances->[0]->{right_column}->{f_uah});
	#adding commons spencies 

	$XML->{whole_sum_with_commons_usd}=to_prec($XML->{work_money_usd}+$master_cards->[0]->{usd});
	$XML->{whole_sum_with_commons_uah}=to_prec($XML->{work_money_uah}+$master_cards->[0]->{uah});
	$XML->{whole_sum_with_commons_eur}=to_prec($XML->{work_money_eur}+$master_cards->[0]->{eur});
	###
	
#	use Data::Dumper;
#	die Dumper $master_cards;

	###
	$XML->{firms_balances_usd}=format_float($firm_balances->[0]->{right_column}->{f_usd});
	$XML->{firms_balances_eur}=format_float($firm_balances->[0]->{right_column}->{f_eur});
	$XML->{firms_balances_uah}=format_float($firm_balances->[0]->{right_column}->{f_uah});
	$XML->{non_ident_usd}=format_float($non_identifier->[0]->{right_column}->{f_usd});
	$XML->{non_ident_uah}=format_float($non_identifier->[0]->{right_column}->{f_uah});
	$XML->{non_ident_eur}=format_float($non_identifier->[0]->{right_column}->{f_eur});	
	$XML->{cards_usd}=format_float
	(
		$permanent_cards->[0]->{mines_column}->{a_usd}+$permanent_cards->[0]->{plus_column}->{a_usd}
	);
	$XML->{cards_eur}=format_float
	(
		$permanent_cards->[0]->{mines_column}->{a_eur}+$permanent_cards->[0]->{plus_column}->{a_eur}
	);
	$XML->{cards_uah}=format_float
	(
		$permanent_cards->[0]->{mines_column}->{a_uah}+$permanent_cards->[0]->{plus_column}->{a_uah}
	);


	
	$XML->{last_sum_exc}=get_last_sum_exc_without();
	
	$XML->{delta_usd}=to_prec($XML->{whole_sum_with_commons_usd}-$XML->{last_sum_exc}->{last_sum_exc_usd});
	$XML->{delta_uah}=to_prec($XML->{whole_sum_with_commons_uah}-$XML->{last_sum_exc}->{last_sum_exc_uah});
	$XML->{delta_eur}=to_prec($XML->{whole_sum_with_commons_eur}-$XML->{last_sum_exc}->{last_sum_exc_eur});
 

	
	$XML->{delta_usd}+=$transfer_info->{USD}; 
  	$XML->{delta_eur}+=$transfer_info->{EUR};
    $XML->{delta_uah}+=$transfer_info->{UAH};
#    	$XML->{delta_usd}+=$transfer_info->{comission}->{USD};     
#	$XML->{delta_eur}+=$transfer_info->{comission}->{EUR};
#  	$XML->{delta_uah}+=$transfer_info->{comission}->{UAH};   
	my $rates=get_rates();

	
=pod	
	$XML->{incom_usd}-=$master_cards->[0]->{usd}; 
        $XML->{incom_eur}-=$master_cards->[0]->{eur};
        $XML->{incom_uah}-=$master_cards->[0]->{uah};

	$XML->{of_usd}-=$master_cards->[0]->{usd}; 
        $XML->{of_eur}-=$master_cards->[0]->{eur};
        $XML->{of_uah}-=$master_cards->[0]->{uah};
=cut	

	my $delta={ usd=> $XML->{delta_usd},eur=>$XML->{delta_eur},uah=>$XML->{delta_uah} };
	my ($conclusion_sums,$common)=get_concl_kcards_without($master_cards,$delta);
	
	
	
	$XML->{conclusions_sum}=$conclusion_sums;
	$XML->{incom_usd}=$XML->{delta_usd}+$common->{usd};
    $XML->{incom_eur}=$XML->{delta_eur}+$common->{eur};
	$XML->{incom_uah}=$XML->{delta_uah}+$common->{uah};
	$XML->{of_usd}=format_float($common->{usd});
	$XML->{of_eur}=format_float($common->{eur});
	$XML->{of_uah}=format_float($common->{uah}); 
	
	
	#use Data::Dumper;
	#die Dumper $conclusion_sums;


    
	
	my $tids=$self->make_conclusion_without($conclusion_sums,$delta,{USD=>$master_cards->[1]->{USD},
	EUR=>$master_cards->[1]->{EUR},UAH=>$master_cards->[1]->{UAH} },681,$rates);
	my $serialized = nfreeze($XML);  	
	
#	 $delta->{incom_usd}=$delta->{delta_usd}+$common->{usd};                                                                                                  
   $delta->{incom_eur}=($delta->{eur}+$common->{eur})*$rates->{eur};                                                                                                  
   $delta->{incom_uah}=($delta->{uah}+$common->{uah})*$rates->{uah};
	 
   $delta->{incom_usd}=($delta->{incom_eur}+ $delta->{incom_uah})+$delta->{usd}+$common->{usd}; 
	 
	$delta->{incom_eur}=0;                                                                             
     $delta->{incom_uah}=0;  	      
	 
	 $delta->{usd}+=$delta->{eur}*$rates->{eur};                                                                             
         $delta->{usd}+=$delta->{uah}*$rates->{uah};  
	 
         $delta->{eur}=0;                                                                                                                              
         $delta->{uah}=0;
	 
	 
	 

	
	
	$dbh->do(q[INSERT INTO reports_without SET
	cr_comments=?,
	cr_xml_detailes=?,
	cr_last_ts=?,
	cr_tids=?,cr_delta_usd=?,cr_delta_eur=?,cr_delta_uah=?,cr_income_usd=?,cr_income_eur=?,cr_income_uah=?,cr_system_state=?
	],undef,'отчетег))',$serialized,$last_ts[0],$tids,$delta->{usd},$delta->{eur},$delta->{uah},$delta->{incom_usd},
	$delta->{incom_eur},$delta->{incom_uah},save_state());

	$self->header_type('redirect');
	return $self->header_add(-url=>'reports.cgi?do=common_report_without_list');
	


}
sub make_conclusion_without
{
	my ($self,$conclusion_sums,$delta,$of,$of_id,$rates)=@_;
	my @tids;
	
	foreach(@$conclusion_sums)
	{


		foreach my $currency (keys %$of)
		{
		
			
			
			
			push @tids,$self->add_trans({
				t_name1 =>$DELTA_W,
				t_name2 =>$_->{a_id}, 
				t_currency =>'USD',
				t_amnt =>$_->{lc($currency)}->{earn_non_format}*$rates->{lc($currency)},
				t_comment =>"Распределение доходов между  основными карточками ",
				t_status=>'system',
       			});
			
			foreach my $key (@{$_->{ow_system}})
			{
   			
				push @tids,$self->add_trans({
      				t_name1 =>$key->{a_id},
    				t_name2 =>$_->{a_id} ,
      				t_currency =>'USD',
      				t_amnt => $key->{sum}->{lc $currency}*$rates->{lc($currency)},
      				t_comment =>"Распределение затрат ",
				    t_status=>'system',
				    fiction_pay=>1,
     				});
			}
=pod
   			push @tids,$self->add_trans({
				t_name1 =>$of_id,
				t_name2 =>$_->{a_id},
				t_currency =>uc $currency,
				t_amnt =>$_->{lc $currency}->{of_non_format},
				t_comment =>"Распределение затрат  ",
				t_status=>'system',
     			});
=cut
			
		}
		
	}
	return join ',',@tids;
}

sub delete_report_without
{
	my $self=shift;
	my $id=$self->query->param('id');
	my $r=$dbh->selectrow_hashref(q[SELECT * FROM 
		reports_without WHERE cr_id=? AND cr_status='created'],undef,$id);
	unless($r->{cr_status})
	{
		$self->header_type('redirect');
		return $self->header_add(-url=>'reports.cgi?do=common_report_without_list');
	}
	my @transes=split(/,/,$r->{cr_tids});
	foreach(@transes)
	{
		my $ref=$dbh->selectrow_hashref(q[SELECT * FROM transactions WHERE t_id=?],undef,$_);		
		my $tid = $self->add_trans({
		
			t_name1 =>$ref->{t_aid2},
    			t_name2 =>$ref->{t_aid1},
      			t_currency =>$ref->{t_currency}  ,
      			t_amnt =>$ref->{t_amnt} ,
      			t_comment =>"Откать :Распределение доходов между  основными карточками ",
       		});
		
		$dbh->do(q[UPDATE  transactions SET t_status='no' WHERE t_id=?],undef,$_);
		$dbh->do(q[DELETE FROM accounts_reports_table WHERE ct_id=? AND ct_ex_comis_type='transaction'],undef,$_);

	}
	$dbh->do(q[UPDATE reports_without SET cr_status='deleted' WHERE cr_id=?],undef,$id);
	
	$self->header_type('redirect');
	return $self->header_add(-url=>'reports.cgi?do=common_report_without_list');


}

sub save_report
{
	my $self=shift;
	#my $comments=$self->query->param('comments');

	my @last_ts=$dbh->selectrow_array(q[SELECT cr_ts
	FROM reports WHERE cr_status='created' ORDER BY cr_ts DESC LIMIT 1]);
		

###########
	my $permanent_cards=&get_permanent_cards();
	my $non_identifier=&get_non_identifier();
# 	my $pay_credits=&percent_payments();
	my $firm_balances=&get_firms_balances();
	my $master_cards=&get_kcards(@last_ts);
	
	my $XML={};

	my $transfer_info=get_transfer_operations(@last_ts);
	map{ $XML->{$_}=$transfer_info->{$_} } keys %{$transfer_info};

	$XML->{permanent_cards}=$permanent_cards;
	$XML->{non_identifier}=$non_identifier;
# 	$XML->{pay_credits}=$pay_credits;
	$XML->{firm_balances}=$firm_balances;
	$XML->{master_cards}=$master_cards;
	$XML->{work_money}=to_prec($permanent_cards->[0]->{plus_column}->{amnt}+$permanent_cards->[0]->{mines_column}->{amnt}-$non_identifier->[0]->{right_column}->{amnt}+$firm_balances->[0]->{right_column}->{amnt});
	

	$XML->{whole_sum_with_commons}=to_prec($XML->{work_money}+$master_cards->[0]->{sum});

	$XML->{last_sum_exc}=get_last_sum_exc();
	
	$XML->{delta}=$XML->{whole_sum_with_commons}-$XML->{last_sum_exc};
	my $delta=$XML->{delta};
	#die $delta;

	$XML->{delta}=format_float(to_prec($delta));
	my $r=$dbh->selectall_hashref(q[SELECT a_id,a_name FROM accounts WHERE a_id IN (33,34,35)],'a_id');

	my $conclusion_sums=get_concl_kcards($master_cards,$delta);
	$XML->{conclusions_sum}=$conclusion_sums;
	my $page=$self->query->param('page');	
	$XML->{firms_balances}=format_float($firm_balances->[0]->{right_column}->{amnt});
	$XML->{non_ident}=format_float($non_identifier->[0]->{right_column}->{amnt});
	$XML->{cards}=format_float($permanent_cards->[0]->{mines_column}->{amnt}+$permanent_cards->[0]->{plus_column}->{amnt});
	my $serialized = nfreeze($XML);  	
	my $office=$master_cards->[1]->{sum};
	$office=~s/[ ]//g;

	my $tids=$self->make_conclusion($conclusion_sums,$delta);
 	#get the date of last report	
	#insert
	$dbh->do(q[INSERT INTO reports SET
	cr_comments=?,
	cr_xml_detailes=?,
	cr_last_ts=?,cr_tids=?,cr_delta=?],undef,'отчетег))',$serialized,$last_ts[0],$tids,$delta);
	$self->header_type('redirect');
	return $self->header_add(-url=>'reports.cgi?do=common_report_list');
	
}
sub make_conclusion
{
	my ($self,$conclusion_sums,$delta)=@_;
	my @tids;
	
	foreach(@$conclusion_sums)
	{

		push @tids,$self->add_trans({
			t_name1 =>$DELTA,
			t_name2 =>$_->{a_id}, 
			t_currency =>  'USD',
			t_amnt =>$_->{earn_non_format},
			t_comment =>"Распределение доходов между  основными карточками ",
			t_status=>'system',
     
      		});
		foreach my $key (@{$_->{ow_system}})
		{
   			
			push @tids,$self->add_trans({
      			t_name1 =>$key->{a_id},
    			t_name2 =>$_->{a_id} ,
      			t_currency =>'USD',
      			t_amnt => $key->{sum}*1,
      			t_comment =>"Распределение затрат на оффис ",
			t_status=>'system',
			fiction_pay=>1,

     			});
		}

	}
	return join ',',@tids;
}

sub view_report_without
{
	my $self=shift;
	my $id=$self->query->param('id');
	my $print=$self->query->param('print');
	my $r=$dbh->selectrow_hashref(q[SELECT * FROM reports_without WHERE cr_id=?],undef,$id);
 	
	unless($r->{cr_id})
	{
			$self->header_type('redirect');
			return $self->header_add(-url=>'reports.cgi?do=common_report_without_list');


	}
	my %params = %{thaw($r->{cr_xml_detailes})};
	$params{view_not_edit}=1;
	my $tmpl=undef;
	unless($print){

	  $tmpl=$self->load_tmpl('common_reports_without.html');
	}else{
    	  $tmpl=$self->load_tmpl('common_reports_without_print.html');
   

	}

	foreach(keys %params)
	{
		$self->{tpl_vars}->{$_}=$params{$_};
	}
# 	
	####
	my $output='';
	$r->{cr_ts}=format_date($r->{cr_ts});
	$self->{'tpl_vars'}->{id}=$id;
	$self->{tpl_vars}->{page_title}="отчета за : $r->{cr_ts},дельта : $self->{tpl_vars}->{delta_usd} USD,
	$self->{tpl_vars}->{delta_eur} EUR, $self->{tpl_vars}->{delta_uah} ГРН";
	
	$self->{tpl_vars}->{date}=$r->{cr_ts};

	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || 
        $tmpl->error();
        return $output;	

}

sub view_report
{
	my $self=shift;
	my $id=$self->query->param('id');
	my $r=$dbh->selectrow_hashref(q[SELECT * FROM reports WHERE cr_id=?],undef,$id);
 	
	unless($r->{cr_id})
	{
			$self->header_type('redirect');
			return $self->header_add(-url=>'reports.cgi?do=common_report_list');


	}
	
	
        my %params = %{thaw($r->{cr_xml_detailes})};
	$params{view_not_edit}=1;
	my $tmpl=$self->load_tmpl('common_reports.html');
	foreach(keys %params)
	{
		$self->{tpl_vars}->{$_}=$params{$_};
	}
	$r->{cr_ts}=format_date($r->{cr_ts});

	$self->{tpl_vars}->{page_title}="отчета за : $r->{cr_ts},дельта : $params{'delta'}";
	
	$self->{tpl_vars}->{date}=$r->{cr_ts};

	my $output='';
	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || 
        $tmpl->error();

        return $output;
	
}

sub common_report
{
	my $self=shift;
  	my $tmpl=$self->load_tmpl('common_reports.html');
	my @last_ts=$dbh->selectrow_array(q[SELECT cr_ts FROM reports  WHERE cr_status='created' ORDER BY cr_id DESC LIMIT 1]);


	#my $static_cards=&get_static_cards(@last_ts);
 	my $permanent_cards=&get_permanent_cards();
	my $non_identifier=&get_non_identifier();
# 	my $pay_credits=&percent_payments();
	my $firm_balances=&get_firms_balances();
	my $master_cards=&get_kcards(@last_ts);

	$self->{tpl_vars}->{permanent_cards}=$permanent_cards;
	$self->{tpl_vars}->{non_identifier}=$non_identifier;
#	$self->{tpl_vars}->{pay_credits}=$pay_credits;
	$self->{tpl_vars}->{firm_balances}=$firm_balances;
	$self->{tpl_vars}->{master_cards}=$master_cards;
 	$self->{tpl_vars}->{work_money}=to_prec(
	($permanent_cards->[0]->{plus_column}->{amnt}+$permanent_cards->[0]->{mines_column}->{amnt})-
	$non_identifier->[0]->{right_column}->{amnt}+$firm_balances->[0]->{right_column}->{amnt});
	
	$self->{tpl_vars}->{whole_sum_with_commons}=to_prec($self->{tpl_vars}->{work_money}+$master_cards->[0]->{sum});
	$self->{tpl_vars}->{last_sum_exc}=get_last_sum_exc();
	$self->{tpl_vars}->{delta}=to_prec($self->{tpl_vars}->{whole_sum_with_commons}-$self->{tpl_vars}->{last_sum_exc});
	
	my $delta=$self->{tpl_vars}->{delta};
	$self->{tpl_vars}->{delta}=format_float($delta);
	my $conclusion_sums=get_concl_kcards($master_cards,$delta);
	$self->{tpl_vars}->{conclusions_sum}=$conclusion_sums;
# 	my %hash=(33=>$delta*0.25,34=>$delta*0.25,35=>$delta*0.5);
	
	$self->{tpl_vars}->{firms_balances}=format_float($firm_balances->[0]->{right_column}->{amnt});
	$self->{tpl_vars}->{non_ident}=format_float($non_identifier->[0]->{right_column}->{amnt});
	$self->{tpl_vars}->{cards}=format_float
	(
		$permanent_cards->[0]->{mines_column}->{amnt}+$permanent_cards->[0]->{plus_column}->{amnt}
	);


	##pages and others reports

		
	



	my $output='';
	my $date=$dbh->selectrow_array(q[SELECT current_timestamp]);
	$self->{tpl_vars}->{page_title}="отчета за : $date,дельта : $delta";
	$self->{tpl_vars}->{date}=$date;
	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || 
        $tmpl->error();



        return $output;
	

	
	
	
}



#system function for get the whole  picture

sub empty
{
    	 my $self=shift;
         my $tmpl=$self->load_tmpl('reports_empty.html');
         $self->{tpl_vars}->{fields}=$proto->{fields};
         my $output='';
         $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || 
         $tmpl->error();
         return $output;


  
}
###



###########################################direct stat#########################################


sub operators
{
         my $self=shift;
        my %filter;
   
        $filter{'t_ts'}=$self->query->param('t_ts');
        $filter{'currency'}=$self->query->param('currency');    
        $filter{'sort_type'}=$self->query->param('sort_type');
        $filter{'sort'}=$self->query->param('sort'); 
	$filter{'sort_type'}='plus' unless($filter{'sort_type'});

        my @tables=('`to`.ts','`from`.ts','`com`.ts');
        $filter{'t_ts'}='today' unless($filter{'t_ts'});
         my $times=time_filter($filter{'t_ts'});
        foreach(@tables)
        {
               
                $filter{$_}="$_>='".$times->{start}.
                "' AND $_<='".$times->{end}."'";    

        }
        $proto->{fields}->[0]->{value}=$filter{'t_ts'};
        $proto->{fields}->[1]->{value}=$filter{'currency'};     
   
	


        my $ref=$self->get_operators_stat(\%filter);
        $self->loading_params($ref);
      
        
        my $sort_type=$filter{'sort_type'};
        my $sort=$filter{'sort'};

        my @headers=(
         {run_mode=>'operators',currency=>$filter{'currency'},t_ts=>$filter{'t_ts'},sorted=>$sort_type eq 
	'plus',sort_type=>'plus',sort=>$sort!=1,asc=>$sort==1,'name'=>'Оборот'},
             {run_mode=>'operators',currency=>$filter{'currency'},t_ts=>$filter{'t_ts'},sorted=>$sort_type eq 
	'freq',sort_type=>'freq',sort=>$sort!=1,asc=>$sort==1,'name'=>'Частота транзакций'},
         {run_mode=>'operators',currency=>$filter{'currency'},t_ts=>$filter{'t_ts'},sorted=>$sort_type eq 
	'com',sort_type=>'com',sort=>$sort!=1,asc=>$sort==1,'name'=>'Отчисления в систему'},
         );

        $self->{tpl_vars}->{headers}=\@headers;
       
       $self->{tpl_vars}->{title}='Статистика по операторам';
       my $tmpl=$self->load_tmpl('reports_operators.html');
        
        my $output='';
       $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
        return $output;
}
sub get_cash_stat
{
      my ($self,$params)=@_;

          my %currency=(
    UAH=>'`from`.ct_amnt', 
    USD=>'`from`.ct_amnt',
    EUR=>'`from`.ct_amnt'
    
    );
    my $count_param=$currency{$params->{currency}};
   
    
    unless($count_param)
    {
        my $echs=get_exchanges();
        $count_param="CASE   `from`.ct_currency WHEN 'EUR' 
        THEN `from`.ct_amnt*$echs->{EUR} WHEN 'USD' THEN `from`.ct_amnt WHEN 'UAH' THEN             `from`.ct_amnt*$echs->{UAH} END";
        
    
    }
    
  my $currency_param; 
  if(!$params->{currency}||$params->{currency} eq '')
  {
      $currency_param=' 1 '; 
  }else
  {
      $currency_param="`from`.ct_currency='$params->{currency}'";
  }  
 



                  my $users=$dbh->selectall_hashref("SELECT a_id as id,
                  '$params->{currency}' as       currency,
                  '$params->{'t_ts'}' as t_ts,
                  a_name as name FROM accounts WHERE a_id=$kassa_id ",'id');
                
                
                my $mines=$dbh->selectall_hashref("SELECT
                $kassa_id as id,
                sum(abs($count_param)) as mines,
                count(`from`.ct_id) as freq,
                max($count_param) as max_trans_amnt
                FROM cashier_transactions as `from` WHERE 
                `from`.ct_fid=$kassa_id AND $currency_param
                 AND $params->{'`from`.t_ts'}   GROUP BY id
                ",'id');
        
              
                my $plus=$dbh->selectall_hashref("SELECT
                $kassa_id as id,
                sum(abs($count_param)) as plus,
                count(`from`.t_id) as freq 
                FROM cashier_transactions as `from` WHERE 
                `from`.ct_fid=$kassa_id AND $currency_param  AND 
                $params->{'`from`.t_ts'}  GROUP BY id
                ",'id');
                
       
                
         


        my @arr;
        my $common_params={};
        foreach(keys %$users)
        {
          
                
                $users->{$_}->{plus}=$plus->{$_}->{plus};
                $users->{$_}->{mines}=$mines->{$_}->{mines};
                $users->{$_}->{freq}=$mines->{$_}->{freq}+$plus->{$_}->{freq};
                $users->{$_}->{sum}=$mines->{$_}->{mines}+$plus->{$_}->{plus};
                push @arr,$users->{$_};
               
        }


        
        return \@arr;
  
  
}
sub get_operators_stat
{
    my ($self,$params)=@_;   
        my %currency=(
        UAH=>'`from`.ct_amnt', 
        USD=>'`from`.ct_amnt',
        EUR=>'`from`.ct_amnt'
        
        );
        my $count_param=$currency{$params->{currency}};
       
        my $echs;
        unless($count_param)
        {
           $echs=get_exchanges();
            $count_param="CASE   `from`.ct_currency WHEN 'EUR' 
            THEN `from`.ct_amnt*$echs->{EUR} WHEN 'USD' THEN `from`.ct_amnt WHEN 'UAH' THEN `from`.ct_amnt*$echs->{UAH} END";

        }
        
      
        
      my $currency_param; 
      if(!$params->{currency}||$params->{currency} eq '')
      {
          $currency_param=' 1 '; 
      }else
      {
          $currency_param="`from`.ct_currency='$params->{currency}'";
      }  
      
      
       
       my $opers=$dbh->selectall_hashref("SELECT o_id as id,
                  o_login as name,
                  '$params->{currency}' as  currency,
                  '$params->{'t_ts'}' as t_ts,
                  o_login as name FROM operators WHERE o_status!='deleted' ",'id');


                
      
        my $plus=$dbh->selectall_hashref("SELECT
                ct_oid as id,
                o_login,
                sum(abs($count_param)) as plus,
                count(`from`.ct_id) as freq
                FROM accounts_reports_table as `from` WHERE 
                ct_status!='deleted' AND $currency_param
                 AND $params->{'`from`.ts'}   GROUP BY id
                ",'id');
	
	unless($currency{$params->{currency}})
	{
		$count_param="CASE   `from`.ct_currency WHEN 'EUR' 
       		THEN `from`.comission*$echs->{EUR} WHEN 'USD' THEN `from`.comission WHEN 'UAH' 
		THEN 	`from`.comission*$echs->{UAH} END"; 	
	}else
	{
		$count_param=q[ `from`.comission ];
	
	}
       


	 
		
        my $com=$dbh->selectall_hashref("SELECT
                ct_oid as id,
                sum(abs($count_param)) as com
                FROM accounts_reports_table as `from` WHERE 
                 $currency_param  AND ct_status!='deleted' AND 
                $params->{'`from`.ts'}  GROUP BY id
                ",'id');

                
                
        my @arr;
        my $common_params={};
	
        foreach(keys %$opers)
        {
          
                
                $opers->{$_}->{plus}=$plus->{$_}->{plus};
                $opers->{$_}->{com}=$com->{$_}->{com};
                $opers->{$_}->{freq}=$plus->{$_}->{freq};
                
                
                $common_params->{plus}+=$opers->{$_}->{plus};
                $common_params->{com}+=$opers->{$_}->{com};
                $common_params->{freq}+=$opers->{$_}->{freq};
                
                push @arr,$opers->{$_};
               
        }
	
        if($params->{'sort'})
	{
		@arr=sort { $a->{$params->{'sort_type'} }<=>$b->{ $params->{'sort_type'} } } @arr;
	}else
	{
		@arr=sort { $b->{$params->{'sort_type'} }<=>$a->{ $params->{'sort_type'} } } @arr;
	}

        $common_params->{list}=\@arr;
        return  $common_params;
      
 
}
sub cash_table
{
        my $self=shift;
        my %filter;
   
        $filter{'ct_date'}=$self->query->param('t_ts');
        $filter{'currency'}=$self->query->param('currency');    
        
        my @tables=('`to`.ct_date','`from`.ct_date','`com`.ct_date');
	###changing the name of filters
		
		
		
		
	####
		
        
        $filter{'ct_date'}='today' unless($filter{'ct_date'});


        my $times=time_filter($filter{'ct_date'});
        foreach(@tables)
        {
               
                $filter{$_}="$_>='".$times->{start}.
                "' AND $_<='".$times->{end}."'";    

        }
	
        $proto->{fields}->[0]->{value}=$filter{'ct_date'};
        $proto->{fields}->[1]->{value}=$filter{'currency'};     
        


        my $ref=$self->get_cash_stat(\%filter);
       $self->{tpl_vars}->{fields}=$proto->{fields};
        $self->{tpl_vars}->{list}=$ref;
        $_POST->{id}=$kassa_id;
        map{ $self->{tpl_vars}->{$_}=$_POST->{$_} } keys %$_POST;
        $self->{tpl_vars}->{title}='Статистика по кассе';
        my $tmpl=$self->load_tmpl('reports_cashtable.html');
        
        my $output='';
        $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
        return $output;



}

sub users
{
        my $self=shift;
        my %filter;
        
                

    
        $filter{'t_ts'}=$self->query->param('t_ts');
        $filter{'currency'}=$self->query->param('currency');    
        $filter{'sort_type'}=$self->query->param('sort_type');  
	    $filter{'sort'}=$self->query->param('sort');
	
       $filter{'sort_type'}='plus' unless( $filter{'sort_type'} );

        my @tables=('`to`.ts','`from`.ts','`com`.ts');
        $filter{'t_ts'}='today' unless($filter{'t_ts'});
         my $times=time_filter($filter{'t_ts'});
        foreach(@tables)
        {
               
                $filter{$_}="$_>='".$times->{start}.
                "' AND $_<='".$times->{end}."'";    

        }
        $proto->{fields}->[0]->{value}=$filter{'t_ts'};
        $proto->{fields}->[1]->{value}=$filter{'currency'};     
        
        my $ref=$self->get_user_stat(\%filter);
        $self->loading_params($ref);
      
        
         my $sort_type= $filter{'sort_type'};
     
          my $sort=$filter{'sort'};
       my @headers=(
         {run_mode=>'users',currency=>$filter{'currency'},t_ts=>$filter{'t_ts'},sorted=>$sort_type eq 'plus',sort_type=>'plus',sort=>$sort!=1,asc=>$sort==1,'name'=>'Приход'},
             {run_mode=>'users',currency=>$filter{'currency'},t_ts=>$filter{'t_ts'},sorted=>$sort_type eq 'mines',sort_type=>'mines',sort=>$sort!=1,asc=>$sort==1,'name'=>'Расход'},
         {run_mode=>'users',currency=>$filter{'currency'},t_ts=>$filter{'t_ts'},sorted=>$sort_type eq 'freq',sort_type=>'freq',sort=>$sort!=1,asc=>$sort==1,'name'=>'Частота переводов'},
        {run_mode=>'users',currency=>$filter{'currency'},t_ts=>$filter{'t_ts'},sorted=>$sort_type eq 'max_trans_amnt',sort_type=>'max_trans_amnt',sort=>$sort!=1,asc=>$sort==1,'name'=>'Максимальный перевод'},
         {run_mode=>'users',currency=>$filter{'currency'},t_ts=>$filter{'t_ts'},sorted=>$sort_type eq 'max_com',sort_type=>'max_com',sort=>$sort!=1,asc=>$sort==1,'name'=>'Максимальная коммисия'},
            {run_mode=>'users',currency=>$filter{'currency'},t_ts=>$filter{'t_ts'},sorted=>$sort_type eq 'sum_com',sort_type=>'sum_com',sort=>$sort!=1,asc=>$sort==1,'name'=>'Сумма выплаченных коммисий'},
         );
         
        $self->{tpl_vars}->{headers}=\@headers;


       $self->{tpl_vars}->{title}='Статистика по пользователям';
        my $tmpl=$self->load_tmpl('reports_users.html');
        
        my $output='';
        $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
        return $output;

}


sub loading_params
{
      my $self=shift;
      my $ref=shift;
  
        ##sorting the output
        my $size=@{$ref->{list}};
       $self->query->param('sort_type','plus')  unless($self->query->param('sort_type'));
	
        if($size>1)
        {
        if($self->query->param('sort'))
        {

			

@{$ref->{list}}=sort { $a->{$self->query->param('sort_type')} <=>$b->{ $self->query->param('sort_type') } } @{$ref->{list}};	
		
        
          
        }else
        {
		@{$ref->{list}}=sort { $b->{$self->query->param('sort_type') }<=>$a->{ $self->query->param('sort_type') } } @{$ref->{list}};
         
        }
        }
###     
        $self->{tpl_vars}->{$self->query->param('sort_type')}=1;
        
        $self->{tpl_vars}->{'sort'}=defined($self->query->param('sort'));

        $self->{tpl_vars}->{fields}=$proto->{fields};
        $self->{tpl_vars}->{list}=$ref->{list};
        delete $ref->{list};
        map{$self->{tpl_vars}->{common_params}->{$_}=$ref->{$_} } keys %$ref;
        map{ $self->{tpl_vars}->{$_}=$_POST->{$_} } keys %$_POST;
	

}
sub firms
{
         my $self=shift;
         my %filter;
#working with filter
        $filter{'t_ts'}=$self->query->param('t_ts');
        $filter{'currency'}=$self->query->param('currency');
        
        my @tables=('`to`.ct_date','`from`.ct_date');
        unless($filter{'t_ts'})
        {
                $filter{'t_ts'}='today';
                $_POST->{'t_ts'}='today';
        }

       my $times=time_filter($filter{'t_ts'});
        foreach(@tables)
        {
               
                $filter{$_}="$_>='".$times->{start}.
                "' AND $_<='".$times->{end}."'";    

        }
    
        $proto->{fields}->[0]->{value}=$filter{'t_ts'};
        $proto->{fields}->[1]->{value}=$filter{'currency'};     
        
###
        $self->{tpl_vars}->{trans_list}->{'do'}->{value}='firms';#for working with this runmode
        my $ref=$self->get_firms_stat(\%filter);

   
        
        $self->loading_params($ref);
	
    
       my $sort_type=$self->query->param('sort_type');
     $sort_type='plus' unless($sort_type);
      my $sort=$self->query->param('sort');
  
    
      
       my @headers=(
         {run_mode=>'firms',currency=>$filter{'currency'},t_ts=>$filter{'t_ts'},sorted=>$sort_type eq 'plus',sort_type=>'plus',sort=>$sort!=1,asc=>$sort==1,'name'=>'Приход'},
          {run_mode=>'firms',currency=>$filter{'currency'},t_ts=>$filter{'t_ts'},sorted=>$sort_type eq 'mines',sort_type=>'mines',sort=>$sort!=1,asc=>$sort==1,'name'=>'Расход'},
         {run_mode=>'firms',currency=>$filter{'currency'},t_ts=>$filter{'t_ts'},sorted=>$sort_type eq 'freq',sort_type=>'freq',sort=>$sort!=1,asc=>$sort==1,'name'=>'Частота переводов'},
         );
         
        $self->{tpl_vars}->{headers}=\@headers;
        $self->{tpl_vars}->{title}='Статистика по фирмам';
        my $tmpl=$self->load_tmpl('reports_firms.html');
        
        my $output='';
       $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
  return $output;

        

}

sub services
{
         my $self=shift;
         my %filter;

        $filter{'t_ts'}=$self->query->param('t_ts');
        $filter{'currency'}=$self->query->param('currency');    
        my @tables=('`from`.ct_ts');
        $filter{'t_ts'}='today' unless($filter{'t_ts'});
        my $times=time_filter($filter{'t_ts'});
        foreach(@tables)
        {
               
                $filter{$_}="$_>='".$times->{start}.
                "' AND $_<='".$times->{end}."'";    

        }
        $proto->{fields}->[0]->{value}=$filter{'t_ts'};
        $proto->{fields}->[1]->{value}=$filter{'currency'};     
        $self->{tpl_vars}->{trans_list}->{'do'}->{value}='services';#for working with this runmode
        my $ref=$self->get_services_stat(\%filter);
        ##sorting the output
        $self->loading_params($ref);

     
	
        my $sort_type=$self->query->param('sort_type');
        $sort_type='plus' unless($sort_type);
	
        my $sort=$self->query->param('sort');
         my @headers=(
         {run_mode=>'services',currency=>$filter{'currency'},t_ts=>$filter{'t_ts'},sorted=>$sort_type eq 'plus',sort_type=>'plus',sort=>$sort!=1,asc=>$sort==1,'name'=>'Оборот'},
          {run_mode=>'services',currency=>$filter{'currency'},t_ts=>$filter{'t_ts'},sorted=>$sort_type eq 'com_sum',sort_type=>'com_sum',sort=>$sort!=1,asc=>$sort==1,'name'=>'Сумма комиссий'},
         {run_mode=>'services',currency=>$filter{'currency'},t_ts=>$filter{'t_ts'},sorted=>$sort_type eq 'freq',sort_type=>'freq',sort=>$sort!=1,asc=>$sort==1,'name'=>'Кол-во использований'},
           {run_mode=>'services',currency=>$filter{'currency'},t_ts=>$filter{'t_ts'},sorted=>$sort_type eq 'users',sort_type=>'users',sort=>$sort!=1,asc=>$sort==1,'name'=>'	Кол-во пользователей услуги'}
         );
         
        $self->{tpl_vars}->{headers}=\@headers;


        $self->{tpl_vars}->{title}='Статистика по сервисам';
        my $tmpl=$self->load_tmpl('reports_services.html');
        my $output='';
        $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
        return $output;

        

}

sub get_services_stat
{
        
                my ($self,$params)=@_;
                
                 my %currency=(
                 UAH=>'sum(abs(`from`.ct_amnt))', 
                 USD=>'sum(abs(`from`.ct_amnt))',
                 EUR=>'sum(abs(`from`.ct_amnt))'
    );
         my %com_currency=(
         UAH=>'sum(abs(t_amnt))', 
         USD=>'sum(abs(t_amnt))',
         EUR=>'sum(abs(t_amnt))'
    );
    my $amnt_currency=$currency{$params->{currency}};
    my $amnt_com_currency=$com_currency{$params->{currency}};
   unless($amnt_currency)
   {
        my $echs=get_exchanges();
        $amnt_currency="sum(abs(CASE   `from`.ct_currency WHEN 'EUR' 
        THEN `from`.ct_amnt*$echs->{EUR} WHEN 'USD' THEN `from`.ct_amnt WHEN 'UAH' THEN `from`.ct_amnt*$echs->{UAH}  END) )";
        
        $amnt_com_currency="sum(abs(CASE   t_currency WHEN 'EUR' 
        THEN t_amnt*$echs->{EUR} WHEN 'USD' THEN t_amnt WHEN 'UAH' THEN t_amnt*$echs->{UAH}  END) )";
   }
 
   
     my $currency_param;
   
  if(!$params->{currency}||$params->{currency} eq '')
  {
       $currency_param=' 1 '; 
  }
  else
  {
      $currency_param="`from`.ct_currency='$params->{currency}'";
  }  
                
                
        my $sth=$dbh->prepare(qq[
                        SELECT  
			firm_services.fs_id as id,
                        firm_services.fs_name as name,
                        $amnt_currency as  plus,
                        $amnt_com_currency as com_sum,
                        count(distinct `from`.ct_aid) as users,
                        count(`from`.ct_id) as freq,
                        '$params->{currency}' as currency,
                        '$params->{'t_ts'}' as t_ts
                        FROM 
                        firm_services,cashier_transactions as `from`,
			transactions  WHERE 
			`from`.ct_fsid=fs_id AND  ct_req='no' AND ct_status IN ('processed') AND 
			fs_id>0 AND $currency_param AND ].$params->{'`from`.ct_ts'}.q[ AND
                         ct_tid2_comis=t_id     GROUP BY fs_id]);       
        
                $sth->execute();
                my @arr;
                my $str_id='';
                my $common_params={};

                while(my $r=$sth->fetchrow_hashref())
                {
                        $str_id.="$r->{id},";
                        $common_params->{plus}+=$r->{plus};
                        $common_params->{com_sum}+=$r->{com_sum};
                        $common_params->{users}+=$r->{users};
                        $common_params->{freq}+=$r->{freq};
                        push @arr,$r;
                }
          
                chop($str_id);
                $sth->finish();
                ###get last not isnerted to the query
                if($str_id!='')
                {       
                   my  $sth=$dbh->prepare(qq[
                        SELECT  firm_services.fs_id as id,
                        firm_services.fs_name as name,
                        0 as  plus,
                        0 as com_sum,
                        0 as users,
                        0 as freq,
                        '$params->{currency}' as currency,
                        '$params->{'t_ts'}' as t_ts
                        FROM 
                        firm_services WHERE fs_id>0 AND fs_id NOT IN ($str_id)]);   
        
                $sth->execute();

                
                while(my $r=$sth->fetchrow_hashref())
                {
                        push @arr,$r;
                }

                $sth->finish();
                }
                $common_params->{list}=\@arr;
                return $common_params;
}






sub get_firms_stat
{
        
                my ($self,$params)=@_;
                
                
                
   my %currency=(
    UAH=>'sum(abs(`from`.ct_amnt))', 
    USD=>'sum(abs(`from`.ct_amnt))',
    EUR=>'sum(abs(`from`.ct_amnt))'
    
    );
    my $amnt_currency=$currency{$params->{currency}};
  unless($amnt_currency)
  {
        my $echs=get_exchanges();
        $amnt_currency="sum(abs(CASE   `from`.ct_currency WHEN 'EUR' 
        THEN `from`.ct_amnt*$echs->{EUR} WHEN 'USD' THEN `from`.ct_amnt WHEN 'UAH' THEN `from`.ct_amnt*$echs->{UAH} END))";
    
  }  
  my $currency_param;
  if(!$params->{currency}||$params->{currency} eq '')
  {
    $currency_param=' 1 '; 
  }else
  {
   $currency_param="`from`.ct_currency='$params->{currency}'";
  }  
 

                my $plus=$dbh->selectall_hashref(
                qq[SELECT               
                 $amnt_currency as  plus,
                (count(`from`.ct_id)) as freq,
                firms.f_name as name,
                firms.f_id as id
                FROM firms ,
                cashier_transactions as `from`
                WHERE  `from`.ct_fid=f_id AND ct_req='no' 
		AND `from`.ct_fid>0 AND
		 ct_status IN ('transit','created','processed')  AND $currency_param AND `from`.ct_amnt>0 AND 
		$params->{'`from`.ct_date'}
                GROUP BY id],'id');
				
		

                my $mines=$dbh->selectall_hashref(
                qq[SELECT               
                         $amnt_currency as  mines,
                        (count(`from`.ct_id)) as freq,
                        firms.f_name as name,
                        firms.f_id as id
                        FROM firms ,
                        cashier_transactions as `from`
                WHERE  
		`from`.ct_fid=f_id AND ct_req='no' AND  ct_status IN ('transit','created','processed') AND 
		$currency_param  AND   `from`.ct_fid>0 AND `from`.ct_amnt<0 AND $params->{'`from`.ct_date'}
                GROUP BY id],'id');
                
                my $firms=$dbh->selectall_hashref(
                qq[SELECT               
                        firms.f_name as name,
                        firms.f_id as id,
                        '$params->{currency}' as currency,
                        '$params->{'t_ts'}' as t_ts 
                        FROM firms  WHERE  f_id>0],'id');
                
                
                my  @arr;   
                my $common_params={};    
                foreach(keys %$firms)
                {       
                        
                        
                        $firms->{$_}->{plus}=$plus->{$_}->{plus};
                        $firms->{$_}->{mines}=$mines->{$_}->{mines};
                        $firms->{$_}->{freq}=$mines->{$_}->{freq}+$plus->{$_}->{freq};
                        
                        $common_params->{plus}+=$firms->{$_}->{plus};
                        $common_params->{mines}+=$firms->{$_}->{mines};
                        $common_params->{freq}+=$firms->{$_}->{freq};
                        
                        push @arr,$firms->{$_};
                }
                $common_params->{list}=\@arr;
                return $common_params;


}

sub get_user_stat
{
        my ($self,$params)=@_;
# 	use Data::Dumper;
# 	die Dumper $params;

          my %currency=(
	    	UAH=>'`from`.ct_amnt', 
    		USD=>'`from`.ct_amnt',
    		EUR=>'`from`.ct_amnt'
    
    );
    my $count_param=$currency{$params->{currency}};
   
    my $echs;
    unless($count_param)
    {
        $echs=get_exchanges();
        $count_param="CASE   `from`.ct_currency WHEN 'EUR' 
        THEN `from`.ct_amnt*$echs->{EUR} WHEN 'USD' THEN `from`.ct_amnt WHEN 'UAH' THEN             `from`.ct_amnt*$echs->{UAH} END";
        
    
    }



    
	my $currency_param; 
	if(!$params->{currency}||$params->{currency} eq '')
	{
		$currency_param=' 1 '; 
	}else
	{
		$currency_param="`from`.ct_currency='$params->{currency}'";
	}  
 



                my $users=$dbh->selectall_hashref("SELECT a_id as id,
                '$params->{currency}' as       currency,
                '$params->{'t_ts'}' as t_ts,
                  a_name as name FROM accounts WHERE a_id>0 ",'id');
                
                
                my $mines=$dbh->selectall_hashref("SELECT
                ct_aid as id,
                sum(abs($count_param)) as mines,
                count(`from`.ct_id) as freq,
                max(abs($count_param)) as max_trans_amnt
                FROM accounts_reports_table as `from` WHERE 
                 $currency_param AND ct_amnt<0 AND ct_status!='deleted'
                AND `from`.ct_aid>1 AND $params->{'`from`.ts'}   GROUP BY id
                ",'id');
        
                
                my $plus=$dbh->selectall_hashref("SELECT
                ct_aid as id,
                sum(abs($count_param)) as plus,
                count(`from`.ct_id) as freq,
		max(abs($count_param)) as max_trans_amnt
                FROM accounts_reports_table as `from` WHERE 
                `from`.ct_aid>1 AND ct_amnt>0 AND $currency_param AND ct_status!='deleted'  AND 
                $params->{'`from`.ts'}  GROUP BY id
                ",'id');
        	##use Data::Dumper;
		
		unless($currency{$params->{currency}})
		{
	
                	$count_param="CASE   `from`.ct_currency WHEN 'EUR' 
	        	THEN `from`.comission*$echs->{EUR} WHEN 'USD' THEN `from`.comission WHEN 'UAH' THEN             
			`from`.comission*$echs->{UAH} END";
		}else
		{
			$count_param=" `from`.comission ";
			
		}

                my $com=$dbh->selectall_hashref("SELECT
                ct_aid as id,
                max(abs($count_param)) as max_com,
                sum(abs($count_param)) as sum_com,
		count(ct_id) as freq
                FROM accounts_reports_table as `from` WHERE 
                `from`.ct_aid>1 AND  $currency_param AND ct_status!='deleted' AND 
                $params->{'`from`.ts'}   GROUP BY id",'id');


        my @arr;
        my $common_params={};
    
        foreach(keys %$users)
        {
                $users->{$_}->{plus}=$plus->{$_}->{plus};
                $users->{$_}->{mines}=$mines->{$_}->{mines};
                $users->{$_}->{freq}=$mines->{$_}->{freq}+$plus->{$_}->{freq}+$com->{$_}->{freq};
		if($mines->{$_}->{max_trans_amnt}>$plus->{$_}->{max_trans_amnt})
		{
			$users->{$_}->{max_trans_amnt}=$mines->{$_}->{max_trans_amnt};
		}else
		{
			$users->{$_}->{max_trans_amnt}=$plus->{$_}->{max_trans_amnt};
		}
		unless($users->{$_}->{max_trans_amnt})
                {
                    $users->{$_}->{max_trans_amnt}=$com->{$_}->{max_com};
                }  
                 $users->{$_}->{max_com}=$com->{$_}->{max_com};
                 $users->{$_}->{sum_com}=$com->{$_}->{sum_com};
                
                $common_params->{max_trans_amnt}=$users->{$_}->{max_trans_amnt}  if($users->{$_}->{max_trans_amnt} > $common_params->{max_trans_amnt}); 
		
                $common_params->{max_com}=$users->{$_}->{max_com}  if(
		$users->{$_}->{max_com} > $common_params->{max_com}); 

                $common_params->{sum_com}+=$users->{$_}->{sum_com};
                push @arr,$users->{$_};
        }
	
	if($params->{'sort'})
	{
		@arr=sort { $a->{$params->{'sort_type'} }<=>$b->{ $params->{'sort_type'} } } @arr;
	}else
	{
		@arr=sort { $b->{$params->{'sort_type'} }<=>$a->{ $params->{'sort_type'} } } @arr;
	}
	






          $common_params->{freq}=$dbh->selectrow_array(qq[SELECT count(ct_id) FROM accounts_reports_table as `from` WHERE 
	ct_status!='deleted'	 AND $currency_param AND $params->{'`from`.ts'}]);
	   $common_params->{plus}=$dbh->selectrow_array(qq[SELECT sum(abs($count_param)) FROM accounts_reports_table as `from` WHERE ct_status!='deleted' AND $params->{'`from`.ts'}  AND $currency_param]);		
	
          $common_params->{list}=\@arr;
        return $common_params;

}






sub generate_query
{
        my ($self,$params)=@_;  
  
        my $param_count=$self->query->param('count_param');
        my $graph_type=$self->query->param('type');
        my $ts=$self->query->param('ts_value');
        my $id=$self->query->param('id');
        my %types;
        my $prec=$params->{prec};
        my %currency_param=
         (
            users=>"`from`.ct_currency",
            services=>"`from`.ct_currency",
            firms=>"`from`.ct_currency",
            cashtable=>"`from`.ct_currency",
            operators=>"`from`.ct_currency"
         );
         my %currencies=(
           UAH=>'UAH',
           USD=>'USD',
           EUR=>'EUR'
           );
           
         
       
          $param_count='plus'  unless($param_count);
        
        

        
        if($id)
        {
                %types=
                (
                              operators=> {
					plus=>{func=>'sum',value=>'abs(`from`.ct_amnt)',
					where=>" ct_status!='deleted' AND ct_oid=$id " },
					freq=>{func=>'count',value=>'`from`.ct_id',
					where=>" ct_status!='deleted' AND ct_oid=$id" },
					com=>{func=>'sum',value=>'abs(`from`.comission)',
					where=>" ct_status!='deleted'  AND ct_oid=$id "}
                                },          
                  
                  
                               users=> {
					plus=>{func=>'sum',value=>'`from`.ct_amnt',where=>"ct_status!='deleted' AND `from`.ct_aid=$id AND ct_amnt>0" },
					mines=>{func=>'sum',value=>'abs(`from`.ct_amnt)',where=>" ct_status!='deleted' AND `from`.ct_aid=$id   AND ct_amnt<0" },
					freq=>{func=>'count',value=>'`from`.ct_id',where=>" ct_status!='deleted' AND `from`.ct_aid=$id " },
					max_trans_amnt=>{func=>'max',value=>'abs(`from`.ct_amnt)',where=>"
					ct_status!='deleted' AND `from`.ct_aid=$id "},
 					max_com=>{func=>'max',value=>'abs(`from`.comission)',where=>" ct_status!='deleted' AND `from`.ct_aid=$id  " },
					sum_com=>{func=>'sum',value=>'abs(`from`.comission)',where=>"ct_status!='deleted' AND `from`.ct_aid=$id  "}
                                },
                                cashtable=>{
					plus=>{func=>'sum',value=>'`from`.ct_amnt',where=>"  `from`.ct_amnt>0 AND 
					`from`.ct_fid=-1 AND ct_status in ('processed','returned')"},
					sum=>{func=>'sum',value=>'`from`.ct_amnt',where=>"`from`.ct_fid=-1 AND 
					ct_status in ('processed','returned') "},
					mines=>{func=>'sum',value=>'abs(`from`.ct_amnt)',where=>" `from`.ct_amnt<0 AND 
					`from`.ct_fid=-1 AND ct_status in ('processed','returned')"},
					freq=>{func=>'count',value=>'`from`.ct_id',where=>" `from`.ct_fid=-1 AND 
					ct_status in ('processed','returned')" },                              
					max_trans_amnt=>{func=>'max',value=>'abs(`from`.ct_amnt)',where=>"  ct_status 
					in ('processed','returned') " }
                                },
                                firms=>
                                {
                                        plus=>{func=>'sum',value=>'`from`.ct_amnt',where=>" ct_amnt>0 AND ct_fid=$id "},
                                        mines=>{func=>'sum',value=>'abs(`from`.ct_amnt)',where=>" ct_amnt<0 AND 
					ct_fid=$id "},
                                        freq=>{func=>'count',value=>'`from`.ct_id',where=>"  ct_fid=$id  "}    
                                },
                                services=>
					{
					plus=>{func=>'sum',value=>'abs(`from`.ct_amnt)',
					where=>"ct_status!='deleted' AND ct_fsid=$id"},
					com_sum=>{func=>'sum', value=>'abs(`transactions`.t_amnt)',
					where=>" ct_status!='deleted' AND ct_fsid=$id "},
					users=>{func=>'count',value=>'distinct ct_aid',where=>" ct_status!='deleted' AND  ct_fsid=$id "},
					freq=>{func=>'count',value=>'`from`.ct_id',where=>" ct_status!='deleted' AND  ct_fsid=$id "}
                        	}
                );
        }else
        {
                %types=
                (
                  
                        operators=> {
					plus=>{func=>'sum',value=>'abs(`from`.ct_amnt)',where=>" ct_status!='deleted'  " },
					freq=>{func=>'count',value=>'`from`.ct_id',where=>" ct_status!='deleted'  " },
					com=>{func=>'sum',value=>'abs(`from`.comission)',where=>"  ct_status!='deleted' "}
                                },  
                        users=> {
			plus=>{func=>'sum',value=>'`from`.ct_amnt',where=>"ct_status!='deleted' AND ct_amnt>0" },
			mines=>{func=>'sum',value=>'abs(`from`.ct_amnt)',where=>" ct_status!='deleted' AND ct_amnt<0 " },
			freq=>{func=>'count',value=>'`from`.ct_id',where=>" ct_status!='deleted' AND 1 " },
			max_trans_amnt=>{func=>'max',value=>'abs(`from`.ct_amnt)',where=>"ct_status!='deleted' AND 1 "},
 			max_com=>{func=>'max',value=>'abs(`from`.comission)',where=>" ct_status!='deleted' AND 1"},
			sum_com=>{func=>'sum',value=>'abs(`from`.comission)',where=>"ct_status!='deleted' AND 1"}
                                },
                         cashtable=>{
					plus=>{func=>'sum',value=>'`from`.ct_amnt',where=>"  `from`.ct_amnt>0 AND `from`.ct_fid=-1 AND ct_status in ('processed','returned')"},
					sum=>{func=>'sum',value=>'`from`.ct_amnt',where=>"`from`.ct_fid=-1 AND ct_status in ('processed','returned') "},
					mines=>{func=>'sum',value=>'abs(`from`.ct_amnt)',where=>" `from`.ct_amnt<0 AND `from`.ct_fid=-1 AND ct_status in ('processed','returned')"},
					freq=>{func=>'count',value=>'`from`.ct_id',where=>" `from`.ct_fid=-1 AND 
					ct_status in ('processed','returned')" },                              max_trans_amnt=>{func=>'max',value=>'abs(`from`.ct_amnt)',where=>"  ct_status in ('processed','returned') " }
                                },
                        firms=>
                                {
                                        plus=>{func=>'sum',value=>'`from`.ct_amnt',where=>q[ct_status IN ('transit','processed','created') AND ct_req='no'  AND ct_amnt>0 AND ct_fid>0 ]},
                                        mines=>{func=>'sum',value=>' abs(`from`.ct_amnt) ',where=>q[ ct_status IN ('transit','processed','created') AND ct_req='no' AND ct_amnt<0 AND ct_fid>0 ]},
                                        freq=>{func=>'count',value=>'`from`.ct_id',where=>q[    ct_status IN ('transit','processed','created') AND ct_req='no' AND ct_fid>0  ]}      
                                },
                        services=>
                                {
                                        plus=>{func=>'sum',value=>'abs(`from`.ct_amnt)',where=>q[ ct_status!='deleted' AND fs_id>0]},
                                        com_sum=>{func=>'sum',value=>'abs(`transactions`.t_amnt)',where=>q[ ct_status!='deleted' AND fs_id>0 ]},
                                        users=>{func=>'count',value=>'distinct ct_aid',where=>q[ ct_status!='deleted'  AND fs_id>0]},
                                        freq=>{func=>'count',value=>'`from`.ct_id',where=>q[ ct_status!='deleted' AND fs_id>0]}
                        }
                );

        }
        
        
        
        
               
              
        my $where=$types{$graph_type}->{$param_count}->{where}; 
        my $t=$types{$graph_type}->{$param_count}->{func};
        my $param=$types{$graph_type}->{$param_count}->{value};
        
        my $currency_param=$currency_param{$graph_type};     
        if(!$currencies{$params->{currency}}&&($t eq 'sum'||$t eq 'max'))
        {
          
                my $echs=get_exchanges();
                $param="$t(CASE   $currency_param WHEN 'EUR' 
                THEN $param*$echs->{EUR} WHEN 'USD' THEN $param WHEN 'UAH' THEN $param*$echs->{UAH}    END)";
                $currency_param=' 1 ';            
        }
        else
        {
                $param="$t($param)";
          
        }
        if($currencies{$params->{currency}})
        {
            $currency_param=$currency_param{$graph_type};
            $currency_param="$currency_param='".$currencies{$params->{currency}}."'";
          
        }else
        {
          $currency_param=' 1 ';
          
        }
        
      
        



        my %group=(
		users_year=>
		{
			week=>{group=>'WEEKOFYEAR',param=>'`from`.`ts`'},
			month=>{group=>'MONTH',param=>'`from`.`ts`'},
			day=>{group=>'DAYOFYEAR',param=>'`from`.`ts`'},
				
		},
                firms_year=>
		{
			week=>{group=>'WEEKOFYEAR',param=>'`from`.`ct_date`'},
			month=>{group=>'MONTH',param=>'`from`.`ct_date`'},
			day=>{group=>'DAYOFYEAR',param=>'`from`.`ct_date`'},
				
		},
 		services_year=>
		{
			week=>{group=>'WEEKOFYEAR',param=>'`from`.`ct_ts`'},
			month=>{group=>'MONTH',param=>'`from`.`ct_ts`'},
			day=>{group=>'DAYOFYEAR',param=>'`from`.`ct_ts`'},
				
		},
                cashtable_year=>
		{
			week=>{group=>'WEEKOFYEAR',param=>'`from`.ct_date'},
			month=>{group=>'MONTH',param=>'`from`.ct_date'},
			day=>{group=>'DAYOFYEAR',param=>'`from`.ct_date'},
				
		},
		 operators_year=>
		{
			week=>{group=>'WEEKOFYEAR',param=>'`from`.`ts`'},
			month=>{group=>'MONTH',param=>'`from`.`ts`'},
			day=>{group=>'DAYOFYEAR',param=>'`from`.`ts`'},
				
		},
                
                users_month=>{group=>'DAYOFMONTH',param=>'`from`.`ts`'},
                firms_month=>{group=>'DAYOFMONTH',param=>'`from`.`ct_date`'},
                services_month=>{group=>'DAYOFMONTH',param=>'`from`.`ct_ts`'},
                cashtable_month=>{group=>'DAYOFMONTH',param=>'`from`.ct_date'},
                operators_month=>{group=>'DAYOFMONTH',param=>'`from`.`ts`'},

                users_week=>{group=>'DAYOFWEEK',param=>'`from`.`ts`'},
                firms_week=>{group=>'DAYOFWEEK',param=>'`from`.`ct_date`'},
                services_week=>{group=>'DAYOFWEEK',param=>'`from`.`ct_ts`'},
                cashtable_week=>{group=>'DAYOFWEEK',param=>'`from`.ct_date'},
                operators_week=>{group=>'DAYOFWEEK',param=>'`from`.`ts`'},
                  
                users_day=>{group=>'HOUR',param=>'`from`.`ts`'},
                firms_day=>{group=>'HOUR',param=>'`from`.`ct_ts`'},
                services_day=>{group=>'HOUR',param=>'`from`.`ct_ts`'},
                cashtable_day=>{group=>'HOUR',param=>'`from`.ct_ts'},
                operators_day=>{group=>'HOUR',param=>'`from`.`ts`'},
        );
             
#it will be edited   
	my $value;
	my $param_value;
	
	if($ts eq 'year')
	{
  		 $value=$group{$graph_type.'_'.$ts}->{$prec}->{group};
        	 $param_value=$group{$graph_type.'_'.$ts}->{$prec}->{param};   
	}else
	{
		$value=$group{$graph_type.'_'.$ts}->{group};
        	$param_value=$group{$graph_type.'_'.$ts}->{param};   
	}

	##for griding in hours set ct_date equal to ct_ts
	#use Data::Dumper;
	#die Dumper 	$params;
	#$params->{'`from`.ct_date'}=$params->{'`from`.ct_ts'}	if($value eq 'HOUR');	      
	
        my %query_types=
        (
        firms=>qq[
                        SELECT $value($param_value)
                        as y,$param as count,DAYOFWEEK(`from`.ct_date) as day_of_week,
                        YEAR(`from`.ct_date) as year_of_ts,       
                        MONTH(`from`.ct_date) as month_of_ts
                        FROM firms,cashier_transactions as `from` 
                        WHERE `from`.ct_fid=f_id    AND $currency_param 
                        AND ].$params->{'`from`.ct_date'}.qq[ AND $where
                        GROUP BY $value($param_value) ORDER BY $value($param_value) ASC],
        services=>qq[
                        SELECT  
                        $value($param_value) as y,$param as count,DAYOFWEEK(`from`.ct_date) as day_of_week,
                        YEAR(`from`.ct_date) as year_of_ts,       
                        MONTH(`from`.ct_date) as month_of_ts
                        FROM 
                        firm_services,cashier_transactions as `from`,transactions 
                        WHERE `from`.ct_fsid=fs_id  AND $currency_param 
                        AND  ct_tid2_comis=transactions.t_id    AND ].$params->{'`from`.ct_ts'}.qq[ 
                         AND $where
                        GROUP BY $value($param_value) ORDER BY $value($param_value) ASC],
        cashtable=>qq[  SELECT $value($param_value) as y,
                        $param as count,
                        DAYOFWEEK(`from`.ct_date) as day_of_week,
                        YEAR(`from`.ct_date) as year_of_ts,        
                        MONTH(`from`.ct_date) as month_of_ts
                        FROM  cashier_transactions as `from`
                        WHERE $where AND $currency_param  AND ct_req='no' AND  
                        ].$params->{'`from`.ct_date'}.
                        qq[ AND 1 GROUP BY $value($param_value) ORDER BY $value($param_value) ASC ],
        users=>qq[SELECT $value($param_value) as y,
                        $param as count,
                        DAYOFWEEK(`from`.ts) as day_of_week,
                        YEAR(`from`.ts) as year_of_ts,        
                        MONTH(`from`.ts) as month_of_ts
                        FROM  accounts_reports_table as `from`
                        WHERE $where AND $currency_param AND 
                        ].$params->{'`from`.ts'}." GROUP BY $value($param_value) ORDER BY $value($param_value) ASC ",
          operators=>qq[SELECT
                         $value($param_value) as y,
                         $param as count,
                         DAYOFWEEK(`from`.ts) as day_of_week,
                         YEAR(`from`.ts) as year_of_ts,        
                         MONTH(`from`.ts) as month_of_ts
                          FROM accounts_reports_table as `from` WHERE 
                         $where AND $currency_param
                        AND $params->{'`from`.ts'}   GROUP BY $value($param_value) ORDER BY $value($param_value) ASC ]
                  );
        return $query_types{$graph_type};
}

sub get_image
{
        my $self=shift;


        my %filter;
	my $prec=$self->query->param('prec');
 	$filter{'prec'}=$prec;
	
        $filter{'t_ts'}=$self->query->param('t_ts');
        $filter{'currency'}=$self->query->param('currency');    

#varios checkings
        my $types={operators=>'operators',users=>'users',firms=>'firms',services=>'services',cashtable=>'cashtable'};
        my $graph_type=$types->{$self->query->param('type')};
        unless($graph_type)
        {
                $graph_type='users';
                $self->query->param('type','users');
        }
        my %fiter_dates_conv=(
                this_week=>'week',
                yesterday=>'day',       
                today=>'day',
                prev_week=>'week',
                this_month=>'month',
                prev_month=>'month',
                this_year=>'year',
                prev_year=>'year',
                all_time=>'year',
        );

        #depened of filter t_ts  param
        	my $grid_param=$fiter_dates_conv{$filter{'t_ts'}};
		
		if($grid_param eq 'year')
		{
			if($prec ne 'month'&&$prec ne 'week'&&$prec ne 'day')				
			{
				$filter{'prec'}='month';
				$prec='month';
			
			}

		}


        $self->query->param('ts_value',$grid_param);
        unless($grid_param)
        {
                $filter{'t_ts'}='this_month';
                $self->query->param('t_ts','this_month');
                $grid_param='month';
                $self->query->param('ts_value','month');
        }
        #
##finishing checkings

        #for filling varios queris params for date
	my %tables_t;
	
	
        	%tables_t=(
			users=>['`to`.ts','`from`.ts','`com`.ts'],
                        cashtable=>['`to`.ct_date','`from`.ct_date','`from`.ct_ts','`com`.ct_date'],
                        firms=>['`to`.ct_date','`from`.ct_ts','`from`.ct_date'],
                        services=>['`from`.ct_date','`from`.ct_ts'],
                        operators=>['`from`.ts'],
                );
	
        
        my $tables=$tables_t{$graph_type};
        
        my $times=time_filter($filter{'t_ts'});
        foreach(@$tables)
        {

               
                $filter{$_}="$_>='".$times->{start}.
                "' AND $_<='".$times->{end}."'";    

        }
  
        
        $proto->{fields}->[0]->{value}=$filter{'t_ts'};
        $proto->{fields}->[1]->{value}=$filter{'currency'};     
        

        my $query=$self->generate_query(\%filter);
        my %hash=
        (
                'year'=>\&year_graph,
                'month'=>\&month_graph,
                'week'=>\&month_graph,
                'day'=>\&day_graph
        );  
       my %type_draw=(
                'year'=>\&draw_image,
                'day'=>\&draw_image_rect,
                'month'=>\&draw_image_rect,
                'week'=>\&draw_image_rect,
                
        );

        my $drawing_params_ext=
	{
		year=>{
			month=>{
					x_step=>60,
					x_width=>60,
					points_number=>12,
					whole_width=>720,
				},
			week=>{
					x_step=>14.04,
					x_width=>60,	
					points_number=>52,
					whole_width=>730,
			},
			day=> {
					x_step=>2,
					x_width=>60.88,	
					points_number=>365,
					whole_width=>730,
			},
			default=>'month'
		}
	};
	
	my $drawing_params=$drawing_params_ext->{$grid_param}->{$prec};
	#if the prec doesn't set
	
	unless($prec)
	{
		$prec=$drawing_params_ext->{$grid_param}->{default};
	}
	#set the rect mode if the grid and precsion are equel
	
	if($drawing_params_ext->{$grid_param}->{default} eq $prec)
	{
		
		$type_draw{$grid_param}	=\&draw_image_rect;
	}
	#
	my %grid_params=
        (
                'year'=>{x=>$drawing_params->{whole_width}+$Y_WIDTH_GRID,y=>241,
		'x_grid'=>$drawing_params->{x_width},y_grid=>20},
                'day'=>{x=>532,y=>241,x_grid=>20,y_grid=>20},
                'month'=>{x=>680,y=>241,x_grid=>20,y_grid=>20},
                'week'=>{x=>660,y=>241,x_grid=>20,y_grid=>20},
        );
  
        my $ref=$hash{$grid_param}->($query,$drawing_params);
        return $type_draw{$grid_param}->($self,$ref,$grid_params{$grid_param});

}


sub draw_image
{
        my ($self,$ref,$grids)=@_;
        my $im = new GD::Image($grids->{x},$grids->{y});
        $self->header_add( -type => 'image/png' );
        # allocate some color
        my $white = $im->colorAllocate(255,255,255);
        my $blue = $im->colorAllocate(0,0,255);
        my $black = $im->colorAllocate(0,0,0);
        my $x_grid = $im->colorAllocate(117,207,167);
        my $red=$im->colorAllocate(255,0,0);
        my $i=0;
        my $len=@{ $ref->{'yy'} };
##grid y 
        my $x_width=$grids->{x_grid};
        my $y_width=$grids->{y_grid};
	my $x_step=$grids->{x_step};
        my $x_len=$grids->{x};
        my $y_len=$grids->{y};
                

        $im->rectangle(0,0, $x_width-1,$y_width-1,$x_grid);

        ###
       
        
        foreach(@{$ref->{'yy'}})
        {
                $im->rectangle(0,$_->{from_y},$x_width-1,$_->{from_y}+($y_width-1),$x_grid);
                $im->fill(2,$_->{from_y}+1,$x_grid);#fill the rectangle
                $im->line($_->{from_x},$_->{from_y},$_->{to_x},$_->{to_y},$black);
                ## x,y
                $im->string(gdSmallFont,$x_width/2,$y_width+$_->{from_y}-2,$ref->{'yy'}->[$len-$i]->{y},$black);
                $i++;

        }
        $im->line($x_width,0,$x_width,$y_len,$black);
        $im->string(gdSmallFont,int($x_width/2),0,$ref->{max_y_value},$black);
        my $step=$x_width;
##there we draw the x grid with numbers 
        $im->rectangle(0,$y_len-$y_width,$step,$y_len,$black);
        $i=0;
        $y_len-=1;
  $im->line(0,$y_len,$x_len,$y_len,$black);
        $im->line($x_len-1,0,$x_len-1,$y_len,$black);
        $im->line(0,0,$x_len,0,$black);
        $im->line(0,0,0,$y_len,$black);
        foreach(@{$ref->{'xx'}})
        {
#                         
                        $im->rectangle($Y_WIDTH_GRID+$step*$i+1,$y_len-$y_width,

 			$Y_WIDTH_GRID+$step*($i+1)+1,$y_len,$x_grid);

                        $im->fill($Y_WIDTH_GRID+$step*$i+10,$y_len-($y_width-5),$x_grid);#fill the rectangle

                        $im->line($Y_WIDTH_GRID+$step*($i+1),$y_len,$Y_WIDTH_GRID+$step*($i+1),$y_len-$y_width,$black);

                        $im->string(gdSmallFont,
			$Y_WIDTH_GRID+$step*($i+1)-15,$y_len-($y_width-2),$_->{x2}.$_->{x1},$black);
                        $i++;   
                        $im->line($_->{from_x},$_->{from_y},$_->{to_x},$_->{to_y},$black);
       
        }

##there we draw the y grid with numbers 

      
      
#borders
      
        my $diagonal_brush = new GD::Image(2,2);
        my $black_ = $diagonal_brush->colorAllocate(0,0,0);
        $diagonal_brush->filledArc(1,1,1,1,0,1,$black_);
        $im->setBrush($diagonal_brush);
        $y_len-=1;
	
	#die Dumper $ref->{'stat'};
	my @test;
	#$step-=10;
        foreach(@{$ref->{'stat'}})
        {
                $im->line($step+$_->{from_x}-ceil($x_step/2),$y_len-($_->{from_y}+$y_width),$step+$_->{to_x}-ceil($x_step/2),$y_len-($_->{to_y}+$y_width),gdBrushed);

 		push @test,{x1=>($step+$_->{from_x}-ceil($x_step/2)),
 			y1=>($y_len-($_->{from_y}+$y_width)),
 			x2=>($step+$_->{to_x}-ceil($x_step/2)),
 			y2=>($y_len-($_->{to_y}+$y_width))};
             #   $im->filledArc($step+$_->{from_x}-ceil($x_step/2),$y_len-($_->{from_y}+($y_width-1)),3,3,0,360,$red);   
        }       
#	die Dumper \@test;
        # make the background transparent and interlaced
        $im->transparent($white);
        $im->interlaced('true');
        return  $im->png;


}

sub draw_image_rect
{
        my ($self,$ref,$grids,$ext_title)=@_;
	
        my $im = new GD::Image($grids->{x},$grids->{y});


        $self->header_add( -type => 'image/png' );
      #grids
        my $white = $im->colorAllocate(255,255,255);
        my $blue = $im->colorAllocate(0,0,255);
        my $green = $im->colorAllocate(200,255,200);
        my $black = $im->colorAllocate(0,0,0);

        my $x_grid = $im->colorAllocate(117,207,167);
        my $red=$im->colorAllocate(255,100,100);
        my $i=0;

        my $len=@{$ref->{'yy'}};

        my $x_width=$grids->{x_grid};
	#die $x_width;
        my $y_width=$grids->{y_grid};

        my $x_len=$grids->{x};
        my $y_len=$grids->{y};
                


        $y_len-=2;
         my $step=$x_width;
	
        foreach(@{$ref->{'stat'}})
        {
                  
                
                $im->rectangle($_->{x}+$Y_WIDTH_GRID,($y_len-$y_width)-($_->{y}),$Y_WIDTH_GRID+$_->{x}+$step,$y_len-$y_width,$green);
                $im->fill($_->{x}+$Y_WIDTH_GRID+1,$y_len-$y_width-1,$green) if($_->{y}>3);
                                

        }

         $y_len+=2;
 
         foreach(@{$ref->{'yy'}})
         {
                 $im->rectangle(0,$_->{from_y},$Y_WIDTH_GRID-1,$_->{from_y}+($y_width-1),$x_grid);
                 $im->fill(2,$_->{from_y}+1,$x_grid);#fill the rectangle
                 $im->line($_->{from_x},$_->{from_y},$_->{to_x}+20,$_->{to_y},$black);
                 ## x,y
                 $im->string(gdSmallFont,20,$_->{from_y}+$y_width+4,$ref->{'yy'}->[$len-$i]->{y},$black);
                 $i++;
 
         }

         $im->line(0,$y_len-$y_width-1,$x_len,$y_len-$y_width-1,$black);
         $im->line($Y_WIDTH_GRID,0,$Y_WIDTH_GRID,$y_len,$black);
         $im->string(gdSmallFont,20,4,$ref->{max_y_value},$black);
         if($ext_title){
#                 require Encode;
#                 my $r = Unicode::Map8->new("cp1251"); 
#                 my $title = $r->to16($ext_title); 
                $im->string(gdGiantFont,int($x_len/1.5),int($y_len/6),$ext_title,$black) 
                
            
          }
#        
# 
         $i=1;
         $y_len-=1;
#       
  $im->line(0,$y_len,$x_len,$y_len,$black);
        $im->line($x_len-1,0,$x_len-1,$y_len,$black);
        $im->line(0,0,$x_len,0,$black);
        $im->line(0,0,0,$y_len,$black);  
	
       foreach(@{$ref->{'xx'}})
       {
                         
           #     $im->rectangle($Y_WIDTH_GRID+$step*$i+1,$y_len-$y_width,$MONTH_COUNT+$step*($i+1)+1,$y_len,$x_grid);
       
     
                         $im->line($Y_WIDTH_GRID+$step*$i,$y_len,$Y_WIDTH_GRID+$step*$i,$y_len-$y_width,$black);
                          $im->string(gdTinyFont,$Y_WIDTH_GRID+$step*$i-int($x_width/2),$y_len-($y_width-2),$_->{x2}.$_->{x1},$black);
          	
                          $i++;   
                  $im->line($_->{from_x},$_->{from_y},$_->{to_x},$_->{to_y},$black);
  		  if($_->{isweekend})
                  {
                          $im->fill($Y_WIDTH_GRID+$step*($i-1)-2,$y_len-($y_width/2),$red );#fill the rectangle
                  }
                  else
                  {
		      
                 	      $im->fill($Y_WIDTH_GRID+$step*($i-1)-$step/2,$y_len-($y_width/2),$x_grid);
			
			#fill the rectangle
                  }  
        
        }

##there we draw the y grid with numbers 

      
      
#borders
      
        my $diagonal_brush = new GD::Image(2,2);
        my $black_ = $diagonal_brush->colorAllocate(0,0,0);
        $diagonal_brush->filledArc(1,1,1,1,0,1,$black_);
        $im->setBrush($diagonal_brush);
        

        # make the background transparent and interlaced
        $im->transparent($white);
        $im->interlaced('true');
        return  $im->png;




}

##fuc

sub get_grad
{
  my ($max,$size)=@_;
  my $y={};
  my $l=length($max);
  my $pow=1;
  if($l>3)
  {
     $l-=3;
     $pow=pow(10,$l);

  }
 
  $max=int($max/$pow);
  my $item;
  if($max>10)
  {
    $item=$max/11;
   
  }else
  {
    $item=ceil(($max/11)*100)/100;
  }

  my @result;
  my ($i,$j);

  for($i=10,$j=0;$i!=0;$j++,$i--)
  {
     push @result,{y=>format_float(($item*$i)*$pow),from_x=>0,to_x=>$size,
                  from_y=>20*$i,to_y=>20*$i};
  }
  return {yy=>\@result,max_y_value=>format_float ($item*11*$pow)};
}

sub pow
{
   my ($num,$pow)=@_;
   my $ret=1;
   
   for(my $i=$pow;$i!=0;$i--)
   {
      $ret=$ret*$num;

   }
   return $ret;
}

sub find_min
{
    my $ref=shift;
    my $min=31;
    foreach(keys %$ref)
    {
    if($min>$_)
        {
          $min=$_;
        }
    }
    return $min;
}

sub find_max_y
{
    my $ref=shift;
    my $maxy=0;
    foreach(keys %$ref)
    {
    if($maxy<$ref->{$_})
        {
          $maxy=$ref->{$_};
        }
    }
    return $maxy;
}

sub get_grid
{
  my ($length,$rows,$size)=@_;
  my @y;

  $size=22 unless($size);
  $rows=11  unless($rows);


  for(my $i=1;$i<$rows;$i++)
  {

        push @y,{from_y=>220-($i-1)*$size,to_y=>220-($i-1)*$size,from_x=>$size,to_x=>$length+22};

  }
  
 return \@y;
}

sub find_max
{
  my $ref=shift;
  my $t=0;
  foreach(keys %$ref)
  {
   $t=$_  if($t<$_);
 }
return $t;

}



sub day_graph
{
        my $stm=shift;
        my $ref=$dbh->selectall_hashref($stm,'y');
        my (@x,@y,$maxy);
        $maxy=0;
        for(my $r=0;$r<24;$r++)
        {
        
                $maxy=$ref->{$r}->{count} if($ref->{$r}->{count}>$maxy);
        
        
        }
        
        my $one_field=$maxy/11;
        my $my_y;
 
        for(my $r=0;$r<24;$r++)
        {
        
                if($ref->{$r}->{count})
                {
                        $my_y=$ref->{$r}->{count};
                        $my_y=20*($my_y/$one_field);
                        push @y,{x=>($r-1)*20,y=>$my_y};#+1 because the 
                }
                else
                {
                        push @y,{x=>$r*20,y=>0};
                }
        }

        my $grad=get_grad(ceil($maxy),520);
        my (@xx);##filling the x cordinate
        for(my $i=1;$i<=24;$i++)
        {
                push @xx,{x1=>int($i%10),x2=>int($i/10)};
        }

        return {'stat'=>\@y,max_y_value=>$grad->{max_y_value},yy=>$grad->{yy},xx=>\@xx};
}
sub year_graph
{
         my ($stm,$draw_params)=@_;
         my $tmp=0;

         my (@x,@y,$str,$t_y);
	 my $ref=$dbh->selectall_hashref($stm,'y');
	        
         my ($x,$max);
         $max=0;
         $tmp=0;
         map{$max=$ref->{$_}->{count} if($ref->{$_}->{count}>$max)} keys  %$ref;
         my $field;
         $field=$max/10 if($max);
         
         my $tmp_x=0;   
         $tmp=0;

###12 -monthes
     my $grad=get_grad(ceil($max),$draw_params->{whole_width}+$Y_WIDTH_GRID);
##set the number of points ,and the value of step 
   	$x=0;
    for(my $i=1;$i<=$draw_params->{points_number};$i++)
    {
       $t_y=$ref->{$i}->{'count'};
    

       $t_y=0 unless($t_y);

       $t_y=($t_y*220)/$max  if($t_y);

    
            
       push @y,{from_y=>$tmp,to_y=>$t_y,y=>$t_y,from_x=>$x,to_x=>$x+$draw_params->{x_step},x=>$x};
        
       $tmp=$t_y;
       $x+=$draw_params->{x_step};
    }
   
    

        
      my (@xx);##filling the x cordinate
      for(my $i=1;$i<=$MONTH_COUNT;$i++)
      {
           push @xx,{x1=>int($i%10),x2=>int($i/10)};
      }
  #use Data::Dumper;
 #   die Dumper $grad->{yy};
    
      return {'stat'=>\@y,'max_y_value'=>$grad->{max_y_value},yy=>$grad->{yy},xx=>\@xx};
}

sub month_graph
{
  my $stm=shift;
  my $ext_params=shift;
  my $ref=shift;
  $ref=$dbh->selectall_arrayref($stm) unless($ref);

  my (@result,$x1,$y1,$y2,$maxy);
  my (%items,%normal_item,%weekend);
 

  
  my ($year,$month);
  foreach(@$ref)
  {

     $weekend{$_->[0]}=($_->[2]==1||$_->[2]==7);
     $year=$_->[3];
     $month=$_->[4];
     $items{$_->[0]*10}=$_->[1];
     $normal_item{$_->[0]}=$_->[1];

  }
  ###getting weekends
  my $tmp;#=$dbh->selectrow_array(qq[SELECT DAYOFWEEK('$year-$month-$i') ]);
        
  for(my $z=1;$z<=$month{$month};$z++)
  {

        unless(defined($weekend{$z}))
        {
        	$tmp=$dbh->selectrow_array(qq[SELECT DAYOFWEEK('$year-$month-$z')]);
        	$weekend{$z}=($tmp==1||$tmp==7);
        
        }
   }

  my $max=find_max(\%items);
  my $min=find_min(\%items);
  $maxy=find_max_y(\%items);
 
  my $one_field=$maxy/11;
  $one_field=1 unless($one_field);
 
 

    my ($my_y,$ostatok);

    for(my $r=1;$r<=$month{$month};$r++)
    {
        if($normal_item{$r})
        {
            $my_y=$normal_item{$r};
            
            $my_y=20*($my_y/$one_field);
    
            push @result,{x=>($r-1)*20,y=>$my_y};
    
        }
        else
        {
    
            push @result,{x=>($r-1)*20,y=>0};
        }
    }


  my $grad=get_grad(ceil($maxy),660);

  ##make image availible to fix into browser
  ##for it we modify its values
  my $len=length($maxy);

  if($len>3)
  {
    $len-=3;
    my $pow=pow(10,$len);
    map {$items{$_}=int($items{$_}/$pow)} keys %items;
  }

  my $size=$ref->[0]->[0];
  my (@xx);##filling the x cordinate
    
  for(my $i=1;$i<=$month{$month};$i++)
  {
       push @xx,{x1=>int($i%10),x2=>int($i/10),isweekend=>$weekend{$i}};
  }
	
    return {'stat'=>\@result,xx=>\@xx,yy=>$grad->{yy},max_y_value=>format_float($maxy)};
   
   
}

1;
