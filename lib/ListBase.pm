package ListBase;
#use Spreadsheet::WriteExcel;
use strict;
use SiteConfig;
use SiteDB;
use SiteCommon;
sub proto_begin_documents_list{
   my $self=shift;
   my $proto=shift;
   my $params=shift;

#   $SIG{__DIE__}=\&proto_die_catcher;

   my $p={};
   $p->{table} = $proto->{table};
   $p->{back_url} = $proto->{back_url};
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


      
     }	
     $index++;
   }
	
   $self->{tpl_vars}->{page_title}=$proto->{page_title};

   return $p;
}

#virual
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


################################################
sub get_documents_list
{
	my $self=shift;
   	my $proto=shift;

   	#die Dumper $proto;
   	my $proc_functions=shift;
 	
	my $filter_where = "";
	my $filter_having = "";
   	my $filter_params = {};

   	if($self->query->param('action') eq 'filter'){
     		map {$filter_params->{$_}=$self->query->param($_)} $self->query->param();
#die Dumper $filter_params;
	}
	my $p = $self->proto_begin_documents_list($proto, {method=>"list"});
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
		if($row->{field} eq "sum_comis")
	   {
 	    	$filter_where .= " AND ((`documents_requests`.`dr_comis` * (`documents_requests`.`dr_amnt` / 100)) > $left AND (`documents_requests`.`dr_comis` * (`documents_requests`.`dr_amnt` / 100)) < $right)";
	   }
	   else
	   {
       		$filter_where .= " AND ( $row->{field}>$left AND $row->{field}<$right )";
       }

}else{
      
       $filter_val=~s/[,]/\./g;
	   $filter_val=~s/[ \"\'\\]//g; 
       $filter_val = 0-$filter_val if($row->{op} eq '-');
       if($row->{field} eq "okpo")
       {
	   		$filter_where .= " AND `documents_requests`.`dr_ofid_from` = ".sql_val($filter_val);
	   }
	   elsif($row->{field} eq "is_payed")
	   {
	   		$filter_having .= " HAVING $row->{field} = ".sql_val($filter_val);

	   }
	   else
	   {
	   		$filter_where .= " AND $row->{field} = ".sql_val($filter_val);
       }
       
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
   
   $extra_where = " AND ($proto->{extra_where}) " if($proto->{extra_where});

   my @rows=();
   my $sql;
		my $sort = "";		
		if($proto->{'sort'})
		{
			$sort = "ORDER BY $proto->{'sort'}";
	    }
	     
$sql = qq[SELECT `documents_requests`.`dr_id` AS `dr_id`,dr_comment, concat(`documents_requests`.`dr_fid`,_utf8'_',`documents_requests`.`dr_aid`,_utf8'_',`documents_requests`.`dr_currency`,_utf8'_',`documents_requests`.`dr_ofid_from`) AS `key_field`,`documents_requests`.`dr_fid` AS `dr_fid`,`documents_requests`.`dr_ofid_from` AS `okpo`,`documents_requests`.`dr_ofid_from` AS `dr_ofid_from`,`documents_requests`.`dr_aid` AS `dr_aid`,`documents_requests`.`dr_amnt` AS `dr_amnt`,(`documents_requests`.`dr_comis` * (`documents_requests`.`dr_amnt` / 100)) AS `sum_comis`,`documents_requests`.`dr_comis` AS `percent_comis`,`documents_requests`.`dr_currency` AS `dr_currency`,`documents_requests`.`dr_status` AS `dr_status`,`documents_requests`.`dr_ts` AS `dr_ts`,`documents_requests`.`dr_date` AS `dr_date`,`accounts`.`a_id` AS `a_incom_id`,sum(`documents_payments`.`dp_amnt`) AS `payed_comis`,if(`documents_requests`.`dr_comis`,(`documents_requests`.`dr_amnt` * (sum(`documents_payments`.`dp_amnt`) / (`documents_requests`.`dr_comis` * (`documents_requests`.`dr_amnt` / 100)))),0) AS `payed_income`,if(sum(`documents_payments`.`dp_amnt`),(((`documents_requests`.`dr_comis` * (`documents_requests`.`dr_amnt` / 100)) / sum(`documents_payments`.`dp_amnt`)) <= 1.01),0) AS `is_payed`,((`documents_requests`.`dr_comis` * (`documents_requests`.`dr_amnt` / 100)) / sum(`documents_payments`.`dp_amnt`)) AS `debug_is_payed` from `documents_requests` ,`accounts`,`documents_payments` where `documents_payments`.`dp_drid` = `documents_requests`.`dr_id` and    1   and $del_sql $extra_where $filter_where  group by `documents_requests`.`dr_id`  $filter_having $sort];

my $sth =$dbh->prepare($sql);
$sth->execute();
return $self->documents_list_data($proto,$sth,$format,$p,$proc_functions);
	
}

sub documents_list_data
{
my $self = shift;
my $proto = shift;
my $sth = shift;
my $format =shift;
my $p = shift;
my $proc_functions =shift;

my @rows;
my $r;

my %result_params;
my $prev_row;
my $tmpl;
my $output;
$result_params{hash}={};

my $linkrow;
my $i_linkrow =0;
foreach my $field(@{$proto->{formats}})
{
	foreach my $row(@{$proto->{fields}})
	{
		if($row->{field} eq $field)
		{
			$linkrow->[$i_linkrow]=$row;
			$i_linkrow++;
		}
	}
}

while( $r = $sth->fetchrow_hashref)
{
    foreach my $row( @{$proto->{fields}} )
	{
		my $val = $r->{ $row->{"field"} };
		$r->{ "orig__".$row->{"field"} } = $val unless($r->{ "orig__".$row->{"field"} } );
	}
 	foreach my $row(@{$linkrow})
	{
		$r->{$row->{"field"}} = $row->{titles_hash}->{$r->{$row->{"field"}}};
	}
	
	$r->{id} = $r->{ $p->{"id_field"} };


	 

#	die(Dumper $r);
	


	
	if($proc_functions->{fetch_row})
	{
			$proc_functions->{fetch_row}->(\@rows,$r,$prev_row,$proto);
	}
	else
	{	
			push @rows, $r;
	}
	 
	map { $result_params{hash}->{$_}->{$r->{"$_"}}=$r if(defined $r->{"$_"}) } keys %{ $result_params{hash} };
	map { $result_params{hash}->{$_}->{$r->{"orig__$_"}}=$r if(defined $r->{"orig__$_"}) } keys %{ $result_params{hash} };
	#format_datetime_month_year(\$r->{dr_date});
	if($proto->{output_formats})
	{
		$self->formating_fields_lite($r,$format,$proto->{formating},@{$proto->{output_formats}}) unless($proto->{no_formating});
	}
	else
	{
		$self->formating_fields($r,$format,$proto->{formating}) unless($proto->{no_formating});
	}

}
   	$sth->finish();
	$proc_functions->{after_list}->(\@rows,$r,$prev_row,$proto) if($proc_functions->{after_list});		
	
	$result_params{rows}=\@rows;
		
  	
  	$result_params{fields}=$proto->{fields};
  	
	$result_params{proto}=$proto;
	my $time=$TIMER->stop;
   	#die($time);
	$result_params{timer}=$time;
    my_log($self,$time);
	return \%result_params;
}


sub proto_list_fast
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

my $sth =$dbh->prepare($sql);

$sth->execute();
$self->proto_list_data($proto,$sth,$format,$p,$proc_functions,$index,$prev_row);
$index++;
 }
my $output ="";
$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
return $output;
}
########------------------
sub proto_list_data
{
	my $self = shift;
	my $proto = shift;
	my $sth = shift;;
	my $format =shift;
	my $p = shift;
	my $proc_functions =shift;
	my $index =shift;
	#my $tmpl = shift;
	my $prev_row = shift;
	#post formating
	my $linkrow;
	my @rows;
	my $i_linkrow =0;
	foreach my $field(@{$proto->{formats}})
	{
		foreach my $row(@{$proto->{fields}})
		{
			if($row->{field} eq $field)
			{
				$linkrow->[$i_linkrow]=$row;
				$i_linkrow++;
			}
		}
	}
	$prev_row=undef;##for first row the prev row will be undef
	my $r;
	while( $r = $sth->fetchrow_hashref)
	{
		foreach my $row( @{$proto->{fields}} )
		{

			my $val = $r->{ $row->{"field"} };
			$r->{ "orig__".$row->{"field"} } = $val unless($r->{ "orig__".$row->{"field"} } );
		}
	 	foreach my $row(@{$linkrow})
		{
			my $val = $r->{ $row->{"field"} };
			if($row->{type} eq 'select'){
				$val = $row->{"titles_hash"}->{ $val };
			}
			elsif($row->{type} eq 'set'){
				my $hash = $self->set2hash($val);
				$val="";
				foreach my $option( @{$row->{titles}} ){
				$self->add2list(\$val, $option->{title}) 
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
		{
			push @rows, $r;
		}
		$prev_row=$r->{ct_date};
		if($proto->{output_formats})
		{
			$self->formating_fields_lite($r,$format,$proto->{formating},@{$proto->{output_formats}}) unless($proto->{no_formating});
		}
		else
		{
			$self->formating_fields($r,$format,$proto->{formating}) unless($proto->{no_formating});
		}

}
$sth->finish();
#die Dumper \@rows;
#if we have 
$proc_functions->{after_list}->(\@rows,$r,$prev_row,$proto) if($proc_functions->{after_list});		
my $key="rows";
$key .= $index if($index>1);
$self->{tpl_vars}->{$key} = \@rows;
$index++;
my $time=$TIMER->stop;
$self->{tpl_vars}->{timer}=$time;
my_log($self,$time);
$self->{tpl_vars}->{fields}=$proto->{fields};
$self->{tpl_vars}->{proto_params}=$proto;
#   $self->{tpl_vars}->{timer}=$TIMER->stop;
}
sub proto_list_short
{
    
   my $self=shift;
   my $proto=shift;
   my $proc_functions=shift;##using for processing rows on fly
   my $prev_row;##for processing rows ,will save the pre row

   my $p = $self->proto_begin($proto, {method=>"list"});
   my $tmpl=$self->load_tmpl($p->{template_prefix}.'_list.html');
   my $filter_where = "";
   my $filter_or="";
   my @or_objec=();
   my $filter_params = {};

   if($self->query->param('action') eq 'filter'){
     map {$filter_params->{$_}=$self->query->param($_)} $self->query->param();
    
}

# titles to hash & filter
    
   my $i=0; 
   my @aliases;
   foreach my $row( @{$proto->{fields}} ){
     
    push @aliases,"$row->{field} as $row->{alias}" if($row->{alias});
        
    if($row->{type} eq 'select'){
      my %select=();
      foreach my $option( @{$row->{titles}} ){
       $select{ $option->{value} } = $option->{title};
        }
        $row->{ "titles_hash" } = \%select;     
}

    

     if(defined $row->{filter}) {
   
     my $filter_val =$filter_params->{ $row->{field} };
     my $filter_val_empty = length($filter_val)==0;

     $filter_val=$filter_params->{ $row->{alias} } if($filter_val_empty&&defined $row->{alias});
     $filter_val_empty = length($filter_val)==0;
    
    if($row->{filter} eq 'time' && $filter_val_empty){
             $filter_val = "yesterday";
             $filter_val_empty = 0;      
    }  
        

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

                unless($row->{'or_obj'}){
                    $filter_where .= " AND ( lcase($row->{field}) like lcase(".sql_val('%'.$trans.'%').") OR  lcase($row->{field}) like lcase(".sql_val('%'.$filter_val.'%').") )";
                }else{
                    push @or_objec,"( lcase($row->{field}) like lcase(".sql_val('%'.$trans.'%').") OR  lcase($row->{field}) like lcase(".sql_val('%'.$filter_val.'%').") )";
                    
                }


                
                }else{
         
               
            
                $filter_val=~s/,/\./;
                $filter_val=~s/[ ]//g;     
                $filter_val=0-$filter_val if($row->{op} eq '-');
                $filter_val=sql_val($filter_val);
                unless($row->{'or_obj'}){

                    $filter_where .= " AND $row->{field} =$filter_val";
                }else{
                    
                    push @or_objec," $row->{field} =$filter_val ";
                }


        
        }
       

    }
   } # if(defined $row->{filter}){
    $i++;
}
    
      my @extra_wheres = ("$proto->{extra_where}");
      
      push @extra_wheres, $proto->{extra_where2} if($proto->{extra_where2});
      if(@or_objec){
          $filter_or=" AND (".join(' OR ',@or_objec)." )";
      }

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
  my $limit=" LIMIT 0,12000";
  if ($proto->{limit}){
    $proto->{rows_per_page}||=30;
    $limit="LIMIT ".$proto->{page}*($proto->{rows_per_page}).",".$proto->{rows_per_page};
    
}
    
        

my $group=$proto->{group};

my $alias='';##generate alias list of fields
if(@aliases){
     $alias=",".join(',',@aliases);##generate alias list of fields
}
if($proto->{'sort'})    
{
     
    $sql = qq[SELECT SQL_CALC_FOUND_ROWS $p->{table}.* $alias FROM $p->{table} 
            WHERE $del_sql $extra_where $filter_where $filter_or $group
            ORDER BY $proto->{'sort'} $limit];
    
}elsif($proto->{id_field})
{   
        
    $sql = qq[SELECT SQL_CALC_FOUND_ROWS $p->{table}.* $alias FROM $p->{table} 
        WHERE $del_sql $extra_where $filter_where $filter_or  $group
        ORDER BY $proto->{id_field} DESC $limit
    ];   
}else
{
                
    $sql = qq[SELECT SQL_CALC_FOUND_ROWS $p->{table}.* $alias FROM $p->{table} 
          WHERE $del_sql $extra_where $filter_where $filter_or $group $limit
    ];   
}
  
####but the old style of work has been saved    
    $TIMER->start('fizzbin'); 
    my $sth =$dbh->prepare($sql);

   $sth->execute();

#post formating
my $format=$dbh->selectall_hashref(qq[DESC $p->{table} ],'Field');

$prev_row=undef;##for first row the prev row will be undef
my $r;

my %process_hash;

$self->generate_procs(\%process_hash,$proto,$format);
 
#use Data::Dumper;
#die Dumper \%process_hash;
while( $r = $sth->fetchrow_hashref)
{
    $r->{id} = $r->{ $p->{"id_field"} };

    if($proc_functions->{fetch_row})
    {
            $proc_functions->{fetch_row}->(\@rows,$r,$prev_row,$proto);
    }  else
    {           
        push @rows, $r;
    }
    $prev_row=$r->{ct_date};

    $prev_row=$r->{ct_date};
    #die(Dumper($r));
    map {  $process_hash{$_->{field}}->($r) } @{$proto->{fields}};
#   die(Dumper($r));
    #   die(Dumper(@{$proto->{fields}}));
}

    $sth->finish();
    #die Dumper \@rows;
    #if we have 
    $proc_functions->{after_list}->(\@rows,$r,$prev_row,$proto) if($proc_functions->{after_list});      
        
   

    my $key="rows";
    $key .= $index if($index>1);
        
    $self->{tpl_vars}->{$key} = \@rows;
    
    $index++;
}
  


  
   $self->{tpl_vars}->{fields}=$proto->{fields};
 
   $self->{tpl_vars}->{proto_params}=$proto;
    
   my $output = "";
   
   $self->{tpl_vars}->{timer}=$TIMER->stop;

   $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
   return $output;
}
sub generate_procs
{
    my ($self,$hash,$proto,$format)=@_;
   

    foreach(@{$proto->{fields}})
    {
            my $ref;
            if($format->{$_->{field}}->{'Type'} eq 'date'&&$_->{formating} eq q{month_year})
            {
            #     format_datetime_month_year(\$r->{$_});
                my $key;
                if($_->{alias}){
                    $key=$_->{alias};
                    $_->{field}=$_->{alias};
                
                }else{
                    $key=$_->{field};
                
                }            

                $ref=sub{
                    my $r=shift;

                    my $name=$key;
                    my $val=$r->{$name};
                    $r->{ "orig__".$name } = $val;
                    
                    # $val = 0-$val if($key->{op} eq '-');
                    
                    $r->{$name}=format_datetime_month_year($val);
                    
                    #$r->{$name}=format_datetime($val);
                    $r->{id} = $r->{ $_->{"id_field"} };
                    return  $r->{$name};
                };
                $hash->{$_->{field}}=$ref;
                next;        

                

            }
            if($_->{field}=~/rate/)
            {
                my $key;
                 if($_->{alias}){
                    $key=$_->{alias};
                    $_->{field}=$_->{alias};
                
                }else{
                    $key=$_->{field};
                
                }            

                $ref=sub{
                        my $r=shift;
                        my $name=$key;
                        my $val=$r->{$name};
                        return  unless($val);
                    
                        $r->{currency1}=$r->{orig__r_currency1}    unless($r->{currency1});
                        $r->{currency2}=$r->{orig__r_currency2}    unless($r->{currency2});
                        my $t;
                        ($t,$val)=$self->calculate_exchange(0,$val,$r->{currency1},$r->{currency2});
                         $r->{$name}=POSIX::ceil($val*10000)/10000;
    
                        return  $r->{$name};
                    };
                    $hash->{$_->{field}}=$ref;
                    next; 



             
                
            }
            elsif($format->{$_->{field}}->{'Type'}=~/float|double/)
            {
                    
    
                   # $r->{'compare_'.$_}=$r->{$_};
              #      $r->{compare}=$r->{$_};
               #     $r->{$_}=andrey_float_format($r->{$_});
                     my $key;
    
                     if($_->{alias}){
                        $key=$_->{alias};
                        $_->{field}=$_->{alias};
                    
                        }else{
                            $key=$_->{field};
                        
                        }            

                     $ref=sub{
                        my $r=shift;
                    
                        my $name=$key;
                        my $val=$r->{$name};
                        $r->{'compare_'.$name}=$val;
            
                       $r->{compare}=$val;
                       $r->{ "orig__".$name } = $val;
                       $r->{$name}=myformat_float($val);
            
                       return  $r->{$name};
                    };
                    $hash->{$_->{field}}=$ref;
                    next;        
                
    
                    
                
            }
            elsif($format->{$_->{field}}->{'Type'}=~/datetime|timestamp/)
            {
                  my $key;
            
#                 $r->{$_}=format_datetime($r->{$_});
                   if($_->{alias}){
                    $key=$_->{alias};
                    $_->{field}=$_->{alias};
                    
                    }else{
                        $key=$_->{field};
                    
                    }            

                    $ref=sub{
                        my $r=shift;
                    
                        my $name=$key;
                        my $val=$r->{$name};
                        $r->{ "orig__".$name } = $val;
                        $r->{$name}=format_datetime($val);
                        return  $r->{$name};
                    };
                    $hash->{$_->{field}}=$ref;
                    next;        


            }elsif($format->{$_->{field}}->{'Type'}=~/date/)
            {
                my $key;

#                 $r->{$_}=format_date($r->{$_});
                if($_->{alias}){
                    $key=$_->{alias};
                    $_->{field}=$_->{alias};
                
                }else{
                    $key=$_->{field};
                
                }
            
                $ref=sub{
                    my $r=shift;
                  
                    my $name=$key;
                    my $val=$r->{$name};
                    $r->{ "orig__".$name } = $val;
                  
                   # $val = 0-$val if($key->{op} eq '-');
                    $r->{$name}=format_date($val);
                   # $r->{id} = $r->{ $_->{"id_field"} };
                    return  $r->{$name};
                };
                $hash->{$_->{field}}=$ref;

                next;        


                
            }elsif($_->{type} eq 'select'  )
            {   
               
                my $key;
                if($_->{alias}){
                    $key=$_->{alias};
                    $_->{field}=$_->{alias};
                
                }else{
                    $key=$_->{field};
                
                }
            
            
             
                        
                       my $h={};
                       foreach my $rrr (@{ $_->{titles} }){
                            $h->{ $rrr->{'value'} }->{value}= $rrr->{'value'};
                            $h->{ $rrr->{'value'} }->{title}=$rrr->{'title'};
                            $h->{ $rrr->{'value'} }->{exp_name}=$rrr->{'title'};

                        
                       }
                       
                       $_->{titles_hash}=$h;

                      
                
                $ref=sub{
                    my $r=shift;
                    my %key=%{$_};
                    my $name=$key{field};
                    my $val=$r->{$name};
                  
                    $r->{ "orig__".$name } = $val;
                    #$val = 0-$val if($key->{op} eq '-');
                    $r->{$name}=$key{"titles_hash"}->{ $val }->{exp_name}; 
                    $r->{'short_'.$name}=$key{"titles_hash"}->{ $val }->{title}; 
                 
                 
                    return  $r->{$name};
                };
                $hash->{$_->{field}}=$ref;
                
                $hash->{$key}=$ref;
                
                
                    

                next;

            }elsif($_->{category}&&$_->{category} ne 'date')
            {
#                $_->{type}='select';
                 my $key;
               
                 if($_->{titles}){
                        
                       my $h={};
                      foreach my $rrr (@{ $_->{titles} }){
                            $h->{ $rrr->{'value'} }->{value}= $rrr->{'value'};
                            $h->{ $rrr->{'value'} }->{title}=$rrr->{'title'};                        
                       }
                       
                       $_->{titles_hash}=$h;

                }else{
                     
                      $_->{titles_hash}=get_category_hash($_->{category});
                }
                 $ref=sub{
                    my $r=shift;
                    my %key=%{$_};
                    my $name=$key{field};
                    my $val=$r->{$name};
                    $r->{ "orig__".$name } = $val;
                    #$val = 0-$val if($key->{op} eq '-');
                    $r->{$name}=$key{"titles_hash"}->{ $val }->{exp_name}; 
                    $r->{'short_'.$name}=$key{"titles_hash"}->{ $val }->{title}; 
                  #  $r->{id} = $r->{ $key{"id_field"} };
                  
                };
                $hash->{$_->{field}}=$ref;

                next;
                
            }else
            {
               my $key;
                
             #   die "hh" if($_->{field} eq 'ct_status');
                $ref=sub{
                    my $r=shift;
                    #die "here3";
                    return ;
                   # my $val=$r->{$name};
                   # $r->{ "orig__".$name } = $val;
                    #$val = 0-$val if($key->{op} eq '-');
                  
                };
                
                $hash->{$_->{field}}=$ref;
                next;

            }
         
            
    } 
   

}
sub get_category_hash{
  my $category = shift;
  my %select;  

#  my $title = "";
 # $title="(id#$id)" if($id);
    my %hash=(
        accounts=>'a_id',
        operators=>'o_id',
        firms=>'f_id',
        firm_services=>'fs_id',
        out_firms=>'of_id',
        'out_firms_okpo'=>'of_id'
    );
      my %hash_names=(
        accounts=>'a_name',
        operators=>'o_login',
        firms=>'f_name',
        firm_services=>'fs_name',
        out_firms=>'of_name',
        out_firms_okpo=>'of_okpo',
       );
        return  unless($hash{$category});
    return $dbh->selectall_hashref("SELECT $hash{$category} as id,
    $hash_names{$category} as title,
    CONCAT($hash_names{$category},'(#',$hash{$category},')') as 
    exp_name
    FROM $category ",'id');
 
}



sub formating_fields_lite
{
	
	my ($self,$r,$format,$formating,@fields)=@_;
	my @arr;
	my $t;
   
	foreach(@fields)
	{
        
		if($_=~/rate/)
		{
			if($r->{$_}!=0)
			{
				
				$r->{currency1}=$r->{orig__r_currency1}    unless($r->{currency1});
				 $r->{currency2}=$r->{orig__r_currency2}    unless($r->{currency2});         
		
				($t,$r->{$_})=$self->calculate_exchange(0,$r->{$_},$r->{currency1},$r->{currency2});
				$r->{$_}=POSIX::ceil($r->{$_}*10000)/10000;
		    
			}    
			
		}
		elsif($format->{$_}->{'Type'}=~/float|double/)
		{
				

 				$r->{'compare_'.$_}=$r->{$_};
 				$r->{compare}=$r->{$_};
				$r->{'orig__'.$_}=$r->{$_};
				$r->{$_}=myformat_float($r->{$_});
				
				
			
		}elsif($formating->{$_} eq q{month_year})
        {
        
         
            format_datetime_month_year(\$r->{$_});
       

        }
        elsif($format->{$_}->{'Type'}=~/datetime|timestamp/&&$r->{$_})
		{
            
				$r->{$_}=format_datetime($r->{$_});

		}elsif($format->{$_}->{'Type'}=~/date/&&$r->{$_})
		{
              
				$r->{$_}=format_date($r->{$_});
		
				
		}
		

   }
}
sub formating_fields
{
    my ($self,$r,$format,$formating)=@_;
    my @arr;
    my $t;
   
    foreach(keys %$r)
    {
        
        if($_=~/rate/)
        {
            if($r->{$_}!=0)
            {
                
                $r->{currency1}=$r->{orig__r_currency1}    unless($r->{currency1});
                 $r->{currency2}=$r->{orig__r_currency2}    unless($r->{currency2});         
        
                ($t,$r->{$_})=$self->calculate_exchange(0,$r->{$_},$r->{currency1},$r->{currency2});
                $r->{$_}=POSIX::ceil($r->{$_}*10000)/10000;
            
            }    
            
        }
        elsif($format->{$_}->{'Type'}=~/float|double/)
        {
                

                $r->{'compare_'.$_}=$r->{$_};
                $r->{compare}=$r->{$_};
                $r->{'orig__'.$_}=$r->{$_};
                $r->{$_}=myformat_float($r->{$_});
                
                
            
        }elsif($formating->{$_} eq q{month_year})
        {
        
         
               format_datetime_month_year(\$r->{$_});
       

        }
        elsif($format->{$_}->{'Type'}=~/datetime|timestamp/&&$r->{$_})
        {
            
                $r->{$_}=format_datetime($r->{$_});

        }elsif($format->{$_}->{'Type'}=~/date/&&$r->{$_})
        {
              
                $r->{$_}=format_date($r->{$_});
        
                
        }
        

}

    


}


1;


