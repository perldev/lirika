package Oper::Lost;

use strict;

use base 'CGIBase';

use SiteConfig;
use SiteDB;
use SiteCommon;

my $proto={
  'table'=>"cashier_transactions",  
  'page_title'=>'�������� ������ ������ ',
  'template_prefix'=>"lost_firm_in",
  'extra_where'=>" ct_fid>0 AND ct_infl='yes'",
  
  'need_confirmation'=>1,
  'id_field'=>'ct_id',
  'sort'=>'ct_date DESC',

  'fields'=>[
    {'field'=>"ct_id", "title"=>"ID", "no_add_edit"=>1}, #first field is ID

    {'field'=>"ct_date",category=>'date', "title"=>"���� �����������",'filter'=>"time","default"=>$now_hash->{sql}
},

   {'field'=>"ct_ts", "no_add_edit"=>1, "add_expr"=>"NOW()", "title"=>"����"

   },

   {'field'=>"ct_infl", "no_add_edit"=>1, "add_expr"=>"'yes'", no_view=>1 },


    {'field'=>"ct_fid", "title"=>"�����", "category"=>"firms", "type"=>"select"
     ,'filter'=>"="
    },

    {'field'=>"ct_amnt", "title"=>"�����",'filter'=>"="},
    {'field'=>"ct_currency", "title"=>"������"
     , "type"=>"select"
     , "titles"=>\@currencies
     ,'filter'=>"="
    },
    {
     'field'=>"ct_comment", "title"=>"����������", 'default'=>"���� ��������",
     'filter'=>'like'
    },
    {'field'=>"ct_oid", "title"=>"��������"
      , "no_add_edit"=>1, "category"=>"operators"
    },
    #{'field'=>"ct_tid", "title"=>"����������", "no_add_edit"=>1,},

    {'field'=>"ct_status", "title"=>"������ ����������"
      ,"no_add_edit"=>1, 
      ,"no_view"=>1,
    },



  ],
};


sub setup
{
  my $self = shift;
  $self->start_mode('list');   
  $self->run_modes(
    'AUTOLOAD'   => 'list',
    'list' => 'list',
    'add'  => 'add',
    'del'  => 'del',
  );
}
sub get_right
{
                my $self=shift;

        return 'correct_back';
}
sub list
{
   my $self = shift;
   #   $proto->{'sort'}='f_id DESC';    	
   return $self->proto_list($proto);
}

sub add
{
   my $self = shift;
   my $ct_amnt=$self->query->param('ct_amnt');
   $ct_amnt=~s/[,]/\./;
   $ct_amnt=~s/[ \,]//g;
   
   $self->query->param('ct_amnt',$ct_amnt);
   $proto->{'page_title'}='�������� ����� ������ ������ ������';
   return $self->proto_add_edit('add', $proto);
}
sub del
{
	my $self=shift;
	my $id=$self->query->param('id');
	$dbh->do(q[DELETE FROM cashier_transactions WHERE ct_id=? AND ct_infl='yes' AND ct_status='created'],undef,$id);
	
    	$self->header_type('redirect');
    	return  $self->header_add(-url=>'?');    

}


1;
