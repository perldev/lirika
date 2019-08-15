package SiteConfig;

use strict;

use base "Exporter";
our @ISA = qw(Exporter);

our @EXPORT = qw(
$db_host $db_name $db_user $db_pass

$FILE_PATH
$FILE_PATH_LOG
$DEFAULT_CURRENCY
$use_secure_cookies
$CLIENT_CATEGORY                                                                                                                                  
$USER_ID
$FASTCGI_SEARCH
$COMPILE_DIR
$TMPL_DIR
$EXCEL_EXPORT_PATH
$TRANSIT_ID
);


our $EXCEL_EXPORT_PATH='/usr/local/www/data/excel/';
our $TMPL_DIR='../tmpl_firm';
our $COMPILE_DIR='/tmp/firm_tmpl_c/';
# database configs #####################################
our $db_host="localhost";
our $FILE_PATH_LOG=">>../lib/log.txt";
our $db_name='fsb';
our $db_user="fsb_user";
our $db_pass="randomnumber";
our $FILE_PATH="../firm_reports/";
our $DEFAULT_CURRENCY='UAH';
# site configs #########################################
#our $defualt_host="fsb";
our $CLIENT_CATEGORY=16;                                                                                                                                      
our $FASTCGI_SEARCH="search/first_fastcgi.exe";                                                                                                                                      
our $USER_ID; 
our $TRANSIT_ID=3687;


# bogdan:
# реализуй этот булеан
our $use_secure_cookies = 0;
##using for calculating reports


1;
