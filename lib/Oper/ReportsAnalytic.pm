package Oper::ReportsAnalytic;
use strict;
use base 'CGIBase';
use SiteConfig;
use SiteDB;
use SiteCommon;
use POSIX;
use ReportsProcedures;
use Storable qw( &nfreeze &thaw );
sub setup 
{
        my $self=shift;
        $self->start_mode('list');
        $self->run_modes(
                        'AUTOLOAD'   =>'list',
                        'list'   =>'list',
                        'save_common_report_without'=>'save_common_report_without',
                        'view_report_without'=>'view_report_without'
       );      
}
my $proto;
sub get_right
{
        my $self=shift;
       $proto={
            'table'=>"reports_without_analytic",  
            'page_title'=>'Динамика баланса',
            'sort'=>'cr_id DESC',

            'template_prefix'=>"reports_analytic",
             fields=>
                [      
                                {'field'=>"cr_ts", "title"=>"Дата", 'filter'=>"time"},
                ]
                };
        return 'reports_analytic';
}
sub list{
   my $self = shift;
   return $self->proto_list_short($proto);
}

sub save_common_report_without{
    my $self=shift;
    my @last_ts=$dbh->selectrow_array(q[SELECT 
        cr_ts FROM reports_without 
        WHERE cr_status='created'   ORDER BY cr_id DESC LIMIT 1]);
   
    my $XML={};
    my $transfer_info=exclude_system_exchange(@last_ts);

    my $permanent_cards=&get_permanent_cards_without();
    my $non_identifier=&get_non_identifier_without();

    my $firm_balances=&get_firms_balances_without();
    my $state=restore_state();
    my $master_cards=&get_kcards_without($state,@last_ts);
    
    $XML->{permanent_cards}=$permanent_cards;
    $XML->{non_identifier}=$non_identifier;
#   $XML->{pay_credits}=$pay_credits;
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

    my $rates=get_rates();

    my $delta={ usd=> $XML->{delta_usd},eur=>$XML->{delta_eur},uah=>$XML->{delta_uah} };
    my ($conclusion_sums,$common)=get_concl_kcards_without($master_cards,$delta);
    
    
    
    $XML->{conclusions_sum}=$conclusion_sums;
    $XML->{incom_usd}=$XML->{delta_usd}+$common->{usd};
    $XML->{incom_eur}=$XML->{delta_eur}+$common->{eur};
    $XML->{incom_uah}=$XML->{delta_uah}+$common->{uah};
    $XML->{of_usd}=format_float($common->{usd});
    $XML->{of_eur}=format_float($common->{eur});
    $XML->{of_uah}=format_float($common->{uah}); 
    



    my $serialized = nfreeze($XML);     
    
#    $delta->{incom_usd}=$delta->{delta_usd}+$common->{usd};                                                                                                  
   $delta->{incom_eur}=($delta->{eur}+$common->{eur})*$rates->{eur};                                                                                                  
   $delta->{incom_uah}=($delta->{uah}+$common->{uah})*$rates->{uah};
     
   $delta->{incom_usd}=($delta->{incom_eur}+ $delta->{incom_uah})+$delta->{usd}+$common->{usd}; 
     
   $delta->{incom_eur}=0;                                                                             
   $delta->{incom_uah}=0;         
     
   $delta->{usd}+=$delta->{eur}*$rates->{eur};                                                                             
   $delta->{usd}+=$delta->{uah}*$rates->{uah};  
     
         $delta->{eur}=0;                                                                                                                              
         $delta->{uah}=0;

    $dbh->do(q[INSERT INTO reports_without_analytic SET
    cr_comments=?,
    cr_xml_detailes=?,
    cr_last_ts=?,
    cr_delta_usd=?,cr_delta_eur=?,cr_delta_uah=?,cr_income_usd=?,cr_income_eur=?,cr_income_uah=?,cr_system_state=?
    ],undef,'отчетег))',$serialized,$last_ts[0],$delta->{usd},$delta->{eur},$delta->{uah},$delta->{incom_usd},
    $delta->{incom_eur},$delta->{incom_uah},save_state());

    $self->header_type('redirect');
    return $self->header_add(-url=>'?do=list');
    

}
sub view_report_without{
    my $self=shift;
    my $id=$self->query->param('id');
    my $r=$dbh->selectrow_hashref(q[SELECT * FROM 
    reports_without_analytic WHERE cr_id=?],undef,$id);
    
    unless($r->{cr_id})
    {
            $self->header_type('redirect');
            return $self->header_add(-url=>'?do=list');


    }
    my %params = %{thaw($r->{cr_xml_detailes})};
    $params{view_not_edit}=1;
    my $tmpl=$self->load_tmpl('common_reports_without.html');
    foreach(keys %params)
    {
        $self->{tpl_vars}->{$_}=$params{$_};
    }

    ####
    my $output='';
    $r->{cr_ts}=format_date($r->{cr_ts});
    $self->{tpl_vars}->{page_title}="отчета за : $r->{cr_ts},дельта : $self->{tpl_vars}->{delta_usd} USD,
    $self->{tpl_vars}->{delta_eur} EUR, $self->{tpl_vars}->{delta_uah} ГРН";
    $self->{tpl_vars}->{date}=$r->{cr_ts};
    $self->{tpl_vars}->{no_menu}=1;
    $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || 
    $tmpl->error();
     return $output; 
}
1;



