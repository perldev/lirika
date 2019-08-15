package Oper::FirmsConv;
use strict;
use Rights qw( get_rights );
use base q[CGIBase];
use SiteCommon;
use SiteConfig;
use SiteDB;

my $proto;

sub get_right
{
                my $self=shift;
 
 $proto={
  'table'=>"firms_exchange_view",  
  'page_title'=>'Конвертация',
  'template_prefix'=>"firms_exchange_view",
  'need_confirmation'=>1,
  'id_field'=>'fe_id',
  'sort'=>'fe_ts DESC',
  'fields'=>[
    {'field'=>"fe_date",  "title"=>"Дата",'filter'=>'time',category=>'date'},
    
   {'field'=>"ct_fid", "title"=>"Фирма", "category"=>"firms", 'filter'=>"="
     , "type"=>"select",
    },   
   {'field'=>"common_sum", "title"=>"Сумма",'filter'=>"=",'positive'=>1,
      java_script_action=>"onkeyup='amnt_pressed()'",
      java_script=>"
          function amnt_pressed()
	      {
	       	get_element('common_sum',1);
		change_sum();
	      }
"
	},

    {'field'=>"ct_currency", "title"=>"Валюта"
     , "type"=>"select"
     , "titles"=>\@currencies
     , 'filter'=>"=",
   java_script_action=>"onChange='change_currency()'",
 
    },
   {'field'=>"ct_eid",'title'=>'Произвести обмен',
'system'=>1,"category"=>"exchange",'not_req'=>1,"from_visible"=>1},	
    {
     'field'=>"fe_comment", "title"=>"Назначение", 'default'=>"Конвертация ",
     'filter'=>'like'
    },
    {'field'=>"o_id", "title"=>"Оператор"
      , "no_add_edit"=>1, "category"=>"operators"
    },
  ],
	
};
               return 'firms_exchange';
}

sub setup 
{
        my $self=shift;
	$SIG{__DIE__}=\&proto_die_catcher;

 	 $self->run_modes(
			'AUTOLOAD'=>'list',
                        'add'=>'add',
                        'back'=>'back',
                        );   
        


}

sub list
{
   my $self = shift;
   
   return $self->proto_list($proto);
}
sub add
{
   my $self = shift;

   return $self->proto_add_edit('add', $proto);
}
sub back
{

	my $self=shift;
	my $id=$self->query->param('id');
	my $ref=$dbh->selectrow_hashref(q[select * FROM firms_exchange WHERE fe_id=?],undef,$id);
	
	unless($ref->{fe_id})
	{
		$self->header_type('redirect');
  		return  $self->header_add(-url=>'?');
	}
	my $str="($ref->{fe_ctid1_in},$ref->{fe_ctid2_in},$ref->{fe_ctid1_out},$ref->{fe_ctid2_out})";
	
	my $res=$dbh->do(qq[UPDATE 
	cashier_transactions SET ct_status='processing' WHERE ct_id IN 
	$str AND ct_status='transit'
	]);
	
	if($res ne 4)
	{
		$self->header_type('redirect');
	   	return  $self->header_add(-url=>'?');    
	}
	
	my $ref1=$dbh->selectrow_hashref(
		q[SELECT * FROM cashier_transactions WHERE ct_id=?],
		undef,$ref->{fe_ctid1_in}
	);
	
	my ($t_in1,$t_in2)=$self->add_trans_firm(
				{
					user_id=>$self->{user_id},
					o_id=>$self->{user_id},
					amnt=>-1*$ref1->{ct_amnt},
					currency=>$ref1->{ct_currency},
					f_id1=>$FIRMS_CONV,
					f_id2=>$ref1->{ct_fid},
					comment=>"Откат обмена :$ref->{ct_comment}",

				}
				);

	my $ref2=$dbh->selectrow_hashref
	(
		q[SELECT * FROM cashier_transactions WHERE ct_id=?],
		undef,$ref->{fe_ctid2_out}
	);

	my ($t_out1,$t_out2)=$self->add_trans_firm(
				{
					user_id=>$self->{user_id},
					o_id=>$self->{user_id},
					amnt=>$ref2->{ct_amnt},
					currency=>$ref2->{ct_currency},
					f_id1=>$ref2->{ct_fid},
					f_id2=>$FIRMS_CONV ,
					#date=>$hash{fe_date},
					comment=>"Откат обмена :$ref->{ct_comment}",

				}
				);
	
		

	my $res=$dbh->do(qq[DELETE FROM 
	cashier_transactions  WHERE ct_id IN 
	$str AND ct_status='processing'
	]);
	
	
	###there we must to check this or fix some
	my $res=$dbh->do(qq[DELETE FROM 
	cashier_transactions  WHERE ct_id IN 
	($t_out1,$t_out2,$t_in1,$t_in2) AND ct_status='transit'
	]);
	$self->header_type('redirect');
  	return  $self->header_add(-url=>'?');    

}
sub proto_add_edit_trigger
{

  	my $self=shift;
  	my $params = shift;    
##by idea all checkings are finishing
	if($params->{step} eq 'operation')
	{
  		my %hash;
		map{ $hash{ $_ }=$self->query->param($_)  } $self->query->param();
		die "Вы не выбрали фирму \n"	unless($hash{ct_fid});
		die "Такая валюта не поддержуется системой \n"	 unless($avail_currency->{$hash{ct_currency}});
		die "Такая валюта не поддержуется системой \n"	unless($avail_currency->{$hash{currency}});
		my ($result_amnt,$rate)=$self->calculate_exchange($hash{common_sum},$hash{rate},$hash{ct_currency},$hash{currency});
		
		#$FIRMS_CONV
		my ($t_in1,$t_in2)=$self->add_trans_firm(
					{
						user_id=>$self->{user_id},
						o_id=>$self->{user_id},
						amnt=>$hash{common_sum},
						currency=>$hash{ct_currency},
						f_id1=>$hash{ct_fid},
						f_id2=>$FIRMS_CONV,
						date=>$hash{fe_date},
						comment=>$hash{fe_comment}
	
					}
					);
	
		my ($t_out1,$t_out2)=$self->add_trans_firm({
								user_id=>$self->{user_id},
								o_id=>$self->{user_id},
								amnt=>$result_amnt,
								currency=>$hash{currency},
								f_id1=>$FIRMS_CONV,
								f_id2=>$hash{ct_fid},
								date=>$hash{fe_date},
								comment=>$hash{fe_comment}
							});
	
		$dbh->do(q[INSERT INTO 
				firms_exchange 
				SET 	  
				fe_rate=?,
				fe_ctid1_in=?,
				fe_ctid2_in=?,
				fe_ctid1_out=?,
				fe_ctid2_out=?
				
			],undef,$rate,$t_in1,$t_in2,$t_out1,$t_out2);
	
			return 1;	
	}
	
  
}
sub proto_die_catcher
{
        return if $^S; # for eval die
        my $msg=join ',', @_;
        print "Content-type: text/html; charset=cp1251\n\n";
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


1;