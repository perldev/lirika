package Oper::Correctings;
use strict;
use base 'CGIBase';

use SiteConfig;
use SiteDB;
use SiteCommon;
use CGI::Carp qw(fatalsToBrowser);
my $proto;
sub get_right
{       
        my $self=shift;
    $proto={
    'correctings'=>1,
    'table'=>"cashier_transactions",  
    'page_title'=>'Правки',
    'template_prefix'=>"firm_in",
    'extra_where'=>" ct_status NOT IN('deleted') AND ct_fid>0",
    'need_confirmation'=>1,
    'id_field'=>'ct_id',
    'sort'=>'ct_date DESC',
    
    'fields'=>[
    
        {'field'=>"ct_id", "title"=>"ID", "no_add_edit"=>1,filter=>'=','filter_invisible'=>'1'}, #first field is ID
    
        {'field'=>"ct_date", "title"=>"Дата поступления",'filter'=>"time","default"=>$now_hash->{sql}
    },
    
    {'field'=>"ct_ts", "no_add_edit"=>1, "add_expr"=>"NOW()", "title"=>"Дата"
    
    },
    #  {'no_view'=>1,'field'=>"ct_aid", category=>'accounts',"title"=>"Карточка",no_add_edit=>1},	
    
        {'field'=>"ct_fid", "title"=>"Фирма", "category"=>"firms", "type"=>"select"
        ,'filter'=>"="
        },
        {'field'=>"ct_amnt", "title"=>"Сумма",'filter'=>"=",},
        {'field'=>"ct_aid", "title"=>"Карточка",'category'=>"accounts",no_view=>1,no_add_edit=>1},
        {'field'=>"ct_currency", "title"=>"Валюта"
        , "type"=>"select"
        , "titles"=>\@currencies
        ,'filter'=>"="
        },
        {
        'field'=>"ct_comment", "title"=>"Назначение", 'default'=>"Ввод безналом",
        'filter'=>'like'
        },
        {'field'=>"ct_oid", "title"=>"Оператор"
        , "no_add_edit"=>1, "category"=>"operators"
        },
        #{'field'=>"ct_tid", "title"=>"Транзакция", "no_add_edit"=>1,},
    
        {'field'=>"ct_status", "title"=>"Статус проведения"
        ,"no_add_edit"=>1, 
        ,"no_view"=>1,
        },
    
    
    
    ],
    };
     return 'correct';
}
sub setup
{
  my $self = shift;
    
  $self->run_modes(
    'AUTOLOAD'   => 'list',
    'list' => 'list',
    'back'=>'back',
    'edit' => 'edit', #correctings
    'del'  => 'del',
    'correctings'=>'correctings',
    're_iden'=>'re_iden'	
  );
}

sub re_iden
{
	my $self=shift;
	my $id=$self->query->param('id');
	my $ct_amnt=$dbh->selectrow_array(q[SELECT ct_amnt FROM cashier_transactions WHERE ct_id=? AND 
	ct_status='created'],undef,$id);
	if($ct_amnt>0)
	{
		$self->header_type('redirect');
		return $self->header_add(-url=>"firm_input2.cgi?do=edit&amp;id=$id");
		
	}else
	{
		$self->header_type('redirect');
		return $self->header_add(-url=>"firm_output.cgi?do=edit&amp;id=$id");
		
	}
	

	


}
sub list
{
   my $self = shift;
   return $self->proto_list($proto);
}
sub edit
{
   my $self = shift;
   return $self->proto_add_edit('edit', $proto);
}
sub correctings
{
   my $self = shift;
  
   return $self->proto_list($proto);
}

sub proto_add_edit_trigger
{

  my $self=shift;
  my $params = shift;    

    


  if($params->{step} eq 'before'){

    my $id=$self->query->param('id');  
    my $fid = $self->query->param('ct_fid');
	
    my $amnt = $self->query->param('ct_amnt');
    $amnt=~s/[,]/\./g;
    $amnt=~s/ \"\'\\//g;
    $self->query->param('ct_amnt',$amnt);
#    $amnt=~s/[ ]//g;
    
    my $cur = $self->query->param('ct_currency');
    $cur=~s/[ \"\'\\]//g;  
    $self->query->param('ct_currency',$cur);
    $cur = lc($cur);   
    my $b_=$dbh->selectrow_hashref(q[SELECT 
	ct_date,
	ct_amnt,
	ct_currency,
	ct_fid,
	f_percent,
	ct_req	 
	FROM cashier_transactions,firms 
	WHERE 
	ct_fid=f_id 
	AND 
	ct_id=? AND ct_status='created'
	],
	undef,
	$id);
  my $old_cur=lc($b_->{ct_currency});

  unless($b_->{ct_amnt})
  {
	return 1;
   
  }
  
  if($b_->{ct_req} eq 'no')
  { 		
	if($b_->{ct_amnt}>0)
	{
	##if the firm with percent of inner transactions	  
	
	$dbh->do(qq[
			UPDATE firms
			SET f_$old_cur=f_$old_cur-? 
			WHERE 
			f_id=? ],undef,
			$b_->{ct_amnt},			
			$b_->{ct_fid}
			);
					
	
	
	}else
	{
		$dbh->do(qq[UPDATE firms 
		SET f_$old_cur=f_$old_cur+? WHERE f_id=?],undef,
		abs($b_->{ct_amnt}),$b_->{ct_fid}
		);
	}
	$amnt=$amnt*1;            
	$cur=~s/[ \"\'\\]//g;
  	my $firm=get_firm_name($fid);
	$cur=lc($cur);
	$dbh->do(qq[UPDATE firms SET f_$cur=f_$cur+? WHERE f_id=?],undef,$amnt,$fid);
	
	$dbh->do(qq[INSERT INTO cashier_transactions SET
	 ct_ts=current_timestamp,
	ct_status='deleted',ct_amnt=?,ct_fid=?,ct_currency=?,ct_date=NOW(),ct_oid2=?,ct_comment=?],undef,
	-1*$b_->{ct_amnt},$b_->{ct_fid},$b_->{ct_currency},
	$self->{user_id},
	"изменение записи номер #$b_->{ct_id}"
	);

	$dbh->do(qq[INSERT INTO cashier_transactions SET
	 ct_ts=current_timestamp,
	ct_status='deleted',ct_amnt=?,ct_fid=?,ct_currency=?,ct_date=?,ct_oid2=?,ct_comment=?],undef,
	 $b_->{ct_amnt},$b_->{ct_fid},$b_->{ct_currency},$b_->{ct_date},
	$self->{user_id},
	"изменение записи номер #$b_->{ct_id}"
	);	
  
  }
  

   foreach my $row( @{$params->{proto}->{fields}} ){
     if($row->{field} eq 'ct_oid'){
       $row->{expr} = $self->{user_id}
     }
   }

   return 1;   

  }elsif($params->{step} eq 'operation'){

    $dbh->do($params->{sql});
  }

}


sub index
{
   my $self=shift;
   my $tmpl=$self->load_tmpl('correctings.html');

   my $output = "";
   $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
   return $output;
}

1;
