insert into operators_accounts_access_view select accounts.a_id,operators.o_id from operators cross join accounts where operators.o_status!='deleted';

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `accounts_view`
 AS 
select `accounts`.`a_id` AS `a_id`,
`accounts`.`a_name` AS `a_name`,
`accounts`.`a_issubs` AS `a_issubs`,
`accounts`.`a_ts` AS `a_ts`,
`accounts`.`a_phones` AS `a_phones`,
`accounts`.`a_status` AS `a_status`,
`classes`.`c_name` AS `a_class`,
`accounts`.`a_aid` AS `a_aid`,
`accounts`.`a_uah` AS `a_uah`,
`accounts`.`a_usd` AS `a_usd`,
`accounts`.`a_eur` AS `a_eur`,
`accounts`.`a_isproject` AS `a_isproject`,
`accounts`.`a_email` AS `a_email`,
`accounts`.`a_oid` AS `a_oid`,
`accounts_cats`.`ac_id` AS `ac_id`,
`accounts_cats`.`ac_title` AS `ac_title`,
`accounts`.`a_incom_id` AS `a_incom_id`,
`accounts_num_records`.`anr_num` AS `a_records_number`,
`operators_accounts_access_view`.`oaav_aid` AS `oaav_aid`,
`operators_accounts_access_view`.`oaav_oid` AS `oaav_oid`
 from ((((`accounts` join `classes`) join `accounts_cats`) join `accounts_num_records`) join operators_accounts_access_view)
 where ((`classes`.`c_id` = `accounts`.`a_class`) and (`accounts`.`a_acid` = `accounts_cats`.`ac_id`) and (`accounts_num_records`.`anr_aid` = `accounts`.`a_id`) and (`operators_accounts_access_view`.`oaav_aid`=`accounts`.`a_id`));


CREATE TABLE IF NOT EXISTS `operators_accounts_access_view` (
  `oaav_aid` int(11) NOT NULL,
  `oaav_oid` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;
