package Oper::FirmInput;
use strict;
use base 'CGIBaseOut';
use SiteConfig;
use SiteDB;
use CGI::Carp qw(fatalsToBrowser);
use SiteCommon;

use XML::Excel;
use DateTime::Format::Excel;

use Encode qw(from_to encode is_utf8); 
my $proto={
  'table'=>"cashier_transactions",  
  'page_title'=>'Выписки',
  'template_prefix'=>"firm_in",
  'extra_where'=>" ct_fid>0 AND ct_status!='deleted'",
  
  'need_confirmation'=>1,
  'id_field'=>'ct_id',
  'sort'=>'ct_date DESC',

  'fields'=>[
    {'field'=>"ct_id", "title"=>"ID", "no_add_edit"=>1}, #first field is ID

    {'field'=>"ct_date", "title"=>"Дата поступления",'filter'=>"time","default"=>$now_hash->{sql}
},

   {'field'=>"ct_ts", "no_add_edit"=>1, "add_expr"=>"NOW()", "title"=>"Дата"

   },

    {'field'=>"ct_fid", "title"=>"Фирма", "category"=>"firms", "type"=>"select"
     ,'filter'=>"="
    },

    {'field'=>"ct_amnt", "title"=>"Сумма",'filter'=>"="},
    {'field'=>"ct_currency", "title"=>"Валюта"
     , "type"=>"select"
     , "titles"=>\@currencies
     ,'filter'=>"="
    },
     {'field'=>"ct_req","no_add_edit"=>1,"title"=>"Заявки"
     , "type"=>"select"
     , "titles"=>[{'value'=>"no",title=>'Не заявки'},{'value'=>"yes", 'title'=>'Заявки'},]
     ,'filter'=>"="
    },
    {
     'field'=>"ct_comment", "title"=>"Назначение", 'default'=>"Ввод безналом",
     'filter'=>'like'
    },
    {'field'=>"ct_oid", "title"=>"Оператор"
      , "no_add_edit"=>1, "category"=>"operators"
    },
   {'field'=>"ct_aid", "title"=>"Карточка"
      , "no_add_edit"=>1, "category"=>"accounts"
    },
    #{'field'=>"ct_tid", "title"=>"Транзакция", "no_add_edit"=>1,},

    {'field'=>"ct_status", "title"=>"Статус проведения"
      ,"no_add_edit"=>1, 
      ,"no_view"=>1,
    },



  ]
};

## this module  needs many checkings of params!!!

sub setup
{
  my $self = shift;
  $self->start_mode('list');   
  $self->run_modes(
    'add'  => 'add',
    'add_do'=>'add_do',
    'add_confirm'=>'add_confirm',
    #'firm_input_file'=>'firm_input_file',	
    #'firm_input_file_confirm'=>'firm_input_file_confirm',
    #'firm_input_file_do'=>'firm_input_file_do',
  );
}
sub read_excel_input_file
{
	my ($self,$id)=@_;
	
	my $excel_obj = XML::Excel->new();
	my $status = $excel_obj->parse_doc($FILE_PATH."$id.txt") || die "here1 $!";
	my $fid;
	my $client;
	my @errors;
	my $i=0;
	my $date;
	my $prev_date;
	my $date_excel = DateTime::Format::Excel->new();##for converting dates
	my @params_insert;
	my $amnt;
	my $firm;	
	my $comment;
	my $i=0;
	my $count=0;
	my $sum=0;
=pod	
	if(0&&$id==4566)
	{
	    use Data::Dumper;
    	    die Dumper $excel_obj->{column_data};
	
	
	}    
=cut		

	foreach(@{$excel_obj->{column_data}})
	{
		if($i==0)
		{
			$_->[0] = encode("utf8", $_->[0]);
			from_to($_->[0],'utf8','cp1251');
			$firm=$_->[0];
			$fid=$dbh->selectrow_array(q[SELECT firms.f_id 
			FROM firms,firms_out_operators WHERE    firms_out_operators.f_status='active' 
			AND firms_out_operators.f_id=firms.f_id AND o_id=? 
			AND  lcase(firms.f_name)=lcase(?)],undef,$self->{user_id},$_->[0]);
			

			if(!$fid)##if we didn't find the firm in our system
			{
					push @errors,{firm_name=>$_->[4]};	
					unlink($FILE_PATH."$id.txt") or die "here4 $!";
					$dbh->do(q[DELETE FROM firm_reports WHERE fr_id=?],undef,$id);
					last;
			}
			
		}
		
		if($i==2)
		{
			$date=trim($_->[0]);
			if($date)
			{
				$date=$_->[0];
				$prev_date=$date;
			}else
			{
				$date=$prev_date;
			}
			
			$date=~/(\d+)\.(\d+)\.(\d+)/;
			$date="$3-$2-$1";
			

		}
		
		$dbh->do('UPDATE firm_reports 
			SET fr_fid=?,fr_date=? WHERE fr_id=?',undef,$fid,$date,$id);
		if($_->[4])##if the field is empty
		{
			
			$_->[4] = encode("utf8", $_->[4]);
			$_->[5] = encode("utf8", $_->[5]);
			from_to($_->[4],'utf8','cp1251');
			from_to($_->[5],'utf8','cp1251');
			$_->[4]=trim($_->[4]);
			$_->[5]=trim($_->[5]);
			$comment=$_->[4]." ".$_->[5];
		
			$_->[2]=~s/[,]//g;
			$_->[3]=~s/[,]//g;
			if($_->[2]*1)					
			{
				$amnt=1*$_->[2];

			}elsif($_->[3]*1)
			{
			
				$amnt=(-1)*$_->[3];
			}
			$sum+=$amnt;
		
			push @params_insert,{i=>$count,format_date=>format_date($date),mines=>$amnt<0,amnt=>$amnt,comment=>$comment,
			currency=>$conv_currency->{$DEFAULT_CURRENCY},firm_id=>$fid,firm=>$firm,date=>$date};
				
			$count++;
		}
		$i++;
		
	}
	return {sum=>$sum,count=>$count,inputs=>\@params_insert,errors=>\@errors};

}

sub firm_input_file
{
	my $self=shift;
	my $file=$self->query->param('file');
	my @stats=stat($file);
	my $data;
	unless($file)	
	{

		$self->header_type('redirect');
		return $self->header_add(-url=>"firm_input.cgi");
	
	}
	read $file,$data,$stats[7];
	$dbh->do(q[INSERT INTO firm_reports SET fr_ts=NOW(),fr_oid=?],undef,$self->{user_id},);
	my $id=$dbh->selectrow_array(q[SELECT last_insert_id() ]);

##wrinting file in order to read it from module
## 
	open(FL,">$FILE_PATH"."$id.txt") || die " here2: $!";
	print FL $data;
	close(FL);
	my $ref=$self->read_excel_input_file($id);
	
	
	

	my $size=@{$ref->{errors}};
	if($size)##if we have wrong firms
	{
		#may you do it
		#
		return	$self->ret_errors({errors=>$ref->{errors}});
	}else
	{
		$self->header_type('redirect');
		return $self->header_add(-url=>"firm_input.cgi?do=firm_input_file_confirm&id=$id");
		
	}
	

}
sub ret_errors
{
	my $self=shift;	
	my $errors=shift;
	

	$self->{tpl_vars}->{page_title}='Ошибка при при добавление выписки из файла';
	$self->{tpl_vars}->{firm_errors}=$errors->{errors};
	$self->{tpl_vars}->{error}=$errors->{file};
	
	my $tmpl=$self->load_tmpl('error_firm_input_file.html');
	my $output='';
	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
	return $output;
	

}
sub firm_input_file_confirm
{
		my $self=shift;
		my $id=$self->query->param('id');
	
		$id=$dbh->selectrow_array(q[SELECT fr_id FROM firm_reports WHERE
		  fr_id=? AND fr_status='created'],undef,$id);
	
		unless($id)
		{
			return $self->ret_errors({file=>1});	
		}
		my $ref=$self->read_excel_input_file($id);
				
		my $size=@{$ref->{errors}};
		if($size)##if we have wrong firms
		{
			return $self->ret_errors({errors=>$ref->{errors}});	
		}
		$self->{tpl_vars}->{id}=$id;
		$self->{tpl_vars}->{page_title}='Подтверждение  добавления выписки';
		
		my $firm=get_firm_name($ref->{inputs}->[0]->{firm_id});
	
		
		$self->{tpl_vars}->{firm}=$firm->{ext_info};
		$self->{tpl_vars}->{result_amnt}=format_float($ref->{sum}+$firm->{f_uah});
		
		
	

		$self->{tpl_vars}->{firm_inputs}=$ref->{inputs};
				

		$self->{tpl_vars}->{count}=$ref->{count};
		my $tmpl=$self->load_tmpl('firm_input_file_confirm.html');
		my $output='';
	 	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
         	return $output;

}
sub firm_input_file_do
{
		my $self=shift;
		my $id=$self->query->param('id');
	
		 $id=$dbh->selectrow_array(q[SELECT fr_id FROM firm_reports WHERE  fr_id=? AND fr_status='created'],undef,$id);
		unless($id)
		{
			return $self->ret_errors({file=>1});	
		}
		my $count=$self->query->param('count');
		unless($count)
		{
			$self->header_type('redirect');
			return $self->header_add(-url=>'firm_input.cgi');
		}
		my @inputs;
		my $amnt;
		for(my $i=0;$i<$count;$i++)
		{
			$amnt=$self->query->param("amnt_$i");
			$amnt=s/[,]/\./g;
			$amnt=s/[\"\' ]//g;
			push @inputs,{
				comment=>$self->query->param("comment_$i"),
				amnt=>$self->query->param("amnt_$i"),
				firm_id=>$self->query->param("firm_id_$i"),
				date=>$self->query->param("date_$i"),
			};
			
		}		
##there must be one more checkin!!
		my $p;
		foreach(@inputs)
		{

				if($_->{amnt}>0)
				{	
					$_->{amnt}=abs($_->{amnt});
					$dbh->do("UPDATE firms 
					SET f_uah=f_uah+? 
					WHERE f_id=?",
					undef,abs($_->{amnt}),$_->{firm_id});
					$dbh->do(
					'INSERT INTO 
					cashier_transactions(ct_amnt,ct_comment,ct_currency,ct_oid,ct_fid,ct_date,ct_ts)  
					VALUES(?,?,?,?,?,?,current_timestamp)',undef,
						$_->{amnt},
						$_->{comment},
						$DEFAULT_CURRENCY,
						$self->{user_id},
						$_->{firm_id},
						$_->{date},
					);
				}else
				{
					$dbh->do(
					'INSERT INTO 
					cashier_transactions(ct_amnt,ct_comment,ct_currency,ct_oid,ct_fid,ct_date,ct_ts)  
					VALUES(?,?,?,?,?,?,current_timestamp)',undef,
						$_->{amnt},
						$_->{comment},
						$DEFAULT_CURRENCY,
						$self->{user_id},
						$_->{firm_id},
						$_->{date}
					);
						$_->{amnt}=abs($_->{amnt});
				         $dbh->do("UPDATE firms  SET f_uah=f_uah-?  WHERE f_id=?",
					          undef,abs($_->{amnt}),$_->{firm_id});
																								
					
				}
			
			

		}
		$dbh->do(q[ UPDATE firm_reports SET fr_status='assigned' WHERE  fr_id=? AND fr_status='created'],undef,$id);
		$self->header_type('redirect');
		return $self->header_add(-url=>'firms.cgi');
	


}

sub ret_errors
{
	my $self=shift;	
	my $errors=shift;
	

	$self->{tpl_vars}->{page_title}='Ошибка при при добавление выписки из файла';
	$self->{tpl_vars}->{firm_errors}=$errors->{errors};
	$self->{tpl_vars}->{error}=$errors->{file};
	
	my $tmpl=$self->load_tmpl('error_firm_input_file.html');
	my $output='';
	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
	return $output;
	

}

sub get_right
{       
        my $self=shift;
        return 'firm';

}
sub add
{
       my $self = shift;
	   my $fid=$self->query->param('f_id');
       $proto->{page_title}='Добавить выписку';
       my $sql = qq[SELECT * FROM firms_out_operators
       WHERE f_status='active' AND f_id=? AND o_id=?
       ORDER BY f_name 
          ];
          my $sth =$dbh->selectrow_hashref($sql,undef,$fid,$self->{user_id});

	    unless($sth->{f_id}){
		    $self->header_type('redirect');
		    return $self->header_add(-url=>'firms.cgi');
	    }
    

       
	$self->{tpl_vars}->{ct_date}=$dbh->selectrow_array(q[SELECT current_timestamp]);
	$sth->{f_uah_non_format}=$sth->{f_uah};
	$sth->{f_uah}=format_float($sth->{f_uah});
    $self->{tpl_vars}->{firm_services}=get_firm_services_percents_out($sth->{f_id});
    $self->{tpl_vars}->{my_firm} =$sth;
	$self->{tpl_vars}->{right_accounts} =get_oper_accounts($self->{user_id});
	$self->{tpl_vars}->{firms_okpo}=get_out_firms_okpo();
	$self->{tpl_vars}->{out_firms} = get_out_firms();

    $self->{tpl_vars}->{months} = \@months;
    $self->{tpl_vars}->{years} = get_years();


	$self->{tpl_vars}->{trans_firms} = get_firms();
	$self->{tpl_vars}->{trans_id} = $TRANSIT_ID;

    shift @{$self->{tpl_vars}->{out_firms}};
    unshift @{$self->{tpl_vars}->{out_firms}},{"value"=>'', "title"=>"Новая"};
	$self->{tpl_vars}->{page_title}='Добавить отчет';
	my $tmpl=$self->load_tmpl('firm_input.html');
    my $output='';
	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
    return $output;



}
sub add_confirm
{   
	my $self = shift;
  	my $firm_id=$self->query->param('ct_fid');
	 my $sql = qq[SELECT * FROM firms_out_operators
       WHERE f_status='active' AND f_id=? AND o_id=?
       ORDER BY f_name 
          ];
          my $firm =$dbh->selectrow_hashref($sql,undef,$firm_id,$self->{user_id});

	unless($firm->{f_id})
	{
		$self->header_type('redirect');
		return $self->header_add(-url=>'firms.cgi');
	}
	my $ac_hash=get_oper_accounts_hash($self->{user_id});  
	my $hash_allowed_services=get_firm_services_percents_out_hash($firm_id);
    
	my @amnts=$self->query->param('ct_amnt');
	my @ct_comment=$self->query->param('ct_comment');
	my @ct_okpo=$self->query->param('ct_okpo');
	my @ct_aid=$self->query->param('ct_aid');
    my @fs_id=$self->query->param('ct_fsid');
    my @dr_id=$self->query->param('dr_id');

	my (@ct_ofid,@ofid_names);
	my $existed_firms=get_out_firms_hash;
  	my $firms = get_firms_hash;
	

	for(my $i =1; $i<40;$i++)
	{
		my @a = $self->query->param('ct_ofid'.$i); 
        my $a_id=$ct_aid[$i-1];
        my $fs_id=$fs_id[$i-1];
        if($a_id==$TRANSIT_ID)
    	{
			if($a[0] eq "")
			{
				return $self->error("Вы не выбрали фирму для транзита!");
			}
			my $tmp_f_id = $dbh->selectrow_array(q[SELECT f_id FROM firms 
				WHERE f_id=?],undef,@a[0]*1);
			unless($tmp_f_id)
			{
				return $self->error("Вы не выбрали фирму для транзита!");
			}
			push @ct_ofid,@a[0];
            next;
    	}
        if($a_id||$fs_id==$SYSTEM_SERVICE){
            push @ct_ofid,undef;
            next;
        }
        else
        {
        	
        }

		if($a[0] eq "")
		{
			if($amnts[$i-1])
			{
				if($a[1] eq "")
				{
					return $self->error("Не для всех записей выбрана фирма !");
				}
				else
				{
					return $self->error("Фирма $a[1] не создана!");
				}
			}
			push @ct_ofid,@a[0];
		}else{
			if($amnts[$i-1])
			{
				my $of_id =$dbh->selectrow_array(q[SELECT of_id FROM out_firms 
				WHERE of_id=?],undef,$a[0]*1);
				
				unless($of_id){
					return $self->error("Не для всех записей выбрана фирма !!");
				}
			}
			push @ct_ofid,@a[0];
		}
        

	}

	#my @ct_ofid=$self->query->param('ct_ofid');
	
	my $currency=$RESIDENT_CURRENCY;
 	my $ct_date=$self->query->param('ct_date');
	my $req='no';
	my $size=@amnts;
	my (@amnt_res);
	#return error $self,"Вы не выбрали валюту \n";
	#return error $self,"Вы не выбрали валюту \n"	unless($conv_currency->{$currency});
	my $sum=0;
	
	for(my $i=0;$i<$size;$i++)
	{
		$amnts[$i]=trim($amnts[$i]);
		$ct_comment[$i]=trim($ct_comment[$i]);
		$ct_aid[$i]=trim($ct_aid[$i]);

    	if($ct_comment[$i]&&$amnts[$i])
		{
#			$amnts[$i]=normal_number($amnts[$i]);
     			$amnts[$i]=~s/[ \"\']//g;#replace the spaces in number
 			$amnts[$i]=~s/[,]/\./g;#replace the comma to 
 			$amnts[$i]=$amnts[$i]*1;
			
			$sum+=$amnts[$i];
			if($ct_aid[$i]&&!$ac_hash->{$ct_aid[$i]}->{a_id})
			{
				$self->header_type('redirect');
				return $self->header_add(-url=>'firms.cgi');
			}	
		
		my $f_name;
		if($ct_aid[$i]==$TRANSIT_ID){
			$f_name=$firms->{$ct_ofid[$i]}->{title};
		}else{
			$f_name=$existed_firms->{$ct_ofid[$i]}->{title};
		}
        $dr_id[$i]=int($dr_id[$i]);

        my $doc='';
        $doc=get_doc_info($dr_id[$i]) if(int($dr_id[$i]));


		push @amnt_res,{
                i=>$i,
				value=>$amnts[$i],
                comments=>$ct_comment[$i],
                account=>$ac_hash->{$ct_aid[$i]}->{a_name},
                fs_id=>$hash_allowed_services->{$fs_id[$i]}->{fs_id},
               	service=>$hash_allowed_services->{$fs_id[$i]}->{fs_name},                
				a_id=>$ct_aid[$i],
				ofid=>$ct_ofid[$i],
				of_name=>$f_name,
				okpo=>$ct_okpo[$i],
				no_comment=>($fs_id[$i]==$SYSTEM_SERVICE||$ct_aid[$i]),
				new_firm=>(!int($ct_ofid[$i]*1))&&!($fs_id[$i]==$SYSTEM_SERVICE||$ct_aid[$i]),
				drid=>$dr_id[$i],
                doc=>$doc,
				};
		}
		

		
	}
	
	$self->{tpl_vars}->{ct_req}=0;
#	die $sum;	
	$self->{tpl_vars}->{result_amnt}=format_float($sum+$firm->{'f_'.lc($currency)});
#	die format_float($sum+$firm->{'f_'.lc($currency)});
	$self->{tpl_vars}->{result_currency}=$conv_currency->{$RESIDENT_CURRENCY};
	
	$self->{tpl_vars}->{desc_amnts}=\@amnt_res;	
	my @tmp = get_out_firms();

	$self->{tpl_vars}->{out_firms}=get_out_firms();	
    shift @{$self->{tpl_vars}->{out_firms}};
	$self->{tpl_vars}->{firms_okpo}=get_out_firms_okpo();

   
	$self->{tpl_vars}->{ct_date}=$ct_date;
	
	$self->{tpl_vars}->{format_ct_date}=format_date($ct_date);

	$self->{tpl_vars}->{firm_name}=$firm->{f_name};
	#format_float($firm->{f_uah})

	$self->{tpl_vars}->{firm_balance}=format_float($firm->{f_uah});

	$self->{tpl_vars}->{firm_id}=$firm->{f_id};
	
	$self->{tpl_vars}->{ct_currency}=$RESIDENT_CURRENCY;
	$self->{tpl_vars}->{currency}=$conv_currency->{$RESIDENT_CURRENCY};

	return $self->error("Что за даты?может вы с марса?!" ) if($ct_date!~/\d\d\d\d-\d\d-\d\d/);
#	return $self->error("Вы не можете добавлять сегодняшней датой,обратите на нее внимание \n") if($dbh->selectrow_array(qq[SELECT DATE(current_timestamp)='$ct_date']) );
#	die("$ct_date");
#	return $self->error("Вы работали в выходные ?! ") if($dbh->selectrow_array(qq[SELECT DAYOFWEEK('$ct_date') in (7,1) ]) && $ct_date ne '2010-08-21');



	$self->{tpl_vars}->{page_title}='Подтвердить добавление отчета';
 	 my $tmpl=$self->load_tmpl('firm_input_confirm.html');
         my $output='';
	 $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
         return $output;
}
sub add_do
{
	my $self=shift;
	my ($amnt,$comments);
	
	my @indexes=$self->query->param('amnt_desc_index');
	my $ct_date=$self->query->param('ct_date');
	my $ct_fid=$self->query->param('ct_fid');
	my $fs_id;
	

	return $self->error("Что за даты?может вы с марса?!" ) if($ct_date!~/\d\d\d\d-\d\d-\d\d/);
#	return $self->error("Вы не можете добавлять сегодняшней датой,обратите на нее внимание \n") if($dbh->selectrow_array(qq[SELECT DATE(current_timestamp)='$ct_date']) );
	#return $self->error("Вы работали в выходные ?! ") if($dbh->selectrow_array(qq[SELECT DAYOFWEEK('$ct_date') in (7,1) ]) && $ct_date ne '2010-08-21');

	my $ct_currency=$RESIDENT_CURRENCY;
	
	$amnt=$self->query->param('ct_amnt_4');
	
	my $percent;
	
	 my $sql = qq[SELECT * FROM firms_out_operators
        WHERE f_status='active' AND f_id=? AND o_id=?
        ORDER BY f_name 
          ];
        my $firm =$dbh->selectrow_hashref($sql,undef,$ct_fid,$self->{user_id});
	my $ac_hash=get_oper_accounts_hash($self->{user_id});  

	unless($firm->{f_id})
	{
		$self->header_type('redirect');
		return $self->header_add(-url=>'firms.cgi');
	}
    my $hash_allowed_services=get_firm_services_percents_out_hash($firm->{f_id});
	#
	#return error $self,"Вы не выбрали валюту \n"	unless($conv_currency->{$currency});
	my $a_id=undef;
  	foreach(@indexes)
	{
		$amnt=$self->query->param('ct_amnt_'.$_);
		$amnt=~s/[ \"\']//g;#replace the spaces in number
		$amnt=~s/[,]/\./g;#replace the comma to 
		$amnt=$amnt*1;
		$comments=$self->query->param('ct_comments_'.$_);
		my $ct_ofid = $self->query->param('ct_ofid_'.$_);
		my $ct_okpo = $self->query->param('ct_okpo_'.$_);
        my $ct_drid = int($self->query->param('ct_drid_'.$_));
        $ct_drid='NULL' unless($ct_drid);

		$a_id=undef;

		$a_id=$self->query->param('ct_account_'.$_);
	        $fs_id=$self->query->param('ct_fsid_'.$_);
    		$fs_id=$hash_allowed_services->{$fs_id}->{fs_id};

		if($a_id&&!$ac_hash->{$a_id}->{a_id})
		{
				$self->header_type('redirect');
				return $self->header_add(-url=>'firms.cgi');
		}	
	
		
		
		#-------------------add firm--------------------------------
       my ($of_id,$okpo)=(0,0);


			if($a_id==$TRANSIT_ID)
			{
					my $f_name = "";
					($of_id,$okpo,$f_name) = $dbh->selectrow_array(q[SELECT f_id,f_okpo,f_name FROM firms 
					WHERE f_id=?],undef,$ct_ofid*1);


					unless($of_id)
					{
						return $self->error("Вы не выбрали фирму для транзита!");
					}
					else
					{
						$comments= $f_name.' '.$comments;
						$ct_ofid=$of_id;
					}

			}
			elsif(!$a_id&&$fs_id!=$SYSTEM_SERVICE)
			{	

				
				($of_id,$okpo)=$dbh->selectrow_array(q[SELECT of_id,of_okpo FROM out_firms 
				WHERE of_id=?],undef,$ct_ofid*1);
				
				unless($of_id){
					return $self->error("Не для всех записей выбрана фирма!");
				}
	
		}

		#--------------------search ct_said----------------------------------
		
			my $ct_said =$dbh->selectrow_array(q[SELECT dt_aid FROM documents_transactions
		    WHERE dt_fid=? AND dt_ofid=?],undef,$ct_fid*1,$ct_ofid*1);
		#------------------------------------------------------
		unless($ct_said)
		{
			$ct_said=0;
		}
		
		unless($a_id)
		{	
		
		$dbh->do(q[INSERT INTO cashier_transactions(ct_amnt,ct_comment,ct_currency,ct_oid,
		ct_fid,ct_date,ct_ts,ct_req,ct_fsid,ct_ofid,ct_said,ct_from_drid) VALUES(?,?,?,?,?,?,current_timestamp,'no',?,?,?,?)],undef,
			$amnt*1,
			$comments,
			$ct_currency,
			$self->{user_id},
			$ct_fid,
			$ct_date,
		    $fs_id,
	        $ct_ofid,
	        $ct_said,
            $ct_drid
            
		);
		
		}else
		{
			my $tid = $self->add_trans({
					t_name1 => $firms_id,
					t_name2 => $a_id,
					t_currency => $ct_currency,
					t_amnt => $amnt,
					t_comment => $comments,
			
			});
			if($a_id == $TRANSIT_ID)
			{
					$dbh->do(q[INSERT INTO 
				                cashier_transactions(ct_status,
				                ct_tid2,ct_aid,ct_amnt,
				                ct_comment,ct_currency,
				                ct_oid,ct_fid,ct_date,ct_ts,ct_ts2,ct_req,ct_fsid,ct_from_fid2,ct_from_drid)
					VALUES('processed',?,?,?,?,?,?,?,?,current_timestamp,current_timestamp,'no',?,?,?)],
					undef,
					$tid,
					$a_id,	
					$amnt*1,
					$comments,
					$ct_currency,
					$self->{user_id},
					$ct_fid,
					$ct_date,
			        $fs_id,
			        $ct_ofid,
                    $ct_drid
			        
				);
				
				
			}
			else
			{
					$dbh->do(q[INSERT INTO 
				                cashier_transactions(ct_status,
				                ct_tid2,ct_aid,ct_amnt,
				                ct_comment,ct_currency,
				                ct_oid,ct_fid,ct_date,ct_ts,ct_ts2,ct_req,ct_fsid,ct_from_drid)
					VALUES('processed',?,?,?,?,?,?,?,?,current_timestamp,current_timestamp,'no',?,?)],
					undef,
					$tid,
					$a_id,	
					$amnt*1,
					$comments,
					$ct_currency,
					$self->{user_id},
					$ct_fid,
					$ct_date,
			        $fs_id,
                    $ct_drid
				);
				
			}
		my $last_id_=$dbh->selectrow_array(q[SELECT last_insert_id()]);
		if($amnt>0)
		{
			
		$dbh->do(q[INSERT INTO accounts_reports_table(ct_id,ct_aid,ct_comment,ct_oid,
		o_login,ct_fid,f_name,ct_amnt,ct_currency,comission,
		result_amnt,ct_comis_percent,ct_ext_commission,
		ct_date,e_currency2,rate,ct_eid,ct_ex_comis_type,ts,col_ts,col_status,ct_status,col_color)
		SELECT `cashier_transactions`.`ct_id` AS `ct_id`,`cashier_transactions`.`ct_aid` 
		AS `ct_aid`,
		`cashier_transactions`.`ct_comment` AS `ct_comment`,
		`cashier_transactions`.`ct_oid` AS `ct_oid`,
		`operators`.`o_login` AS `o_login`,
		`firms`.`f_id` AS `ct_fid`,
		`firms`.`f_name` AS `f_name`,
		`cashier_transactions`.`ct_amnt` AS `ct_amnt`,
		`cashier_transactions`.`ct_currency` AS `ct_currency`,
		(-(1) * if((`cashier_transactions`.`ct_eid` is not null),
		if((`cashier_transactions`.`ct_ex_comis_type` = _cp1251'in_rate'),
		((1 / `exchange_view`.`e_rate`) * ((`exchange_view`.`e_rate` * `cashier_transactions`.`ct_amnt`) -
		(`cashier_transactions`.`ct_amnt` * (`exchange_view`.`e_rate` + 
		((`exchange_view`.`e_rate` * `cashier_transactions`.`ct_comis_percent`) / 100))))),
		((`cashier_transactions`.`ct_amnt` * `cashier_transactions`.`ct_comis_percent`) / 100)),
		((`cashier_transactions`.`ct_amnt` * `cashier_transactions`.`ct_comis_percent`) / 100))) AS `comission`,
		if((`cashier_transactions`.`ct_eid` is not null),`exchange_view`.`e_amnt2`,
		(`cashier_transactions`.`ct_amnt` - ((`cashier_transactions`.`ct_comis_percent` * `cashier_transactions`.`ct_amnt`) / 100))) AS `result_amnt`,
		`cashier_transactions`.`ct_comis_percent` AS `ct_comis_percent`,
		`cashier_transactions`.`ct_ext_commission` AS `ct_ext_commission`,cast(if(isnull(`cashier_transactions`.`ct_ts2`),
		`cashier_transactions`.`ct_ts`,`cashier_transactions`.`ct_ts2`) as date) AS `ct_date`,
		`exchange_view`.`e_currency2` AS `e_currency2`,
		`exchange_view`.`e_rate` AS `rate`,
		`cashier_transactions`.`ct_eid` AS `ct_eid`,
		`cashier_transactions`.`ct_ex_comis_type` AS `ct_ex_comis_type`,if(isnull(`cashier_transactions`.`ct_ts2`),
		`cashier_transactions`.`ct_ts`,`cashier_transactions`.`ct_ts2`) AS `ts`,
		`cashier_transactions`.`col_ts` AS `col_ts`,
		'no',
		`cashier_transactions`.`ct_status` AS `ct_status`,
		`cashier_transactions`.`col_color` AS `col_color`
		
		from (((`cashier_transactions` 
		left join `exchange_view` on((`exchange_view`.`e_id` = `cashier_transactions`.`ct_eid`))) 
		left join `firms` on((`cashier_transactions`.`ct_fid` = `firms`.`f_id`))) 
		left join `operators` on((`cashier_transactions`.`ct_oid` = `operators`.`o_id`)))
		where (1  AND ct_id=? AND (`cashier_transactions`.`ct_amnt` > 0) and (`cashier_transactions`.`ct_status` 
		in (_cp1251'processed'))) LIMIT 0,1],undef,$last_id_);	



		}else
		{
			$dbh->do(q[INSERT INTO accounts_reports_table(ct_id,ct_aid,ct_comment,ct_oid,
				o_login,ct_fid,f_name,ct_amnt,ct_currency,comission,
				result_amnt,ct_comis_percent,ct_ext_commission,
				ct_date,e_currency2,rate,ct_eid,ct_ex_comis_type,ts,col_ts,ct_status,col_color,col_status)
				select `cashier_transactions`.`ct_id` AS `ct_id`,`cashier_transactions`.`ct_aid` AS `ct_aid`,
				`cashier_transactions`.`ct_comment` AS `ct_comment`,
				`cashier_transactions`.`ct_oid` AS `ct_oid`,
				`operators`.`o_login` AS `o_login`,
				`firms`.`f_id` AS `ct_fid`,
				`firms`.`f_name` AS `f_name`,
				`cashier_transactions`.`ct_amnt` AS `ct_amnt`,
				`cashier_transactions`.`ct_currency` AS `ct_currency`,
				if((`cashier_transactions`.`ct_eid` is not null),
				if((`cashier_transactions`.`ct_ex_comis_type` = _cp1251'in_rate'),
				((1 / `exchange_view`.`e_rate`) * ((`exchange_view`.`e_rate` * `cashier_transactions`.`ct_amnt`) - 
				(`cashier_transactions`.`ct_amnt` * (`exchange_view`.`e_rate` + 
				((`exchange_view`.`e_rate` * `cashier_transactions`.`ct_comis_percent`) / 100))))),
				((`cashier_transactions`.`ct_amnt` * `cashier_transactions`.`ct_comis_percent`) / 100)),
				((`cashier_transactions`.`ct_amnt` * `cashier_transactions`.`ct_comis_percent`) / 100)) AS `comission`,
				if((`cashier_transactions`.`ct_eid` is not null),
				`exchange_view`.`e_amnt1`,(`cashier_transactions`.`ct_amnt` - 
				((`cashier_transactions`.`ct_comis_percent` * abs(`cashier_transactions`.`ct_amnt`)) / 100))) AS `result_amnt`,
				`cashier_transactions`.`ct_comis_percent` AS `ct_comis_percent`,
				(-(1) * `cashier_transactions`.`ct_ext_commission`) AS `ct_ext_commission`,
				cast(if(isnull(`cashier_transactions`.`ct_ts2`),
				`cashier_transactions`.`ct_ts`,`cashier_transactions`.`ct_ts2`) as date) AS `ct_date`,
				`exchange_view`.`e_currency1` AS `e_currency2`,
				`exchange_view`.`e_rate` AS `rate`,
				`cashier_transactions`.`ct_eid` AS `ct_eid`,
				`cashier_transactions`.`ct_ex_comis_type` AS `ct_ex_comis_type`,if(isnull(`cashier_transactions`.`ct_ts2`),
				`cashier_transactions`.`ct_ts`,`cashier_transactions`.`ct_ts2`) AS `ts`,
				'0000-00-00 00:00:00',
				`cashier_transactions`.`ct_status` AS `ct_status`,
				16777215,
				'no'
				    from 
				(((`cashier_transactions` left join `exchange_view` on((`exchange_view`.`e_id` = `cashier_transactions`.`ct_eid`))) 
				left join `firms` on((`cashier_transactions`.`ct_fid` = `firms`.`f_id`))) 
				left join `operators` on((`cashier_transactions`.`ct_oid` = `operators`.`o_id`))) 
				where ((`cashier_transactions`.`ct_amnt` < 0) 
				and (`cashier_transactions`.`ct_status` in (_cp1251'processed'))) 
				AND ct_id=? LIMIT 0,1],undef,$last_id_);

		}		
			


		}


		$dbh->do("UPDATE firms SET f_$ct_currency = f_$ct_currency + ? 
			  WHERE f_id = ?", undef, $amnt,$ct_fid);
	    
	}
	
	$self->header_type('redirect');


	return $self->header_add(-url=>'firms.cgi?')
}





1;
