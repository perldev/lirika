package Oper::Settings;
use strict;
use base 'CGIBase';
use SiteConfig;
use SiteDB;
##for testing on my machine
use lib qw(/usr/lib/perl/5.8/auto);

use SiteCommon;
my $RIGHT='settings';
#this  package needing the checking of all params
sub setup
{
  my $self = shift;
  $self->start_mode('menu');  
$self->run_modes(
   'AUTOLOAD'   => 'menu',
    'list_tabs' => 'list_tabs',
    'save_tabs'  => 'save_tabs',
    'reset_tabs'=>'reset_tabs',
  );

}

sub menu
{
	my $self = shift;
	$self->{tpl_vars}->{page_title}='Общии настройки системы';
	my $tmpl=$self->load_tmpl('settings_menu_common.html');
	my $output='';
	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
	return $output;

}
sub list_tabs
{
	my $self=shift;	
	$self->{tpl_vars}->{page_title}='Название основных разделов';
	my $menus;
	require Storable;
	unless(open(FROM,"$FILE_TAB_CONFIG"))
	{
		$menus=$DEF_TABS;
	}else
	{
		$menus=Storable::fd_retrieve(*FROM) || die "can't store to stdout\n";
		close(FROM);
	
	
		my $size= keys %$menus;
		my $sz=keys %$DEF_TABS;
		$menus=$DEF_TABS	if($sz!=$size);
	}
	my @array; 
	map {push @array,$menus->{$_} } keys %$menus;

	$self->{tpl_vars}->{tabs_name_list}=\@array;
   	my $tmpl=$self->load_tmpl('settings_menu_edit.html');
   	my $output='';
   	$tmpl->process($self->{tpl_file}, $self->{tpl_vars}, \$output) || die $tmpl->error();
   	return $output;
}
sub save_tabs
{
	my $self=shift;
	my %res;
	my $t;

	require Storable;
	my $tm;    
	foreach(keys %$DEF_TABS)
	{
		$tm=$DEF_TABS->{$_};
		$t=$self->query->param($tm->{value});
		unless($t)
		{
			$t=$tm->{title};
		}
 		$res{$_}={title=>$t,value=>$tm->{value},desc=>$tm->{desc},script=>$DEF_TABS->{$_}->{script}};


	}	
	open(FROM,">$FILE_TAB_CONFIG") or die $!;
	Storable::store_fd(\%res,*FROM);
	close(FROM);
        my $md=get_cache_connection();   
#	use Data::Dumper;
                                                                                                                    
	$md->set('name_tabs',\%res);
	
#	use Data::Dumper;
#	die Dumper $md->get('name_tabs');

	$self->header_type('redirect');
	return $self->header_add(-url=>'?do=list_tabs');
	
}
sub reset_tabs
{
	my $self=shift;
	$self->header_type('redirect');
	return $self->header_add(-url=>'?do=save_tabs');
}
sub get_right
{
        my $self=shift;
        return $RIGHT;
}


1;
