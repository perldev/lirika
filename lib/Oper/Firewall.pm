package Oper::Firewall;

use strict;

use base 'CGIBase';

use SiteConfig;
use SiteDB;
use SiteCommon;
my $proto;
sub get_right
{       
         my $self=shift;
=pod
fs_id int(11) auto_increment primary key,
 fs_port int(11) default 443,
 fs_src_ip varchar(255) NOT NULL,
 fs_dst_ip varchar(255) default  NULL,

 fs_status enum('deleted','actual') default 'actual',
 fs_type enum('INPUT') default 'INPUT',
 fs_rule enum('ACCEPT','DROP') default 'ACCEPT',
 fs_oid int(11) NOT NULL
=cut
        my $string_rules='';
        my $list=[map{ "'$_': '$ACCEPT_ACTION{$_}'" }  keys %ACCEPT_ACTION];
        $string_rules=join(',',@$list);

        $proto={
        'table'=>"firewall_settings",
        'template_prefix'=>"firewall",
        'page_title'=>'Настройки Firewall-а',
        'extra_where'=>"fs_status='actual'",
        'sort'=>'fs_number ASC',
        'init_java_script'=>qq[

        var RULES_HASH={$string_rules};
        ],
        'fields'=>[
            {'field'=>"fs_id", "title"=>"ID", "no_add_edit"=>1,filter=>'='}, #first field is ID
            {'field'=>"fs_comment", "title"=>"Комментарии ",filter=>'like'},
            {
            'field'=>'fs_rule',"title"=>"Действие",filter=>'=',type=>'select',
            "titles"=>[map { { value=>$_,title=>$ACCEPT_ACTION{$_} } } keys %ACCEPT_ACTION]
            },
            {'field'=>"fs_port", "title"=>"Port",filter=>'='},
            {'field'=>"fs_oid", "title"=>"Оператор",    
            , "no_add_edit"=>1, "category"=>"operators"
            },
            {'field'=>"fs_src_ip", "title"=>"IP/Сеть",filter=>'like'},
        ],
        };
        
        $proto->{rules}=$proto->{fields}->[2]->{titles};
        return 'firewall';
}
sub setup
{
  my $self = shift;
  $self->start_mode('list');  
  $self->run_modes(
    'AUTOLOAD'   => 'list',
    'list' => 'list',
    'add'  => 'add',
    'refresh'=>'refresh'	
   );
}
sub refresh{
	my $self=shift;
	my $res=$dbh->do(q[UPDATE firewall_updates SET fu_status='not_actual' WHERE DATE(fu_date)=current_date ]);
	$dbh->do(q[INSERT firewall_updates SET fu_status='not_actual'])	if($res ne '1');
	$self->header_type('redirect');
	return $self->header_add(-url=>'?');


}

sub list
{

   my $self = shift;
   return $self->proto_list($proto);


}




1;
