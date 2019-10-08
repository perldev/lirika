package CGIBase;
#use Spreadsheet::WriteExcel;
use strict;
use Encode qw/from_to encode decode/;
use base qw[CGI::Application];
use Exporter;    
use Template;
use POSIX;
use lib qq(/usr/lib/perl/5.8/auto/);
use Storable qw( &freeze &thaw );
use SiteConfig;
use SiteDB;
# use MyFormat;
use SiteCommon;
use Rights;
use Data::Dumper;
use CGI;
use Russian;
use CGI::Carp qw(fatalsToBrowser);

use base 'ListBase';
# $SIG{__DIE__}=\&handle_errors;
our @EXPORT = qw(
add_trans

);
sub handle_errors
{
       return if $^S; # for eval die
        my $msg=join ',', @_;
        my @arr=split(':',$msg);
        $msg=$arr[1];
        $msg=~s/at(.*)//;
	
        my $tmpl = Template->new(
	    {
		    INCLUDE_PATH => '../tmpl',
		    INTERPOLATE  => 1,               # expand "$var" in plain text
		    POST_CHOMP   => 1,               # cleanup whitespace 
		    EVAL_PERL    => 1,       
	    }
        );

        
        my $vars = {};
        $vars->{error}=$msg;
        $tmpl->process('proto_error.html',$vars) || die $tmpl->error();
        $SIG{__DIE__}=undef;
}
sub get_head_rates
{
	my $ref=$dbh->selectrow_hashref(q[SELECT hr_domi as usd_uah_mb,hr_rate_mb as usd_uah,
		    hr_rate_street as cusd_uah,hr_rate_cross as eur_usd,
		    hr_rate_cross_street as eur_usd_street 
		    FROM header_rates
		    WHERE DATE(hr_date)=DATE(current_timestamp) ORDER BY hr_id DESC LIMIT 1]);


	
	return $ref;

}

sub load_tmpl
{
	
   my ($self,$file)=@_;
    $self->{tpl_file}=$file;
    $self->{tpl_vars}->{user_id}=$self->{user_id};
	$self->{tpl_vars}->{no_script}=$self->{no_script};
	$self->{tpl_vars}->{no_header_menu}=$self->{no_header_menu};
	    
        my $rights=$self->{rights};
        my $sz=keys %$rights;
        unless($sz)
	{
			$rights->{no_rights}=1;
			$self->{tpl_vars}->{rights}=$rights;
			
	}else
	{
			$self->{tpl_vars}->{rights}=$rights;
			$self->{tpl_vars}->{tabs}=$self->{tabs};
			
	}
	my $max=$dbh->selectrow_array(q[SELECT count(*) FROM joke]);
	$self->{tpl_vars}->{my_comment}=$dbh->selectrow_array(q[SELECT 
	comment 
	FROM joke WHERE id=?],undef,int(rand($max)));
#	print $self->{tpl_vars}->{my_comment};

	my $array=$dbh->selectall_arrayref(q[SELECT 
	id,date,comment,title FROM operators_notes WHERE date=DATE(current_timestamp) AND 
	o_id=?],undef,$self->{user_id});
	my @notes;
	map{push @notes,{title=>$_->[3],comment=>$_->[2],id=>$_->[0]} } @$array;
	
	my $rates=get_head_rates();
	$self->{tpl_vars}->{cusd_uah}=$rates->{cusd_uah};
	$self->{tpl_vars}->{eur_usd}=$rates->{eur_usd};
	$self->{tpl_vars}->{usd_uah}=$rates->{usd_uah};
	$self->{tpl_vars}->{eur_usd_street}=$rates->{eur_usd_street};
	$self->{tpl_vars}->{usd_uah_mb}=$rates->{usd_uah_mb};
	$self->{tpl_vars}->{form_action}=$ENV{SCRIPT_NAME};
	    
	$self->{tpl_vars}->{operators_notes}=\@notes;
	$self->{tpl_vars}->{login}=$self->{login};
	$self->{tpl_vars}->{greeding}=$self->{greeding};
    $self->{tpl_vars}->{o_menu_type}=$self->{o_menu_type};

    #$self->{o_menu_type}=$o_menu_type;

 	#$self->{tpl_vars}->{chat}=$self->{session_data}->{chat} eq 'yes' if();
        
#map{ $self->{tpl_vars}->{$_}=1 } keys %$rights;
        #print $DIR;        
	my $template = Template->new(
	{
        	INCLUDE_PATH => $DIR,
                INTERPOLATE  => 1,               # expand "$var" in plain text
                POST_CHOMP   => 1,               # cleanup whitespace 
                EVAL_PERL    => 1,
		CACHE_SIZE => 256,
		#COMPILE_EXT => '.ttc', # turn off caching 
		#COMPILE_DIR=>$COMPILE_DIR
	}
        );

   return $template;
}

sub cgiapp_init {
    my $self = shift;

#put GET params to POST params, as in PHP
    $self->{tpl_vars}={};
  
    map { $_->{name}=$_->{title} } @currencies;
    $self->{tpl_vars}->{currencies}=\@currencies;
    $self->{tpl_vars}->{time_filter_rows} = \@time_filter_rows;
    $self->header_add(-type=>'text/html',-charset=>'windows-1251');
    $self->mode_param('do');
}

sub cgiapp_postrun
{	
    my $self=shift;
    CGI::_reset_globals(); 
    database_disconnect(); 
    $self->query->param($_,'') foreach($self->query->param());
    $self->query->url_param($_,'') foreach($self->query->url_param());

}

sub get_data{

  my $self=shift;
  my $data=$self->query->param('data');
  my $name=$self->query->param('name');
  open(my $fh,'>/tmp/'.$name);
  binmode($fh);
  print $fh $data;
  close($fh);
  return 'ok';
  


}



sub cgiapp_prerun 
{
   my $self = shift;
    database_connect();
    $TIMER  = RHP::Timer->new();
    $TIMER->start('fizzbin');
    $dbh->do("SET charset cp1251;");                                                                                                  
    $dbh->do("SET names   cp1251;");  
#   return   if($self->{non_login});
##FOR USING UNDER FAST_CGI
    $self->{__QUERY_OBJ} = $self->cgiapp_get_query;
   ###from cgiapp_init
        my %url_params = map {$_=>$self->query->url_param($_)} $self->query->url_param();
        ##my %params = map {$_=>$self->query->param($_)} $self->query->param();
        ##foreach my $key (keys %url_params)
        ##{
        ##        $self->query->param($key, $url_params{$key}) unless(defined $params{$key});
       ## }

    my $rows=get_accounts();
    my $firms=get_firms();
    $self->{tpl_vars}->{my_firms}=$firms;
    $self->{tpl_vars}->{rate_forms} = \@RATE_FORMS;
    $self->{tpl_vars}->{filter_accounts} = get_permit_accounts_simple($self->{user_id}); # $rows;
   ##finishing code from it
    $self->{count}++;
    my $session=$self->query->cookie('session');
    $session=$self->query->param('session') unless($session);
     #die "session = ".$self->query->param('session') unless($session);
     $self->{user_id}=$self->get_user_by_session($session);

    $self->run_modes(
                        'login'=>'login',
                        'login_do'=>'login_do',
                        'denied'=>'denied',
                        'logout'=>'logout',
                        'export_excel'=>'export_excel',
                        'get'=>'get',
			'get_data'=>'get_data'
                    );


#     my $r=$self->get_right();       
     if($self->query->param('do') eq 'get_data'){

	      $self->prerun_mode('get_data');   
	      return; 
	      
	}
   
    my $rights=get_rights($self->{user_id});
	


	if($self->query->param('do') eq 'logout')
	{
		$self->prerun_mode('logout');   
		return; 
	}
	elsif($self->query->param('do') eq 'login_do')
	{
	#    die "here";
		$self->prerun_mode('login_do');   
		return; 
	}elsif(!$self->{user_id})##if chat then the empty screen
	{
		$self->prerun_mode('login');     
		return;
	}
      		

   

   $rights->{'index'}=1;
   $self->{rights}=$rights;
   $self->{"accounts2view"} =  get_permit_accounts_simple($self->{user_id});
   $self->{tpl_vars}->{filter_accounts} = $self->{"accounts2view"};
    my $r=$self->get_right();
#   my $r=$self->get_right();
# $self->{tabs}->{current}=$r;
   $self->{tabs}={};
   $self->{rights}->{current}=$r;
   $self->prerun_mode('denied')      unless($rights->{$r});
  
   return $self->prerun_mode('get') if($self->query->param('do') eq 'get');

##get through all right and setting a name for it
   my $tabs=get_desc_rights();
   
   
   my @oper_tabs;
   foreach( keys %$rights){
        $self->{tabs}->{$_}={};
        $self->{tabs}->{$_}->{title}=$tabs->{$_}->{title};
        $self->{tabs}->{$_}->{script}=$tabs->{$_}->{script};

    }
    

		  



}
sub empty
{
	my $self=shift;
	return '';

}

sub denied
{
        my $self=shift;
        my $tmpl=$self->load_tmpl('denied.html');
        my $output = "";
        $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
        return $output;


}
sub add_trans_firm
{
	my ($self,$ref)=@_;
	
	$ref->{user_id}=$self->{user_id};
	
	($ref->{f_id1},$ref->{f_name1})=$dbh->selectrow_array(q[SELECT f_id,f_name FROM firms WHERE f_id=? ],undef, $ref->{f_id1});

         die "$TRANSLATE{firm_not_reg} \n" unless($ref->{f_id1});

	($ref->{f_id2},$ref->{f_name2})=$dbh->selectrow_array(q[SELECT f_id,f_name FROM firms WHERE f_id=? ],undef,$ref->{f_id2});

        die "$TRANSLATE{firm_not_reg}"     unless($ref->{f_id2});

	$ref->{comment}="$TRANSLATE{transit}   : $TRANSLATE{s} $ref->{f_name1} $TRANSLATE{on}  $ref->{f_name2} $ref->{amnt} $ref->{currency}"  	unless($ref->{comment});

        my $field=$avail_currency_firms->{$ref->{currency}};
        $ref->{account_bill}=$field;
	die "$TRANSLATE{cur_no_support} \n"  unless($field);
        $ref->{date}=$dbh->selectrow_array('SELECT current_timestamp')	unless($ref->{date});
        $ref->{amnt}=~s/[,]/\./g;
	$ref->{amnt}=~s/[ \"\'\\]//g;

	die "$TRANSLATE{bad_sum_format}\n"  unless($ref->{amnt}=~/[\-]{0,1}\d+\.{0,1}\d{0,2}/);
  
        $dbh->{AutoCommit} = 0;  # enable transactions, if possible
        $dbh->{RaiseError} = 1;
        my ($t_id1,$t_id2);

        eval{
                ($t_id1,$t_id2)=do_trans_firm($ref);       # and updates
                $dbh->commit;
                $dbh->{AutoCommit} = 1;   # commit the changes if we get this far
	};

      if ($@) {
                warn "Transaction aborted because $@";
                my $qwe = "$@";
# now rollback to undo the incomplete changes
# but do it in an eval{} as it may also fail
                eval { $dbh->rollback };
		my $r=$dbh->errstr;
                 die "$TRANSLATE{to_developer} : code 4 ($qwe)\n"; 
# add other application on-error-clean-up code here
	}

        return ($t_id1,$t_id2);   


		
}
sub do_trans_firm
{
        my $ref=shift;
      
	my $res=$dbh->do(qq[UPDATE 
	firms SET $ref->{account_bill}=$ref->{account_bill}+? WHERE 
        f_id=$ref->{f_id1}   ],undef,-1*$ref->{amnt}); 
	

         die "$TRANSLATE{to_developer}  : code 1\n" unless($res eq 1);
       
	$res=$dbh->do(qq[UPDATE firms SET $ref->{account_bill}=$ref->{account_bill}+? WHERE 
        f_id=$ref->{f_id2}],undef,$ref->{amnt});

 	die "$TRANSLATE{to_developer}   : code 3\n" unless($res eq 1);

### there is must be some checking here
	$dbh->do(q[INSERT 
	INTO 
	cashier_transactions 
	SET 
	ct_oid=?,
	ct_fid=?,
	ct_amnt=?,
	ct_currency=?,
	ct_date=?,
	ct_ts=current_timestamp,
	ct_status='transit',
	ct_comment=?],
	undef,$ref->{user_id},
	$ref->{f_id1},-1*$ref->{amnt},$ref->{currency},$ref->{date},$ref->{comment});
	my $id1=$dbh->selectrow_array(q[ SELECT last_insert_id()]);
		

	$dbh->do(
	q[INSERT 
	INTO cashier_transactions
	SET
	ct_oid=?,
	ct_fid=?,
	ct_amnt=?,
	ct_ts=current_timestamp,
	ct_currency=?,
	ct_date=?,
	ct_status='transit',
	ct_comment=?],undef,$ref->{user_id},
	$ref->{f_id2},$ref->{amnt},$ref->{currency},$ref->{date},$ref->{comment});
	my $id2=$dbh->selectrow_array(q[ SELECT last_insert_id()]);
	$dbh->do(q[INSERT INTO firms_transit SET ft_ctid1=?,ft_ctid2=?],undef,$id1,$id2);
	return ($id1,$id2);

	

}
sub del_trans
{
    my ($self,$id)=@_;
    my $ref=$dbh->selectrow_hashref(q[SELECT * FROM transactions WHERE t_id=?],undef,$id);
                    my $id1=$self->add_trans(
                    {
                        t_name1 => $ref->{t_aid2},
                        t_name2 => $ref->{t_aid1},
                        t_currency => $ref->{t_currency},
                        t_amnt => $ref->{t_amnt},
                        t_comment => "$TRANSLATE{delete} $ref->{t_comment}",               
                        t_status=>$ref->{t_status},

                    });
    
    return $id1;


} 


sub add_trans
{
        my ($self,$ref)=@_;

        $ref->{t_oid}=$self->{user_id};
	$ref->{o_login}=$self->{o_login};
        die "$TRANSLATE{user_no_reg} \n" unless($ref->{t_name1});
	$ref->{t_status}='no' unless($ref->{t_status});

	
	 $ref->{t_aid1}=$ref->{t_name1};
#my $a2=$dbh->selectrow_array(q[SELECT a_id FROM accounts WHERE a_id=? ],undef,$ref->{t_name2});

	die "$TRANSLATE{user_no_reg} \n" unless($ref->{t_name2});

        $ref->{del_status}='processed' 	unless($ref->{del_status});

	$ref->{t_aid2}=$ref->{t_name2};

		

        my $field=$avail_currency->{$ref->{t_currency}};
        $ref->{account_bill}=$field;
	
        die "$TRANSLATE{cur_no_support} \n" unless($field);
        
	$ref->{t_amnt}=~s/[,]/\./g;
	$ref->{t_amnt}=~s/[ \"\'\\]//g;
	
         die "$TRANSLATE{bad_dig} $ref->{t_amnt}\n" unless($ref->{t_amnt}=~/[\-]{0,1}\d+\.{0,1}\d{0,2}/);
        
		

	($ref->{sum_before2},$ref->{a_name2})=$dbh->selectrow_array(qq[SELECT $field,a_name 
	FROM accounts WHERE a_id=? ],undef,$ref->{t_name2});   
	($ref->{sum_before1},$ref->{a_name1})=$dbh->selectrow_array(qq[SELECT $field,a_name
	FROM accounts WHERE a_id=? ],undef,$ref->{t_name1});     
	
# 	if($ref->{fiction_benef})
# 	{
# 		$ref->{t_aid2}=$dbh->selectrow_array(q[SELECT a_id FROM accounts WHERE a_mirror=?],undef,$ref->{t_aid2});
# 		die "$TRANSLATE{user_no_reg} \n"	unless($ref->{t_aid2});
# 	}
# 	if($ref->{fiction_pay})
# 	{
# 		$ref->{t_aid1}=$dbh->selectrow_array(q[SELECT a_id FROM accounts WHERE a_mirror=?],undef,$ref->{t_aid1});
# 		 die "$TRANSLATE{user_no_reg}  \n"	unless($ref->{t_aid1});
# 	}

           die "$TRANSLATE{comm_no_empty} \n" if(!$ref->{t_comment});

        $dbh->{AutoCommit} = 0;  # enable transactions, if possible
        $dbh->{RaiseError} = 1;
        my $t_id;

        eval {
                $t_id=do_trans($ref);       # and updates
                $dbh->commit;
                $dbh->{AutoCommit} = 1;   # commit the changes if we get this far
	};
        if ($@) {
                warn "Transaction aborted because $@";
                my $qwe = "$@";
# now rollback to undo the incomplete changes
# but do it in an eval{} as it may also fail
                eval { $dbh->rollback };
		        my $r=$dbh->errstr;
			die "internal error: code 4 ($qwe) ".Dumper($ref,$self->query)." \n"; 
# add other application on-error-clean-up code here
	}
        return $t_id;   



}
sub do_trans
{
        my $ref=shift;
      
        my $res=$dbh->do(qq[UPDATE accounts SET $ref->{account_bill}=$ref->{account_bill}+? WHERE 
        a_id=$ref->{t_aid1}   ],undef,-1*$ref->{t_amnt}); 

        die "$TRANSLATE{\"internal error\"}: code 1\n" unless($res eq 1);

         my $t_id=1;
       
         $res=$dbh->do(q[
            INSERT 
	        INTO
 	        transactions(t_ts,t_aid1,t_aid2,t_amnt,t_currency,t_comment,t_oid,t_status,
	        t_amnt_before1,t_amnt_before2,del_status) 
	        VALUES(current_timestamp,?,?,?,?,?,?,?,?,?,?)],undef,
	  @$ref{qw( t_aid1 t_aid2 t_amnt t_currency  t_comment t_oid t_status sum_before1 sum_before2 del_status)});
          die " $TRANSLATE{\"internal error\"}: code 2\n" unless($res eq 1);   
          $t_id=$dbh->selectrow_array(q[SELECT last_insert_id()]);
	  if($ref->{t_status} eq 'system')
	  {
	
		
		$dbh->do(q[INSERT DELAYED  INTO accounts_reports_table(
		ct_id,ct_aid,ct_comment,ct_oid,o_login,ct_fid,f_name,ct_amnt,
		ct_currency,result_amnt,ct_date,e_currency2,ct_ex_comis_type,ts,ct_status
		)
		  VALUES(?,?,?,?,?,?,?,?,?,?,current_timestamp,?,
		'transaction',current_timestamp,'processed')],undef,$t_id, 
		@$ref{qw( t_aid2  t_comment t_oid o_login t_aid1 a_name1 t_amnt t_currency t_amnt t_currency)});

	

		$ref->{t_amnt}=-1*$ref->{t_amnt};
		$dbh->do(q[INSERT  DELAYED INTO accounts_reports_table(
		ct_id,ct_aid,ct_comment,ct_oid,o_login,ct_fid,f_name,ct_amnt,
		ct_currency,result_amnt,ct_date,e_currency2,ct_ex_comis_type,ts,ct_status
		)  VALUES(?,?,?,?,?,?,?,?,?,?,
		current_timestamp,?,'transaction',current_timestamp,'processed')],undef,$t_id, 
		@$ref{qw( t_aid1  t_comment t_oid o_login t_aid2 a_name2 t_amnt t_currency t_amnt t_currency)});
		$ref->{t_amnt}=-1*$ref->{t_amnt};

	 }


        $res=$dbh->do(qq[UPDATE accounts SET $ref->{account_bill}=$ref->{account_bill}+?
         WHERE 
        a_id=$ref->{t_aid2}],undef,$ref->{t_amnt}) unless($ref->{invis_benef});
         die "$TRANSLATE{\"internal error\"}  : code 3\n"  unless($res eq 1);
        
        return $t_id ;


}    
sub login
{
   my $self=shift;
   my $tmpl=$self->load_tmpl('login.html');
   my $output = "";
   $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
   #print $output;
   return $output;
}
sub login_do
{
   my $self=shift;
   my $tmpl=$self->load_tmpl('login.html');
   my $output = "";
   my $pwd = $self->query->param('pwd');
   my $login = $self->query->param('login');
   my ($user_id,$session) =  $self->auth_login($login, $pwd); 
#    die "here";

	
   	unless($user_id)
	{    
		$self->{tpl_vars}->{error}=1;
		$self->{tpl_vars}->{login}=$self->query->param('login');
		$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
		return $output;
	
	}else
	{
		my $cookie= $self->query->cookie(
							-name=>'session',
							-value=>$session,
							-path=>'/',
		    					-secure=>$use_secure_cookies
						);
	
		$self->header_type('redirect');
    	    $self->header_add(-cookie=>$cookie);
		return  $self->header_add(-url=>'/cgi-bin/index.cgi'); # oper.cgi
	}

}
sub add_exc
{
        my ($self,$param)=@_;
	$param->{e_fid} = $exchange_id unless($param->{e_fid});

        die " $TRANSLATE{course_no_set}" unless($param->{'rate'});
        require POSIX;
        die "$TRANSLATE{cur_no_support}\n"	unless($avail_currency->{$param->{e_currency1}});
        die "$TRANSLATE{cur_no_support}  \n"	unless($avail_currency->{$param->{e_currency2}});

        my %types=('auto'=>'auto','cash'=>'cash','cashless'=>'cashless','system'=>'system');

        unless($param->{'type'}=$types{$param->{'type'}})
	{
                $param->{'type'}='cashless';
	}
	 
   	my $rate_base=$dbh->selectrow_array(
					qq[
						SELECT r_rate FROM rates WHERE r_currency1=? 
						AND 
						r_currency2=? 
						AND
						r_type=?
					],undef,
						$param->{e_currency1},
						$param->{e_currency2},
						$param->{'type'}
					);

        my $type=$param->{type};
        my $rate=$param->{rate};
        my $amnt=$param->{e_amnt1};
        my $aid=$param->{a_id};
        my $e_currency1=$param->{e_currency1};
        my $e_currency2=$param->{e_currency2};
        my $comment=$param->{e_comment};
	
   	my $amnt_to=POSIX::floor($amnt*100)/100;
	my $amnt_from;
	
	($amnt_from,$rate)=$self->calculate_exchange(
		$amnt_to,$param->{rate},
		$param->{e_currency1},$param->{e_currency2}
	);

	$param->{del_status}='processed'	unless($param->{del_status});
	my ($usd_id1,$usd_id2);
=pod
	if($param->{'type'} ne 'auto')	
	{
		my $sum_from=$dbh->selectrow_array(qq[SELECT get_eq_usd_from($aid,$amnt_to,'$e_currency1')]);
		my $usd_id1=$dbh->selectrow_array(qq[SELECT add_usd_trans($aid,-1*$sum_from,-1*$amnt_to,'$e_currency1') ]);
		my $usd_id2=$dbh->selectrow_array(qq[SELECT add_usd_trans($aid,$sum_from,$amnt_from,'$e_currency1') ]);
	}
=cut
        my $tid1 = $self->add_trans(
	{
        	t_name1 => $aid,
        	t_name2 => $exchange_id,
        	t_currency => $e_currency1,
        	t_amnt => $amnt_to,
        	t_comment => $comment,
		del_status=>$param->{del_status}
	}
	);
  
        my $tid2 = $self->add_trans(
	{	
        	t_name1 => $exchange_id,
        	t_name2 => $aid,
        	t_currency => $e_currency2,
        	t_amnt => $amnt_from,
        	t_comment => $comment,
		del_status=>$param->{del_status}
	});
	
	if($param->{e_date})
	{		
        	my $rate_base=$dbh->do(qq[INSERT INTO 
		exchange(e_date,e_type,e_rate_base,e_rate,e_tid1,e_tid2,e_fid) VALUES(?,?,?,?,?,?,?)],undef,
        	$param->{e_date},$type,$rate_base, $rate,$tid1,$tid2, $param->{e_fid});
	}else
	{
		my $rate_base=$dbh->do(qq[INSERT INTO 
		exchange(e_date,e_type,e_rate_base,e_rate,e_tid1,e_tid2, e_fid) 
		VALUES(current_timestamp,?,?,?,?,?,?)],undef,
        	$type,$rate_base, $rate,$tid1,$tid2,$param->{e_fid});
	}

	my $id_=$dbh->selectrow_array('SELECT last_insert_id()');
	$dbh->do(qq[
	INSERT INTO accounts_reports_table(ct_id,ct_aid,ct_comment,ct_oid,
	o_login,ct_fid,f_name,ct_amnt,ct_currency,comission,
	result_amnt,ct_comis_percent,ct_ext_commission,
	ct_date,e_currency2,rate,ct_eid,ct_ex_comis_type,ts,col_ts,ct_status,col_color)
	select `exchange_view`.`e_id` AS `e_id`,
	`exchange_view`.`a_id` AS `a_id`,`exchange_view`.`t_comment` AS `t_comment`,
	`exchange_view`.`o_id` AS `o_id`,
	`exchange_view`.`o_login` AS `o_login`,
	`firms`.`f_id` AS `f_id`,`firms`.`f_name` AS `f_name`,
	`exchange_view`.`e_amnt1` AS `e_amnt1`,`exchange_view`.`e_currency1` AS `e_currency1`,
	 0 AS `0`,
	`exchange_view`.`e_amnt2` AS `e_amnt2`,
	 0 AS `0`,0 AS `0`,cast(`exchange_view`.`e_date` as date) AS `e_date`,
	`exchange_view`.`e_currency2` AS `e_currency2`,
	`exchange_view`.`e_rate` AS `rate`,
	`exchange_view`.`e_id` AS `e_id`,
	'simple' as ct_ex_comis_type,
	`exchange_view`.`e_date` AS `t_ts`,
	'0000-00-00 00:00:00',
	`exchange_view`.`e_status` AS `e_status`,
	16777215 
	from (`exchange_view` join `firms`) where ((`firms`.`f_id` = $param->{e_fid} ) 
	and (`exchange_view`.`e_type` <> _latin1'auto')) AND e_id=?  LIMIT 0,1],undef,$id_);
 
 
        if($param->{"incash_office"}){
            #if it's a cash exchange make a cash out at the moment
            my $tid3 = $self->add_trans(
               {	
        	t_name1 => $aid,
        	t_name2 => $param->{e_fid},
        	t_currency => $e_currency2,
        	t_amnt => $amnt_from,
        	t_comment => $comment,
		del_status=>$param->{del_status}
            });
            my $percent=0;
            my $sql4cash=q[INSERT  INTO  
                            cashier_transactions(ct_fid,ct_aid,ct_currency,ct_amnt,ct_oid, ct_tid, ct_comment, ct_comis_percent , ct_status, ct_ts, ct_ts2, ct_date)
                            VALUES(?,?,?,?,?,?,?, 0, "processed", current_timestamp, current_timestamp, NOW()) ];
            $dbh->do($sql4cash, undef, $param->{"e_fid"},  $aid, $e_currency2, -1*$amnt_from,  $self->{"user_id"}, $tid3, $comment); 
            my $ct_id=$dbh->selectrow_array(q[ SELECT last_insert_id()]);

            
            $dbh->do(qq[
			INSERT  $SQL_DELAYED INTO accounts_reports_table(ct_id,ct_aid,ct_comment,ct_oid,
			o_login,ct_fid,f_name,ct_amnt,ct_currency,comission,
			result_amnt,ct_comis_percent,ct_ext_commission,
			ct_date,
			ct_ex_comis_type,ts,col_ts,col_status,
			ct_status,col_color)
			select `cashier_transactions`.`ct_id` AS `ct_id`,
			`cashier_transactions`.`ct_aid` AS `ct_aid`,
			`cashier_transactions`.`ct_comment` AS `ct_comment`,
			`cashier_transactions`.`ct_oid` AS `ct_oid`,
			`operators`.`o_login` AS `o_login`,
			`firms`.`f_id` AS `ct_fid`,
			`firms`.`f_name` AS `f_name`,
			`cashier_transactions`.`ct_amnt` AS `ct_amnt`,
			`cashier_transactions`.`ct_currency` AS 
			`ct_currency`,
			 $percent,
			(`cashier_transactions`.`ct_amnt`+$percent) AS `result_amnt`,
			`cashier_transactions`.`ct_comis_percent` AS `ct_comis_percent`,
			(-(1) * `cashier_transactions`.`ct_ext_commission`) AS `ct_ext_commission`,
			cast(if(isnull(`cashier_transactions`.`ct_ts2`),`cashier_transactions`.`ct_ts`,
			`cashier_transactions`.`ct_ts2`) as date) AS `ct_date`,
			`cashier_transactions`.`ct_ex_comis_type` AS `ct_ex_comis_type`,
			 if(isnull(`cashier_transactions`.`ct_ts2`),
			`cashier_transactions`.`ct_ts`,
			`cashier_transactions`.`ct_ts2`) AS `ts`,
			'0000-00-00 00:00:00',
			'no',
			`cashier_transactions`.`ct_status` AS `ct_status`,
			16777215 
			from ((`cashier_transactions` 
			left join `firms` on((`cashier_transactions`.`ct_fid` = `firms`.`f_id`))) 
			left join `operators` on((`cashier_transactions`.`ct_oid` = `operators`.`o_id`)))
			where 	`cashier_transactions`.`ct_status` 
			IN (_cp1251'processed')  AND ct_id=? LIMIT 1
			],undef,$ct_id);	
                $dbh->do(q[UPDATE exchange SET ct_id=? WHERE id=?],undef, $ct_id, $id_);
			
			
        }



        return $id_;
}
sub auth_login
{
        my ($self,$login,$pwd)=@_;
        my ($user_id,$session_data)=$dbh->selectrow_array(q[SELECT 
	o_id,o_session_data FROM operators 
	WHERE  o_login=? AND o_password=SHA1(?) AND o_status='active'],undef,$login,$pwd);        
	
        return (undef,undef) unless($user_id);
	##cache new session
	my $memd=get_cache_connection();
	$memd->add($user_id,thaw($session_data)) if($session_data);
	
	###cache
        my $session=$dbh->selectrow_array(q[SELECT md5(rand())]);

        my $r=$dbh->do(q[INSERT INTO oper_sessions(os_session,os_oid,os_ip,os_created,os_expired) values(?,?,?,
        current_timestamp,date_add(current_timestamp,interval 10 hour))],undef,$session,$user_id,$ENV{REMOTE_ADDR});
        return ($user_id,$session);
        
        
}
sub get_user_by_session
{
        
        my $self=shift;
        my $session=shift;

	 my ($os_oid,$sub);
    
	if($ENV{REMOTE_ADDR}  ne '127.0.0.1')
	{
    
  			
            ($os_oid,$sub)=$dbh->selectrow_array(qq[SELECT    os_oid,
		timestampdiff(minute,current_timestamp,os_expired)
	     FROM oper_sessions WHERE  os_session=? AND os_status='active' AND os_ip=?  AND os_expired>current_timestamp],undef,$session,$ENV{REMOTE_ADDR});
#	     die"$os_oid,$ENV{REMOTE_ADDR},$session\n";

	}else{
       
         
	 ($os_oid,$sub)=$dbh->selectrow_array(qq[SELECT    os_oid,                                                                                       
	                timestampdiff(minute,current_timestamp,os_expired)  
                        FROM oper_sessions WHERE  os_session=? 
			AND os_status='active'  AND os_expired>current_timestamp],undef,$session);
	
	}
        
	my $chat=$self->query->cookie('chat');

        unless(defined($os_oid))
	{
		$os_oid=$dbh->selectrow_array(q[SELECT    os_oid FROM oper_sessions WHERE  os_session=?],undef,$session);
		
		if(defined($os_oid))
		{
			$dbh->do(q[UPDATE oper_sessions SET os_status='deleted' WHERE os_oid=? ],undef,$os_oid);

			return  undef;
		}else
		{
			return undef;
		}
				
	}else{
	    
	
      


#if there isn't any params we will use from last enter here
		
	###caching the session data

		my $memd =get_cache_connection(); 
		$self->{session_data}={};
	
		my ($str,$o_login,$o_greeding,$o_menu_type)=$dbh->selectrow_array(q[SELECT o_session_data,o_login,o_greeding,o_menu_type
						FROM operators WHERE o_id=?],undef,$os_oid);

		$self->{login}=	$o_login;
		$self->{greeding}=$o_greeding;
		$self->{o_menu_type}=$o_menu_type;
		$self->{user_id}=$os_oid;
		unless($self->{session_data}=$memd->get($os_oid))
		{
		
		
		
	  
			$self->{session_data}=thaw($str) if($str);
			$self->{session_data}->{chat}=$chat if(defined($chat));
			$self->update_session();
			$memd->add($os_oid,$self->{session_data});
			$self->save_session($os_oid);
					
		}else
		{
			$self->update_session();
			$memd->replace($os_oid,$self->{session_data});

		}		

		


                
	}

return $os_oid;


     


}

sub update_session
{
	
		my $self=shift;			
                my $size=$self->query->param();
		my $right=$self->get_right();
         	my $do=$self->query->param('do');
	        my $action=$self->query->param('action');
	
		if(!$size)
		{
			
			
##chat must be chaged
			if($right!~/report/&&$right!~/chat/&&$self->{session_data})
			{	

				my $r=$self->{session_data}->{$right};
	
				foreach(keys %$r)
				{
					$self->query->param($_,$r->{$_});	
				}
			}
			elsif($right!~/chat/&&$self->{session_data})
			{
				my $r=$self->{session_data}->{$right}->{$do};
				foreach(keys %$r)
				{
					$self->query->param($_,$r->{$_});	
				}	

			}
				
		}
		elsif($do=~/list/||$action=~/filter/)
		{
			my %r;
			map { $r{$_}=$self->query->param($_) } $self->query->param();
#			die Dumper $self->{session_data};
			$r{right}=$right;
			$self->{session_data}={} unless($self->{session_data});
			$self->{session_data}->{$right}=\%r;
#$self->save_session($os_oid);
		}elsif($right=~/report/&&!defined($action)&&$self->{session_data})
		{
		
					my $r=$self->{session_data}->{$right}->{$do};	
					
					foreach(keys %$r)
					{
						$self->query->param($_,$r->{$_});	
					}
		
		}elsif($right=~/report/&&defined($action)&&$self->{session_data})
		{
					my $r=$self->{session_data}->{$right}->{$do};
					map { $r->{$_}=$self->query->param($_) } $self->query->param();
					$self->{session_data}->{$right}->{$do}=$r;
		
		
		}



}


sub save_session
{
	my $self=shift;
	my $os_oid=shift;
	$dbh->do(q[UPDATE  operators SET o_session_data=? WHERE o_id=?],undef,freeze($self->{session_data}),$os_oid) if($self->{session_data});


}
sub set_session
{
	

	my $self=shift;
	my $os_oid=shift;
	my $str=$dbh->selectrow_array(q[SELECT o_session_data 
	FROM operators WHERE o_id=?],undef,$os_oid);
	
	my @params=split('&',$str);
	my %hash;
	foreach(@params)
{
		my @prms=split(';',$_);
		my %tmp;
		foreach my $key (@prms) 
{
			$key=/(.+)=(.+)/;
			$tmp{$1}=$2;
			
}
		$hash{$tmp{right}}=\%tmp;

			
		
}
	$self->{session_data}=\%hash;

}
sub logout
{
        my $self=shift;
        my $session=$self->query->cookie('session');

        my $os_oid=$dbh->selectrow_array(q[SELECT    
	os_oid FROM oper_sessions WHERE  os_session=? AND os_status='active' AND os_ip=? AND 
	os_expired>current_timestamp],undef,$session,$ENV{REMOTE_ADDR});
	$self->save_session($os_oid);
        if($os_oid)
	{
                $dbh->do(q[UPDATE oper_sessions SET os_status='deleted'  WHERE os_oid=?],undef,$os_oid);
	}
        my $cookie= $self->query->cookie(
                                                 -name=>'session',
                                                 -value=>$session,
                                                 -path=>'/',
                                                 -expires=>'-240h',
                                                  -secure=>$use_secure_cookies
                                             );
        $self->header_add(-cookie=>$cookie);
        $self->header_type('redirect');
        return $self->header_add(-url=>'/cgi-bin/oper.cgi');
                
        
        

}


# ==== proto FOR accounts/operators ... =====================================

sub category_title{
  my $category = shift;
  my $id = shift;
  my $params = shift;
  my $title = "";
  $title="(id#$id)" if($id);
  die($id);
  if($category eq "accounts"){
    return "" if($id == -3);

    my $r = $dbh->selectrow_hashref("SELECT * FROM $category WHERE a_status='active' AND a_id = ".sql_val($id));
    if($r){
      $title = "$r->{a_name} $title";
}
}elsif($category eq "operators"){
    my $r = $dbh->selectrow_hashref("SELECT * FROM $category WHERE o_id = ".sql_val($id));
    if($r){
      $title = "$r->{o_login} $title";
}
}elsif($category eq "firms"){
    my $r = $dbh->selectrow_hashref("SELECT * FROM $category WHERE f_status='active' AND f_id = ".sql_val($id));
    if($r){
      $title = "$r->{f_name} $title";
}    
}elsif($category eq "firm_services"){
    my $r = $dbh->selectrow_hashref("SELECT * FROM $category WHERE fs_id = ".sql_val($id)." AND fs_id>0");
    if($r){
      $title = "$r->{fs_name} $title";
}
}elsif($category eq "rich_text")
{
	$title="<div class='center_div_table'> $id </div>";

}elsif($category eq "out_firms")
{
	my $r = $dbh->selectrow_array("SELECT of_name FROM $category WHERE of_id = ".sql_val($id));
	$title="$r (#$id)";

}	

  return $title;
}


sub category_title{
  my $category = shift;
  my $id = shift;
  my $params = shift;
  my $title = "";
  $title="(id#$id)" if($id);
  if($category eq "accounts"){
    return "" if($id == -3);

    my $r = $dbh->selectrow_hashref("SELECT * FROM $category WHERE a_status='active' AND a_id = ".sql_val($id));
    if($r){
      $title = "$r->{a_name} $title";
}
}elsif($category eq "operators"){
    my $r = $dbh->selectrow_hashref("SELECT * FROM $category WHERE o_id = ".sql_val($id));
    if($r){
      $title = "$r->{o_login} $title";
}
}elsif($category eq "firms"){
    my $r = $dbh->selectrow_hashref("SELECT * FROM $category WHERE f_status='active' AND f_id = ".sql_val($id));
    if($r){
      $title = "$r->{f_name} $title";
}    
}elsif($category eq "firm_services"){
    my $r = $dbh->selectrow_hashref("SELECT * FROM $category WHERE fs_id = ".sql_val($id)." AND fs_id>0");
    if($r){
      $title = "$r->{fs_name} $title";
}
}elsif($category eq "rich_text")
{
	$title="<div class='center_div_table'> $id </div>";

}elsif($category eq "out_firms")
{
	my $r = $dbh->selectrow_array("SELECT of_name FROM $category WHERE of_id = ".sql_val($id));
	$title="$r (#$id)";

}	

  return $title;
}



sub category_get_hash{
  my $category = shift;
  
  my $r = qq("SELECT * FROM $category ");
  my $sth=$dbh->prepare($r); 
  $sth->execute();
  my @ar;
  while(my $r=$sth->fetchrow_hashref())      
  {
        push @ar,{title=>$r,value=>};
  }

  return \@ar;
}



# 


sub proto_begin{
   my $self=shift;
   my $proto=shift;
   my $params=shift;

#   $SIG{__DIE__}=\&proto_die_catcher;

   my $p={};
   $p->{table} = $proto->{table};
   $p->{back_url} = $proto->{back_url};

   $p->{edit_where} = $proto->{edit_where};
   $p->{edit_where}=' 1 '   unless($p->{edit_where});

#   $p->{'sort'} = $proto->{'sort'};
   $p->{back_url} = "?" unless($p->{back_url});

   $p->{template_prefix} = $proto->{template_prefix};
   $p->{template_prefix} = $proto->{table} unless($p->{template_prefix});


   my $index=0;
   foreach my $row( @{$proto->{fields}} ){
     $p->{id_field}=$row->{field} if($index == 0);

     if( $row->{del_value} ){
       $p->{del_field} = $row->{field};
       $p->{del_value} = $row->{del_value};
	}

     if( ($row->{category} eq "firms" || $row->{category} eq "firms_with_balance") &&  $row->{type} eq "select"){
       
        my $sql = qq[
       SELECT * FROM firms
       WHERE f_status='active' 
       ORDER BY f_name
       ];
   
       my @titles=();
       my $sth =$dbh->prepare($sql);
       $sth->execute();                          
       while(my $r = $sth->fetchrow_hashref)
       {
		my $q = "";
			if($row->{category} eq "firms_with_balance"){
			$q=" $r->{f_uah} UAH, $r->{f_usd} USD, $r->{f_eur} EUR";
		}

         push @titles, {"value"=>$r->{f_id}, "title"=>"$r->{f_name} (id#$r->{f_id}) $q"};
	   }
       $sth->finish();

       $row->{titles} = \@titles; 


      
     }elsif($row->{category} eq "out_firms"&&$row->{type} eq "select")
     {
	   my $sql = qq[
      	 SELECT * FROM out_firms
      	 ORDER BY of_name
       ];
   
       my @titles=();
       my $sth =$dbh->prepare($sql);
       $sth->execute();                          
       while(my $r = $sth->fetchrow_hashref)
       {
	        push @titles, {"value"=>$r->{of_id}, "title"=>"$r->{of_name} (id#$r->{of_id})"};
       }
       $sth->finish();

       $row->{titles} = \@titles; 	


     
     }
=pod
elsif($row->{category} eq "accounts"&&$row->{type} eq "select"){
       my $sql = qq[
         SELECT * FROM accounts_view
         ORDER BY a_name
       ];
   
       my @titles=();
       my $sth =$dbh->prepare($sql);
       $sth->execute();                          
       while(my $r = $sth->fetchrow_hashref)
       {
            push @titles, {"value"=>$r->{a_id}, "title"=>"$r->{a_name} (id#$r->{of_id})"};
       }
       $sth->finish();

       $row->{titles} = \@titles;   


     
     }
=cut

     $index++;
   }
	
   $self->{tpl_vars}->{page_title}=$proto->{page_title};

   return $p;
}
sub proto_die_catcher
{
        return if $^S; # for eval die
        my $msg=join ',', @_;
        print "Content-type: text/html; charset=cp1251\n\n\n";
	my @arr=split(':',$msg);
	$msg=$arr[1];
	$msg=~s/at(.*)//;
	require Template;
        my $tmpl = Template->new(
	{
		INCLUDE_PATH => '../tmpl',
		INTERPOLATE  => 1,               # expand "$var" in plain text
		POST_CHOMP   => 1,               # cleanup whitespace 
		EVAL_PERL    => 1,       
	}
        );

        
        my $vars = {};
        $vars->{error}=$msg;
        $tmpl->process('proto_error.html',$vars) || die $tmpl->error();
        $SIG{__DIE__}=undef;
}

=head2 proto_list

=head2 Params:

=over 4

=item excel - return data as Excel table

=back

=cut
sub get_proto_list
{
	my $self=shift;
   	my $proto=shift;
   	my $proc_functions=shift;
 
	my $filter_where = "";
   	my $filter_params = {};
	my $p = $self->proto_begin($proto, {method=>"list"});
	
   	if($self->query->param('action') eq 'filter'){
     		map {$filter_params->{$_}=$self->query->param($_)} $self->query->param();
#die Dumper $filter_params;
	}


    my $format=$dbh->selectall_hashref(qq[DESC $p->{table} ],'Field');

# titles to hash & filter
	
   my $i=0;	
	
   foreach my $row( @{$proto->{fields}} ){
     if($row->{type} eq 'select'){
      my %select=();
   foreach my $option( @{$row->{titles}} ){
       $select{ $option->{value} } = $option->{title};
	  }
     	$row->{ "titles_hash" } = \%select;     
	}

    

     if(defined $row->{filter}) {
	
           my $filter_val = "".$filter_params->{ $row->{field} };
       my $filter_val_empty = length($filter_val)==0;
 	
	if($row->{filter} eq 'time' && $filter_val_empty){
        	 $filter_val = "yesterday";
         	 $filter_val_empty = 0;      
}  
#die "$row->{filter} - '$filter_val' - $filter_val_empty";

       if(!$filter_val_empty){
         $row->{value}=$filter_val;

	
         if($row->{filter} eq 'time'){
	
	    if($filter_params->{type_time_filter}  eq 'time_filterinterval')
		{
		
		my $row1={};
		my $from=$filter_params->{$row->{field}.'_from'};
		
		my $to=$filter_params->{$row->{field}.'_to'};
		
	 	$filter_where .= qq[  AND $row->{field}>='$from' AND $row->{field}<='$to' ];
		
		$row1->{'from'}=$filter_params->{$row->{field}.'_from'};
		
		$row1->{'to'}=$filter_params->{$row->{field}.'_to'};	
	
		$row1->{filter}='time';
		$row1->{field}=$row->{field};
		$row1->{'type_time_filter'}='time_filterinterval';
		$proto->{fields}->[$i]=$row1;
	
		
		}else
		{
 			my $res = time_filter($filter_val);
	     	  	 $filter_where .= " AND '$res->{start}'<=$row->{field} AND '$res->{end}'>=$row->{field}";
		}		

	   


}elsif($row->{filter} eq 'like'){
	   my $trans=get_translit($filter_val);
           $filter_where .= " AND ( lcase($row->{field}) like lcase(".sql_val('%'.$trans.'%').") OR  lcase($row->{field}) like lcase(".sql_val('%'.$filter_val.'%').") )";

}elsif($row->{filter} eq 'eq'){

    

       $filter_val=~s/[,]/\./g;
       $filter_val=~s/[ \"\'\\]//g; 
        my $left=0;
        my $right=0;
       if($row->{op} eq '-'){
            $filter_val = 0-$filter_val;
            $left=sql_val($filter_val+($filter_val*$FILTER_NUMBER_MISTAKE));
            $right=sql_val($filter_val-($filter_val*$FILTER_NUMBER_MISTAKE));

        }else{   
 
           $left=sql_val($filter_val-($filter_val*$FILTER_NUMBER_MISTAKE));
           $right=sql_val($filter_val+($filter_val*$FILTER_NUMBER_MISTAKE));
        }
       $filter_where .= " AND ( $row->{field}>$left AND $row->{field}<$right )";

}else{
	$filter_val=~s/,/\./;
        $filter_val=~s/[ ]//g;      
        $filter_val=~s/[ \"\'\\]//g; 
       $filter_val = 0-$filter_val if($row->{op} eq '-');
	   $filter_where .= " AND $row->{field} = ".sql_val($filter_val);
         
}
       

}
} # if(defined $row->{filter}){
	$i++;
}
	my %result_params;
  $result_params{filter_where}=$filter_where;

#  my $index = 1;
 

#  foreach my $extra_where(@extra_wheres){
	
   my $extra_where;
   my $del_sql = "1";
   $del_sql = "$p->{del_field}<>'$p->{del_value}'" if($p->{del_field});
   
   $extra_where = " AND ($proto->{extra_where}) " if($proto->{extra_where});

   my @rows=();
   my $sql;

#setting sorting from Bogdan!!a new feature
##setting the format
  
#what about formating do not forgot please 
#apriori formating
  my $limit=" LIMIT 0,12000";
  if ($proto->{limit}){
    $proto->{rows_per_page}||=30;
    $limit="LIMIT ".$proto->{page}*($proto->{rows_per_page}).",".$proto->{rows_per_page};
    
}
	
		
my $group=$proto->{group};


if($proto->{'sort'})	
{
	 
    $sql = qq[SELECT SQL_CALC_FOUND_ROWS * FROM $p->{table} 
     		WHERE $del_sql $extra_where $filter_where $group
     		ORDER BY $proto->{'sort'} $limit];
	
}elsif($proto->{id_field})
{	
	  	
 	$sql = qq[SELECT SQL_CALC_FOUND_ROWS * FROM $p->{table} 
     	WHERE $del_sql $extra_where $filter_where  $group
     	ORDER BY $proto->{id_field} DESC $limit
   	];   
}else
{
				
	$sql = qq[SELECT SQL_CALC_FOUND_ROWS * FROM $p->{table} 
		  WHERE $del_sql $extra_where $filter_where $group $limit
	];   
}
	
#die $sql;
  	

####but the old style of work has been saved	
#    die $sql;
#    $TIMER->start('fizzbin');
# die $sql;
   my $sth =$dbh->prepare($sql);



   $sth->execute();

#post formating

my $prev_row=undef;##for first row the prev row will be undef
my $r;
$result_params{hash}={};
map { $result_params{hash}->{$_}={} }	@{ $proto->{key_hashes} };

while( $r = $sth->fetchrow_hashref)
{
     foreach my $row( @{$proto->{fields}} )
	{
	    
		my $val = $r->{ $row->{"field"} };
		$r->{ "orig__".$row->{"field"} } = $val unless($r->{ "orig__".$row->{"field"} } );
		
	
	
	if($row->{type} eq 'select'){
#		if( $row->{"titles_hash"}->{ $val } ){
		$val = $row->{"titles_hash"}->{ $val };
#	}
	}
	elsif($row->{type} eq 'set'){
		my $hash = set2hash($val);
	#die Dumper $hash;
		$val="";
		foreach my $option( @{$row->{titles}} ){
		add2list(\$val, $option->{title})  if( $hash->{ $option->{value} } );          
	        }
	}
	elsif(defined $row->{category}){         
		$val = category_title($row->{category}, $val, {row=>$r});
	}
		$val = 0-$val if($row->{op} eq '-');
	
		$r->{ $row->{"field"} } = $val;
	
	
	}
	
   	$r->{id} = $r->{ $p->{"id_field"} };
        	
##if  we defind a sub of working with te record
	
	if($proc_functions->{fetch_row})
	{
			$proc_functions->{fetch_row}->(\@rows,$r,$prev_row,$proto);
	}
	else
	{	
			push @rows, $r;
								
	}

	$prev_row=$r->{ct_date};
	
	map { $result_params{hash}->{$_}->{$r->{"$_"}}=$r if(defined $r->{"$_"}) } keys %{ $result_params{hash} } ;
	map { $result_params{hash}->{$_}->{$r->{"orig__$_"}}=$r if(defined $r->{"orig__$_"}) } keys %{ $result_params{hash} } ;


	$self->formating_fields($r,$format,$proto->{formating}) unless($proto->{no_formating});
	
  	
}
   	$sth->finish();
	#die Dumper \@rows;
	#if we have 
	$proc_functions->{after_list}->(\@rows,$r,$prev_row,$proto) if($proc_functions->{after_list});		
	
	$result_params{rows}=\@rows;
		
  
  	$result_params{fields}=$proto->{fields};
  	
	$result_params{proto}=$proto;
	my $time=$TIMER->stop;
	$result_params{timer}=$time;
    my_log($self,$time);
#    $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
    return \%result_params;

}
sub template_proto_list
{
	
	my $self=shift;
	my $params=shift;
    my $tmpl=$self->load_tmpl($params->{file});

	delete $params->{file};
	map {$self->{tpl_vars}->{$_}=$params->{$_} } keys %$params;
   	my $output = "";
   	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
   	return $output;
	


}



sub proto_list
{
   my $self=shift;
   my $proto=shift;
   my $proc_functions=shift;##using for processing rows on fly
   my $prev_row;##for processing rows ,will save the pre row

   my $p = $self->proto_begin($proto, {method=>"list"});
   my $tmpl=$self->load_tmpl($p->{template_prefix}.'_list.html');
   my $filter_where = "";
   my $filter_params = {};
   my $format=$dbh->selectall_hashref(qq[DESC $p->{table} ],'Field');  

   if($self->query->param('action') eq 'filter'){
     map {$filter_params->{$_}=trim($self->query->param($_))} $self->query->param();
#die Dumper $filter_params;
}

# titles to hash & filter
	
   my $i=0;	



   foreach my $row( @{$proto->{fields}} ){

     if($row->{type} eq 'select'){
      my %select=();
      foreach my $option( @{$row->{titles}} ){
       $select{ $option->{value} } = $option->{title};
	}
     	$row->{ "titles_hash" } = \%select;     
	}

    

     if(defined $row->{filter}) {

       my $filter_val = "".$filter_params->{ $row->{field} };
       my $filter_val_empty = length($filter_val)==0;

         


 	
	if($row->{filter} eq 'time' && $filter_val_empty){
        	 $filter_val = "yesterday";
         	 $filter_val_empty = 0;      
	} 

		if($row->{filter} eq 'date_month_year'){
        	 $filter_val = "yesterday";
         	 $filter_val_empty = 0;      
		} 



 
#die "$row->{filter} - '$filter_val' - $filter_val_empty";

       if(!$filter_val_empty){
         $row->{value}=$filter_val;
 



         if($row->{filter} eq 'time'){
	
	    if($filter_params->{type_time_filter}  eq 'time_filterinterval')
		{
		
		    my $row1={};
		    my $from=$filter_params->{$row->{field}.'_from'};
		    
		    my $to=$filter_params->{$row->{field}.'_to'};
		    
	        $filter_where .= qq[  AND $row->{field}>='$from' AND $row->{field}<='$to' ];
		    
		    $row1->{'from'}=$filter_params->{$row->{field}.'_from'};
		    
		    $row1->{'to'}=$filter_params->{$row->{field}.'_to'};	
	    
		    $row1->{filter}='time';
		    $row1->{field}=$row->{field};
		    $row1->{'type_time_filter'}='time_filterinterval';
		    $proto->{fields}->[$i]=$row1;
	
		
		}else
		{
 			my $res = time_filter($filter_val);
	     	   $filter_where .= " AND '$res->{start}'<=$row->{field} AND '$res->{end}'>=$row->{field}";
		}		

	   


}
elsif($row->{filter} eq 'date_month_year'){
	
		    my $row1={};
		    my $mounth=$filter_params->{$row->{field}.'_month'};
		    my $year=$filter_params->{$row->{field}.'_year'};
			my $from = "$year-$mounth-01";
			my $to = "$year-$mounth-31";
	        $filter_where .= qq[  AND $row->{field}>='$from' AND $row->{field}<='$to' ];
           $self->{tpl_vars}->{'selected_month'}=$filter_params->{$row->{field}.'_month'};
            $self->{tpl_vars}->{'selected_year'}=$filter_params->{$row->{field}.'_year'};   
}
elsif($row->{filter} eq 'like'){
	   my $trans=get_translit($filter_val);
           $filter_where .= " AND ( lcase($row->{field}) like lcase(".sql_val('%'.$trans.'%').") OR  lcase($row->{field}) like lcase(".sql_val('%'.$filter_val.'%').") )";

}elsif($row->{filter} eq 'eq'){

    


    

        $filter_val=~s/[ ]//;
       $filter_val=~s/[,]/\./g;
       $filter_val=~s/[ \"\'\\]//g; 
        my $left=0;
        my $right=0;
       if($row->{op} eq '-'){
            $filter_val = 0-$filter_val;
            $left=sql_val($filter_val+($filter_val*$FILTER_NUMBER_MISTAKE));
            $right=sql_val($filter_val-($filter_val*$FILTER_NUMBER_MISTAKE));

        }else{   
 
           $left=sql_val($filter_val-($filter_val*$FILTER_NUMBER_MISTAKE));
           $right=sql_val($filter_val+($filter_val*$FILTER_NUMBER_MISTAKE));
        }
       $filter_where .= " AND ( $row->{field}>$left AND $row->{field}<$right )";

}else{


        $filter_val=~s/[ ]//g;
	   $filter_val=~s/[,]/\./g;
	   $filter_val=~s/[ \"\'\\]//g; 
           $filter_val = 0-$filter_val if($row->{op} eq '-');
	   $filter_where .= " AND $row->{field} = ".sql_val($filter_val);
         
}
       

}
} # if(defined $row->{filter}){
	$i++;
}
	
 
	  my @extra_wheres = ("$proto->{extra_where}");
	  push @extra_wheres, $proto->{extra_where2} if($proto->{extra_where2});


 my $index = 1;
 

 foreach my $extra_where(@extra_wheres){

   my $del_sql = "1";
   $del_sql = "$p->{del_field}<>'$p->{del_value}'" if($p->{del_field});
   
   $extra_where = " AND ($extra_where) " if($extra_where);

   my @rows=();
  my $sql;

#setting sorting from Bogdan!!a new feature
##setting the format
  
#what about formating do not forgot please 
#apriori formating
  my $limit=" LIMIT 0,30000";
  if ($proto->{limit}){
    $proto->{rows_per_page}||=30;
    $limit="LIMIT ".$proto->{page}*($proto->{rows_per_page}).",".$proto->{rows_per_page};
    
}


	
		

my $group=$proto->{group};


if($proto->{'sort'})	
{
	 
    
$sql = qq[SELECT SQL_CALC_FOUND_ROWS * FROM $p->{table} 
     		WHERE $del_sql $extra_where $filter_where $group
     		ORDER BY $proto->{'sort'} $limit];
	
}elsif($proto->{id_field})
{	
	  	
 	$sql = qq[SELECT SQL_CALC_FOUND_ROWS * FROM $p->{table} 
     	WHERE $del_sql $extra_where $filter_where  $group
     	ORDER BY $proto->{id_field} DESC $limit
   	];   
}else
{
				
	$sql = qq[SELECT SQL_CALC_FOUND_ROWS * FROM $p->{table} 
		  WHERE $del_sql $extra_where $filter_where $group $limit
	];   
}

    my $time=$TIMER->stop;
    $self->{tpl_vars}->{timer}=$time;


	$self->{tpl_vars}->{sql} =  $sql;

   my $sth =$dbh->prepare($sql);

   $sth->execute();




$prev_row=undef;##for first row the prev row will be undef
my $r;
while( $r = $sth->fetchrow_hashref)
{
	    foreach my $row( @{$proto->{fields}} )
		{

			my $val = $r->{ $row->{"field"} };
			$r->{ "orig__".$row->{"field"} } = $val unless($r->{ "orig__".$row->{"field"} } );
			


		if($row->{type} eq 'select'){
		#		if( $row->{"titles_hash"}->{ $val } ){
			$val = $row->{"titles_hash"}->{ $val };
		#	}
		}
		elsif($row->{type} eq 'set'){
			my $hash = set2hash($val);
		#die Dumper $hash;
			$val="";
			foreach my $option( @{$row->{titles}} ){
			add2list(\$val, $option->{title}) 
			if( $hash->{ $option->{value} } );          
		}
		}
		elsif(defined $row->{category}){  
			$val = category_title($row->{category}, $val, {row=>$r});
		}
			$val = 0-$val if($row->{op} eq '-');

			$r->{ $row->{"field"} } = $val;
		}
		
     		$r->{id} = $r->{ $p->{"id_field"} };
##if  we defind a sub of working with te record
if($proc_functions->{fetch_row})
{
		    $proc_functions->{fetch_row}->(\@rows,$r,$prev_row,$proto);
}
else
{	push @rows, $r;
							
}

$prev_row=$r->{ct_date};


$self->formating_fields($r,$format,$proto->{formating}) unless($proto->{no_formating});


  	
}
   	$sth->finish();
# 	die Dumper \@rows;
	#if we have 
	$proc_functions->{after_list}->(\@rows,$r,$prev_row,$proto) if($proc_functions->{after_list});		
		
   
	
	my $key="rows";
	$key .= $index if($index>1);
		
	$self->{tpl_vars}->{$key} = \@rows;
	
	$index++;
 }
    

    my $time=$TIMER->stop;
   $self->{tpl_vars}->{timer}=$time;
   my_log($self,$time);
   $self->{tpl_vars}->{fields}=$proto->{fields};
   $self->{tpl_vars}->{proto_params}=$proto;
	
   my $output = "";
	
#   $self->{tpl_vars}->{timer}=$TIMER->stop;

   $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
   return $output;
}

sub get{

      my $self=shift;
      my $aid=$self->query->param('ct_aid');
      my $name=$self->query->param('name');
      my ($prototype,$code)=$dbh->selectrow_array(q[SELECT 
                                                       p_prototype,p_code
                                                       FROM plugins WHERE p_name=? ],undef,$name);
      my $proto_hash;
      eval "$code";
      if($@){
        die $@;
      }
      my $output ="";
      my $tmpl=$self->load_tmpl("$PLUGIN_TMPL"."$name.html");
      $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
      return $output; 


}
sub built_excel
{
    my ($self,$rows,$file,$headings)=@_;
    require Spreadsheet::WriteExcel::Simple;
    my $ss = Spreadsheet::WriteExcel::Simple->new;
    map {   $_=my_decode($_) } @$headings;
    $ss->write_bold_row($headings);
    foreach my $k (@{$rows})
    {   
             map {  $_=my_decode(trim($_)) } @$k;
             $ss->write_row($k);
            
    }
    $ss->save($file) or die $!;


}
sub export_excel
{
    my $self=shift;
    my $st=$self->query->param('data');
    require Encode;
    Encode::from_to($st,'utf8','cp1251');
    my @ar=split(/\|/,$st);

    my (@rows,$str);  
    for(my $i=1;$i<@ar;$i++){

         my $str= $ar[$i];
         my @temp=split(/!/,$str);
        for(my $z=0;$z<@temp;$z++)
		{
			my $str2 = $temp[$z];
			 if($str2 =~ /^[\s-]*[\s\d,.]*$/)
			 {
			 	 $temp[$z] =~s/\s//;
			 	 $temp[$z] =~s/[-]{2,}/-/;
			 	
			 }
        }
        #clearing number
         map {$_=~s/(\d) (\d)/$1$2/g } @temp;
         push @rows,\@temp;

    }
  
    #    $self->built_excel($self->{tpl_vars}->{rows},">../data/excel/$id"."_$now.xls") or die $!;
    my $file_server=int(rand(1000));
    my $file="excel/$file_server.xls";
    my @headers=split(/!/,$ar[0]);
    
  
    unlink("$EXCEL_EXPORT_PATH$file_server.xls");
    $self->built_excel(\@rows,">$EXCEL_EXPORT_PATH$file_server.xls",\@headers);
    return $file;


}

sub exc_list
{
        my $ref=shift;
        $ref->{page}=$ref->{page}*$ref->{how};
        my $sth=$dbh->prepare(qq[
        SELECT 
        SQL_CALC_FOUND_ROWS 
        *
        FROM exchange_view   WHERE   $ref->{'filter'}  ORDER BY e_id DESC LIMIT].qq[ $ref->{'page'},$ref->{'how'}]);
         

         my %types=('cash'=>$TRANSLATE{"cashe"},'cashless'=>$TRANSLATE{"cashless"},auto=>$TRANSLATE{"auto"});
        my @res;
        $sth->execute();
        while(my $s=$sth->fetchrow_hashref())
	{

		$s->{e_rate}=pow($s->{e_rate},$RATE_FORMS{$s->{e_currency1}}->{$s->{e_currency2}});
		$s->{e_rate}=POSIX::floor( $s->{'e_rate'}*10000)/10000;
                $s->{e_type}=$types{$s->{e_type}};
		$s->{e_date}=format_date($s->{e_date});
                push @res,$s;
	}

        $sth->finish();
        return {list=>\@res,count_pages=>$dbh->selectrow_array(q[SELECT found_rows()])};

}




sub proto_add_edit_trigger
{
  	my $self=shift;
  	my $params = shift;
 
  	if($params->{step} eq 'before'){
    		return 1;
	}elsif($params->{step} eq 'operation'){
    		$dbh->do($params->{sql});
	}
}
sub error
{
	my ($self,$msg)=@_;
	my $tmpl=$self->load_tmpl('proto_error.html');
 	$self->{tpl_vars}->{error} = $msg;
	my $output = "";
   	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
   	return $output;
}



sub proto_add_edit
{
   my $self=shift;
   my $method=shift;
   my $proto=shift;
	
   

   my $p = $self->proto_begin($proto, {method=>$method});

   my $id = $self->query->param("id");

   
   my $is_apply = $self->query->param('action') eq 'apply';
   # $TIMER->start('fuzzbin');

###checcking the fileds	
   if($is_apply){
     
     return $self->header_add(-location=>$p->{back_url}) if($self->query->param('__cancel'));
    	


     foreach my $row( @{$proto->{fields}} ){
	
		

       my $val=$self->query->param( $row->{field} );
	
       my $prefix = "$TRANSLATE{field} '$row->{title}'";

		next if($row->{no_add_edit});

##filters
		if($row->{positive})
		{         
			$val=~s/[,]/\./g;##for blonds
			$val=~s/[ \\]//g;
			$self->query->param($row->{field},$val);
			    return $self->error("$prefix $TRANSLATE{no_number_format} ")  unless ($val =~ /^\s*[+-]?\d+\.?\d*\s*$/);
			$val += 0;
			return error $self,"$prefix $TRANSLATE{must_be_lage} 0" if($val <= 0);
		}elsif($row->{num_or_empty})
		{
			$val=~s/[,]/\./g;##for blonds
			$val=~s/[ \\]//g;
			$self->query->param($row->{field},$val);
			return  error $self,"$prefix !!!" if(!$val =~ /^\s*[+-]?\d+\.?\d*\s*$/&&!$val);
		
		}elsif($row->{req_currency})
		{
			return  error $self,"$prefix $TRANSLATE{cur_no_support} !" unless($avail_currency->{$val});

		}
        elsif($row->{etalon}&&abs($val)>(2*$row->{etalon}))
        {
            return error $self, "$prefix  $TRANSLATE{diff_standart}  \n";

        }
		elsif($row->{uniq})
		{
			##if setting id ,the it must be editing
			
			if($id&&$dbh->selectrow_array("SELECT $row->{field} FROM  $proto->{table} WHERE $row->{field}=? 
						AND  ",undef,$val))
			{
				return error $self,"$prefix $TRANSLATE{must_be_unique}  !!! \n";

			}elsif($dbh->selectrow_array("SELECT $row->{field} FROM  $proto->{table} WHERE $row->{field}=? ",undef,$val)) ##in other case it adding
			{
				return error $self,"$prefix $TRANSLATE{must_be_unique}  !!!  !!! \n";
			}
		
		}elsif($row->{category} eq 'accounts'){
			
		return error $self,"$prefix   \n" unless($dbh->selectrow_array(q[SELECT a_id FROM accounts WHERE a_id=?],undef,$val));
			
			
		}elsif($row->{category} eq 'exchange')
		{
			$row->{exchange_yes}=$self->query->param('exchange_yes');
			if($row->{exchange_yes})
			{
				
				$row->{common_sum}=$self->query->param('common_sum');
				$row->{rate}=$self->query->param('rate');
				$row->{currency}=$self->query->param('currency');	
				$row->{ct_comis_percent_exchange}=$self->query->param('ct_comis_percent_exchange');
                $row->{ct_comis_percent_in_exchange}=$self->query->param('ct_comis_percent_in_exchange');

				$row->{ct_currency}=$self->query->param('ct_currency');	
				$row->{ct_comis_percent_exchange}=~s/,/\./g;
				$row->{ct_comis_percent}=$self->query->param('ct_comis_percent');
				$row->{ct_comis_percent}=~s/,/\./g;

			return error $self, "$TRANSLATE{course_no_set} \n"	if(!$self->query->param('light_rate')&&!$row->{rate});
			return error $self, "$TRANSLATE{cur_no_support} \n"	unless($avail_currency->{$row->{currency}});

#			die $row->{ct_comis_percent};
			return error $self, " $TRANSLATE{not_set_proc} \n" if($row->{ct_comis_percent_exchange}!~/0|0\.0/&&!$row->{not_req}&&!$row->{ct_comis_percent_exchange}&&!$row->{ct_comis_percent});
			delete $row->{ct_comis_percent};
			
# 
			}
		}elsif($row->{'require'})
		{
	            return error $self, "$TRANSLATE{comm_no_empty} \n" unless($self->query->param('ct_comment'));

		}
			
	


	}


}


   my $is_apply_but_need_confirm = 
   $is_apply && $proto->{'need_confirmation'} && !$self->query->param('__confirm');
   

   if($is_apply && !$is_apply_but_need_confirm){     

 $self->proto_add_edit_trigger({
       'method'=>$method,
       'proto'=>$proto,
       'p'=>$p,
       'step'=>'before',
});

return my_log($self,$TIMER->stop) if($self->{__HEADER_TYPE} eq 'redirect');


     my $sql = "";

     if($method eq 'edit'){
       $sql .= "UPDATE";
}else{
       $sql .= "INSERT";
}
     $sql .= " $p->{table} SET ";

        my $sql_list = "";

     foreach my $row( @{$proto->{fields}} ){

	

       next if($row->{no_base}||$row->{'system'});
       my $expr="";
       if($row->{no_add_edit}){         

         $expr = $row->{add_expr} if($row->{add_expr} && $method eq 'add');
         $expr = $row->{edit_expr} if($row->{edit_expr} && $method eq 'edit');
         $expr = $row->{expr} if($row->{expr});

	}elsif($row->{type} eq 'set'){

         my $val="";
         foreach my $option( @{$row->{titles}} ){                    
          add2list(\$val, $option->{value}, "|") 
          if(
            $self->query->param( $row->{field}."__".$option->{value} )
          );                    
	}
         $expr = sql_val("|$val|");

		}else{
			my $val = $self->query->param( $row->{field} );
			if($row->{crypt}){
				if( length($val) > 0 ){
					$expr = sql_val($val);
					$expr = "$row->{crypt}($expr)";
				}
			}else{
				$val = trim($val);
				$val = 0-$val if($row->{op} eq '-');
				$val = undef if(length($val)==0 && $row->{may_null});
				$expr = sql_val($val);
			}
		}
		
       		add2list(\$sql_list, "$row->{field} = $expr") if( length($expr)>0 );
	}

     $sql .= $sql_list;

      #$p->{edit_where}=' 1 '  unless(defined $p->{edit_where});     

     if($method eq 'edit'){       
       $sql .= " WHERE $p->{edit_where}  AND  $p->{id_field}=".sql_val($id);
	}
     
     $self->proto_add_edit_trigger({
       'sql'=>$sql,
       'method'=>$method,
       'proto'=>$proto,
       'p'=>$p,
       'step'=>'operation',
});
	
	$self->header_type('redirect');
            
    my_log($self,$TIMER->stop);
    return $self->header_add(-url=>$p->{back_url}."#$id");
}else{


     if($method eq 'edit'){  

  
#       $p->{edit_where}=' 1 '  unless(defined $p->{edit_where});     
    
       my $r = $dbh->selectrow_hashref("SELECT * FROM $p->{table} WHERE $p->{edit_where}  AND  $p->{id_field} = ".sql_val($id));
       if($is_apply_but_need_confirm){
	
         map {$r->{$_}=$self->query->param($_)} $self->query->param();
 	

#fixme: set not work!
#i can fix you ,because i'm not a genetic engineer
		}

	
       if($r){

	
        foreach my $row( @{$proto->{fields}} ){

         next if($row->{crypt});


### firm_services SELECT for ct_fid #####################
         if($row->{category} eq "firm_services"){
           my $rf = $dbh->selectrow_hashref("SELECT * FROM firms WHERE f_id = ".sql_val( $r->{ct_fid} ));
#die Dumper $rf;
           if($rf){
             my $services = set2hash($rf->{f_services});
             my $slist = "";
             foreach my $s( keys(%$services) ){
               add2list(\$slist, $s);
	}       
             my $sql = qq[SELECT * FROM firm_services
              WHERE fs_status='active' AND fs_id IN ($slist)
              AND fs_id>0
              ORDER BY fs_id
             ];
             my @titles=();
             push @titles, {"value"=>undef, "title"=>""};

             if(length($slist) > 0){
               my $sth =$dbh->prepare($sql);
               $sth->execute();
               while(my $r = $sth->fetchrow_hashref)
		{
			push @titles, {
			"value"=>$r->{fs_id}, 
			"title"=>"$r->{fs_name} (id#$r->{fs_id}) Silver: $r->{fs_silver_per} Gold:$r->{fs_gold_per} Platinum:$r->{fs_platinum_per} Infinite: $r->{fs_infinite_per} Partner: $r->{fs_partner_per}) "#$title"
		};
		
		}
		$sth->finish();
	
		}


             $row->{titles} = \@titles;
	     $row->{type}   = "select";
#bogdan work for javascripts
	   
		
	
###
		
		}
	}
		
  

	if($row->{type} eq 'set'){
		
          my $val = $r->{ $row->{field} };
	   
	    unless($val  ){
	         $r->{ $row->{field} }=$row->{val};
	         $val=$row->{val};
	   }
          my $hash = set2hash($val);
          
          my $index = 0;
          foreach my $option( @{$row->{titles}} ){                    
           $option->{checked}=1            
           if($hash->{ $option->{value} });
           
           $index++;
	}

          next;
}
		
	
         unless($row->{'system'})
	     {
	    	$row->{value} = $r->{ $row->{field} };
			
	     }
	
#are used by javascript
		
         if($row->{no_add_edit}){

		if(defined $row->{category}){
		$row->{value} = category_title($row->{category}, $row->{value}, {row=>$r});
		}

		}

         $row->{value} = 0-$row->{value} if($row->{op} eq '-');
	}
      

}


}else{
	my $pr;
	
       
       foreach my $row( @{$proto->{fields}} ){

   	if($row->{category} eq "exchange"){
		
		if($row->{exchange_yes})
		{
			$row->{rate}=$self->query->param('rate');
			$row->{to}=$self->query->param('ct_currency');
			$row->{rate}=$self->query->param('rate');
			$row->{currency}=$self->query->param('currency');
			unless($row->{common_sum})
			{
				$row->{common_sum}=$row->{ct_amnt}-($row->{ct_comis_percent}*$row->{ct_amnt})/100;
			}else
			{
				$row->{common_sum}=$row->{common_sum};
			}

			$row->{common_sum}=POSIX::floor($row->{common_sum}*100)/100;
			
			($row->{exchange_amnt},$row->{math_rate})=$self->calculate_exchange(
				$row->{common_sum},
				$row->{rate},
				$row->{ct_currency},
				$row->{currency}
			);

		}
		
	}elsif($row->{category} eq "kassa_firm_services"){
	            
	          
	            
	            
	             my $rf = $dbh->selectrow_hashref("SELECT * FROM firms WHERE f_id =-1 ");
		     #die Dumper $rf;
		               
                 if($rf){
                         my $services = set2hash($rf->{f_services});
                         my $slist = "";
                         foreach my $s( keys(%$services) ){
	                     add2list(\$slist, $s);
                     }
                 my $sql = qq[SELECT * FROM firm_services
                     WHERE fs_status='active' AND fs_id IN ($slist)
                     ORDER BY fs_id
                 ];
                 my @titles=();
                 push @titles, {"value"=>undef, "title"=>""};
                 if(length($slist) > 0){
                             my $sth =$dbh->prepare($sql);
	                     $sth->execute();
	                     while(my $r = $sth->fetchrow_hashref)
	                     {
	                             push @titles, {
	                                 "value"=>$r->{fs_id}, 
	                         "title"=>"$r->{fs_name} (id#$r->{fs_id}) Silver: $r->{fs_silver_per} Gold:$r->{fs_gold_per} Platinum:$r->{fs_platinum_per} Infinite: $r->{fs_infinite_per} Partner: $r->{fs_partner_per}) "#$title"
	                     };
	         }
	         $sth->finish();
	 }
	     $row->{titles} = \@titles;
	     $row->{type}   = "select";
	         #bogdan work for javascripts
	 }
	}
    if($is_apply_but_need_confirm&&!$row->{'system'}){
           $row->{value} = $self->query->param( $row->{field} );
           next;
	
	#fexme: set not work!
}
	$pr=$self->query->param($row->{field});
         unless($pr)
	{
			$row->{value} = $row->{default};
		
	}else
	{
			$row->{value} = $pr;
	}

		
}
}
   
}

   	
   my $tmpl=$self->load_tmpl($p->{template_prefix}.'_add_edit.html');
   if($is_apply_but_need_confirm){
     $self->{tpl_vars}->{need_confirm}=1;
}	
   $self->{tpl_vars}->{method}=$method;
   $self->{tpl_vars}->{fields}=$proto->{fields};
   $self->{tpl_vars}->{id} = $id;
   $self->{tpl_vars}->{init_java_script}=$proto->{init_java_script};
   $self->{tpl_vars}->{proto_params}=$proto; 


   my $output = "";
   my $time=$TIMER->stop;
   $self->{tpl_vars}->{timer}=$time;
   my_log($self,$time);

   $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();

   return $output;
}
sub calculate_exchange
{
	my ($self,$amnt,$rate,$from,$to)=@_;

	$rate=$rate**$RATE_FORMS{$from}->{$to};

	my $res=$rate*$amnt;

	return (POSIX::ceil($res*100000)/100000,$rate);
	

}
 sub proto_action
{
   my $self=shift;
   my $method=shift;
   my $proto=shift;
   my $p = $self->proto_begin($proto, {method=>$method});
   my $id=$self->query->param('id');
   if( $method eq 'del' ){
     $dbh->do(
       qq[UPDATE $p->{table} SET $p->{del_field}='$p->{del_value}' WHERE $p->{id_field}=?],
       undef,
       $id
     );
}

   return $self->header_add(-location=>$p->{back_url}."#$id");
}


### subs which will be used for gropu identifier
sub add_common_
{
	my $self=shift;
	my $ext=shift;
	$ext=undef unless($ext);
	my @ct_id=$self->query->param('ct_id');
	push @ct_id,0;

	map{$_=~s/["' \\]//g}  @ct_id;
	my $str=join(',',@ct_id);
	
	my $sum;
	

##for checking objections of common identification
	my ($currency,$fid);
	my @res;
	my $firm_info={};
	
	my $out_firms=get_out_firms_hash();
	my $sth=$dbh->prepare(
			qq[	
				SELECT * FROM cashier_transactions,firms 
				 WHERE 
				 ct_fid>0  
				 AND 1 AND ct_status='created' AND ct_fid=f_id 
				 AND  ct_id IN ($str) 
			  ]
			  );
	$sth->execute();
	my ($services,$services2);


	if(my $r=$sth->fetchrow_hashref())
	{	

        $services = set2hash($r->{f_services});
		
		$currency=$r->{ct_currency};
		$fid=$r->{ct_fid};
		$r->{ct_amnt}=abs($r->{ct_amnt});

		$firm_info->{f_name}=$r->{f_name};
		$firm_info->{f_uah}=$r->{f_uah};
		$firm_info->{f_usd}=$r->{f_usd};
		$firm_info->{f_eur}=$r->{f_eur};
		$firm_info->{f_id}=$fid;
		$self->{tpl_vars}->{ct_fid}=$fid;
		$self->{tpl_vars}->{ct_currency}=$currency;
		$sum+=$r->{ct_amnt};

        $r->{out_firm}=$out_firms->{ $r->{ct_ofid} }->{title};
        
        
		$r->{ct_currency}=$conv_currency->{$r->{ct_currency}};
		$r->{ct_date}=format_date($r->{ct_date});
		push @res,$r;
		
		while( my $r=$sth->fetchrow_hashref() )	
		{
			$r->{ct_amnt}=abs($r->{ct_amnt});
			$services2=set2hash($r->{f_services});
			map{delete $services->{$_} unless($services2->{$_}) } keys %$services;
		
			
			if($r->{ct_currency} ne $currency)
			{

				##if the varios objections of different cards
				die " $TRANSLATE{diff_terms}  \n";
				
			}		
			$r->{ct_currency}=$conv_currency->{$r->{ct_currency}};
			$r->{ct_date}=format_date($r->{ct_date});
            $r->{out_firm}=$out_firms->{ $r->{ct_ofid} }->{title};

			$sum+=$r->{ct_amnt};

			push @res,$r;
		}
	
	}else{ ##if we didn't select any record
	
		die " $TRANSLATE{row_no_select}\n";
	}

	my $count=@res;
	$self->{tpl_vars}->{count_records}=$count;

	$sth->finish();
	$self->{tpl_vars}->{list}=\@res;
	
 	map {$self->{tpl_vars}->{$_}=$firm_info->{$_} } keys %$firm_info;
	$services->{'0'}=1;
	$self->{tpl_vars}->{services}=get_special_services(keys %$services);

	##use ext comission
	$self->{tpl_vars}->{ext}=$ext;

	$self->{tpl_vars}->{sum}=$sum;


   	$self->{tpl_vars}->{page_title}=$TRANSLATE{"group_add"};

 	my $tmpl=$self->load_tmpl('firm_common_input2.html');

        my $output='';
   	$self->{tpl_vars}->{timer}=$TIMER->stop;
	
        my_log($self,$self->{tpl_vars}->{timer});
	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
        return $output;	

	


}
sub add_common_confirm_
{
	my $self=shift;
	my $ext=shift;
	my @ct_id=$self->query->param('ct_id');
	push @ct_id,0;
	my $exchange_yes=$self->query->param('exchange_yes');
	my $ct_comis_percent=$self->query->param('ct_comis_percent');
	my $ct_fsid=$self->query->param('ct_fsid');
	my $ct_aid=$self->query->param('ct_aid');

	my $ct_comis_percent_exchange=$self->query->param('ct_comis_percent_exchange');

    my $ct_comis_percent_in_exchange=$self->query->param('ct_comis_percent_in_exchange');
	
	my $ct_ext_comission=$self->query->param('ct_ext_comission');
   
    my $ct_comis_percent_in=$self->query->param('ct_comis_percent_in');
    $ct_comis_percent_in*=1;
    $ct_ext_comission*=1;
    my $out_firms=get_out_firms_hash();


    my ($ct_comis_percent_exchange_sum,$ct_comis_percent_in_exchange_sum)=(0,0);
    die "$TRANSLATE{dont_set_add_cred_commission} \n"    if(($ct_comis_percent_in&&$ct_ext_comission)||($ct_comis_percent_in_exchange&&$ct_ext_comission));

	my $light_rate;
	my $source_currency;
    my $real_rate;

    
    die "$TRANSLATE{client_no_set} \n " unless($dbh->selectrow_array('SELECT a_id FROM accounts WHERE a_id=?',undef,$ct_aid));
	if($exchange_yes)
	{
            $ct_comis_percent_exchange=~s/[,]/\./g;
            $ct_comis_percent=~s/[,]/\./g;
            $source_currency=$self->query->param('currency');

            die " $TRANSLATE{cur_no_support} \n" unless($avail_currency->{$source_currency});
            $light_rate=$self->query->param('rate');
            die " $TRANSLATE{course_no_set} \n"  unless($light_rate);
            die " $TRANSLATE{input_proc}\n" if($ct_comis_percent_exchange!~/0|0\.0/&&!$ct_comis_percent_exchange*1&&!$ct_comis_percent*1);

            die "$TRANSLATE{comis_lage_standart}\n" if(abs($ct_comis_percent_exchange)>2*$ETALON_VALUE_COMIS||abs($ct_comis_percent)>2*$ETALON_VALUE_COMIS);
            
           


	        		
	}
	

	map{$_=~s/["' \\]//g}  @ct_id;
	my $str=join(',',@ct_id);
	my $sth=$dbh->prepare(
			qq[	
				SELECT * FROM cashier_transactions,firms 
				 WHERE 
				 ct_fid>0  
				 AND ct_status='created'  AND ct_fid=f_id 
				 AND  ct_id IN ($str) 
			  ]
			  );
	
	my ($sum,$result_sum);
	
##for checking objections of common identification
	my ($currency,$fid);
	my $firm_info={};
	my @res;
	$sth->execute();
	my $commission=0;
	
		
	my $exchange_amnt;
	my ($services2,$services);
    
	if(my $r=$sth->fetchrow_hashref())
	{	
        $services = set2hash($r->{f_services});
		map{ die " $TRANSLATE{diff_terms}  \n" if( $ct_fsid&&!$services->{$ct_fsid} ) } keys %$services;


		$currency=$r->{ct_currency};
        $real_rate=$self->calculate_exchange(0,$light_rate,$currency,$source_currency);

		$fid=$r->{ct_fid};
		$r->{ct_amnt}=abs($r->{ct_amnt});

		$self->{tpl_vars}->{my_ct_currency}=$conv_currency->{$currency};
		$firm_info->{f_name}=$r->{f_name};
		$firm_info->{f_uah}=$r->{f_uah};
		$firm_info->{f_usd}=$r->{f_usd};
		$firm_info->{f_eur}=$r->{f_eur};
		$firm_info->{f_id}=$r->{f_id};
		$self->{tpl_vars}->{ct_fid}=$fid;
		$self->{tpl_vars}->{ct_currency}=$currency;
            
                

	$r->{ext_comission}=$ct_ext_comission;
        $ct_comis_percent_exchange_sum=0;
        $ct_comis_percent_exchange_sum=($r->{ct_amnt}*$real_rate-$r->{ct_amnt}*($real_rate-($real_rate/100)*$ct_comis_percent_exchange))/$real_rate if($ct_comis_percent_exchange>0);
        $ct_comis_percent_in_exchange_sum=0;
        $ct_comis_percent_in_exchange_sum=($r->{ct_amnt}*$real_rate-$r->{ct_amnt}*($real_rate-($real_rate/100)*$ct_comis_percent_in_exchange))/$real_rate if($ct_comis_percent_in_exchange>0);

        
        $r->{comission}=$ct_comis_percent_exchange_sum+$ct_comis_percent_in_exchange_sum+$ct_comis_percent*($r->{ct_amnt}/100)+$ct_comis_percent_in*($r->{ct_amnt}/100)+$r->{ext_comission};
        
        $commission+=$r->{comission};
		

            
        
		$r->{ct_currency}=$conv_currency->{$r->{ct_currency}};
		##for working with input and output pays
		if($ext){

			$exchange_amnt=$r->{ct_amnt}+$r->{comission};

		}else{

			$exchange_amnt=$r->{ct_amnt}-$r->{comission};
		}
		

		#we use  or now exchange
			if($exchange_yes){

				($r->{result_amnt},$r->{normal_rate})=$self->calculate_exchange
				(
					$exchange_amnt, $light_rate,
					$currency,$source_currency
				);
				
				$r->{user_rate}=$light_rate;	
				$result_sum+=$r->{result_amnt};
			}else{
				$r->{result_amnt}=$exchange_amnt;
				$result_sum+=$r->{result_amnt};
				
			
			}
		
		$r->{ct_date}=format_date($r->{ct_date});
		$r->{ct_amnt}=format_float($r->{ct_amnt});
		$r->{result_amnt}=format_float($r->{result_amnt});
        $r->{out_firm}=$out_firms->{ $r->{ct_ofid} }->{title};

		push @res,$r;
		
		while( my $r=$sth->fetchrow_hashref() )	
		{
		
			$r->{ct_amnt}=abs($r->{ct_amnt});
			$services2=set2hash($r->{f_services});

				map{die " $TRANSLATE{diff_terms} \n" if($ct_fsid&&!$services2->{$ct_fsid}) } keys %$services2;
		
			
		if($r->{ct_currency} ne $currency)
		{
				##if the varios objections of different cards
				die "$TRANSLATE{diff_cur} \n";
				
		}		

        $r->{ext_comission}=$ct_ext_comission;
        $r->{ct_currency}=$conv_currency->{$r->{ct_currency}};


        $ct_comis_percent_exchange_sum=($r->{ct_amnt}*$real_rate-$r->{ct_amnt}*($real_rate-($real_rate/100)*$ct_comis_percent_exchange))/$real_rate if($ct_comis_percent_exchange>0);
        $ct_comis_percent_in_exchange_sum=($r->{ct_amnt}*$real_rate-$r->{ct_amnt}*($real_rate-($real_rate/100)*$ct_comis_percent_in_exchange))/$real_rate if($ct_comis_percent_in_exchange>0);

        
        $r->{comission}=$ct_comis_percent_exchange_sum+$ct_comis_percent_in_exchange_sum+$ct_comis_percent*($r->{ct_amnt}/100)+$ct_comis_percent_in*($r->{ct_amnt}/100)+$r->{ext_comission};



			$commission+=$r->{comission};

			if($ext)
			{
				$exchange_amnt=$r->{ct_amnt}+$r->{comission};
			}else
			{
				$exchange_amnt=$r->{ct_amnt}-$r->{comission};
			}

			if($exchange_yes)
			{
				($r->{result_amnt},$r->{normal_rate})=$self->calculate_exchange
				(
					$exchange_amnt, $light_rate,
					$currency,$source_currency
				);
				
				$r->{user_rate}=$light_rate;	
				$result_sum+=$r->{result_amnt};
			}else
			{
				$r->{result_amnt}=$exchange_amnt;
				$result_sum+=$r->{result_amnt};
			
			}
				$r->{ct_date}=format_date($r->{ct_date});
				$r->{ct_amnt}=format_float($r->{ct_amnt});
                $r->{out_firm}=$out_firms->{ $r->{ct_ofid} }->{title};

				$r->{result_amnt}=format_float($r->{result_amnt});
				push @res,$r;
		}
		
	}else ##if we didn't select any record
	{
		die "$TRANSLATE{row_no_select}  \n";
	}

	$sth->finish();
	if($exchange_yes)
	{
		$self->{tpl_vars}->{my_currency}=$conv_currency->{$source_currency};	
	}else
	{
		$self->{tpl_vars}->{my_currency}=$conv_currency->{$currency};	
	}
	$self->{tpl_vars}->{ct_comis_percent}=$ct_comis_percent;
	$self->{tpl_vars}->{my_ct_comis_percent}=$ct_comis_percent+$ct_comis_percent_in+$ct_comis_percent_exchange+$ct_comis_percent_in_exchange;
    my $a=get_account_name($self->query->param('ct_aid'));

    $self->{tpl_vars}->{error_msg}="$TRANSLATE{card_bal_minus} \n" if($a->{ac_id}==$CLIENT_CATEGORY&&$ext&&($a->{lc($self->{tpl_vars}->{my_currency})}-$result_sum)<0);

	$self->{tpl_vars}->{account_title}=$a->{ext_info};
	
	$self->{tpl_vars}->{ext}=$ext;
	$self->{tpl_vars}->{ct_ext_comission}=$ct_ext_comission;
	
	$self->{tpl_vars}->{result_comission}=$commission;
	
	$self->{tpl_vars}->{ct_comment}=$self->query->param('ct_comment');
	$self->{tpl_vars}->{ct_ts2}=$self->query->param('ct_ts2');
	$self->{tpl_vars}->{ct_ts2_unformat}=format_date($self->{tpl_vars}->{ct_ts2});

	$self->{tpl_vars}->{exchange_yes}=$exchange_yes;

	$self->{tpl_vars}->{currency}=$source_currency;
	$self->{tpl_vars}->{rate}=$light_rate;
	$self->{tpl_vars}->{result_amnt}=format_float($result_sum);
	$self->{tpl_vars}->{ct_comis_percent_exchange}=$ct_comis_percent_exchange;
    $self->{tpl_vars}->{ct_comis_percent_in_exchange}=$ct_comis_percent_in_exchange;
    $self->{tpl_vars}->{ct_comis_percent_in}=$ct_comis_percent_in;

	$self->{tpl_vars}->{list}=\@res;	
	
 	map {$self->{tpl_vars}->{$_}=$firm_info->{$_} } keys %$firm_info;
	
	$self->{tpl_vars}->{ct_fsid}=$ct_fsid;
	
	my $account_info=get_account_name($ct_aid);
	
	$self->{tpl_vars}->{fs_name}=$dbh->selectrow_array(q[SELECT fs_name FROM firm_services WHERe fs_id=?],undef,$ct_fsid);
	
	$self->{tpl_vars}->{ct_aid}=$ct_aid;
	
	$self->{tpl_vars}->{page_title}=$TRANSLATE{"confirm_groups_add"};

	my $tmpl=$self->load_tmpl('firm_common_input2_confirm.html');
        my $output='';
 	$self->{tpl_vars}->{timer}=$TIMER->stop;
    my_log($self,$self->{tpl_vars}->{timer});
	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
        return $output
}
1;


