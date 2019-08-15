#!/usr/bin/perl
use strict;
use lib q[/usr/local/www/lib];
use warnings;
use SiteDB;
use SiteCommon;
use SiteConfig;
database_connect();
my $sth=$dbh->prepare(q[SELECT * FROM firewall_settings 
WHERE fs_status='actual' ORDER BY fs_number DESC]);

my $upds=$dbh->selectrow_hashref(q[SELECT fu_date,fu_status FROM firewall_updates WHERE  DATE(fu_date)=current_date ]) ;


if($upds && $upds->{fu_status} eq 'actual'){

	database_disconnect();

	exit(0);

}
unless($upds){
	$dbh->do(q[INSERT INTO firewall_updates(fu_date,fu_status) VALUES(current_date,'actual') ]);

	exit(0);

}

$sth->execute();

my $IPTABLES="/sbin/iptables";
my $INET_IFACE=$INTERFACE;
my $EXT=$EXT_IP;

system("$IPTABLES -F");
#$IPTABLES -t nat -F
system(qq[$IPTABLES -P FORWARD ACCEPT ]);


while( my $row=$sth->fetchrow_hashref() ){
    my $src_ip='';
    if($row->{fs_src_ip}){
             $src_ip="-s $row->{fs_src_ip}";
    }
    system("$IPTABLES -I $row->{fs_type}    -p tcp $src_ip -i $INET_IFACE -d $EXT --dport $row->{fs_port} -j $row->{fs_rule} ");
    print "$IPTABLES -I $row->{fs_type}     -p tcp $src_ip -i $INET_IFACE  -d $EXT --dport $row->{fs_port} -j $row->{fs_rule} \n";
}
$dbh->do(q[UPDATE firewall_updates SET fu_status='actual' ]);

=pod
$IPTABLES  -A INPUT -s 195.68.202.230 -i $INET_IFACE -p tcp -m tcp -d $EXT_IP --dport 443 -j ACCEPT

$IPTABLES  -A INPUT -s 89.28.202.182 -i $INET_IFACE -p tcp -m tcp -d $EXT_IP --dport 443 -j ACCEPT



$IPTABLES  -A INPUT -s 62.64.86.236/32 -i $INET_IFACE -p tcp -m tcp -d $EXT_IP --dport 443 -j ACCEPT 
$IPTABLES  -A INPUT -s 66.249.65.188/32 -i $INET_IFACE  -p tcp -m tcp -d $EXT_IP --dport 443 -j ACCEPT 
$IPTABLES  -A INPUT -s 94.248.84.78/32 -i $INET_IFACE -p tcp -m tcp  -d $EXT_IP --dport 443 -j ACCEPT 
$IPTABLES  -A INPUT -s 109.167.45.35/32 -i $INET_IFACE -p tcp -m tcp -d $EXT_IP  --dport 443 -j ACCEPT 
$IPTABLES -A INPUT -s 92.49.234.70/32 -i $INET_IFACE -p tcp -m tcp -d $EXT_IP --dport 443 -j ACCEPT 
$IPTABLES -A INPUT -s 89.28.202.242/32 -i $INET_IFACE -p tcp -m tcp -d $EXT_IP  --dport 443 -j ACCEPT 
$IPTABLES -A INPUT -s 89.28.205.126/32 -i $INET_IFACE -p tcp -m tcp -d $EXT_IP --dport 443 -j ACCEPT 
$IPTABLES -A INPUT -s 89.28.202.2/32 -i $INET_IFACE -p tcp -m tcp -d $EXT_IP --dport 443 -j ACCEPT 
$IPTABLES -A INPUT -s 89.28.202.138/32 -i $INET_IFACE -p tcp -m tcp -d $EXT_IP --dport 443 -j ACCEPT 
$IPTABLES -A INPUT -s 77.198.250.126/32 -i $INET_IFACE -p tcp -m tcp -d $EXT_IP  --dport 443 -j ACCEPT 
$IPTABLES -A INPUT  -i $INET_IFACE -p tcp -m tcp -d $EXT_IP  --dport 80 -j ACCEPT

$IPTABLES -A INPUT -i eth0 -p tcp -m tcp --dport 443 -j DROP 
$IPTABLES  -A INPUT -i eth0 -p tcp -m tcp --dport 445 -j DROP 
$IPTABLES -A INPUT -i eth0 -p tcp -m tcp --dport 993 -j DROP 
$IPTABLES -A INPUT -i eth0 -p tcp -m tcp --dport 8080 -j DROP 
$IPTABLES -A INPUT -i eth0 -p tcp -m tcp --dport 8081 -j DROP 
$IPTABLES  -A INPUT -i eth0 -p tcp -m tcp --dport 143 -j DROP 
=cut
