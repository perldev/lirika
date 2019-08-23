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
    'ACCEPT'=>'разрешить',
    'DROP'=>'запретить'
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
       transfers=>{"value"=>"transfers", "title"=>"Трансферы",desc=>'Переводы денег между карточками',script=>'trans.cgi'},
        all_firms=>{"value"=>"all_firms", "title"=>"ДЕНЬ",desc=>'Работа с безналичными счетами на всех фирмах',script=>'all_firms_list.cgi'},
       firms_exchange=>{"value"=>"firms_exchange", "title"=>"Конвертация",desc=>'Конвертация безналичных средств',script=>'conv.cgi'},
       account=>{"value"=>"account", "title"=>"Карточки",desc=>'Управление карточками клиентов',script=>'accounts.cgi'},
       oper=>{"value"=>"oper", "title"=>"Операторы",desc=>"Управление операторами системы и их правами",script=>'operators.cgi'},
       trans=>{"value"=>"trans", "title"=>"Транзакции",desc=>"Просмотр и добавление атомарных переводов",script=>'oper.cgi'},
       firm=>{"value"=>"firm", "title"=>"Фирмы",desc=>"Фирмы и их сервисы",script=>'firms.cgi'},
       firm_list=>{"value"=>"firm_list","title"=>"Выписки по фирмам",desc=>"Просмотр работы со счетами фирмы",script=>'firm_trans.cgi'},  
       fservice=>{"value"=>"fservice", "title"=>"Услуги фирм",desc=>"Услуги фирм",script=>'firm_services.cgi'},
        firewall=>{"value"=>"firewall", "title"=>"Firewall",desc=>"Firewall",script=>'firewall.cgi'},
        
#cash offices        
        
       exch_kiev1=>{"value"=>"exch_kiev1",script=>'exch_kiev1.cgi', "title"=>"Обмен касса опт",desc=>'Обмен валют для киевской кассы 1'},
       exch_kiev2=>{"value"=>"exch_kiev2",script=>'exch_kiev2.cgi', "title"=>"Обмен касса розница",desc=>'Обмен валют для киевской кассы 2'},
#        exch_kiev3=>{"value"=>"exch_kiev3",script=>'exch_kiev3.cgi', "title"=>"Обмен киев 3",desc=>'Обмен валют для киевской кассы 3'},
#        exch_kiev4=>{"value"=>"exch_kiev4",script=>'exch_kiev4.cgi', "title"=>"Обмен киев 4",desc=>'Обмен валют для киевской кассы 4'},
#        exch_kiev5=>{"value"=>"exch_kiev5",script=>'exch_kiev5.cgi', "title"=>"Обмен киев 5",desc=>'Обмен валют для киевской кассы 5'},
#        exch_kiev6=>{"value"=>"exch_kiev6",script=>'exch_kiev6.cgi', "title"=>"Обмен киев 6",desc=>'Обмен валют для киевской кассы 6'},
#        exch_kiev7=>{"value"=>"exch_kiev7",script=>'exch_kiev7.cgi', "title"=>"Обмен киев 7",desc=>'Обмен валют для киевской кассы 7'},
#        exch_kiev8=>{"value"=>"exch_kiev8",script=>'exch_kiev8.cgi', "title"=>"Обмен киев 8",desc=>'Обмен валют для одесской кассы 8'},
#        exch_kiev9=>{"value"=>"exch_kiev9",script=>'exch_kiev9.cgi', "title"=>"Обмен киев 9",desc=>'Обмен валют для киевской кассы'},
#        exch_odessa=>{"value"=>"exch_odessa",script=>'exch_odessa.cgi', "title"=>"Обмен одесса :)",desc=>'Обмен валют для одесской кассы'},

#        cash_in_one_dnepr=>{"value"=>"cash_in_one_dnepr", script=>'cashier_input_one_dnepr.cgi',"title"=>"Приход кассы1 Днепр",desc=>"Ввод наличных в систему на карточки одним действием"},
#        cash_in_one_kiev=>{"value"=>"cash_in_one_kiev", script=>'cashier_input_one_kiev.cgi',"title"=>"Приход кассы1 Киев",desc=>"Ввод наличных в систему на карточки действием"},
       
       cash_in_before_kiev1=>{"value"=>"cash_in_before_kiev1",script=>'cashier_input_before_dnepr.cgi', "title"=>"Заявки на приход кассы опт",desc=>'Непосредственный ввод наличных в кассу'},
       cash_out_kiev1=>{"value"=>"cash_out_kiev1",script=>'cashier_output_dnepr.cgi' ,"title"=>"Заявки на расход опт",desc=>"Работа с заявками на  вывод наличных "},
       cash_out2_kiev1=>{"value"=>"cash_out2_kiev1",script=>'cashier_output2_dnepr.cgi', "title"=>"Расход опт",desc=>"Непосредственный ввывод наличных"},
       cash_in_kiev1=>{"value"=>"cash_out2_kiev1",script=>'cashier_input_dnepr.cgi', "title"=>"Приход кассы опт",desc=>"Ввод наличных в систему на карточки"},
       cash_kiev1=>{"value"=>"cash_kiev1", script=>'cash.cgi',"title"=>"Касса опт",desc=>'Сводная таблица кассы приходы и расходы  по дня '},

       
       cash_in_before_kiev2=>{"value"=>"cash_in_before_kiev2", "title"=>"Заявки на приход кассы розница",desc=>'Непосредственный ввод наличных в кассу',script=>'cashier_input_before_kiev.cgi'},
       cash_out_kiev2=>{"value"=>"cash_out_kiev2",script=>'cashier_output_kiev.cgi' ,"title"=>"Заявки на расход кассы розница",desc=>"Работа с заявками на  вывод наличных "},
       cash_out2_kiev2=>{"value"=>"cash_out2_kiev2",script=>'cashier_output2_kiev.cgi' , "title"=>"Расход кассы розница",desc=>"Непосредственный ввывод наличных"},
       cash_in_kiev2=>{"value"=>"cash_in_kiev2", script=>'cashier_input_kiev.cgi',"title"=>"Приход кассы розница",desc=>"Ввод наличных в систему на карточки"},
       cash_kiev2=>{"value"=>"cash_kiev2", script=>'cash_kiev.cgi',"title"=>"Касса розница",desc=>'Сводная таблица кассы приходы и расходы  по дням Киев '},
#  
#         
#       
#         cash_in_before_kiev3=>{"value"=>"cash_in_before_kiev3", "title"=>"Заявки на приход кассы киев 3",desc=>'Непосредственный ввод наличных в кассу ',script=>'cashier_input_before_atrium.cgi'},
#         cash_out_kiev3=>{"value"=>"cash_out_kiev3",script=>'cashier_output_atrium.cgi' ,"title"=>"Заявки на расход кассы киев 3",desc=>"Работа с заявками на  вывод наличных киев 3"},
#         cash_out2_kiev3=>{"value"=>"cash_out2_kiev3",script=>'cashier_output2_atrium.cgi' , "title"=>"Расход кассы киев 3",desc=>"Непосредственный ввывод наличных киев 3"},
#         cash_in_kiev3=>{"value"=>"cash_in_kiev3", script=>'cashier_input_atrium.cgi',"title"=>"Приход кассы киев 3",desc=>"Ввод наличных в систему на карточки киев 3"},
#         cash_kiev3=>{"value"=>"cash_kiev3", script=>'cash_atrium.cgi',"title"=>"Касса Киев 3",desc=>'Сводная таблица кассы приходы и расходы  по дням киев 3 '},
# 
#     
#     
#         cash_in_before_kiev4=>{"value"=>"cash_in_before_kiev4",script=>'cashier_input_before_odessa.cgi', "title"=>"Заявки на приход кассы киев 4 ",desc=>'Непосредственный ввод наличных в кассу'},
#          cash_out_kiev4=>{"value"=>"cash_out_kiev4", script=>'cashier_output_odessa.cgi',"title"=>"Заявки на расход кассы киев 4 ",desc=>"Работа с заявками на  вывод наличных "},
#          cash_out2_kiev4=>{"value"=>"cash_out2_kiev4",script=>'cashier_output2_odessa.cgi' , "title"=>"Расход кассы киев 4",desc=>"Непосредственный ввывод наличных"},
#          cash_in_kiev4=>{"value"=>"cash_in_kiev4", script=>'cashier_input_odessa.cgi' ,"title"=>"Приход кассы киев 4",desc=>"Ввод наличных в систему на карточки"},         
#          cash_kiev4=>{"value"=>"cash_kiev4", script=>'cash_odessa.cgi',"title"=>"Касса киев 4",desc=>'Сводная таблица кассы приходы и расходы  по дням  '},
# 
#         cash_in_before_kiev5=>{"value"=>"cash_in_before_kiev5", "title"=>"Заявки на приход кассы киев 5",desc=>'Непосредственный ввод наличных в кассу',script=>'cashier_input_before_kiev5.cgi'},
#         cash_out_kiev5=>{"value"=>"cash_out_kiev5",script=>'cashier_output_kiev5.cgi' ,"title"=>"Заявки на расход кассы киев 5",desc=>"Работа с заявками на  вывод наличных "},
#         cash_out2_kiev5=>{"value"=>"cash_out2_kiev5",script=>'cashier_output2_kiev5.cgi' , "title"=>"Расход кассы киев 5",desc=>"Непосредственный ввывод наличных"},
#         cash_in_kiev5=>{"value"=>"cash_in_kiev5", script=>'cashier_input_kiev5.cgi',"title"=>"Приход кассы киев 5",desc=>"Ввод наличных в систему на карточки"},
#         cash_kiev5=>{"value"=>"cash_kiev5", script=>'cash_kiev5.cgi',"title"=>"Касса Киев 5",desc=>'Сводная таблица кассы приходы и расходы  по дням Киев '},
#         
#         cash_in_before_kiev6=>{"value"=>"cash_in_before_kiev6", "title"=>"Заявки на приход кассы киев 6",desc=>'Непосредственный ввод наличных в кассу',script=>'cashier_input_before_kiev6.cgi'},
#        cash_out_kiev6=>{"value"=>"cash_out_kiev6",script=>'cashier_output_kiev6.cgi' ,"title"=>"Заявки на расход кассы киев 6",desc=>"Работа с заявками на  вывод наличных "},
#        cash_out2_kiev6=>{"value"=>"cash_out2_kiev6",script=>'cashier_output2_kiev6.cgi' , "title"=>"Расход кассы киев 6",desc=>"Непосредственный ввывод наличных"},
#        cash_in_kiev6=>{"value"=>"cash_in_kiev6", script=>'cashier_input_kiev6.cgi',"title"=>"Приход кассы киев 6",desc=>"Ввод наличных в систему на карточки"},
#        cash_kiev6=>{"value"=>"cash_kiev6", script=>'cash_kiev6.cgi',"title"=>"Касса Киев 6",desc=>'Сводная таблица кассы приходы и расходы  по дням Киев '},
# #  
# #     
# 
#        cash_in_before_kiev7=>{"value"=>"cash_in_before_kiev7", "title"=>"Заявки на приход кассы киев 7",desc=>'Непосредственный ввод наличных в кассу',script=>'cashier_input_before_kiev7.cgi'},
#        cash_out_kiev7=>{"value"=>"cash_out_kiev7",script=>'cashier_output_kiev7.cgi' ,"title"=>"Заявки на расход кассы киев 7",desc=>"Работа с заявками на  вывод наличных "},
#        cash_out2_kiev7=>{"value"=>"cash_out2_kiev7",script=>'cashier_output2_kiev7.cgi' , "title"=>"Расход кассы киев 7",desc=>"Непосредственный ввывод наличных"},
#        cash_in_kiev7=>{"value"=>"cash_in_kiev7", script=>'cashier_input_kiev7.cgi',"title"=>"Приход кассы киев 7",desc=>"Ввод наличных в систему на карточки"},
#        cash_kiev7=>{"value"=>"cash_kiev7", script=>'cash_kiev7.cgi',"title"=>"Касса Киев 7",desc=>'Сводная таблица кассы приходы и расходы  по дням Киев '},
# #  
# #     
# 
#        cash_in_before_kiev8=>{"value"=>"cash_in_before_kiev8", "title"=>"Заявки на приход кассы киев 8",desc=>'Непосредственный ввод наличных в кассу',script=>'cashier_input_before_kiev8.cgi'},
#        cash_out_kiev8=>{"value"=>"cash_out_kiev8",script=>'cashier_output_kiev8.cgi' ,"title"=>"Заявки на расход кассы киев 8",desc=>"Работа с заявками на  вывод наличных "},
#        cash_out2_kiev8=>{"value"=>"cash_out2_kiev8",script=>'cashier_output2_kiev8.cgi' , "title"=>"Расход кассы киев 8",desc=>"Непосредственный ввывод наличных"},
#        cash_in_kiev8=>{"value"=>"cash_in_kiev8", script=>'cashier_input_kiev8.cgi',"title"=>"Приход кассы киев 8",desc=>"Ввод наличных в систему на карточки"},
#        cash_kiev8=>{"value"=>"cash_kiev8", script=>'cash_kiev8.cgi',"title"=>"Касса Киев 8",desc=>'Сводная таблица кассы приходы и расходы  по дням Киев '},
#        
       
       
       cash_in_before_btc=>{"value"=>"cash_in_before_btc", "title"=>"Заявки на приход кассы киев BTC",desc=>'Непосредственный ввод BTC',script=>'cashier_input_before_btc.cgi'},
       cash_out_btc=>{"value"=>"cash_out_btc",script=>'cashier_output_btc.cgi' ,"title"=>"Заявки на расход кассы киев BTC",desc=>"Работа с заявками на  вывод BTC "},
       cash_out2_btc=>{"value"=>"cash_out2_btc",script=>'cashier_output2_btc.cgi' , "title"=>"Расход кассы киев BTC",desc=>"Непосредственный ввывод BTC"},
       cash_in_btc=>{"value"=>"cash_in_btc", script=>'cashier_input_btc.cgi',"title"=>"Приход кассы киев BTC",desc=>"Ввод BTC в систему на карточки"},
       cash_btc=>{"value"=>"cash_btc", script=>'cash_btc.cgi',"title"=>"Касса BTC",desc=>'Сводная таблица BTC приходы и расходы  по дням Киев '},
       exch_btc=>{"value"=>"exch_btc",script=>'exch_btc.cgi', "title"=>"Обмен BTC",desc=>'Обмен валют для  BTC'},

#  
       
       
#  
#     

#  
#     

         
         
         
#===end of cash offices====         
         
         
#         saldo_documents=>{"value"=>"saldo_documents", script=>'mail_reports.cgi' ,"title"=>"Сальдо документов",desc=>"Сальдо документов"},

        'reports_analytic'=>{"value"=>"reports_analytic", 
                              script=>'reportsanalytic.cgi' ,
                             "title"=>"Дельта аналитика",
                              desc=>"Изменение дельты в течение дня"},

       firm_in=>{"value"=>"firm_in",script=>'firm_input.cgi', "title"=>"Ввод отчетов по фирмам",desc=>"Работа с предварительными заявками на ввод безналичных средств"},
       firm_in2=>{"value"=>"firm_in2",script=>'firm_input2.cgi', "title"=>"Распределение приходов",desc=>"Ввод безналичных средств из предварительных заявок"},
       firm_out=>{"value"=>"firm_out",script=>'firm_output.cgi', "title"=>"Распределение расходов",desc=>"Вывод безналичных средств"},
       rates=>{"value"=>"rates", "title"=>"Курсы",desc=>"Курсы обмена",script=>'rates.cgi'},
       exchange=>{'value'=>'exchange',script=>'exc.cgi','title'=>'Обмен валют',desc=>"Непосредственный обмен валют  между счетами"},
       report=>{'value'=>'report','title'=>'Отчеты',desc=>"Работа с различными вариантами отчетов ",script=>'reports.cgi'},
#        credit=>{"value"=>"credit", script=>'credits.cgi',"title"=>"Кредиты",desc=>"Работа с кредитами (добавлени,просмотр,редактирование)"},
#        credit_perms=>{'value'=>'credit_perms',title=>"Параметры кредитов",desc=>"Настройка условий кредитования",
#        script=>'credits_objections.cgi'},
       correct=>{"value"=>"correct",script=>'correctings.cgi', "title"=>"Правки",desc=>'Исправление уже совершонных операций'},
        correct_back=>{"value"=>"correct_back", script=>'lost.cgi',"title"=>"Операции з/ч",desc=>'Занесение и удаление б/н операция задним числом'},
       class=>{"value"=>'class', "title"=>"Классы клиентов",desc=>"Работа с основными классами клиентов",script=>'class.cgi'},
        banks=>{"value"=>'banks', "title"=>"Банки",desc=>"Банки",script=>'banks.cgi'},

       settings=>{"value"=>'settings', "title"=>"Настройки",desc=>"Работа с общими  параметрами  работы системы",
       script=>'settings.cgi'},
       transit=>{"value"=>'transit', "title"=>"Транзит",desc=>"Работа с  переводами между фирмами",script=>'transit.cgi'},
       joke=>{"value"=>'joke', script=>'joke.cgi',"title"=>"Шутка",desc=>"Просто сообщения  шапке"},
  #     docs=>{"value"=>'docs', "title"=>"Документооборот",desc=>"Учет оборота документов",script=>'docs.cgi'},
  #     docs_pays=>{"value"=>'docs_pays', "title"=>"Оплата документов",
  #                 desc=>"Правки оплаты документов",   
  #                 script=>'docs_payments.cgi'},

#        docs_fact=>{ "value"=>'docs_fact',
#                     "title"=>"Документы(факт)",
#                     desc=>"Заведенные фирмами документы",
#                     script=>'factdocs.cgi'},
      
#        plugins=>{ "value"=>'plugins',
#                    "title"=>"Плагин",
#                    "desc"=>"Дополнительные плагин",
#                    "script"=>'plugins.cgi'},


#        du=>{"value"=>'du', "title"=>"ДЕНЬ(ГРН)",desc=>"Резидентные операции ",script=>'all_firms_list.cgi?resident=1'},


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
# реализуй этот булеан
our $use_secure_cookies = 0;
##using for calculating reports
###not used now

1;
