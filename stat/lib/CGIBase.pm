package CGIBase;
#use Spreadsheet::WriteExcel;
use strict;
use Encode qw/from_to encode decode/;
use base qw[CGI::Application];
use Exporter;    
use Template;
use POSIX;
use SiteConfig;
use SiteDB;
use SiteCommon;
#use Rights;
use CGI;
$SIG{__DIE__}=\&handle_errors;
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
		    INCLUDE_PATH => './tmpl',
		    INTERPOLATE  => 1,               # expand "$var" in plain text
		    POST_CHOMP   => 1,               # cleanup whitespace 
		    EVAL_PERL    => 1,       
	    }
        );

        
        my $vars = {};
        $vars->{error}=$msg;
        $tmpl->process('proto_error.xml',$vars) || die $tmpl->error();
        $SIG{__DIE__}=undef;
}


sub load_tmpl
{
       my ($self,$file)=@_;

       $self->{tpl_file}=$file;
	my $template = Template->new(
	{
        	INCLUDE_PATH => $DIR,
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
    $self->{tpl_vars}={};
    $self->header_add(-type=>'text/xml',-charset=>'utf-8');
    $self->start_mode('denied');
    $self->mode_param('do');
    
}

sub cgiapp_postrun
{	
	my $self=shift;
        CGI::_reset_globals(); 
        $self->query->param($_,'') foreach($self->query->param());
        $self->query->url_param($_,'') foreach($self->query->url_param());

}

sub cgiapp_prerun 
{
   my $self = shift;
   return   if($self->{non_login});
##FOR USING UNDER FAST_CGI
    $self->{__QUERY_OBJ} = $self->cgiapp_get_query;
    $dbh->do("SET charset cp1251;");                                                                                                  
    $dbh->do("SET names   cp1251;");  
   ###from cgiapp_init
    my %url_params = map {$_=>$self->query->url_param($_)} $self->query->url_param();
    my %params = map {$_=>$self->query->param($_)} $self->query->param();
    foreach my $key (keys %url_params)
    {
                $self->query->param($key, $url_params{$key}) unless(defined $params{$key});
    }


   ##finishing code from it
    my  $session=$self->query->param('session');
    #die "session = ".$self->query->param('session') unless($session);
		
   $self->{user_id}=$self->get_user_by_session($session);
#   die $self->{user_id};


     $self->run_modes(
    			'AUTOLOAD'=>'denied',
                        'logout'=>'logout',
			'login_do'=>'login_do',
                        'denied'=>'denied'
		    );

         if(!defined ($self->query->param('do'))){
	    return $self->denied();
		     
	 } elsif($self->query->param('do') eq 'logout'){
		$self->prerun_mode('logout');   
		return; 
	}elsif($self->query->param('do') eq 'login_do'){
	#    die "here";
		$self->prerun_mode('login_do');   
		return; 
	}elsif(!$self->{user_id})##if chat then the empty screen
	{
	
		return $self->denied();
	}
#die "her";      		


  

##get through all right and setting a name for it
   

}
sub empty
{
	my $self=shift;
	return '';

}

sub denied{
        my $self=shift;
        my $tmpl=$self->load_tmpl('denied.xml');
        my $output = "";
        $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
        return $output;
}

sub login_do{
       
   my $self=shift;
   my $output = "";
   my ($user_id,$session) =  $self->auth_login($self->query->param('session'));
#    die "here";

	
   	unless($user_id){
                my $tmpl=$self->load_tmpl('error.xml');
     		$self->{tpl_vars}->{error}=1;
		$self->{tpl_vars}->{login}=$self->query->param('login');
		$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
		return $output;
	
	}else{
	
	        my $tmpl=$self->load_tmpl('session.xml');
		$self->{tpl_vars}->{session}=$session;
		$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
		return $output;
	}

}
sub auth_login
{
        my ($self,$pwd)=@_;
        my $user_id=$dbh->selectrow_array(q[SELECT 
	o_id FROM stat_operators 
	WHERE   o_password=? ],undef,$pwd);        
    
        return undef unless($user_id);
	##cache new session
	
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
	if($ENV{REMOTE_ADDR}  ne '127.0.0.1'){
            ($os_oid,$sub)=$dbh->selectrow_array(qq[SELECT    os_oid,
		timestampdiff(minute,current_timestamp,os_expired)
		FROM oper_sessions WHERE  os_session=?
                AND
		os_status='active' AND
		os_ip=?
		AND os_expired>current_timestamp],undef,$session,$ENV{REMOTE_ADDR});
	}else{
	 ($os_oid,$sub)=$dbh->selectrow_array(qq[SELECT    os_oid,                                                                                       
	                 timestampdiff(minute,current_timestamp,os_expired)                                                                                          
	                 FROM oper_sessions
			 WHERE  os_session=?
		         AND os_status='active'  AND os_expired>current_timestamp],undef,$session);
	
	}
   

        unless(defined($os_oid)){
		
		$os_oid=$dbh->selectrow_array(q[SELECT
                                              os_oid
					      FROM
					      oper_sessions
					      WHERE  os_session=?],undef,$session);
		if(defined($os_oid))
		{

			$dbh->do(q[UPDATE oper_sessions
				 SET os_status='deleted'
				 WHERE os_oid=? ],undef,$os_oid);

			return  undef;
		}else
		{
			return undef;
		}
				
	}
       return $os_oid;


     


}



sub logout
{
        my $self=shift;
        my $session=$self->query->param('session');

        my $os_oid=$dbh->selectrow_array(q[SELECT    
	os_oid FROM oper_sessions WHERE  os_session=? AND os_status='active' AND os_ip=? AND 
	os_expired>current_timestamp],undef,$session,$ENV{REMOTE_ADDR});
##	$self->save_session($os_oid);
        if($os_oid)
	{
                $dbh->do(q[UPDATE oper_sessions SET os_status='deleted'  WHERE os_oid=?],undef,$os_oid);
	}
        return ;
                
        
        

}
# ==== proto FOR accounts/operators ... =====================================





1;


