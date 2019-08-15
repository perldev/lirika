package Russian;
use strict;
use base "Exporter";  

our @EXPORT = qw(
%TRANSLATE
$test
);
our $test = 'test';
our %TRANSLATE;
#CGIBase########################################################
$TRANSLATE{"firm_not_reg"} = "Такая фирма не зарегистрирована";
$TRANSLATE{"cur_no_support"} = "Такая валюта не поддержуется";
$TRANSLATE{"bad_sum_format"} = "Неправильный формат суммы";
$TRANSLATE{"to_developer"} = "Обратитесь к разработчику ";
$TRANSLATE{"delete"} = "Удаление";
$TRANSLATE{"user_no_reg"} = "Такой пользователь   не зарегистрирован";
$TRANSLATE{"bad_dig"} = "Неправильный формат числа";
$TRANSLATE{"insert_coments"} = "Заполните поле комментариев";
$TRANSLATE{"course_no_set"} = "Курс не задан";
$TRANSLATE{"transit"} = "Транзит";
$TRANSLATE{"on"} = "на";
$TRANSLATE{"no_number_format"} = "не соответсвует формату числа";
$TRANSLATE{"less"} = "меньше";
$TRANSLATE{"not_reg_in_system"} = "не зарегистрировано в системе";
$TRANSLATE{"diff_standart"} = "слишком отличается от эталона";
$TRANSLATE{"must_be_unique"} = "должно быть уникальным";
$TRANSLATE{"must_be_lage"} = "должно быть больше";
$TRANSLATE{"not_set_proc"} = "не задали процент комиссии";
$TRANSLATE{"comm_no_empty"} = "Поле комментариев должно быть не пустым";
$TRANSLATE{"diff_terms"} = "Разные условия у записей";
$TRANSLATE{"row_no_select"} = "Вы не выбрали ни одной записи";
$TRANSLATE{"group_add"} = "Групповое добавление";
$TRANSLATE{"dont_set_add_cred_commission"} = "Нельзя задавать дополнительную и приходую комиссию";
$TRANSLATE{"card_no_select"} = "Карточка не выбрана";
$TRANSLATE{"proc_is_very_big"} = "Процент комиссии слишком большой";
$TRANSLATE{"card_bal_minus"} = "Баланс данной карточки уйдет в минус";
$TRANSLATE{"confirm_groups_add"} = "Подтверждение группового добавления";
$TRANSLATE{"s"} = "c";
$TRANSLATE{"internal error"} = "внутренняя ошибка";
$TRANSLATE{"cashe"} = "Нал";
$TRANSLATE{"cashless"} = "Безнал.";
$TRANSLATE{"auto"} = "авто";
$TRANSLATE{"field"} = "Поле";
$TRANSLATE{"client_no_set"} = "Вы не выбрали клиента";
$TRANSLATE{"input_proc"} = "Введите процент комиссии при обмене";
$TRANSLATE{"comis_lage_standart"} = "Комиссия больше эталонного значения";
$TRANSLATE{"diff_cur"} = "Валюты не совпадают";
##################################################################

1;


