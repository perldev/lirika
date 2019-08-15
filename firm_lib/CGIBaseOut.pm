package CGIBaseOut;
#use Spreadsheet::WriteExcel;
use strict;
use Encode qw/from_to encode decode/;
use base qw[CGI::Application Exporter];
use Template;
use POSIX;
use lib qq(/usr/lib/perl/5.8/auto/);
use Storable qw( &freeze &thaw );
use SiteConfig;
use SiteDB;
use SiteCommon;
use Rights;
our @EXPORT = qw(

add_trans
search_amnt_confirm

);



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



sub load_tmpl
{
   my ($self,$file)=@_;
        $self->{tpl_file}=$file;
        $self->{tpl_vars}->{user_id}=$self->{user_id};
	    
        
     
   
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

	$self->{tpl_vars}->{operators_notes}=\@notes;
	
 	$self->{tpl_vars}->{chat}=$self->{session_data}->{chat} eq 'yes';
        
#map{ $self->{tpl_vars}->{$_}=1 } keys %$rights;
        $self->{tpl_vars}->{rights}->{current}=$self->get_right();
	
	my $template = Template->new(
	{
        	INCLUDE_PATH => $TMPL_DIR,
                INTERPOLATE  => 1,               # expand "$var" in plain text
                POST_CHOMP   => 1,               # cleanup whitespace 
                EVAL_PERL    => 1,
		CACHE_SIZE => 256,
		COMPILE_EXT => '.ttc',  
		COMPILE_DIR=>$COMPILE_DIR    
	}
        );



   return $template;
}

sub cgiapp_init {
    my $self = shift;

#put GET params to POST params, as in PHP
        my %url_params = map {$_=>$self->query->url_param($_)} $self->query->url_param();
        my %params = map {$_=>$self->query->param($_)} $self->query->param();
        foreach my $key (keys %url_params)
	    {
                $self->query->param($key, $url_params{$key}) unless(defined $params{$key});
	    }


    $self->{tpl_vars}={};
    
    
    map { $_->{name}=$_->{title} } @currencies;
    $self->{tpl_vars}->{currencies}=\@currencies;
    $self->{tpl_vars}->{time_filter_rows} = \@time_filter_rows;


   
    my $firms=get_firms();
    $self->{tpl_vars}->{my_firms}=$firms;
    $self->header_add(-type=>'text/html',-charset=>'windows-1251');
    $self->mode_param('do');
}


sub cgiapp_prerun 
{
   my $self = shift;
 #  use Data::Dumper;
    
#   die Dumper $self;
   #return   if($self->{non_login});

   my $session=$self->query->cookie('session');

	
   $self->{user_id}=$self->get_user_by_session($session);
#   die $self->{user_id};
    $USER_ID=$self->{user_id};

   $self->run_modes(
                        'login'=>'login',
                        'login_do'=>'login_do',
                        'denied'=>'denied',
                        'logout'=>'logout',
			'export_excel'=>'export_excel'
                    );


    my $r=$self->get_right();       
#    die $r;
	


#die $self->{user_id};
	if($self->query->param('do') eq 'logout')
	{
		return $self->prerun_mode('logout');   
		return; 
	}
	elsif($self->query->param('do') eq 'login_do')
	{
	#    die "here";
		return $self->prerun_mode('login_do');   
		return; 
	}elsif(!$self->{user_id})##if chat then the empty screen
	{
#		die "here";
		return $self->prerun_mode('login');     
	
		return ;
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
sub login
{
   my $self=shift;
   my $tmpl=$self->load_tmpl('login.html');
   my $output = "";
   $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
   return $output;
}

sub del_trans
{
    my ($self,$id)=@_;
        my $ref=$dbh->selectrow_hashref(q[SELECT * FROM transactions WHERE t_id=?],undef,$id);
            my $id=$self->add_trans(
                {
                    t_name1 => $ref->{t_aid2},
                    t_name2 => $ref->{t_aid1},
	            t_currency => $ref->{t_currency},
	            t_amnt => $ref->{t_amnt},
	            t_comment => "Удаление $ref->{t_comment}",               
	            t_status=>$ref->{t_status},
	        });
	return $id;
} 
																											
sub login_do
{
   my $self=shift;
   my $tmpl=$self->load_tmpl('login.html');
   my $output = "";
   my ($user_id,$session) =  $self->auth_login($self->query->param('login'), $self->query->param('pwd')); 
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

sub auth_login
{
        my ($self,$login,$pwd)=@_;
        my ($user_id,$session_data)=$dbh->selectrow_array(q[SELECT 
	o_id,o_session_data FROM operators 
	WHERE  o_login=? AND o_password=SHA1(?) AND o_status='active' 
	AND o_type='out'],undef,$login,$pwd);        

        return (undef,undef) unless($user_id);
	##cache new session
	my $memd=get_cache_connection();
	$memd->add($user_id,thaw($session_data)) if($session_data);
	
	###cache
        my $session=$dbh->selectrow_array(q[SELECT md5(rand())]);

        my $r=$dbh->do(q[INSERT INTO oper_sessions(os_session,os_oid,os_ip,os_created,os_expired) values(?,?,?,
        current_timestamp,date_add(current_timestamp,interval 6 hour))],undef,$session,$user_id,'127.0.0.1');
        return ($user_id,$session);
        
        
}
sub get_user_by_session
{
        
        my $self=shift;
        my $session=shift;
	
        my ($os_oid,$sub)=$dbh->selectrow_array(qq[SELECT    
	os_oid,timestampdiff(minute,current_timestamp,os_expired)
	FROM oper_sessions WHERE  os_session=? AND os_status='active'  AND 
	os_expired>current_timestamp],undef,$session);
	   

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


                
	}
   
       #die $os_oid;
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
			if($right!~/report/&&$right!~/chat/)
			{	
				my $r=$self->{session_data}->{$right};
				
				foreach(keys %$r)
				{
					$self->query->param($_,$r->{$_});	
				}
			}
			elsif($right!~/chat/)
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
#		die Dumper $self->{session_data};
			$r{right}=$right;
			$self->{session_data}->{$right}=\%r;

		}elsif($right=~/report/&&!defined($action))
		{
		
					my $r=$self->{session_data}->{$right}->{$do};	
					
					foreach(keys %$r)
					{
						$self->query->param($_,$r->{$_});	
					}
		
		}elsif($right=~/report/&&defined($action))
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
	$dbh->do(q[UPDATE  operators SET o_session_data=? WHERE o_id=?],undef,
	freeze($self->{session_data}),$os_oid) if($self->{session_data});


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
	#ie "here"
        $self->header_type('redirect');
        return $self->header_add(-url=>'/cgi-bin/login.cgi');
                
        
        

}
# ==== proto FOR accounts/operators ... =====================================

sub category_title{
  my $category = shift;
  my $id = shift;
  my $params = shift;

  my $title = "";
  $title="(id#$id)" if($id);

  if($category eq "accounts"){
    return "" if($id == -3);

    my $r = $dbh->selectrow_hashref("SELECT * FROM $category WHERE a_id = ".sql_val($id));
    if($r){
      $title = "$r->{a_name} $title";
}
}elsif($category eq "operators"){
    my $r = $dbh->selectrow_hashref("SELECT * FROM $category WHERE o_id = ".sql_val($id));
    if($r){
      $title = "$r->{o_login} $title";
}
}elsif($category eq "firms"){
    my $r = $dbh->selectrow_hashref("SELECT * FROM $category WHERE f_id = ".sql_val($id));
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

}	

  return $title;
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
       SELECT * FROM firms_out_operators
       WHERE o_id=?
       ORDER BY f_name
       ];
   
       my @titles=();
       my $sth =$dbh->prepare($sql);
       $sth->execute($self->{user_id});
#          push @titles, {"title"=>"Все"} if($params->{method} eq 'list');

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
}elsif($row->{category} eq "out_firms"&&$row->{type} eq "select"){
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

     $index++;
}
   $self->{tpl_vars}->{page_title}=$proto->{page_title};
   $self->{tpl_vars}->{fastCgiS}=$FASTCGI_SEARCH;
 
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
   if($self->query->param('action') eq 'filter'){
     map {$filter_params->{$_}=$self->query->param($_)} $self->query->param();
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
           $filter_where .= " AND lcase($row->{field}) like lcase(".sql_val('%'.$filter_val.'%').")";
}else{


	   $filter_val=~s/[,]/\./g;
	   $filter_val=~s/[ \"\']//g; 
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
  my $limit="";
  if ($proto->{limit}){
    $proto->{rows_per_page}||=30;
    $limit="LIMIT ".$proto->{page}*($proto->{rows_per_page}).",".$proto->{rows_per_page};
    
}

  if($proto->{'sort'})	
{
	 
    $sql = qq[SELECT SQL_CALC_FOUND_ROWS * FROM $p->{table} 
     		WHERE $del_sql $extra_where $filter_where
     		ORDER BY $proto->{'sort'} $limit];
	
}elsif($proto->{id_field})
{	
	  	
 	$sql = qq[SELECT SQL_CALC_FOUND_ROWS * FROM $p->{table} 
     	WHERE $del_sql $extra_where $filter_where 
     	ORDER BY $proto->{id_field} DESC $limit
   	];   
}else
{
				
	$sql = qq[SELECT SQL_CALC_FOUND_ROWS * FROM $p->{table} 
		  WHERE $del_sql $extra_where $filter_where $limit
	];   
}
  
####but the old style of work has been saved	

   my $sth =$dbh->prepare($sql);
   $sth->execute();

#post formating
my $format=$dbh->selectall_hashref(qq[DESC $p->{table} ],'Field');

$prev_row=undef;##for first row the prev row will be undef
my $r;
while( $r = $sth->fetchrow_hashref)
{

    foreach my $row( @{$proto->{fields}} )
	{
	
		my $val = $r->{ $row->{"field"} };
		$r->{ "orig__".$row->{"field"} } = $val unless($r->{ "orig__".$row->{"field"} } );
		
	
	
	if($row->{type} eq 'select')
	{
		if( $row->{"titles_hash"}->{ $val } )
		{
			$val = $row->{"titles_hash"}->{ $val };
		}

	}elsif($row->{type} eq 'select2hash')
	{
		my $hash_name = "hash1";
		if($r->{$row->{"if_member"}} == $row->{"value_for_h2"})
		{
			$hash_name = "hash2";
		}

		if( $row->{$hash_name}->{ $val } ){
			$val = $row->{$hash_name}->{ $val };
		}

	}
	elsif($row->{type} eq 'set'){
		my $hash = set2hash($val);

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
			##after processing row we can format it
			$prev_row=$r->{ct_date};
			$self->formating_fields($r,$format);
			
		}
		else
		{
			
			
			push @rows, $r;
			$prev_row=$r->{ct_date};
			$self->formating_fields($r,$format);
		}
		
##save the prev row
	
  	
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

	
   $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
   return $output;
}
sub formating_fields
{
	my ($self,$r,$format)=@_;
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
				$r->{$_}=format_float($r->{$_});

				
			
		}elsif($format->{$_}->{'Type'}=~/datetime|timestamp/&&$r->{$_})
		{
				$r->{$_}=format_datetime($r->{$_});

		}elsif($format->{$_}->{'Type'}=~/date/&&$r->{$_})
		{
				$r->{$_}=format_date($r->{$_});
		
				
		}
		

}

	


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


###checcking the fileds	
   if($is_apply){
     
     return $self->header_add(-location=>$p->{back_url}) if($self->query->param('__cancel'));
	
   	
     foreach my $row( @{$proto->{fields}} ){
	
		

       my $val=$self->query->param( $row->{field} );
	
       my $prefix = "пїЅпїЅпїЅпїЅ '$row->{title}'";

		next if($row->{no_add_edit});

##filters
		if($row->{positive})
		{         
			$val=~s/[,]/\./g;##for blonds
			$val=~s/[ ]//g;
			$self->query->param($row->{field},$val);
			return $self->error("$prefix должно иметь формат числа!!!") unless ($val =~ /^\s*[+-]?\d+\.?\d*\s*$/);
			$val += 0;
			return error $self,"$prefix должно быть больше нуля!!!" if($val <= 0);
		}elsif($row->{num_or_empty})
		{
			$val=~s/[,]/\./g;##for blonds
			$val=~s/[ ]//g;
			$self->query->param($row->{field},$val);
			return  error $self,"$prefix должно иметь формат числа!!!" if(!$val =~ /^\s*[+-]?\d+\.?\d*\s*$/&&!$val);
		
		}elsif($row->{req_currency})
		{
			return  error $self,"$prefix Вы не выбрали значение!" unless($avail_currency->{$val});

		}
		elsif($row->{uniq})
		{
			##if setting id ,the it must be editing
			
			if($id&&$dbh->selectrow_array("SELECT $row->{field} FROM  $proto->{table} WHERE $row->{field}=? 
			AND  ",undef,$val,$id))
			{
				return error $self,"$prefix  должно быть больше быть уникальным !!!! \n";

			}elsif($dbh->selectrow_array("SELECT $row->{field} FROM  $proto->{table} WHERE $row->{field}=? ",undef,$val)) ##in other case it adding
			{
				return error $self,"$prefix  должно быть больше быть уникальным ! !!! \n";
			}
		
		}elsif($row->{category} eq 'accounts')
		{
			
		return error $self,"$prefix не задано\n" unless($dbh->selectrow_array(q[SELECT a_id FROM accounts WHERE a_id=?],undef,$val));
			
			
		}elsif($row->{category} eq 'exchange')
		{
			$row->{exchange_yes}=$self->query->param('exchange_yes');
			if($row->{exchange_yes})
			{
				
			$row->{common_sum}=$self->query->param('common_sum');
			$row->{rate}=$self->query->param('rate');
			$row->{currency}=$self->query->param('currency');	

			$row->{ct_currency}=$self->query->param('ct_currency');	

		
		
		return error $self, "Не задан курс обмена \n"	if(!$self->query->param('light_rate')&&!$row->{rate});
			return error $self, "Не задана валюта обмена \n"	unless($avail_currency->{$row->{currency}});
		
			

			}
		}elsif($row->{another_enable})
		{
		    
    		    my @val=$self->query->param($row->{field});
		
		    unless($val[0]){
		    
			    $self->query->param($row->{field},$val[1]);
		     }else{
			    $self->query->param($row->{field},$val[0]); 
		    
		    
		    }

		
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

     if($method eq 'edit'){       
       $sql .= " WHERE $p->{id_field}=".sql_val($id);
}     
     $self->proto_add_edit_trigger({
       'sql'=>$sql,
       'method'=>$method,
       'proto'=>$proto,
       'p'=>$p,
       'step'=>'operation',
});
	
	$self->header_type('redirect');

     return $self->header_add(-url=>$p->{back_url}."#$id");
}else{


     if($method eq 'edit'){  
     
       my $r = $dbh->selectrow_hashref("SELECT * FROM $p->{table} WHERE $p->{id_field} = ".sql_val($id));
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
		    
		    if($row->{exchange_yes}){
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
		    
	    }
        
         if($is_apply_but_need_confirm&&!$row->{'system'}){
            #the part where in confirmation installing variables from form
             $row->{value} =($row->{component_function} && $row->{component_function}->($row,$self))||($self->query->param( $row->{field} )|| $row->{default});
             
             next;
	    
	        #fixme: set not work!
         }

	       $pr=$self->query->param($row->{field});
           $row->{value} =$pr  || $row->{default};
	             
                
    
		    
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
    
	
   my $output = "";
   $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
   return $output;
}



sub add_trans
{
        my ($self,$ref)=@_;
	
        
	
        $ref->{t_oid}=$self->{user_id};
        die "Такого пользователя нет в системе \n" unless($ref->{t_name1});
	$ref->{t_status}='no' unless($ref->{t_status});
        
	
	 $ref->{t_aid1}=$ref->{t_name1};
#my $a2=$dbh->selectrow_array(q[SELECT a_id FROM accounts WHERE a_id=? ],undef,$ref->{t_name2});
    
	die "Такого пользователя нет в системе \n"  unless($ref->{t_name2});
        
	$ref->{t_aid2}=$ref->{t_name2};
		

        my $field=$avail_currency->{$ref->{t_currency}};
        $ref->{account_bill}=$field;
	
        die "Такого счета нет \n" unless($field);
        
	$ref->{t_amnt}=~s/[,]/\./g;
	$ref->{t_amnt}=~s/[ \"\']//g;
	
        die "Сумма не соостветсвует формату числа\n" unless($ref->{t_amnt}=~/[\-]{0,1}\d+\.{0,1}\d{0,2}/);
        
	$ref->{sum_before2}=$dbh->selectrow_array(qq[SELECT $field 
	FROM accounts WHERE a_id=? ],undef,$ref->{t_name2});   
	$ref->{sum_before1}=$dbh->selectrow_array(qq[SELECT $field 
	FROM accounts WHERE a_id=? ],undef,$ref->{t_name1});     
	
        die "Пожайлуста заполните поле комментариев \n" if(!$ref->{t_comment});

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
                die "Внутренняя ошибка системы обратитесь к разработчику: code 4 ($qwe)\n"; 
# add other application on-error-clean-up code here
}
        return $t_id;   



}
sub do_trans
{
        my $ref=shift;
      
        my $res=$dbh->do(qq[UPDATE accounts SET $ref->{account_bill}=$ref->{account_bill}+? WHERE 
        a_id=$ref->{t_aid1}   ],undef,-1*$ref->{t_amnt}); 

        die "Внутренняя ошибка системы обратитесь к разработчику : code 1\n" unless($res eq 1);

        my $t_id=1;
       
         $res=$dbh->do(q[INSERT 
	  INTO
 transactions(t_ts,t_aid1,t_aid2,t_amnt,t_currency,t_comment,t_oid,t_status,t_amnt_before1,t_amnt_before2) 
	  VALUES(current_timestamp,?,?,?,?,?,?,?,?,?)],undef,
	  @$ref{qw( t_aid1 t_aid2 t_amnt t_currency  t_comment t_oid t_status sum_before1 sum_before2)});
          die "Внутренняя ошибка системы обратитесь к разработчику : code 2\n" unless($res eq 1);   
          $t_id=$dbh->selectrow_array(q[SELECT last_insert_id()]);


        $res=$dbh->do(qq[UPDATE accounts SET $ref->{account_bill}=$ref->{account_bill}+? WHERE 
        a_id=$ref->{t_aid2}],undef,$ref->{t_amnt});
        die "Внутренняя ошибка системы обратитесь к разработчику : code 3\n" unless($res eq 1);
        
        return $t_id ;


}    








1;


