package SiteConfig;

use strict;

use base "Exporter";
our @ISA = qw(Exporter);

our @EXPORT = qw(
$db_host $db_name $db_user $db_pass
$PMS_PATH

$FILE_PATH
$USERS_HASH
$comis_aid

$FILE_TAB_CONFIG
$DEF_TABS
$FILE_PATH_LOG
$DEFAULT_CURRENCY

$SEARCH_DISP_FIRM
$SEARCH_DAYS_FIRM

@RATE_FORMS
%RATE_FORMS

$COMPILE_DIR_LITE
$DIR_LITE
$COMPILE_DIR
$DIR
$CLIENT_CATEGORY  
$use_secure_cookies
);

##config of setting of rate of various currencies
    our @RATE_FORMS=(
    	{from=>'USD',to=>'UAH',rate_form=>1},
    	{from=>'USD',to=>'EUR',rate_form=>-1},
    	{from=>'UAH',to=>'USD',rate_form=>-1},			
    	{from=>'UAH',to=>'EUR',rate_form=>-1},
    	{from=>'EUR',to=>'USD',rate_form=>1},			
    	{from=>'EUR',to=>'UAH',rate_form=>1},
	{from=>'EUR',to=>'EUR',rate_form=>1},
	{from=>'UAH',to=>'UAH',rate_form=>1},
	{from=>'USD',to=>'USD',rate_form=>1},
    ); 	
    our %RATE_FORMS=(
	USD=>{USD=>1,UAH=>1,EUR=>-1},
	UAH=>{USD=>-1,UAH=>1,EUR=>-1},
	EUR=>{USD=>1,UAH=>1,EUR=>1},
   ); 

our $SEARCH_DISP_FIRM=0.001;#in percents

our $CLIENT_CATEGORY=16;                                                                                                                          
our $COMPILE_DIR='./tmpl';                                                                                               
our $DIR ='./tmpl';                                                                                                      
                         

our $SEARCH_DAYS_FIRM=2;#in days


# database configs #####################################
our $db_host="localhost";
our $FILE_TAB_CONFIG="../lib/firm.conf";
our $FILE_PATH_LOG=">>../lib/log.txt";


our $db_name='fsb';
our $db_user="fsb_user";
our $db_pass="randomnumber";
our $PMS_PATH="/home/bogdan/pms/pms/lib/";
our $FILE_PATH="../firm_reports/";
our $DEFAULT_CURRENCY='UAH';
# site configs #########################################
#our $defualt_host="fsb";


our $comis_aid = 1;


# bogdan:
# реализуй этот булеан

1;
