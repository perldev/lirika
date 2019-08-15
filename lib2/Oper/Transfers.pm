package Oper::Transfers;
use strict;
use Rights qw( get_rights );
use base q[CGIBase];
use SiteCommon;
use SiteConfig;
use SiteDB;
my $proto;
sub get_right{
             my $self=shift;
              

            $proto={
	            'table'=>"transfers",  
	            'page_title'=>'Трансферы',
	            'template_prefix'=>"transfers",
	            'need_confirmation'=>1,
	            'id_field'=>'at_id',
	            'sort'=>'t_date DESC',
	            'fields'=>[
	            {'field'=>"t_id", "title"=>"ID", "no_add_edit"=>1,filter=>'=','filter_invisible'=>'1'},    
	            {'field'=>"t_date", "no_add_edit"=>1, "title"=>"Дата",'filter'=>'time'},
	            {'field'=>"t_aid1",title=>'Отправитель',category=>'accounts',
                    "type"=>"select",
                    'filter'=>'=',
            
                },
	            {
                    'field'=>"t_aid2",title=>'Получатель',category=>'accounts',
                    filter=>'=',"type"=>"select",
                    'filter'=>'=',
            
                },
	            {'field'=>"common_sum", "title"=>"Сумма",'filter'=>"=",'positive'=>1},


                {'field'=>"exchange1", "title"=>"Обмен у получателя",'system'=>1,"category"=>"exchange",},

	            {'field'=>'ts',title=>'Дата',category=>'date'},
	            {'field'=>"ct_currency", "title"=>"Валюта"
	            , "type"=>"select"
	            , "titles"=>\@currencies
	            ,'filter'=>"="
	            },
	            {
	            'field'=>"t_comment", "title"=>"Назначение", 'default'=>"Перевод ",
	            'filter'=>'like'
	            },
	            {'field'=>"o_id", "title"=>"Оператор"
	            , "no_add_edit"=>1, "category"=>"operators"
	            },
	            ],
	            
            };  
                $proto->{fields}->[2]->{titles}=get_accounts_simple();
                $proto->{fields}->[3]->{titles}=get_accounts_simple();


                return 'transfers';
}
sub setup 
{
        my $self=shift;
 	 $self->run_modes(
			'AUTOLOAD'=>'list',
                        'add'=>'add',
                        'del'=>'del',
                        add_many=>'add_many',
                        add_many_confirm=>'add_many_confirm',
                        add_many_do=>'add_many_do'
                        );   
        


}


sub list
{
   my $self = shift;
   $proto->{fields}->[4]->{field}='t_amnt';
                                                                                            
   $proto->{fields}->[7]->{field}='t_currency';
   
   return $self->proto_list($proto);
}
sub add_many
{
    my $self=shift;
    my $tmpl=$self->load_tmpl('add_many_transfers.html');
    my $output='';
    $self->{tpl_vars}->{page_title}='Добавление нескольких трансферов';
    $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
    return $output;

}
sub add_many_confirm
{
        my $self=shift;
        my %params;

        map { $params{$_}=$self->query->param($_) } $self->query->param();
        my $forms_number;
        my %forms;
        my %check_hash=('t_comment'=>\&check_text,
                        't_aid1'=>\&check_user,
                        't_aid2'=>\&check_user,
                        't_currency'=>\&check_currency,
                        't_amnt'=>\&check_number,
                        'ts'=>\&check_ts
                        );
        my %ru_names=(  
                        't_comment'=>"Комментарии",
                        't_aid1'=>"Отправитель",
                        't_aid2'=>"Получатель",
                        't_currency'=>"Валюта",
                        't_amnt'=>"Сумма",
                        'ts'=>'Дата'        
                    );
      
        
        foreach(1..5)
        {
           next     if( check_number( $params{"t_amnt$_"} ) );
           my %confirm;

           foreach my $key (keys %check_hash){

                die " Поле '$ru_names{$key}' в форме $_ заполненно не верно \n"    if( $check_hash{$key}->( $params{"$key$_"} ) );
                $confirm{$key}=$params{"$key$_"};
                

           }
            
           my $a=get_account_name($confirm{'t_aid1'});
           $confirm{error_msg}="Баланс данной карточки уйдет в минус \n" if($a->{ac_id}==$CLIENT_CATEGORY&&($a->{lc($params{'t_currency'})}-$params{"t_amnt$_"})<0);
                            
        
                    
         

           $confirm{"t_amnt"}=format_float_inner($confirm{"t_amnt"});
           $confirm{"formated_ts"}=format_date($confirm{"ts"});
           $confirm{"formated_t_aid1"}=get_account_name($confirm{"t_aid1"})->{account_title};
           $confirm{"formated_t_aid2"}=get_account_name($confirm{"t_aid2"})->{account_title};
           $self->{tpl_vars}->{"confirm_params_$_"}=\%confirm;

        }

    my $output;
    my $tmpl=$self->load_tmpl('add_many_transfers_confirm.html');
    $self->{tpl_vars}->{page_title}='Добавление нескольких трансферов подтверждение';
    $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
    return $output;



}
sub add_many_do
{
        my $self=shift;
        my %params;
         map { $params{$_}=$self->query->param($_) } $self->query->param();
        my $forms_number;
        my %forms;
        my %check_hash=('t_comment'=>\&check_text,
                        't_aid1'=>\&check_user,
                        't_aid2'=>\&check_user,
                        't_currency'=>\&check_currency,
                        't_amnt'=>\&check_number,
                        'ts'=>\&check_ts
                        );
        my %ru_names=(  
                        't_comment'=>"Комментарии",
                        't_aid1'=>"Отправитель",
                        't_aid2'=>"Получатель",
                        't_currency'=>"Валюта",
                        't_amnt'=>"Сумма",
                        'ts'=>'Дата'        
                    );
        my @transes;
        foreach(1..5)
        {
           next     if( check_number( $params{"t_amnt$_"} ) );
           my %confirm;

           foreach my $key (keys %check_hash) 
           {
                die " Поле '$ru_names{$key}' в форме $_ заполненно не верно \n"    if( $check_hash{$key}->( $params{"$key$_"} ) );
                $confirm{$key}=$params{"$key$_"};
                

           }
            push @transes,\%confirm;

        }
        map {$self->add_transfer($_) } @transes;
        $self->header_type('redirect');
        return  $self->header_add(-url=>'?');

}
sub add
{
   my $self = shift;
   $proto->{'page_title'}='Добавить трансфер';
    delete $proto->{fields}->[2]->{titles};
    delete $proto->{fields}->[2]->{type};
    delete $proto->{fields}->[3]->{titles};
    delete $proto->{fields}->[3]->{type};
    my $ct_amnt=$self->query->param('t_amnt');
    if($ct_amnt){
            my $a=get_account_name($self->query->param('t_aid1'));
            

            my $currency=$self->query->param('t_currency');
            $ct_amnt=~s/[ \\]//g;
            $ct_amnt=~s/[,]/\./g;
            $self->query->param('t_amnt',$ct_amnt);
            $self->{tpl_vars}->{error_msg}="Баланс данной карточки уйдет в минус \n" if($a->{ac_id}==$CLIENT_CATEGORY&&($a->{lc($currency)}-$ct_amnt)<0);
                    

            
    }
 #   use Data::Dumper;

   return $self->proto_add_edit('add', $proto);
}
sub add_transfer
{
  my $self=shift;

  my $params = shift;    
  my %hash=%{$params};
  my $tid = $self->add_trans({
            t_name1 =>$hash{t_aid1},
            t_name2 => $hash{t_aid2},
            t_currency =>  $hash{t_currency},
            t_amnt =>$hash{t_amnt} ,
            t_comment =>$hash{t_comment},
      });
    $hash{ts}=~s/["'\\]//g;

    $dbh->do(q[INSERT INTO accounts_transfers SET at_tid=?],undef,$tid);
    my $atid=$dbh->selectrow_array(q[SELECT last_insert_id()]);

    $dbh->do(qq[
        INSERT INTO accounts_reports_table(ct_id,ct_aid,ct_comment,ct_oid,
        o_login,ct_fid,f_name,ct_amnt,ct_currency,comission,
        result_amnt,ct_comis_percent,ct_ext_commission,
        ct_date,e_currency2,rate,ct_eid,ct_ex_comis_type,ts,col_ts,ct_status,col_color)
        select 
        t_id,
        `transactions`.`t_aid2` AS `t_aid2`,
        `transactions`.`t_comment` AS   `t_comment`,
        `operators`.`o_id` AS `o_id`,`operators`.`o_login` AS `o_login`,
        `transactions`.`t_aid1` AS 
        `t_aid1`,`accounts`.`a_name` AS `a_name`,`transactions`.`t_amnt` AS 
        `t_amnt`,`transactions`.`t_currency` 
         AS `t_currency`,
        0 AS `0`,
        `transactions`.`t_amnt` AS `t_amnt`,
        0 AS `0`,
        0 AS `0`,
        '$hash{ts}',
        `transactions`.`t_currency` AS `t_currency`,
        0 AS `0`,
        0 AS `0`,'transaction' AS `transaction`,
        '$hash{ts}',
        '0000-00-00 00:00:00',
        `transactions`.`del_status` AS `del_status`,
        16777215  
        from ((`transactions` join `operators`) join `accounts`) 
        WHERE (1 and (`operators`.`o_id` = `transactions`.`t_oid`) 
 
        AND (`accounts`.`a_id` = `transactions`.`t_aid1`))
        AND t_id=?
    
    ],undef,$tid);
#   AND ((`transactions`.`t_aid1` > 1) and (`transactions`.`t_aid2` > 1)) 
    $dbh->do(qq[
        INSERT INTO accounts_reports_table(ct_id,ct_aid,ct_comment,ct_oid,
        o_login,ct_fid,f_name,ct_amnt,ct_currency,comission,
        result_amnt,ct_comis_percent,ct_ext_commission,
        ct_date,e_currency2,rate,ct_eid,ct_ex_comis_type,ts,col_ts,ct_status,col_color)
        select 
        t_id,
        `transactions`.`t_aid1` AS `t_aid1`,
        `transactions`.`t_comment` AS `t_comment`,
        `operators`.`o_id` AS `o_id`,
        `operators`.`o_login` AS `o_login`,
        `transactions`.`t_aid2` AS `t_aid2`,
        `accounts`.`a_name` AS `a_name`,
        -(`transactions`.`t_amnt`) AS `-t_amnt`,
        `transactions`.`t_currency` AS `t_currency`,
        0 AS `0`,
        -(`transactions`.`t_amnt`) AS `-t_amnt`,
        0 AS `0`,0 AS `0`,
        '$hash{ts}' ,
        `transactions`.`t_currency` AS `t_currency`,0 AS `0`,0 AS `0`,
        'transaction' AS `transaction`,
        '$hash{ts}',
        '0000-00-00 00:00:00',
        `transactions`.`del_status` AS `del_status`,
        16777215  
        from ((`transactions` join `operators`) join `accounts`) 
        where (1 and (`operators`.`o_id` = `transactions`.`t_oid`) 
        AND (`accounts`.`a_id` = `transactions`.`t_aid2`))
        AND t_id=?
    
    ],undef,$tid);
    return ;

}


sub proto_add_edit_trigger
{

  my $self=shift;
  my $params = shift;    
##by idea all checkings are finishing
  if($params->{step} eq 'before'){
	my %hash;
	map{ $hash{ $_ }=$self->query->param($_)  } $self->query->param();
	
    

    $hash{t_amnt}=$hash{common_sum};
    $hash{t_currency}=$hash{ct_currency};
 
    $self->add_transfer(\%hash);
 
   if($hash{exchange_yes}){
           my $eid=$self->add_exc(
            {
                e_date=>$hash{ts},
                a_id=>$hash{t_aid2},
                e_currency1=>$hash{t_currency},
                e_currency2=>$hash{currency},
                rate=>$hash{rate},
                type=>'cashless',
                e_amnt1=> $hash{t_amnt},
                e_comment=>'Автообмен при трансфере  по курсу'.$hash{rate}
            });

    
     }        
            
    
    }
    
    
	
    $self->header_type('redirect');
	return  $self->header_add(-url=>'?');

}





1;