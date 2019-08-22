package Oper::Rates;

use strict;

use base 'CGIBase';
use CGI::Carp qw(fatalsToBrowser);
use Data::Dumper;
use SiteConfig;
use SiteDB;
use SiteCommon;
my $proto;
sub get_right
{       
        my $self=shift;

 

        $proto={
        'table'=>"rates",  
        
        'need_confirmation'=>1,
        'page_title'=>'Добавление курса',
        'fields'=>[
            {'field'=>"r_id", "title"=>"ID", "no_add_edit"=>1}, #first field is ID
            
            {'field'=>"r_ts", "no_add_edit"=>1, "add_expr"=>"NOW()", "title"=>"Дата", 'filter'=>"time"},
            
            {'field'=>"r_currency1", "title"=>"Сколько нужно заплатить за 1 ед. "
            , "type"=>"select"
            , "titles"=>\@currencies_withbtc
            , 'filter'=>"="
            },
        
            {'field'=>"r_currency2", "title"=>"Единиц данной валюты "
            , "type"=>"select"
            , "titles"=>\@currencies_withbtc
            , 'filter'=>"="
            },
        
            {'field'=>"r_rate", "title"=>"Курс", 'default'=>"1.00", "positive"=>1},
        
            {'field'=>"r_type", "title"=>"Тип"
            , "type"=>"select"
            , "titles"=>[
                {'value'=>"cash", 'title'=>"наличный"},
                {'value'=>"cashless", 'title'=>"безналичный"},
            ]
            , 'filter'=>"="
            },
        
            {'field'=>"r_oid", "title"=>"Оператор"
            , "no_add_edit"=>1, "category"=>"operators"
            },
        
        
        ],
        };
       return 'rates';
}
sub setup
{
  my $self = shift;
  $self->start_mode('main'); 
  $self->run_modes(
    'AUTOLOAD'   => 'main',
    'main' => 'main',
    'list' => 'list',
    'add'  => 'add',
    'edit' => 'edit',
    'del'  => 'del',
  );
}



sub main{
        my $self = shift;

        my $page=$self->query->param('page');
        my $how=$self->query->param('how');
        
        my @cash_rates = ();
        my @cashless_rates = ();
        my $BASE_CURRENCY = "UAH";
        
        foreach my $cur1_row(@currencies_withbtc){
                my $cur1 = $cur1_row->{'value'};
            
                my ($buy, $sell) = ('', '');
                
                my $r = $dbh->selectrow_hashref(
                    "SELECT * FROM rates WHERE r_currency1='$BASE_CURRENCY' AND r_currency2=? AND r_type='cash' ORDER BY r_id DESC LIMIT 1"
                    , undef, $cur1
                );
                $buy = $r->{r_rate} if($r);
                $r = $dbh->selectrow_hashref(
                    "SELECT * FROM rates WHERE r_currency1=? AND r_currency2='$BASE_CURRENCY' AND r_type='cash' ORDER BY r_id DESC LIMIT 1"
                    , undef, $cur1
                );
                
                $sell = $r->{r_rate} if($r);
                push @cash_rates, {cur=>$cur1, buy=>to_prec4(pow($buy, $RATE_FORMS{$BASE_CURRENCY}->{$cur1})), sell=>to_prec4(pow($sell, $RATE_FORMS{$cur1}->{$BASE_CURRENCY})) };
                
        }
        
        foreach my $cur1_row(@currencies_withbtc){
                my $cur1 = $cur1_row->{'value'};
            
                my ($buy, $sell) = ('', '');
                
                my $r = $dbh->selectrow_hashref(
                    "SELECT * FROM rates WHERE r_currency1='$BASE_CURRENCY' AND r_currency2=? AND r_type='cashless' ORDER BY r_id DESC LIMIT 1"
                    , undef, $cur1
                );
                $buy = $r->{r_rate} if($r);
                $r = $dbh->selectrow_hashref(
                    "SELECT * FROM rates WHERE r_currency1=? AND r_currency2='$BASE_CURRENCY' AND r_type='cashless' ORDER BY r_id DESC LIMIT 1"
                    , undef, $cur1
                );
                
                $sell = $r->{r_rate} if($r);
                push @cashless_rates, {cur=>$cur1, buy=>to_prec4(pow($buy, $RATE_FORMS{$BASE_CURRENCY}->{$cur1})), sell=>to_prec4(pow($sell, $RATE_FORMS{$cur1}->{$BASE_CURRENCY})) };
                
        }
        
	$page=s/["' ]//g;
	$page=0 unless($page);
	my $r = $dbh->selectall_arrayref(
              "SELECT SQL_CALC_FOUND_ROWS hr_id,hr_date,hr_rate_mb,hr_rate_street,hr_rate_cross,hr_domi,hr_rate_cross_street 
        FROM header_rates  ORDER BY hr_date DESC LIMIT $page,500");
	my @reports_rates;
	foreach(@$r)
	{
		$_->[1]=format_date($_->[1]);
		push @reports_rates,{hr_id=>$_->[0],hr_date=>$_->[1],hr_rate_mb=>$_->[2],hr_rate_street=>$_->[3],hr_rate_cross=>$_->[4],hr_domi=>$_->[5],hr_rate_cross_street=>$_->[6]};
	}
	
	my $counts_pages=$dbh->selectrow_array('SELECT found_rows()');
	my $paging=paging(
                        {	url=>'rates.cgi?',
                        	count_pages=>$counts_pages,
                        	how=>$how,
                        	page_name=>'page',
                        	page=>$page
			}
       );
	


   my $tmpl=$self->load_tmpl('rates.html');
  $self->{tpl_vars}->{pages}=$paging->{pages};	
   $self->{tpl_vars}->{cash_rates} = \@cash_rates;
   $self->{tpl_vars}->{cashless_rates} = \@cashless_rates;
   $self->{tpl_vars}->{reports_rates}=\@reports_rates;

   my $output = "";
   $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
   return $output;
}


sub list
{
   my $self = shift;
   return $self->proto_list($proto);
}


sub add
{
   my $self = shift;
   my $head=$self->query->param('header_rates');
    if($head)
    {
                
                my $proto1={
                        'table'=>"header_rates",  
                        'need_confirmation'=>1,
                        'template_prefix'=>"reports_rate",

                        'page_title'=>'Добавление заглавных курсов',
                        'fields'=>[
                                {'field'=>"header_rates",'system'=>1,no_view=>1,'value'=>'1','no_base'=>'1'},
                                
                                {'field'=>"hr_id", "title"=>"ID", "no_add_edit"=>1}, #first field is ID
                                {'field'=>"hr_date", "title"=>"Дата",'filter'=>"time",'category'=>"date",},
                                {field=>'hr_domi',title=>'Мб покупка'},
                                {'field'=>"hr_rate_mb", "title"=>"МБ" },
                                {'field'=>"hr_rate_street","title"=>"Улица", },
                                {'field'=>"hr_rate_cross","title"=>"EUR/USD", },
                {'field'=>"hr_rate_cross_street","title"=>"EUR/USD(улица)", },
                        ],
                        };
                
                return $self->proto_add_edit('add', $proto1);
        }else{
            return $self->proto_add_edit('add', $proto);
        }
}

sub edit
{
   	my $self = shift;
	my $head=$self->query->param('hr_id');
	if($head)
	{
			my $proto1={
			'table'=>"header_rates",  
  			'template_prefix'=>"reports_rate",
                         'need_confirmation'=>1,
			'page_title'=>'Добавление заглавных курсов ',
			'fields'=>[
			{'field'=>"hr_id", "title"=>"ID", "no_add_edit"=>1}, #first field is ID
 			{'field'=>"hr_date",no_view=>1, "title"=>"Дата",'filter'=>"time",no_add_edit=>1},
            {field=>'hr_domi',title=>'Мб покупка'},
			{'field'=>"hr_rate_mb", "title"=>"МБ", },
			{'field'=>"hr_rate_street","title"=>"Улица", },
			{'field'=>"hr_rate_cross","title"=>"EUR/USD", },
             {'field'=>"hr_rate_cross_street","title"=>"EUR/USD(улица)", },

			],
			};
   		
		return $self->proto_add_edit('edit', $proto1);

	
	}

   return $self->proto_add_edit('edit', $proto);
}

sub del
{
   my $self = shift;
  return $self->proto_action('del', $proto);
}


sub proto_add_edit_trigger{
  my $self=shift;
  my $params = shift;    
  	

  if($params->{step} eq 'before'){
   foreach my $row( @{$params->{proto}->{fields}} ){
     if($row->{field} eq 'r_oid'){
       $row->{expr} = $self->{user_id}
     }elsif($row->{field} eq 'r_rate')
	{
		my ($currency1,$currency2,$rate)=($self->query->param('r_currency1'),$self->query->param('r_currency2'),$self->query->param('r_rate'));
		
		$row->{expr} = $rate**$RATE_FORMS{$currency1}->{$currency2};
                die $row->{expr};
		$self->query->param('r_rate',$row->{expr});
	}
   }

	
	
	
   	return 1;

  }elsif($params->{step} eq 'operation'){
	
	    if($params->{p}->{id_field} eq 'rr'&&$params->{method} eq 'add')
	    {
			##if there is a rate  for this date,then update that one
			##there is't any checkings because of it must be done before
			$params->{p}->{my_id}=$dbh->selectrow_array(
				q[
				SELECT rr_id 
				FROM 
				reports_rate WHERE DATE(rr_date)=DATE(?)
				],
			undef,$self->query->param('rr_date'));
			
			if($params->{p}->{my_id})
			{
				##there is't any checkings because of it must be done before
				my $rate=$self->query->param('rr_rate');
				$params->{sql}=qq[UPDATE reports_rate SET rr_rate=$rate WHERE rr_id=].$params->{p}->{my_id};
			}
                        
			$dbh->do($params->{sql});

	    }	
	    else
	    {
	        
    		$dbh->do($params->{sql});
		

	    }	
  
	}
}


1;
