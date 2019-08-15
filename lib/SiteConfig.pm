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

$MAIL_DIR
$MAIL 
$MAIL_PASS

$PATH

@RATE_FORMS
%RATE_FORMS

$COMPILE_DIR_LITE
$DIR_LITE
$COMPILE_DIR
$DIR
$CLIENT_CATEGORY  
$use_secure_cookies
$ARCHIVE_WORKING_WINDOW

%PORTS_ACCEPT
%ACCEPT_ACTION
$INTERFACE
$PLUGIN_TMPL
$EXT_IP
$EXCEL_EXPORT_PATH
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
our $working_path='/home/fsb/new_fsb/www/';


our $MAIL_DIR = '/tmp/msg';
our $MAIL = 'fsbreports@mail.ru'; 
our $MAIL_PASS = "12stroper89";

our $PATH = '/usr/local/www';

our $SEARCH_DISP_FIRM=0.001;#in percents
our $PLUGIN_TMPL='plugin/';

our $COMPILE_DIR_LITE=$working_path.'/tmpl_lite_c';
our $DIR_LITE=$working_path.'tmpl_lite';   
                                                         ##firewall settings     
our %PORTS_ACCEPT=(
    22=>1
    );
our %ACCEPT_ACTION=(
    'ACCEPT'=>'���������',
    'DROP'=>'���������'
    );

our $EXT_IP='89.28.202.146';

our $INTERFACE='eth0';
###
               
our $CLIENT_CATEGORY=16;                                                                                                                          
our $COMPILE_DIR= $working_path.'/tmpl_c';                                                                     
our $DIR =$working_path.'tmpl';                                                                                                      
our $ARCHIVE_WORKING_WINDOW=1000;

our $SEARCH_DAYS_FIRM=2;#in days


# database configs #####################################
our $db_host="localhost";
our $FILE_TAB_CONFIG="../lib/firm.conf";
our $FILE_PATH_LOG=">>../lib/log.txt";

our $DEF_TABS={
       transfers=>{"value"=>"transfers", "title"=>"���������",desc=>'�������� ����� ����� ����������',script=>'trans.cgi'},
        all_firms=>{"value"=>"all_firms", "title"=>"����",desc=>'������ � ������������ ������� �� ���� ������',script=>'all_firms_list.cgi'},
       firms_exchange=>{"value"=>"firms_exchange", "title"=>"�����������",desc=>'����������� ����������� �������',script=>'conv.cgi'},
       account=>{"value"=>"account", "title"=>"��������",desc=>'���������� ���������� ��������',script=>'accounts.cgi'},
       cash_dnepr=>{"value"=>"cash_dnepr", script=>'cash.cgi',"title"=>"�����",desc=>'������� ������� ����� ������� � �������  �� ��� '},
       oper=>{"value"=>"oper", "title"=>"���������",desc=>"���������� ����������� ������� � �� �������",script=>'operators.cgi'},
       trans=>{"value"=>"trans", "title"=>"����������",desc=>"�������� � ���������� ��������� ���������",script=>'oper.cgi'},
       firm=>{"value"=>"firm", "title"=>"�����",desc=>"����� � �� �������",script=>'firms.cgi'},
       firm_list=>{"value"=>"firm_list","title"=>"������� �� ������",desc=>"�������� ������ �� ������� �����",script=>'firm_trans.cgi'},  
       fservice=>{"value"=>"fservice", "title"=>"������ ����",desc=>"������ ����",script=>'firm_services.cgi'},
        firewall=>{"value"=>"firewall", "title"=>"Firewall",desc=>"Firewall",script=>'firewall.cgi'},
        exch_kiev=>{"value"=>"exch_kiev",script=>'exch_kiev.cgi', "title"=>"����� ����",desc=>'����� ����� ��� �������� �����'},
        exch_odessa=>{"value"=>"exch_odessa",script=>'exch_odessa.cgi', "title"=>"����� ������",desc=>'����� ����� ��� �������� �����'},

       cash_in_before_dnepr=>{"value"=>"cash_in_before_dnepr",script=>'cashier_input_before_dnepr.cgi', "title"=>"������ �� ������ �����",desc=>'���������������� ���� �������� � �����'},
       cash_out_dnepr=>{"value"=>"cash_out_dnepr",script=>'cashier_output_dnepr.cgi' ,"title"=>"������ �� ������ �����",desc=>"������ � �������� ��  ����� �������� "},
       cash_out2_dnepr=>{"value"=>"cash_out2_dnepr",script=>'cashier_output2_dnepr.cgi', "title"=>"������ �����",desc=>"���������������� ������ ��������"},
       cash_in_dnepr=>{"value"=>"cash_in_dnepr",script=>'cashier_input_dnepr.cgi', "title"=>"������ �����",desc=>"���� �������� � ������� �� ��������"},

# 
        cash_in_before_kiev=>{"value"=>"cash_in_before_kiev", "title"=>"������ �� ������ ����� ����",desc=>'���������������� ���� �������� � �����',script=>'cashier_input_before_kiev.cgi'},
        cash_out_kiev=>{"value"=>"cash_out_kiev",script=>'cashier_output_kiev.cgi' ,"title"=>"������ �� ������ ����� ����",desc=>"������ � �������� ��  ����� �������� "},
        cash_out2_kiev=>{"value"=>"cash_out2_kiev",script=>'cashier_output2_kiev.cgi' , "title"=>"������ ����� ����",desc=>"���������������� ������ ��������"},
        cash_in_kiev=>{"value"=>"cash_in_kiev", script=>'cashier_input_kiev.cgi',"title"=>"������ ����� ����",desc=>"���� �������� � ������� �� ��������"},
# 
        cash_kiev=>{"value"=>"cash_kiev", script=>'cash_kiev.cgi',"title"=>"����� ����",desc=>'������� ������� ����� ������� � �������  �� ���� ���� '},
#  
#         
      
        cash_in_before_atrium=>{"value"=>"cash_in_before_atrium", "title"=>"������ �� ������ ����� atrium",desc=>'���������������� ���� �������� � ����� atrium',script=>'cashier_input_before_atrium.cgi'},
        cash_out_atrium=>{"value"=>"cash_out_atrium",script=>'cashier_output_atrium.cgi' ,"title"=>"������ �� ������ ����� atrium",desc=>"������ � �������� ��  ����� �������� atrium"},
        cash_out2_atrium=>{"value"=>"cash_out2_atrium",script=>'cashier_output2_atrium.cgi' , "title"=>"������ ����� atrium",desc=>"���������������� ������ �������� atrium"},
        cash_in_atrium=>{"value"=>"cash_in_atrium", script=>'cashier_input_atrium.cgi',"title"=>"������ ����� atrium",desc=>"���� �������� � ������� �� �������� atrium"},
# 
        cash_atrium=>{"value"=>"cash_atrium", script=>'cash_atrium.cgi',"title"=>"����� ������",desc=>'������� ������� ����� ������� � �������  �� ���� ������ '},

        cash_in_one_dnepr=>{"value"=>"cash_in_one_dnepr", script=>'cashier_input_one_dnepr.cgi',"title"=>"������ �����1 �����",desc=>"���� �������� � ������� �� �������� ����� ���������"},
        cash_in_one_kiev=>{"value"=>"cash_in_one_kiev", script=>'cashier_input_one_kiev.cgi',"title"=>"������ �����1 ����",desc=>"���� �������� � ������� �� �������� ���������"},
    
# 
         cash_in_before_odessa=>{"value"=>"cash_in_before_odessa",script=>'cashier_input_before_odessa.cgi', "title"=>"������ �� ������ ����� ������ ",desc=>'���������������� ���� �������� � �����'},
         cash_out_odessa=>{"value"=>"cash_out_odessa", script=>'cashier_output_odessa.cgi',"title"=>"������ �� ������ ����� ������ ",desc=>"������ � �������� ��  ����� �������� "},
         cash_out2_odessa=>{"value"=>"cash_out2_odessa",script=>'cashier_output2_odessa.cgi' , "title"=>"������ ����� ������",desc=>"���������������� ������ ��������"},
         cash_in_odessa=>{"value"=>"cash_in_odessa", script=>'cashier_input_odessa.cgi' ,"title"=>"������ ����� ������",desc=>"���� �������� � ������� �� ��������"},
#         
         cash_odessa=>{"value"=>"cash_odessa", script=>'cash_odessa.cgi',"title"=>"����� ������",desc=>'������� ������� ����� ������� � �������  �� ���� ������ '},

#         saldo_documents=>{"value"=>"saldo_documents", script=>'mail_reports.cgi' ,"title"=>"������ ����������",desc=>"������ ����������"},

        'reports_analytic'=>{"value"=>"reports_analytic", 
                              script=>'reportsanalytic.cgi' ,
                             "title"=>"������ ���������",
                              desc=>"��������� ������ � ������� ���"},

       firm_in=>{"value"=>"firm_in",script=>'firm_input.cgi', "title"=>"���� ������� �� ������",desc=>"������ � ���������������� �������� �� ���� ����������� �������"},
       firm_in2=>{"value"=>"firm_in2",script=>'firm_input2.cgi', "title"=>"������������� ��������",desc=>"���� ����������� ������� �� ��������������� ������"},
       firm_out=>{"value"=>"firm_out",script=>'firm_output.cgi', "title"=>"������������� ��������",desc=>"����� ����������� �������"},
       rates=>{"value"=>"rates", "title"=>"�����",desc=>"����� ������",script=>'rates.cgi'},
       exchange=>{'value'=>'exchange',script=>'exc.cgi','title'=>'����� �����',desc=>"���������������� ����� �����  ����� �������"},
       report=>{'value'=>'report','title'=>'������',desc=>"������ � ���������� ���������� ������� ",script=>'reports.cgi'},
#        credit=>{"value"=>"credit", script=>'credits.cgi',"title"=>"�������",desc=>"������ � ��������� (���������,��������,��������������)"},
#        credit_perms=>{'value'=>'credit_perms',title=>"��������� ��������",desc=>"��������� ������� ������������",
#        script=>'credits_objections.cgi'},
       correct=>{"value"=>"correct",script=>'correctings.cgi', "title"=>"������",desc=>'����������� ��� ����������� ��������'},
        correct_back=>{"value"=>"correct_back", script=>'lost.cgi',"title"=>"�������� �/�",desc=>'��������� � �������� �/� �������� ������ ������'},
       class=>{"value"=>'class', "title"=>"������ ��������",desc=>"������ � ��������� �������� ��������",script=>'class.cgi'},
       settings=>{"value"=>'settings', "title"=>"���������",desc=>"������ � ������  �����������  ������ �������",
       script=>'settings.cgi'},
       transit=>{"value"=>'transit', "title"=>"�������",desc=>"������ �  ���������� ����� �������",script=>'transit.cgi'},
       joke=>{"value"=>'joke', script=>'joke.cgi',"title"=>"�����",desc=>"������ ���������  �����"},
  #     docs=>{"value"=>'docs', "title"=>"���������������",desc=>"���� ������� ����������",script=>'docs.cgi'},
  #     docs_pays=>{"value"=>'docs_pays', "title"=>"������ ����������",
  #                 desc=>"������ ������ ����������",
  #                 script=>'docs_payments.cgi'},

#        docs_fact=>{ "value"=>'docs_fact',
#                     "title"=>"���������(����)",
#                     desc=>"���������� ������� ���������",
#                     script=>'factdocs.cgi'},
      
#        plugins=>{ "value"=>'plugins',
#                    "title"=>"������",
#                    "desc"=>"�������������� ������",
#                    "script"=>'plugins.cgi'},


#        du=>{"value"=>'du', "title"=>"����(���)",desc=>"����������� �������� ",script=>'all_firms_list.cgi?resident=1'},


      };
our $EXCEL_EXPORT_PATH=$working_path.'data/excel/';

our $db_name='lirika';
our $db_user="masha";
our $db_pass="shdgfvah_Zdhghav324_f";
our $PMS_PATH="/home/bogdan/pms/pms/lib/";
our $FILE_PATH="../firm_reports/";
our $DEFAULT_CURRENCY='UAH';
# site configs #########################################
#our $defualt_host="fsb";
our $comis_aid = 1;
# bogdan:
# �������� ���� ������
our $use_secure_cookies = 0;
##using for calculating reports
###not used now

1;
