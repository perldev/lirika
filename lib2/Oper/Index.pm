package Oper::Index;

use strict;

use base 'CGIBase';

use SiteConfig;
use SiteDB;
use SiteCommon;


sub setup
{
  my $self = shift;
    
  #$self->start_mode('index');  
	
  $self->run_modes(
    'AUTOLOAD'   => 'index',
    'index' => 'index',
  );
}
sub get_right
{
	my $self=shift;
	return 'index';
}
sub index
{
   my $self=shift;
  
  	
   my $tmpl=$self->load_tmpl('index.html');

   my $output = "";
   $tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
   return $output;
}

1;
