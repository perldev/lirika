package Rights;
use strict;
use base "Exporter";
use SiteCommon qw(set2hash);
use SiteDB;

our @EXPORT = qw(
	get_rights
);
sub get_rights
{
	my $oper_id=shift;
	my $rights=set2hash($dbh->selectrow_array(q[SELECT concat(o_privileges,'chat|') FROM operators WHERE o_id=? ],undef,$oper_id));

	return $rights;
	
}