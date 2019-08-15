#!/usr/bin/perl -w
#use CGI::Carp qw(fatalsToBrowser);
use lib q(/usr/local/www/lib);
use strict;
use Net::POP3;
#use Data::Dumper;
use SiteConfig;
use SiteDB;
my $TIMER  = RHP::Timer->new();
$TIMER->start('fizzbin');
open(FL,">>".$MAIL_DIR."/logs.dat");
my ($sec,$min,$hour) = localtime();
print FL "\nstart in $hour:$sec:$min";


database_connect();

my $server = "pop3.mail.ru";




my $pop = new Net::POP3($server);
## «алогинитс€
my $msgs = $pop->login($MAIL, $MAIL_PASS);
## login возвращает undef, если не удалось залогинитс€ и число сообщений
## в почтовом €щике, если удалось.
print FL "\nLogin failed\n" if not defined $msgs;
print FL "\n$msgs messages\n";
## —писок сообщений.  list возвращает ссылку на хэш, ключами которого €вл€ютс€
## номера сообщений, а значени€ми -- размер письма в байтах.
my %list = %{$pop->list};
for my $msg_num (keys(%list)) {
##	        die('test');
	    my $ref=$dbh->selectrow_hashref(q[SELECT * 
                                      FROM 
                                      reports_mail
                                      WHERE rm_id=? AND rm_size=?],undef,$msg_num,$list{$msg_num});

        unless($ref)
        {
        	$dbh->do(q[insert into reports_mail VALUES(?,NOW(),?,'new')],undef,$msg_num,$list{$msg_num});
			#print "#$msg_num - $list{$msg_num} байт\n";
	        my $msg = $pop->get($msg_num);
	        open F, ">".$MAIL_DIR."/msg$msg_num" or die "msg$msg_num: $!";
	        print F join("", @$msg);
	        close F;
        }
        #$pop->delete($msg_num);

}
# «акрыть соединение с сервером
$pop->quit();
my $tim = $TIMER->stop;
print FL "\n work: $tim\n=========================\n";
close FL;


