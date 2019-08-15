package Oper::Chat;
use strict;
use base 'CGIBase';
use SiteConfig;
use SiteDB;
use SiteCommon;
my $_POST={};
sub setup 
{
 	my $self=shift;
	map{$_POST->{$_}=trim($self->query->param($_))} $self->query->param();
	$self->run_modes(
			'AUTOLOAD' => 'main',
			'main'	   => 'main',
			'list'     => 'list',
			'add'      =>  'add',
			'send_invite'=>'send_invite',
			'form'=>'form',
			'private_room'=>'private_room',
			'users'=>'users',
			
	);	



}
sub send_invite
{
      my $self=shift;
      my $guest=$dbh->selectrow_array(qq[SELECT o_login FROM operators WHERE o_id=?],undef,$_POST->{id});
      $dbh->do(qq[INSERT INTO chat_private_room(cpr_oid1,cpr_oid2) VALUE(?,?)],undef,$self->{user_id},$_POST->{id});
      my $ID=$dbh->selectrow_array(q[SELECT last_insert_id() ]);
     my   $MSG_INVITE=qq[
     <font color=blue> Пригласил в приват пользователя $guest,для входа нажмите </font><span style="cursor:pointer" onclick="window.open('chat.cgi?do=private_room&c_room=$ID','', 'scrollbars=yes, resizable=no, toolbar=no, location=no, directories=no, status=no, menubar=no, width=716, height=200'); return false;"><strong>сюда</strong></span>  
      ];
       $dbh->do(qq[INSERT  INTO chat(c_oid,c_msg) VALUES(?,?) ],undef,$self->{user_id},$MSG_INVITE);
       $self->header_type('redirect');
       return $self->header_add(-url=>"chat.cgi?do=private_room&amp;c_room=$ID");           
      
  
}

sub private_room
{
  my $self=shift;
	my $tmpl=$self->load_tmpl('chat_private.html');
	$self->{tpl_vars}->{c_room}=$_POST->{c_room};
  	my $output='';
	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
	return $output;

}
sub get_right
{
	return 'chat';
}
sub main
{
	my $self=shift;
	my $tmpl=$self->load_tmpl('chat_main.html');
        my $output='';
	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
	return $output;

}
sub users
{
	my $self=shift;
	my $tmpl=$self->load_tmpl('chat_users.html');
 	
	my $sth=$dbh->prepare(qq[SELECT o_login,o_id,date_add(os_created,interval 40 second )>=current_timestamp as 'new'  FROM oper_sessions,operators WHERE os_oid=o_id AND os_status='active' AND os_expired>current_timestamp GROUP BY o_id ]);
        $sth->execute();
	my @res;
        while(my $s=$sth->fetchrow_hashref())
        {
		if($s->{new})
		{
			$s->{color}=1;
		}
                push @res,$s;
                
        }
	
        $sth->finish();
        $self->{tpl_vars}->{list}=\@res;
	my $output='';
	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
	return $output;

}
sub list
{
	my $self=shift;
  map{ $self->{tpl_vars}->{$_}=$_POST->{$_} } keys %$_POST;
	my $ref={};
 	my $ref=$self->mess_list($ref);
	$self->{tpl_vars}->{list}=$ref;
  my $output='';
  my $tmpl=$self->load_tmpl('chat_mess_list.html');

	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
        return $output;

}
sub mess_list
{
	      my ($self,$ref)=@_;
        #my ($filter,$page,$how)=@_;
        my $room=$_POST->{c_room};
        if($room)
        {
          
              my $sth=$dbh->prepare(qq[SELECT o_login,
                          DATE_FORMAT(c_ts,"%H:%i %m.%d.%Y") as date,
                          c_msg  FROM chat,operators,chat_private_room 
                          WHERE c_oid=o_id  
                          AND cpr_id=c_room AND c_room=? AND (cpr_oid1=? OR cpr_oid2=?)  
                          ORDER BY c_id  DESC  LIMIT 20]);
        $sth->execute($_POST->{c_room},$self->{user_id},$self->{user_id});
	      my @res;
        while(my $s=$sth->fetchrow_hashref())
        {
                
                push @res,$s;
                
        }
        $sth->finish();
        return \@res;
              
          
        }else
        {
             my $sth=$dbh->prepare(qq[SELECT o_login,DATE_FORMAT(c_ts,"%H:%i %m.%d.%Y") as date,c_msg  FROM chat,operators 
                WHERE c_oid=o_id    
               
                AND c_room IS NULL ORDER BY c_id DESC LIMIT 20]);
        $sth->execute();
	      my @res;
        while(my $s=$sth->fetchrow_hashref())
        {
                
                push @res,$s;
                
        }
        $sth->finish();
        return \@res;
        
        
      }
     

}
sub form
{	
    	my $self=shift;
    	my $tmpl=$self->load_tmpl('chat_add.html');
    	$self->{tpl_vars}->{c_room}=$_POST->{c_room};
    	
    	my $output='';
    	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
      return $output;

}
sub add
{
	my ($self)=shift;
	
  if($_POST->{c_room})
  {
      $dbh->do(qq[INSERT  INTO chat(c_oid,c_msg,c_room) VALUES(?,?,?) ],undef,$self->{user_id},$_POST->{'c_msg'},$_POST->{c_room});
  }else
  {
    	$dbh->do(qq[INSERT  INTO chat(c_oid,c_msg) VALUES(?,?) ],undef,$self->{user_id},$_POST->{'c_msg'});
  
  }
	$self->header_type('redirect');
	return $self->header_add(-url=>'chat.cgi?do=form&c_room='.$_POST->{c_room});
			
}

1;
