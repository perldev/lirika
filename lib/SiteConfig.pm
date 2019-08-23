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
    	{from=>'BTC',to=>'UAH',rate_form=>1},
    	{from=>'BTC',to=>'USD',rate_form=>1},
    	{from=>'BTC',to=>'EUR',rate_form=>1},
    	
    	{from=>'USD',to=>'UAH',rate_form=>1},
    	{from=>'USD',to=>'EUR',rate_form=>-1},
    	{from=>'USD',to=>'BTC',rate_form=>-1},
    	
    	{from=>'UAH',to=>'USD',rate_form=>-1},			
    	{from=>'UAH',to=>'EUR',rate_form=>-1},
    	{from=>'UAH',to=>'BTC',rate_form=>-1},
    	
    	{from=>'EUR',to=>'USD',rate_form=>1},			
    	{from=>'EUR',to=>'UAH',rate_form=>1},
    	{from=>'EUR',to=>'BTC',rate_form=>-1},
    	
	{from=>'EUR',to=>'EUR',rate_form=>1},
	{from=>'BTC',to=>'BTC',rate_form=>1},
	{from=>'UAH',to=>'UAH',rate_form=>1},
	{from=>'USD',to=>'USD',rate_form=>1},
    ); 	
    our %RATE_FORMS=(
 	USD=>{USD=>1,UAH=>-1,EUR=>-1, BTC=>-1},
	UAH=>{USD=>-1,UAH=>1,EUR=>-1, BTC=>-1},
 	EUR=>{USD=>1,UAH=>1,EUR=>1, BTC=>-1},
        BTC=>{USD=>1,UAH=>1,EUR=>1,BTC=>1},

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
       oper=>{"value"=>"oper", "title"=>"���������",desc=>"���������� ����������� ������� � �� �������",script=>'operators.cgi'},
       trans=>{"value"=>"trans", "title"=>"����������",desc=>"�������� � ���������� ��������� ���������",script=>'oper.cgi'},
       firm=>{"value"=>"firm", "title"=>"�����",desc=>"����� � �� �������",script=>'firms.cgi'},
       firm_list=>{"value"=>"firm_list","title"=>"������� �� ������",desc=>"�������� ������ �� ������� �����",script=>'firm_trans.cgi'},  
       fservice=>{"value"=>"fservice", "title"=>"������ ����",desc=>"������ ����",script=>'firm_services.cgi'},
        firewall=>{"value"=>"firewall", "title"=>"Firewall",desc=>"Firewall",script=>'firewall.cgi'},
        
#cash offices        
        
       exch_kiev1=>{"value"=>"exch_kiev1",script=>'exch_kiev1.cgi', "title"=>"����� ����� ���",desc=>'����� ����� ��� �������� ����� 1'},
       exch_kiev2=>{"value"=>"exch_kiev2",script=>'exch_kiev2.cgi', "title"=>"����� ����� �������",desc=>'����� ����� ��� �������� ����� 2'},
#        exch_kiev3=>{"value"=>"exch_kiev3",script=>'exch_kiev3.cgi', "title"=>"����� ���� 3",desc=>'����� ����� ��� �������� ����� 3'},
#        exch_kiev4=>{"value"=>"exch_kiev4",script=>'exch_kiev4.cgi', "title"=>"����� ���� 4",desc=>'����� ����� ��� �������� ����� 4'},
#        exch_kiev5=>{"value"=>"exch_kiev5",script=>'exch_kiev5.cgi', "title"=>"����� ���� 5",desc=>'����� ����� ��� �������� ����� 5'},
#        exch_kiev6=>{"value"=>"exch_kiev6",script=>'exch_kiev6.cgi', "title"=>"����� ���� 6",desc=>'����� ����� ��� �������� ����� 6'},
#        exch_kiev7=>{"value"=>"exch_kiev7",script=>'exch_kiev7.cgi', "title"=>"����� ���� 7",desc=>'����� ����� ��� �������� ����� 7'},
#        exch_kiev8=>{"value"=>"exch_kiev8",script=>'exch_kiev8.cgi', "title"=>"����� ���� 8",desc=>'����� ����� ��� �������� ����� 8'},
#        exch_kiev9=>{"value"=>"exch_kiev9",script=>'exch_kiev9.cgi', "title"=>"����� ���� 9",desc=>'����� ����� ��� �������� �����'},
#        exch_odessa=>{"value"=>"exch_odessa",script=>'exch_odessa.cgi', "title"=>"����� ������ :)",desc=>'����� ����� ��� �������� �����'},

#        cash_in_one_dnepr=>{"value"=>"cash_in_one_dnepr", script=>'cashier_input_one_dnepr.cgi',"title"=>"������ �����1 �����",desc=>"���� �������� � ������� �� �������� ����� ���������"},
#        cash_in_one_kiev=>{"value"=>"cash_in_one_kiev", script=>'cashier_input_one_kiev.cgi',"title"=>"������ �����1 ����",desc=>"���� �������� � ������� �� �������� ���������"},
       
       cash_in_before_kiev1=>{"value"=>"cash_in_before_kiev1",script=>'cashier_input_before_dnepr.cgi', "title"=>"������ �� ������ ����� ���",desc=>'���������������� ���� �������� � �����'},
       cash_out_kiev1=>{"value"=>"cash_out_kiev1",script=>'cashier_output_dnepr.cgi' ,"title"=>"������ �� ������ ���",desc=>"������ � �������� ��  ����� �������� "},
       cash_out2_kiev1=>{"value"=>"cash_out2_kiev1",script=>'cashier_output2_dnepr.cgi', "title"=>"������ ���",desc=>"���������������� ������ ��������"},
       cash_in_kiev1=>{"value"=>"cash_out2_kiev1",script=>'cashier_input_dnepr.cgi', "title"=>"������ ����� ���",desc=>"���� �������� � ������� �� ��������"},
       cash_kiev1=>{"value"=>"cash_kiev1", script=>'cash.cgi',"title"=>"����� ���",desc=>'������� ������� ����� ������� � �������  �� ��� '},

       
       cash_in_before_kiev2=>{"value"=>"cash_in_before_kiev2", "title"=>"������ �� ������ ����� �������",desc=>'���������������� ���� �������� � �����',script=>'cashier_input_before_kiev.cgi'},
       cash_out_kiev2=>{"value"=>"cash_out_kiev2",script=>'cashier_output_kiev.cgi' ,"title"=>"������ �� ������ ����� �������",desc=>"������ � �������� ��  ����� �������� "},
       cash_out2_kiev2=>{"value"=>"cash_out2_kiev2",script=>'cashier_output2_kiev.cgi' , "title"=>"������ ����� �������",desc=>"���������������� ������ ��������"},
       cash_in_kiev2=>{"value"=>"cash_in_kiev2", script=>'cashier_input_kiev.cgi',"title"=>"������ ����� �������",desc=>"���� �������� � ������� �� ��������"},
       cash_kiev2=>{"value"=>"cash_kiev2", script=>'cash_kiev.cgi',"title"=>"����� �������",desc=>'������� ������� ����� ������� � �������  �� ���� ���� '},
#  
#         
#       
#         cash_in_before_kiev3=>{"value"=>"cash_in_before_kiev3", "title"=>"������ �� ������ ����� ���� 3",desc=>'���������������� ���� �������� � ����� ',script=>'cashier_input_before_atrium.cgi'},
#         cash_out_kiev3=>{"value"=>"cash_out_kiev3",script=>'cashier_output_atrium.cgi' ,"title"=>"������ �� ������ ����� ���� 3",desc=>"������ � �������� ��  ����� �������� ���� 3"},
#         cash_out2_kiev3=>{"value"=>"cash_out2_kiev3",script=>'cashier_output2_atrium.cgi' , "title"=>"������ ����� ���� 3",desc=>"���������������� ������ �������� ���� 3"},
#         cash_in_kiev3=>{"value"=>"cash_in_kiev3", script=>'cashier_input_atrium.cgi',"title"=>"������ ����� ���� 3",desc=>"���� �������� � ������� �� �������� ���� 3"},
#         cash_kiev3=>{"value"=>"cash_kiev3", script=>'cash_atrium.cgi',"title"=>"����� ���� 3",desc=>'������� ������� ����� ������� � �������  �� ���� ���� 3 '},
# 
#     
#     
#         cash_in_before_kiev4=>{"value"=>"cash_in_before_kiev4",script=>'cashier_input_before_odessa.cgi', "title"=>"������ �� ������ ����� ���� 4 ",desc=>'���������������� ���� �������� � �����'},
#          cash_out_kiev4=>{"value"=>"cash_out_kiev4", script=>'cashier_output_odessa.cgi',"title"=>"������ �� ������ ����� ���� 4 ",desc=>"������ � �������� ��  ����� �������� "},
#          cash_out2_kiev4=>{"value"=>"cash_out2_kiev4",script=>'cashier_output2_odessa.cgi' , "title"=>"������ ����� ���� 4",desc=>"���������������� ������ ��������"},
#          cash_in_kiev4=>{"value"=>"cash_in_kiev4", script=>'cashier_input_odessa.cgi' ,"title"=>"������ ����� ���� 4",desc=>"���� �������� � ������� �� ��������"},         
#          cash_kiev4=>{"value"=>"cash_kiev4", script=>'cash_odessa.cgi',"title"=>"����� ���� 4",desc=>'������� ������� ����� ������� � �������  �� ����  '},
# 
#         cash_in_before_kiev5=>{"value"=>"cash_in_before_kiev5", "title"=>"������ �� ������ ����� ���� 5",desc=>'���������������� ���� �������� � �����',script=>'cashier_input_before_kiev5.cgi'},
#         cash_out_kiev5=>{"value"=>"cash_out_kiev5",script=>'cashier_output_kiev5.cgi' ,"title"=>"������ �� ������ ����� ���� 5",desc=>"������ � �������� ��  ����� �������� "},
#         cash_out2_kiev5=>{"value"=>"cash_out2_kiev5",script=>'cashier_output2_kiev5.cgi' , "title"=>"������ ����� ���� 5",desc=>"���������������� ������ ��������"},
#         cash_in_kiev5=>{"value"=>"cash_in_kiev5", script=>'cashier_input_kiev5.cgi',"title"=>"������ ����� ���� 5",desc=>"���� �������� � ������� �� ��������"},
#         cash_kiev5=>{"value"=>"cash_kiev5", script=>'cash_kiev5.cgi',"title"=>"����� ���� 5",desc=>'������� ������� ����� ������� � �������  �� ���� ���� '},
#         
#         cash_in_before_kiev6=>{"value"=>"cash_in_before_kiev6", "title"=>"������ �� ������ ����� ���� 6",desc=>'���������������� ���� �������� � �����',script=>'cashier_input_before_kiev6.cgi'},
#        cash_out_kiev6=>{"value"=>"cash_out_kiev6",script=>'cashier_output_kiev6.cgi' ,"title"=>"������ �� ������ ����� ���� 6",desc=>"������ � �������� ��  ����� �������� "},
#        cash_out2_kiev6=>{"value"=>"cash_out2_kiev6",script=>'cashier_output2_kiev6.cgi' , "title"=>"������ ����� ���� 6",desc=>"���������������� ������ ��������"},
#        cash_in_kiev6=>{"value"=>"cash_in_kiev6", script=>'cashier_input_kiev6.cgi',"title"=>"������ ����� ���� 6",desc=>"���� �������� � ������� �� ��������"},
#        cash_kiev6=>{"value"=>"cash_kiev6", script=>'cash_kiev6.cgi',"title"=>"����� ���� 6",desc=>'������� ������� ����� ������� � �������  �� ���� ���� '},
# #  
# #     
# 
#        cash_in_before_kiev7=>{"value"=>"cash_in_before_kiev7", "title"=>"������ �� ������ ����� ���� 7",desc=>'���������������� ���� �������� � �����',script=>'cashier_input_before_kiev7.cgi'},
#        cash_out_kiev7=>{"value"=>"cash_out_kiev7",script=>'cashier_output_kiev7.cgi' ,"title"=>"������ �� ������ ����� ���� 7",desc=>"������ � �������� ��  ����� �������� "},
#        cash_out2_kiev7=>{"value"=>"cash_out2_kiev7",script=>'cashier_output2_kiev7.cgi' , "title"=>"������ ����� ���� 7",desc=>"���������������� ������ ��������"},
#        cash_in_kiev7=>{"value"=>"cash_in_kiev7", script=>'cashier_input_kiev7.cgi',"title"=>"������ ����� ���� 7",desc=>"���� �������� � ������� �� ��������"},
#        cash_kiev7=>{"value"=>"cash_kiev7", script=>'cash_kiev7.cgi',"title"=>"����� ���� 7",desc=>'������� ������� ����� ������� � �������  �� ���� ���� '},
# #  
# #     
# 
#        cash_in_before_kiev8=>{"value"=>"cash_in_before_kiev8", "title"=>"������ �� ������ ����� ���� 8",desc=>'���������������� ���� �������� � �����',script=>'cashier_input_before_kiev8.cgi'},
#        cash_out_kiev8=>{"value"=>"cash_out_kiev8",script=>'cashier_output_kiev8.cgi' ,"title"=>"������ �� ������ ����� ���� 8",desc=>"������ � �������� ��  ����� �������� "},
#        cash_out2_kiev8=>{"value"=>"cash_out2_kiev8",script=>'cashier_output2_kiev8.cgi' , "title"=>"������ ����� ���� 8",desc=>"���������������� ������ ��������"},
#        cash_in_kiev8=>{"value"=>"cash_in_kiev8", script=>'cashier_input_kiev8.cgi',"title"=>"������ ����� ���� 8",desc=>"���� �������� � ������� �� ��������"},
#        cash_kiev8=>{"value"=>"cash_kiev8", script=>'cash_kiev8.cgi',"title"=>"����� ���� 8",desc=>'������� ������� ����� ������� � �������  �� ���� ���� '},
#        
       
       
       cash_in_before_btc=>{"value"=>"cash_in_before_btc", "title"=>"������ �� ������ ����� ���� BTC",desc=>'���������������� ���� BTC',script=>'cashier_input_before_btc.cgi'},
       cash_out_btc=>{"value"=>"cash_out_btc",script=>'cashier_output_btc.cgi' ,"title"=>"������ �� ������ ����� ���� BTC",desc=>"������ � �������� ��  ����� BTC "},
       cash_out2_btc=>{"value"=>"cash_out2_btc",script=>'cashier_output2_btc.cgi' , "title"=>"������ ����� ���� BTC",desc=>"���������������� ������ BTC"},
       cash_in_btc=>{"value"=>"cash_in_btc", script=>'cashier_input_btc.cgi',"title"=>"������ ����� ���� BTC",desc=>"���� BTC � ������� �� ��������"},
       cash_btc=>{"value"=>"cash_btc", script=>'cash_btc.cgi',"title"=>"����� BTC",desc=>'������� ������� BTC ������� � �������  �� ���� ���� '},
       exch_btc=>{"value"=>"exch_btc",script=>'exch_btc.cgi', "title"=>"����� BTC",desc=>'����� ����� ���  BTC'},

#  
       
       
#  
#     

#  
#     

         
         
         
#===end of cash offices====         
         
         
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
        banks=>{"value"=>'banks', "title"=>"�����",desc=>"�����",script=>'banks.cgi'},

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
