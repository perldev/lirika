package Oper::FirmInput;
use strict;
use base 'CGIBase';
use SiteConfig;
use SiteDB;
use CGI::Carp qw(fatalsToBrowser);
use SiteCommon;

use XML::Excel;
use DateTime::Format::Excel;

use Encode qw(from_to encode is_utf8); 
my $proto;
sub get_right{       
        my $self=shift;

    
 $proto={
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



  ],
};
    return 'firm_in';
}
## this module  needs many checkings of params!!!

sub setup
{
  my $self = shift;
    
  $self->run_modes(
    'AUTOLOAD'   => 'list',
    'list' => 'list',
    'back'=>'back',
    'firm_input_file'=>'firm_input_file',	
    'firm_input_file_confirm'=>'firm_input_file_confirm',
    'firm_input_file_do'=>'firm_input_file_do',
    'add'  => 'add',
    'add_do'=>'add_do',
    'add_confirm'=>'add_confirm',
  );
}

sub read_excel_input_file
{
	my $id=shift;
	
	my $excel_obj = XML::Excel->new();
	my $status = $excel_obj->parse_doc($FILE_PATH."$id.txt") || die $!;
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
			$fid=$dbh->selectrow_array(q[SELECT f_id 
			FROM firms WHERE   lcase(f_name)=lcase(?)],undef,$_->[0]);
			if(!$fid)##if we didn't find the firm in our system
			{
					push @errors,{firm_name=>$_->[4]};	
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
			
			$date=~/(\d+)-(\d+)-(\d+)/;
			
			$date="20$3-$1-$2";
		}
		$dbh->do('UPDATE firm_reports SET fr_fid=?,fr_date=? WHERE fr_id=?',undef,$fid,$date,$id);
		if($_->[4])##if the field is empty
		{
			
			$_->[4] = encode("utf8", $_->[4]);
			$_->[5] = encode("utf8", $_->[5]);
			from_to($_->[4],'utf8','cp1251');
			from_to($_->[5],'utf8','cp1251');
			$_->[4]=trim($_->[4]);
			$_->[5]=trim($_->[5]);
			$comment=$_->[4]." ".$_->[5];
		
			$_->[2]=~s/[,\\]//g;
			$_->[3]=~s/[,\\]//g;
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
	open(FL,">$FILE_PATH"."$id.txt") || die " here: $!";
	print FL $data;
	close(FL);
	my $ref=read_excel_input_file($id);

	
	

	my $size=@{$ref->{errors}};
	if($size)##if we have wrong firms
	{
		#may you do it
		#unlink($FILE_PATH."$id.txt");
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
		my $ref=read_excel_input_file($id);
				
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
		#my $ref=read_excel_input_file($id);
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
		return $self->header_add(-url=>'firm_input.cgi');
	


}

sub list
{
   my $self = shift;
   return $self->proto_list($proto);
}


sub add
{
       my $self = shift;
       $proto->{page_title}='Добавить выписку';
   	
       my $sql = qq[SELECT * FROM firms
       WHERE f_status='active' AND f_id>0
       ORDER BY f_name 
          ];
   	
       my @titles=();
       my $sth =$dbh->prepare($sql);
       $sth->execute();                          
       while(my $r = $sth->fetchrow_hashref)
       {
		$r->{f_uah}=format_float($r->{f_uah});
		$r->{f_usd}=format_float($r->{f_usd});
		$r->{f_eur}=format_float($r->{f_eur});
         	push @titles, {"value"=>$r->{f_id}, "title"=>"$r->{f_name} (id#$r->{f_id}) $r->{f_uah} ГРН   
		$r->{f_usd} USD $r->{f_eur} EUR"};
       }
        $sth->finish();
	$self->{tpl_vars}->{ct_date}=$dbh->selectrow_array(q[SELECT current_timestamp]);
        $self->{tpl_vars}->{my_firms} = \@titles;       
	$self->{tpl_vars}->{page_title}='Добавить выписку';
	 my $tmpl=$self->load_tmpl('firm_input.html');
         my $output='';
	 $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
         return $output;



}
sub add_confirm
{   
	my $self = shift;
  	my $firm_id=$self->query->param('ct_fid');
	my @amnts=$self->query->param('ct_amnt');
	my @ct_comment=$self->query->param('ct_comment');
	my $currency=$self->query->param('ct_currency');
 	my $ct_date=$self->query->param('ct_date');
	my $req='no';
	$req='yes'	if($RESIDENT_CURRENCY ne $currency);
    
    
    my $size=@amnts;
	my (@amnt_res);
	my $firm=get_firm_name($firm_id);
    return  $self->error("Вы  выбрали неправильную валюту \n")   if($firm->{f_isres} eq 'no' &&
     $RESIDENT_CURRENCY eq $currency);


	my $percent;
	unless($conv_currency->{$currency}){
			 return  $self->error("Вы  не выбрали  валюту \n") 
	}

	#return error $self,"Вы не выбрали валюту \n"	unless($conv_currency->{$currency});

	return $self->error("Вы не выбрали фирму \n")	unless($firm->{firm_id});

	

	my $sum=0;	
	for(my $i=0;$i<$size;$i++)
	{
		$amnts[$i]=trim($amnts[$i]);
		$percent=0;
    		if($amnts[$i])
		{
		
    			$amnts[$i]=~s/[ \"\'\\]//g;#replace the spaces in number
			$amnts[$i]=~s/[,]/\./g;#replace the comma to 
			$amnts[$i]=$amnts[$i]*1;

			$sum+=$amnts[$i];	
		
		if($amnts[$i]>0)
		{
		   
      			$percent=($amnts[$i]*$firm->{f_percent})/100;
    		}
    
		push @amnt_res,{i=>$i,value=>$amnts[$i],
     		 		in_percent=> $percent,
      		 		comments=>$ct_comment[$i]};
		}
		
	}

	$self->{tpl_vars}->{ct_req}=$req eq 'yes';
	
	
	$self->{tpl_vars}->{result_amnt}=format_float($sum+$firm->{'f_'.lc($currency)});

	$self->{tpl_vars}->{result_currency}=$conv_currency->{$currency};

	

	
	$self->{tpl_vars}->{desc_amnts}=\@amnt_res;	
   
	$self->{tpl_vars}->{ct_date}=$ct_date;
	
	$self->{tpl_vars}->{firm_name}=$firm->{ext_info};

	$self->{tpl_vars}->{firm_id}=$firm->{firm_id};
	
	$self->{tpl_vars}->{ct_currency}=$currency;
	$self->{tpl_vars}->{currency}=$conv_currency->{$currency};


	$self->{tpl_vars}->{page_title}='Подтвердить добавление выписки';

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
	my $ct_currency=$self->query->param('ct_currency');
	my $req='no';
	$req='yes' if($RESIDENT_CURRENCY ne $ct_currency);
	
	$ct_currency=lc($ct_currency);
	$amnt=$self->query->param('ct_amnt_4');
	
	my $percent;
	
	my $firm=get_firm_name($ct_fid);
    return  $self->error("Вы  выбрали неправильную валюту \n")   if($firm->{f_isres} eq 'no' &&
     $RESIDENT_CURRENCY eq $ct_currency);

	unless($conv_currency->{uc($ct_currency)})
	{
			return  $self->error("Вы не выбрали валюту \n");
	}
	#return error $self,"Вы не выбрали валюту \n"	unless($conv_currency->{$currency});
	return $self->error("Вы не выбрали фирму \n")	unless($firm->{firm_id});

  	foreach(@indexes)
	{
		$amnt=$self->query->param('ct_amnt_'.$_);
		$amnt=~s/[ \"\'\\]//g;#replace the spaces in number
		$amnt=~s/[,]/\./g;#replace the comma to 
		$amnt=$amnt*1;
		$comments=$self->query->param('ct_comments_'.$_);
		$percent=0;
		if($req eq 'no')
		{		
					$dbh->do("UPDATE firms SET f_$ct_currency = f_$ct_currency + ? 
					WHERE f_id = ?", undef, $amnt,$ct_fid);
					#open(FL,"$FILE_PATH_LOG") or die $!;
					#print FL "add $amnt of $ct_currency FROM $ct_fid \n";
					#close(FL);
			
		}

	
		$dbh->do(qq'INSERT  INTO cashier_transactions(ct_amnt,ct_comment,ct_currency,ct_oid,
		ct_fid,ct_date,ct_ts,ct_req) VALUES(?,?,?,?,?,?,current_timestamp,?)',undef,
			$amnt*1,
			$comments,
			$ct_currency,
			$self->{user_id},
			$ct_fid,
			$ct_date,
			$req
		);
	    
	}
	
	$self->header_type('redirect');


	return $self->header_add(-url=>'firm_input.cgi')
}





1;