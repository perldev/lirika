-- MySQL dump 10.13  Distrib 5.7.25, for Linux (x86_64)
--
-- Host: localhost    Database: lirika
-- ------------------------------------------------------
-- Server version	5.7.25-0ubuntu0.16.04.2

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `account_balance_logs`
--

DROP TABLE IF EXISTS `account_balance_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `account_balance_logs` (
  `abl_id` int(11) NOT NULL AUTO_INCREMENT,
  `abl_ts` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `abl_aid` int(11) NOT NULL DEFAULT '0',
  `abl_uah` double(12,2) NOT NULL DEFAULT '0.00',
  `abl_usd` double(12,2) NOT NULL DEFAULT '0.00',
  `abl_eur` double(12,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`abl_id`),
  KEY `abl_ts` (`abl_ts`),
  KEY `abl_aid` (`abl_aid`)
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COLLATE=cp1251_ukrainian_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `account_balance_logs`
--

LOCK TABLES `account_balance_logs` WRITE;
/*!40000 ALTER TABLE `account_balance_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `account_balance_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accounts`
--

DROP TABLE IF EXISTS `accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts` (
  `a_id` int(11) NOT NULL AUTO_INCREMENT,
  `a_name` varchar(255) COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT '',
  `a_ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `a_phones` varchar(255) COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT '',
  `a_class` int(11) NOT NULL DEFAULT '0',
  `a_status` enum('active','blocked','deleted') COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT 'active',
  `a_aid` int(11) DEFAULT NULL,
  `a_uah` double(12,2) NOT NULL DEFAULT '0.00',
  `a_usd` double(12,2) NOT NULL DEFAULT '0.00',
  `a_eur` double(12,2) NOT NULL DEFAULT '0.00',
  `a_isproject` enum('yes','no') COLLATE cp1251_ukrainian_ci DEFAULT 'no',
  `a_email` varchar(255) COLLATE cp1251_ukrainian_ci DEFAULT '',
  `a_issubs` enum('yes','no') COLLATE cp1251_ukrainian_ci DEFAULT 'yes',
  `a_report_passwd` varchar(255) COLLATE cp1251_ukrainian_ci NOT NULL,
  `a_oid` int(11) DEFAULT NULL,
  `a_acid` int(11) DEFAULT NULL,
  `a_aid_parent` int(11) DEFAULT NULL,
  `a_mirror` int(11) DEFAULT NULL,
  `a_incom_id` int(11) DEFAULT NULL,
  `a_usd_eq` double(12,2) DEFAULT NULL,
  `a_hour_report` tinyint(4) DEFAULT '0',
  `a_is_debt` enum('yes','no') COLLATE cp1251_ukrainian_ci DEFAULT 'no',
  `a_menu` enum('grid','line') COLLATE cp1251_ukrainian_ci DEFAULT 'line',
  `a_pid` int(11) DEFAULT NULL,
  `a_btc` double(12,6) DEFAULT '0.000000',
  PRIMARY KEY (`a_id`),
  KEY `a_name` (`a_name`),
  KEY `a_ts` (`a_ts`),
  KEY `a_phones` (`a_phones`),
  KEY `a_class` (`a_class`),
  KEY `a_status` (`a_status`),
  KEY `a_uah` (`a_uah`),
  KEY `a_usd` (`a_usd`),
  KEY `a_eur` (`a_eur`),
  KEY `incom_index` (`a_incom_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=cp1251 COLLATE=cp1251_ukrainian_ci
/*!50100 PARTITION BY RANGE (a_id)
(PARTITION p1 VALUES LESS THAN (1000) ENGINE = InnoDB,
 PARTITION p2 VALUES LESS THAN (2000) ENGINE = InnoDB,
 PARTITION p3 VALUES LESS THAN (3000) ENGINE = InnoDB,
 PARTITION p4 VALUES LESS THAN (4000) ENGINE = InnoDB,
 PARTITION p5 VALUES LESS THAN (5000) ENGINE = InnoDB,
 PARTITION p6 VALUES LESS THAN (7000) ENGINE = InnoDB,
 PARTITION p7 VALUES LESS THAN (8000) ENGINE = InnoDB,
 PARTITION p8 VALUES LESS THAN (9000) ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts`
--

LOCK TABLES `accounts` WRITE;
/*!40000 ALTER TABLE `accounts` DISABLE KEYS */;
INSERT INTO `accounts` VALUES (-5,'Exchange','2019-08-14 14:34:33','карта обмена',24,'active',NULL,-80.00,0.00,0.00,'no','','no','te',67,NULL,NULL,NULL,NULL,NULL,0,'yes','line',NULL,0.000000),(-4,'Firms','2019-08-14 16:23:33','',24,'active',NULL,-1001.00,-2013.00,0.00,'no','','yes','123',67,NULL,NULL,NULL,NULL,NULL,0,'yes','line',NULL,0.000000),(-3,'Svoy','2019-08-14 16:23:42','',24,'active',NULL,0.00,0.00,0.00,'no','','yes','123',67,NULL,NULL,NULL,NULL,NULL,0,'yes','line',NULL,0.000000),(-1,'Касса','2011-07-23 12:23:58','Основная касса',23,'active',NULL,-1881.21,0.00,0.00,'no','perldev@mail.ru','yes','123',67,NULL,NULL,NULL,NULL,NULL,2,'yes','line',NULL,0.000000),(1,'комиссионный','2011-07-23 12:02:27','для тестов',23,'active',NULL,1.20,0.00,0.00,'no','perldev@mail.ru','yes','123',67,NULL,NULL,NULL,NULL,NULL,0,'yes','line',NULL,0.000000),(3,'Новая карта','2011-07-24 09:38:33','',23,'active',NULL,2961.01,2013.00,0.00,'no','perldev@mail.ru','yes','123',67,NULL,NULL,NULL,NULL,NULL,2,'yes','line',NULL,0.000000);
/*!40000 ALTER TABLE `accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accounts_42`
--

DROP TABLE IF EXISTS `accounts_42`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts_42` (
  `a_id` int(11) NOT NULL,
  `a_name` varchar(255) DEFAULT NULL,
  `a_uah` double(12,2) DEFAULT NULL,
  `a_usd` double(12,2) DEFAULT NULL,
  `a_eur` double(12,2) DEFAULT NULL,
  PRIMARY KEY (`a_id`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts_42`
--

LOCK TABLES `accounts_42` WRITE;
/*!40000 ALTER TABLE `accounts_42` DISABLE KEYS */;
/*!40000 ALTER TABLE `accounts_42` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accounts_cats`
--

DROP TABLE IF EXISTS `accounts_cats`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts_cats` (
  `ac_id` int(11) NOT NULL AUTO_INCREMENT,
  `ac_title` varchar(255) DEFAULT NULL,
  `ac_acid` int(11) DEFAULT NULL,
  PRIMARY KEY (`ac_id`)
) ENGINE=MyISAM AUTO_INCREMENT=18 DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts_cats`
--

LOCK TABLES `accounts_cats` WRITE;
/*!40000 ALTER TABLE `accounts_cats` DISABLE KEYS */;
/*!40000 ALTER TABLE `accounts_cats` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accounts_history`
--

DROP TABLE IF EXISTS `accounts_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts_history` (
  `ah_id` int(11) NOT NULL AUTO_INCREMENT,
  `ah_aid` int(11) NOT NULL,
  `ah_ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ah_uah` double(12,2) DEFAULT '0.00',
  `ah_usd` double(12,2) DEFAULT '0.00',
  `ah_eur` double(12,2) DEFAULT '0.00',
  `ah_oid` int(11) DEFAULT NULL,
  `ah_acid` int(11) DEFAULT NULL,
  `ah_status` enum('created','processing','processed','deleted') COLLATE cp1251_ukrainian_ci DEFAULT 'created',
  PRIMARY KEY (`ah_id`)
) ENGINE=MyISAM AUTO_INCREMENT=599 DEFAULT CHARSET=cp1251 COLLATE=cp1251_ukrainian_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts_history`
--

LOCK TABLES `accounts_history` WRITE;
/*!40000 ALTER TABLE `accounts_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `accounts_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accounts_num_records`
--

DROP TABLE IF EXISTS `accounts_num_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts_num_records` (
  `anr_aid` int(11) NOT NULL,
  `anr_num` int(11) DEFAULT '0',
  PRIMARY KEY (`anr_aid`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251 COLLATE=cp1251_ukrainian_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts_num_records`
--

LOCK TABLES `accounts_num_records` WRITE;
/*!40000 ALTER TABLE `accounts_num_records` DISABLE KEYS */;
INSERT INTO `accounts_num_records` VALUES (1,0),(2,1),(3,20),(4,0),(5,0),(6,0);
/*!40000 ALTER TABLE `accounts_num_records` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accounts_old`
--

DROP TABLE IF EXISTS `accounts_old`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts_old` (
  `a_id` int(11) NOT NULL AUTO_INCREMENT,
  `a_name` varchar(255) COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT '',
  `a_ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `a_phones` varchar(255) COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT '',
  `a_class` int(11) NOT NULL DEFAULT '0',
  `a_status` enum('active','blocked','deleted') COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT 'active',
  `a_aid` int(11) DEFAULT NULL,
  `a_uah` double(12,2) NOT NULL DEFAULT '0.00',
  `a_usd` double(12,2) NOT NULL DEFAULT '0.00',
  `a_eur` double(12,2) NOT NULL DEFAULT '0.00',
  `a_isproject` enum('yes','no') COLLATE cp1251_ukrainian_ci DEFAULT 'no',
  `a_email` varchar(255) COLLATE cp1251_ukrainian_ci DEFAULT '',
  `a_issubs` enum('yes','no') COLLATE cp1251_ukrainian_ci DEFAULT 'yes',
  `a_report_passwd` varchar(255) COLLATE cp1251_ukrainian_ci NOT NULL,
  `a_oid` int(11) DEFAULT NULL,
  `a_acid` int(11) DEFAULT NULL,
  `a_aid_parent` int(11) DEFAULT NULL,
  `a_mirror` int(11) DEFAULT NULL,
  `a_incom_id` int(11) DEFAULT NULL,
  `a_usd_eq` double(12,2) DEFAULT NULL,
  `a_hour_report` tinyint(4) DEFAULT '0',
  `a_is_debt` enum('yes','no') COLLATE cp1251_ukrainian_ci DEFAULT 'no',
  `a_menu` enum('grid','line') COLLATE cp1251_ukrainian_ci DEFAULT 'line',
  PRIMARY KEY (`a_id`),
  KEY `a_name` (`a_name`),
  KEY `a_ts` (`a_ts`),
  KEY `a_phones` (`a_phones`),
  KEY `a_class` (`a_class`),
  KEY `a_status` (`a_status`),
  KEY `a_uah` (`a_uah`),
  KEY `a_usd` (`a_usd`),
  KEY `a_eur` (`a_eur`),
  KEY `incom_index` (`a_incom_id`)
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COLLATE=cp1251_ukrainian_ci
/*!50100 PARTITION BY RANGE (a_id)
(PARTITION p1 VALUES LESS THAN (1000) ENGINE = InnoDB,
 PARTITION p2 VALUES LESS THAN (2000) ENGINE = InnoDB,
 PARTITION p3 VALUES LESS THAN (3000) ENGINE = InnoDB,
 PARTITION p4 VALUES LESS THAN (4000) ENGINE = InnoDB,
 PARTITION p5 VALUES LESS THAN (5000) ENGINE = InnoDB,
 PARTITION p6 VALUES LESS THAN (7000) ENGINE = InnoDB,
 PARTITION p7 VALUES LESS THAN (8000) ENGINE = InnoDB,
 PARTITION p8 VALUES LESS THAN (9000) ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts_old`
--

LOCK TABLES `accounts_old` WRITE;
/*!40000 ALTER TABLE `accounts_old` DISABLE KEYS */;
/*!40000 ALTER TABLE `accounts_old` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accounts_parts`
--

DROP TABLE IF EXISTS `accounts_parts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts_parts` (
  `a_id` int(11) NOT NULL AUTO_INCREMENT,
  `a_name` varchar(255) COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT '',
  `a_ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `a_phones` varchar(255) COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT '',
  `a_class` int(11) NOT NULL DEFAULT '0',
  `a_status` enum('active','blocked','deleted') COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT 'active',
  `a_aid` int(11) DEFAULT NULL,
  `a_uah` double(12,2) NOT NULL DEFAULT '0.00',
  `a_usd` double(12,2) NOT NULL DEFAULT '0.00',
  `a_eur` double(12,2) NOT NULL DEFAULT '0.00',
  `a_isproject` enum('yes','no') COLLATE cp1251_ukrainian_ci DEFAULT 'no',
  `a_email` varchar(255) COLLATE cp1251_ukrainian_ci DEFAULT '',
  `a_issubs` enum('yes','no') COLLATE cp1251_ukrainian_ci DEFAULT 'yes',
  `a_report_passwd` varchar(255) COLLATE cp1251_ukrainian_ci NOT NULL,
  `a_oid` int(11) DEFAULT NULL,
  `a_acid` int(11) DEFAULT NULL,
  `a_aid_parent` int(11) DEFAULT NULL,
  `a_mirror` int(11) DEFAULT NULL,
  `a_incom_id` int(11) DEFAULT NULL,
  `a_usd_eq` double(12,2) DEFAULT NULL,
  `a_hour_report` tinyint(4) DEFAULT '0',
  `a_is_debt` enum('yes','no') COLLATE cp1251_ukrainian_ci DEFAULT 'no',
  `a_menu` enum('grid','line') COLLATE cp1251_ukrainian_ci DEFAULT 'line',
  PRIMARY KEY (`a_id`),
  KEY `a_name` (`a_name`),
  KEY `a_ts` (`a_ts`),
  KEY `a_phones` (`a_phones`),
  KEY `a_class` (`a_class`),
  KEY `a_status` (`a_status`),
  KEY `a_uah` (`a_uah`),
  KEY `a_usd` (`a_usd`),
  KEY `a_eur` (`a_eur`),
  KEY `incom_index` (`a_incom_id`)
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COLLATE=cp1251_ukrainian_ci
/*!50100 PARTITION BY RANGE (a_id)
(PARTITION p1 VALUES LESS THAN (1000) ENGINE = InnoDB,
 PARTITION p2 VALUES LESS THAN (2000) ENGINE = InnoDB,
 PARTITION p3 VALUES LESS THAN (3000) ENGINE = InnoDB,
 PARTITION p4 VALUES LESS THAN (4000) ENGINE = InnoDB,
 PARTITION p5 VALUES LESS THAN (5000) ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts_parts`
--

LOCK TABLES `accounts_parts` WRITE;
/*!40000 ALTER TABLE `accounts_parts` DISABLE KEYS */;
/*!40000 ALTER TABLE `accounts_parts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accounts_reports_in_comment`
--

DROP TABLE IF EXISTS `accounts_reports_in_comment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts_reports_in_comment` (
  `aric_id` int(11) NOT NULL AUTO_INCREMENT,
  `aric_aid` int(11) NOT NULL,
  `aric_date` date NOT NULL,
  `aric_comment` varchar(255) DEFAULT NULL,
  `aric_oid` int(11) DEFAULT NULL,
  PRIMARY KEY (`aric_id`),
  UNIQUE KEY `income_comments` (`aric_aid`,`aric_date`)
) ENGINE=MyISAM AUTO_INCREMENT=8 DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts_reports_in_comment`
--

LOCK TABLES `accounts_reports_in_comment` WRITE;
/*!40000 ALTER TABLE `accounts_reports_in_comment` DISABLE KEYS */;
/*!40000 ALTER TABLE `accounts_reports_in_comment` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accounts_reports_table`
--

DROP TABLE IF EXISTS `accounts_reports_table`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts_reports_table` (
  `ct_id` int(11) DEFAULT NULL,
  `ct_aid` int(11) DEFAULT NULL,
  `ct_comment` varchar(255) DEFAULT NULL,
  `ct_oid` int(11) DEFAULT NULL,
  `o_login` varchar(255) DEFAULT NULL,
  `ct_fid` int(11) DEFAULT NULL,
  `f_name` varchar(255) DEFAULT NULL,
  `ct_amnt` double DEFAULT NULL,
  `ct_currency` varchar(3) DEFAULT NULL,
  `comission` double DEFAULT NULL,
  `result_amnt` double DEFAULT NULL,
  `ct_comis_percent` float(7,2) DEFAULT NULL,
  `ct_ext_commission` double DEFAULT NULL,
  `ct_date` date DEFAULT NULL,
  `e_currency2` varchar(3) DEFAULT NULL,
  `rate` double(9,8) DEFAULT NULL,
  `ct_eid` int(11) DEFAULT NULL,
  `ct_ex_comis_type` varchar(11) DEFAULT NULL,
  `ts` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `col_ts` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `ct_status` varchar(10) DEFAULT NULL,
  `col_color` int(11) DEFAULT NULL,
  `col_status` enum('yes','no') DEFAULT 'no',
  `is_archive_status` enum('yes','no') DEFAULT 'no',
  KEY `account` (`ct_aid`),
  KEY `accounts_reports_table_index` (`ct_id`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts_reports_table`
--

LOCK TABLES `accounts_reports_table` WRITE;
/*!40000 ALTER TABLE `accounts_reports_table` DISABLE KEYS */;
INSERT INTO `accounts_reports_table` VALUES (1,3,'Ввод наличных',69,'maria',-1,'kassa',2000,'UAH',0,2000,0.00,NULL,'2019-08-14',NULL,NULL,NULL,'input','2019-08-14 14:55:25','0000-00-00 00:00:00','processed',16777215,'no','no'),(72436,3,'нал. обмен  на , базовый курс не задан',69,'maria',-2,'exchange',1000,'UAH',0,40,0.00,0,'2019-08-14','USD',0.04000000,72436,'simple','2019-08-13 21:00:00','0000-00-00 00:00:00','deleted',16777215,'no','no'),(2,3,' Ввод безналом',69,'maria',257,'Тестовая фирма',1000,'UAH',0,1000,0.00,0,'2019-08-14',NULL,NULL,NULL,'input','2019-08-13 21:00:00','0000-00-00 00:00:00','processed',16777215,'','no'),(3,3,' Ввод безналом',69,'maria',257,'Тестовая фирма',1001,'UAH',0,1001,0.00,0,'2019-08-14',NULL,NULL,NULL,'input','2019-08-13 21:00:00','0000-00-00 00:00:00','processed',16777215,'','no'),(4,3,' Ввод безналом',69,'maria',257,'Тестовая фирма',-1000,'UAH',0,-1000,0.00,0,'2019-08-14',NULL,NULL,NULL,'input','2019-08-13 21:00:00','0000-00-00 00:00:00','processed',16777215,'no','no'),(5,3,' Ввод безналом',69,'maria',257,'Тестовая фирма',1000,'USD',0,1000,0.00,0,'2019-08-15',NULL,NULL,NULL,'input','2019-08-14 21:00:00','0000-00-00 00:00:00','processed',16777215,'','no'),(6,3,' Ввод безналом',69,'maria',257,'Тестовая фирма',1000,'USD',0,1000,0.00,0,'2019-08-15',NULL,NULL,NULL,'input','2019-08-14 21:00:00','0000-00-00 00:00:00','processed',16777215,'','no'),(7,3,' Ввод безналом',69,'maria',257,'Тестовая фирма',13,'USD',0,13,0.00,0,'2019-08-15',NULL,NULL,NULL,'input','2019-08-14 21:00:00','0000-00-00 00:00:00','processed',16777215,'','no'),(72437,3,'нал. обмен  на , базовый курс не задан',67,'mysterio',-2,'exchange',1000,'UAH',0,40,0.00,0,'2019-08-15','USD',0.04000000,72437,'simple','2019-08-14 21:00:00','0000-00-00 00:00:00','deleted',16777215,'no','no'),(11,3,'Вывод наличными',67,'mysterio',-1,'kassa',-118.7878787879,'UAH',-1.19987756351414,-119.98775635141413,1.00,NULL,'2019-08-15',NULL,NULL,NULL,'input','2019-08-15 13:56:59','0000-00-00 00:00:00','processed',16777215,'no','no'),(72438,3,'Откат обмена  #72437',69,'maria',-2,'exchange',40,'USD',0,1000,0.00,0,'2019-08-15','UAH',25.00000000,72438,'simple','2019-08-15 15:29:55','0000-00-00 00:00:00','deleted',16777215,'no','no'),(72439,3,'Откат обмена  #72436',69,'maria',-2,'exchange',40,'USD',0,1000,0.00,0,'2019-08-15','UAH',25.00000000,72439,'simple','2019-08-15 15:35:31','0000-00-00 00:00:00','deleted',16777215,'no','no'),(72440,3,'нал. обмен  на , базовый курс не задан',67,'mysterio',-2,'exchange',1000,'UAH',0,40,0.00,0,'2019-08-15','USD',0.04000000,72440,'simple','2019-08-14 21:00:00','0000-00-00 00:00:00','processed',16777215,'no','no'),(72441,3,'нал. обмен  на , базовый курс не задан',67,'mysterio',-2,'exchange',40,'USD',0,1080,0.00,0,'2019-08-15','UAH',27.00000000,72441,'simple','2019-08-14 21:00:00','0000-00-00 00:00:00','processed',16777215,'no','no');
/*!40000 ALTER TABLE `accounts_reports_table` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 trigger archiving_identifier after insert on  accounts_reports_table for each row
begin 
 update accounts_num_records SET anr_num=anr_num+1 WHERE anr_aid=NEW.ct_aid;
end */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `accounts_reports_table_archive`
--

DROP TABLE IF EXISTS `accounts_reports_table_archive`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts_reports_table_archive` (
  `ct_id` int(11) DEFAULT NULL,
  `ct_aid` int(11) NOT NULL,
  `ct_comment` varchar(255) DEFAULT NULL,
  `ct_oid` int(11) DEFAULT NULL,
  `o_login` varchar(255) DEFAULT NULL,
  `ct_fid` int(11) DEFAULT NULL,
  `f_name` varchar(255) DEFAULT NULL,
  `ct_amnt` double DEFAULT NULL,
  `ct_currency` varchar(3) DEFAULT NULL,
  `comission` double DEFAULT NULL,
  `result_amnt` double DEFAULT NULL,
  `ct_comis_percent` float(7,2) DEFAULT NULL,
  `ct_ext_commission` double DEFAULT NULL,
  `ct_date` date DEFAULT NULL,
  `e_currency2` varchar(3) DEFAULT NULL,
  `rate` double(9,8) DEFAULT NULL,
  `ct_eid` int(11) DEFAULT NULL,
  `ct_ex_comis_type` varchar(11) DEFAULT NULL,
  `ts` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `col_ts` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `ct_status` varchar(10) DEFAULT NULL,
  `col_color` int(11) DEFAULT NULL,
  `col_status` enum('yes','no') DEFAULT 'no',
  `ah_id` int(11) NOT NULL,
  `is_archive_status` enum('yes','no') DEFAULT 'no',
  KEY `accounts_reports_table` (`ct_id`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts_reports_table_archive`
--

LOCK TABLES `accounts_reports_table_archive` WRITE;
/*!40000 ALTER TABLE `accounts_reports_table_archive` DISABLE KEYS */;
/*!40000 ALTER TABLE `accounts_reports_table_archive` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `accounts_reports_table_master`
--

DROP TABLE IF EXISTS `accounts_reports_table_master`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts_reports_table_master` (
  `ct_id` int(11) DEFAULT NULL,
  `ct_aid` int(11) DEFAULT NULL,
  `ct_comment` varchar(255) DEFAULT NULL,
  `ct_oid` int(11) DEFAULT NULL,
  `o_login` varchar(255) DEFAULT NULL,
  `ct_fid` int(11) DEFAULT NULL,
  `f_name` varchar(255) DEFAULT NULL,
  `ct_amnt` double DEFAULT NULL,
  `ct_currency` varchar(3) DEFAULT NULL,
  `comission` double DEFAULT NULL,
  `result_amnt` double DEFAULT NULL,
  `ct_comis_percent` float(7,2) DEFAULT NULL,
  `ct_ext_commission` double DEFAULT NULL,
  `ct_date` date DEFAULT NULL,
  `e_currency2` varchar(3) DEFAULT NULL,
  `rate` double(9,8) DEFAULT NULL,
  `ct_eid` int(11) DEFAULT NULL,
  `ct_ex_comis_type` varchar(11) DEFAULT NULL,
  `ts` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `col_ts` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `ct_status` varchar(10) DEFAULT NULL,
  `col_color` int(11) DEFAULT NULL,
  `col_status` enum('yes','no') DEFAULT 'no',
  `is_archive_status` enum('yes','no') DEFAULT 'no',
  KEY `account` (`ct_aid`),
  KEY `accounts_reports_table_index` (`ct_id`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts_reports_table_master`
--

LOCK TABLES `accounts_reports_table_master` WRITE;
/*!40000 ALTER TABLE `accounts_reports_table_master` DISABLE KEYS */;
/*!40000 ALTER TABLE `accounts_reports_table_master` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `accounts_reports_table_union`
--

DROP TABLE IF EXISTS `accounts_reports_table_union`;
/*!50001 DROP VIEW IF EXISTS `accounts_reports_table_union`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `accounts_reports_table_union` AS SELECT 
 1 AS `ct_id`,
 1 AS `ct_aid`,
 1 AS `ct_comment`,
 1 AS `ct_oid`,
 1 AS `o_login`,
 1 AS `ct_fid`,
 1 AS `f_name`,
 1 AS `ct_amnt`,
 1 AS `ct_currency`,
 1 AS `comission`,
 1 AS `result_amnt`,
 1 AS `ct_comis_percent`,
 1 AS `ct_ext_commission`,
 1 AS `ct_date`,
 1 AS `e_currency2`,
 1 AS `rate`,
 1 AS `ct_eid`,
 1 AS `ct_ex_comis_type`,
 1 AS `ts`,
 1 AS `col_status`,
 1 AS `col_ts`,
 1 AS `ct_status`,
 1 AS `col_color`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `accounts_transfers`
--

DROP TABLE IF EXISTS `accounts_transfers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accounts_transfers` (
  `at_id` int(11) NOT NULL AUTO_INCREMENT,
  `at_tid` int(11) NOT NULL,
  `at_tid_back` int(11) DEFAULT NULL,
  `at_status` enum('deleted','processed') DEFAULT 'processed',
  PRIMARY KEY (`at_id`)
) ENGINE=MyISAM AUTO_INCREMENT=31406 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `accounts_transfers`
--

LOCK TABLES `accounts_transfers` WRITE;
/*!40000 ALTER TABLE `accounts_transfers` DISABLE KEYS */;
/*!40000 ALTER TABLE `accounts_transfers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `accounts_view`
--

DROP TABLE IF EXISTS `accounts_view`;
/*!50001 DROP VIEW IF EXISTS `accounts_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `accounts_view` AS SELECT 
 1 AS `a_id`,
 1 AS `a_name`,
 1 AS `a_issubs`,
 1 AS `a_ts`,
 1 AS `a_phones`,
 1 AS `a_status`,
 1 AS `a_class`,
 1 AS `a_aid`,
 1 AS `a_uah`,
 1 AS `a_usd`,
 1 AS `a_eur`,
 1 AS `a_isproject`,
 1 AS `a_email`,
 1 AS `a_oid`,
 1 AS `a_incom_id`,
 1 AS `a_records_number`,
 1 AS `oaav_aid`,
 1 AS `oaav_oid`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `back`
--

DROP TABLE IF EXISTS `back`;
/*!50001 DROP VIEW IF EXISTS `back`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `back` AS SELECT 
 1 AS `ct_id`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `cash_atrium`
--

DROP TABLE IF EXISTS `cash_atrium`;
/*!50001 DROP VIEW IF EXISTS `cash_atrium`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `cash_atrium` AS SELECT 
 1 AS `ct_amnt`,
 1 AS `ct_date`,
 1 AS `ct_currency`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `cash_dnepr`
--

DROP TABLE IF EXISTS `cash_dnepr`;
/*!50001 DROP VIEW IF EXISTS `cash_dnepr`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `cash_dnepr` AS SELECT 
 1 AS `ct_amnt`,
 1 AS `ct_date`,
 1 AS `ct_currency`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `cash_kiev`
--

DROP TABLE IF EXISTS `cash_kiev`;
/*!50001 DROP VIEW IF EXISTS `cash_kiev`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `cash_kiev` AS SELECT 
 1 AS `ct_amnt`,
 1 AS `ct_date`,
 1 AS `ct_currency`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `cash_odessa`
--

DROP TABLE IF EXISTS `cash_odessa`;
/*!50001 DROP VIEW IF EXISTS `cash_odessa`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `cash_odessa` AS SELECT 
 1 AS `ct_amnt`,
 1 AS `ct_date`,
 1 AS `ct_currency`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `cash_offices`
--

DROP TABLE IF EXISTS `cash_offices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cash_offices` (
  `co_id` int(11) NOT NULL AUTO_INCREMENT,
  `co_name` varchar(32) COLLATE cp1251_ukrainian_ci NOT NULL,
  `co_aid` int(11) NOT NULL,
  `co_title` varchar(30) CHARACTER SET cp1251 DEFAULT NULL,
  `co_script_ex` varchar(10) COLLATE cp1251_ukrainian_ci DEFAULT NULL,
  PRIMARY KEY (`co_id`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=cp1251 COLLATE=cp1251_ukrainian_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cash_offices`
--

LOCK TABLES `cash_offices` WRITE;
/*!40000 ALTER TABLE `cash_offices` DISABLE KEYS */;
INSERT INTO `cash_offices` VALUES (6,'dnepr',-1,'Касса','dnepr');
/*!40000 ALTER TABLE `cash_offices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cashier_out_block`
--

DROP TABLE IF EXISTS `cashier_out_block`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cashier_out_block` (
  `cob_id` int(11) NOT NULL AUTO_INCREMENT,
  `cob_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cob_block` enum('yes','deleted') DEFAULT NULL,
  `cob_coid` int(11) NOT NULL,
  PRIMARY KEY (`cob_id`)
) ENGINE=MyISAM AUTO_INCREMENT=108 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cashier_out_block`
--

LOCK TABLES `cashier_out_block` WRITE;
/*!40000 ALTER TABLE `cashier_out_block` DISABLE KEYS */;
/*!40000 ALTER TABLE `cashier_out_block` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cashier_transactions`
--

DROP TABLE IF EXISTS `cashier_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `cashier_transactions` (
  `ct_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `ct_ts` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `ct_aid` int(11) DEFAULT NULL,
  `ct_amnt` double(20,10) DEFAULT NULL,
  `ct_currency` enum('UAH','USD','EUR') COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT 'UAH',
  `ct_comment` varchar(255) COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT '',
  `ct_oid` int(11) unsigned NOT NULL DEFAULT '0',
  `ct_tid` int(11) DEFAULT NULL,
  `ct_ts2` datetime DEFAULT NULL,
  `ct_oid2` int(11) DEFAULT NULL,
  `ct_status` enum('processing','transit','returned','processed','canceled','deleted','created') COLLATE cp1251_ukrainian_ci DEFAULT 'created',
  `ct_tid2` int(11) DEFAULT NULL,
  `ct_date` date DEFAULT NULL,
  `ct_fid` int(11) NOT NULL DEFAULT '-1',
  `ct_fsid` int(11) DEFAULT NULL,
  `ct_tid2_comis` int(11) DEFAULT NULL,
  `ct_ext_commission` float(7,2) DEFAULT NULL,
  `ct_tid2_ext_com` int(11) DEFAULT NULL,
  `ct_eid` int(11) DEFAULT NULL,
  `ct_comis_percent` float(7,2) NOT NULL,
  `ct_ex_comis_type` enum('in_rate','input') COLLATE cp1251_ukrainian_ci DEFAULT 'input',
  `ct_infl` enum('yes','no') COLLATE cp1251_ukrainian_ci DEFAULT 'no',
  `ct_req` enum('yes','no') COLLATE cp1251_ukrainian_ci DEFAULT 'no',
  `col_status` enum('yes','no') COLLATE cp1251_ukrainian_ci DEFAULT 'no',
  `col_ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `col_color` int(11) DEFAULT '16777215',
  `col_oid` int(11) DEFAULT NULL,
  `ct_usd_eq` double(12,2) DEFAULT NULL,
  `ct_ofid` int(11) DEFAULT NULL,
  `ct_said` int(11) DEFAULT NULL,
  `ct_from_fid2` int(11) DEFAULT NULL,
  `ct_from_drid` int(11) DEFAULT NULL,
  `ct_dr_date` date DEFAULT '0000-00-00',
  PRIMARY KEY (`ct_id`),
  KEY `ct_ts` (`ct_ts`),
  KEY `ct_aid` (`ct_aid`),
  KEY `ct_amnt` (`ct_amnt`),
  KEY `ct_currency` (`ct_currency`),
  KEY `ct_comment` (`ct_comment`),
  KEY `ct_oid` (`ct_oid`),
  KEY `ct_tid` (`ct_tid`),
  KEY `ct_ts2` (`ct_ts2`),
  KEY `ct_oid2` (`ct_oid2`),
  KEY `ct_status` (`ct_status`),
  KEY `ct_tid2` (`ct_tid2`),
  KEY `firms_cashier` (`ct_fid`),
  KEY `amnt_cashier` (`ct_amnt`),
  KEY `excha_cashier` (`ct_eid`),
  KEY `cur_cashier` (`ct_currency`),
  KEY `acc_cashier` (`ct_aid`),
  KEY `date_cashi` (`ct_date`),
  KEY `date_cash` (`ct_date`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=cp1251 COLLATE=cp1251_ukrainian_ci
/*!50100 PARTITION BY RANGE (ct_id)
(PARTITION p0 VALUES LESS THAN (306801) ENGINE = InnoDB,
 PARTITION p1 VALUES LESS THAN (500000) ENGINE = InnoDB,
 PARTITION p2 VALUES LESS THAN (650000) ENGINE = InnoDB,
 PARTITION p3 VALUES LESS THAN (800000) ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cashier_transactions`
--

LOCK TABLES `cashier_transactions` WRITE;
/*!40000 ALTER TABLE `cashier_transactions` DISABLE KEYS */;
INSERT INTO `cashier_transactions` VALUES (1,'2019-08-14 17:55:15',3,2000.0000000000,'UAH','Ввод наличных',69,2,'2019-08-14 17:55:25',69,'processed',NULL,'2019-08-14',-1,NULL,1,NULL,NULL,NULL,0.00,'input','no','no','no','2019-08-14 14:55:25',16777215,NULL,NULL,NULL,NULL,NULL,NULL,'0000-00-00'),(2,'2019-08-14 19:12:32',3,1000.0000000000,'UAH','Ввод безналом',69,NULL,'2019-08-14 00:00:00',69,'processed',5,'2019-08-14',257,0,0,NULL,NULL,NULL,0.00,'input','no','no','no','2019-08-14 16:28:18',16777215,NULL,NULL,NULL,NULL,NULL,NULL,'0000-00-00'),(3,'2019-08-14 19:20:35',3,1001.0000000000,'UAH','Ввод безналом',69,NULL,'2019-08-14 00:00:00',69,'processed',6,'2019-08-14',257,0,0,NULL,NULL,NULL,0.00,'input','no','no','no','2019-08-14 16:28:18',16777215,NULL,NULL,NULL,NULL,NULL,NULL,'0000-00-00'),(4,'2019-08-14 19:28:50',3,-1000.0000000000,'UAH','Ввод безналом',69,NULL,'2019-08-14 00:00:00',69,'processed',7,'2019-08-14',257,0,0,0.00,0,NULL,0.00,'input','no','no','no','2019-08-14 16:28:50',16777215,NULL,NULL,NULL,NULL,NULL,NULL,'0000-00-00'),(5,'2019-08-15 11:04:42',3,1000.0000000000,'USD','Ввод безналом',69,NULL,'2019-08-15 00:00:00',69,'processed',8,'2019-08-15',257,0,0,NULL,NULL,NULL,0.00,'input','no','no','no','2019-08-15 08:08:25',16777215,NULL,NULL,NULL,NULL,NULL,NULL,'0000-00-00'),(6,'2019-08-15 11:04:42',3,1000.0000000000,'USD','Ввод безналом',69,NULL,'2019-08-15 00:00:00',69,'processed',9,'2019-08-15',257,0,0,NULL,NULL,NULL,0.00,'input','no','no','no','2019-08-15 08:08:25',16777215,NULL,NULL,NULL,NULL,NULL,NULL,'0000-00-00'),(7,'2019-08-15 11:04:42',3,13.0000000000,'USD','Ввод безналом',69,NULL,'2019-08-15 00:00:00',69,'processed',10,'2019-08-15',257,0,0,NULL,NULL,NULL,0.00,'input','no','no','no','2019-08-15 08:08:25',16777215,NULL,NULL,NULL,NULL,NULL,NULL,'0000-00-00'),(8,'2019-08-15 11:04:42',NULL,-13.0000000000,'USD','Ввод безналом',69,NULL,NULL,NULL,'created',NULL,'2019-08-15',257,NULL,NULL,NULL,NULL,NULL,0.00,'input','no','yes','no','2019-08-15 08:04:42',16777215,NULL,NULL,NULL,NULL,NULL,NULL,'0000-00-00'),(9,'2019-08-15 11:04:42',NULL,-1400.0000000000,'USD','Ввод безналом',69,NULL,NULL,NULL,'created',NULL,'2019-08-15',257,NULL,NULL,NULL,NULL,NULL,0.00,'input','no','yes','no','2019-08-15 08:04:42',16777215,NULL,NULL,NULL,NULL,NULL,NULL,'0000-00-00'),(10,'2019-08-15 11:11:54',NULL,1000.0000000000,'EUR','Ввод безналом',69,NULL,NULL,NULL,'created',NULL,'2019-08-15',257,NULL,NULL,NULL,NULL,NULL,0.00,'input','no','yes','no','2019-08-15 08:11:54',16777215,NULL,NULL,NULL,NULL,NULL,NULL,'0000-00-00'),(11,'2019-08-15 16:56:38',3,-118.7878787879,'UAH','Вывод наличными',67,14,'2019-08-15 16:56:59',67,'processed',NULL,'2019-08-15',-1,NULL,13,NULL,NULL,NULL,1.00,'input','no','no','no','2019-08-15 13:56:59',16777215,NULL,NULL,NULL,NULL,NULL,NULL,'0000-00-00');
/*!40000 ALTER TABLE `cashier_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `cashier_transactions_comis`
--

DROP TABLE IF EXISTS `cashier_transactions_comis`;
/*!50001 DROP VIEW IF EXISTS `cashier_transactions_comis`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `cashier_transactions_comis` AS SELECT 
 1 AS `ct_id`,
 1 AS `ct_ts`,
 1 AS `ct_aid`,
 1 AS `ct_amnt`,
 1 AS `ct_currency`,
 1 AS `ct_comment`,
 1 AS `ct_oid`,
 1 AS `ct_tid`,
 1 AS `ct_ts2`,
 1 AS `ct_oid2`,
 1 AS `ct_status`,
 1 AS `ct_tid2`,
 1 AS `ct_date`,
 1 AS `ct_fid`,
 1 AS `ct_fsid`,
 1 AS `ct_tid2_comis`,
 1 AS `ct_ext_commission`,
 1 AS `ct_tid2_ext_com`,
 1 AS `ct_eid`,
 1 AS `ct_comis_percent`,
 1 AS `ct_ex_comis_type`,
 1 AS `ct_infl`,
 1 AS `ct_req`,
 1 AS `col_status`,
 1 AS `col_ts`,
 1 AS `col_color`,
 1 AS `ct_usd_eq`,
 1 AS `ct_comis_result`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `chat`
--

DROP TABLE IF EXISTS `chat`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `chat` (
  `c_id` int(11) NOT NULL AUTO_INCREMENT,
  `c_oid` int(11) NOT NULL DEFAULT '0',
  `c_ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `c_msg` text,
  `c_room` int(11) DEFAULT NULL,
  PRIMARY KEY (`c_id`)
) ENGINE=MyISAM AUTO_INCREMENT=106 DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chat`
--

LOCK TABLES `chat` WRITE;
/*!40000 ALTER TABLE `chat` DISABLE KEYS */;
/*!40000 ALTER TABLE `chat` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chat_private_room`
--

DROP TABLE IF EXISTS `chat_private_room`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `chat_private_room` (
  `cpr_id` int(11) NOT NULL AUTO_INCREMENT,
  `cpr_oid1` int(11) DEFAULT NULL,
  `cpr_oid2` int(11) DEFAULT NULL,
  PRIMARY KEY (`cpr_id`)
) ENGINE=MyISAM AUTO_INCREMENT=25 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chat_private_room`
--

LOCK TABLES `chat_private_room` WRITE;
/*!40000 ALTER TABLE `chat_private_room` DISABLE KEYS */;
/*!40000 ALTER TABLE `chat_private_room` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chat_room`
--

DROP TABLE IF EXISTS `chat_room`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `chat_room` (
  `cr_id` int(11) NOT NULL AUTO_INCREMENT,
  `cr_title` varchar(255) DEFAULT 'Private room',
  PRIMARY KEY (`cr_id`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chat_room`
--

LOCK TABLES `chat_room` WRITE;
/*!40000 ALTER TABLE `chat_room` DISABLE KEYS */;
/*!40000 ALTER TABLE `chat_room` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `chat_users_room`
--

DROP TABLE IF EXISTS `chat_users_room`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `chat_users_room` (
  `cur_oid` int(11) NOT NULL DEFAULT '0',
  `cur_crid` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`cur_oid`,`cur_crid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `chat_users_room`
--

LOCK TABLES `chat_users_room` WRITE;
/*!40000 ALTER TABLE `chat_users_room` DISABLE KEYS */;
/*!40000 ALTER TABLE `chat_users_room` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `classes`
--

DROP TABLE IF EXISTS `classes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `classes` (
  `c_id` int(11) NOT NULL AUTO_INCREMENT,
  `c_name` varchar(255) DEFAULT NULL,
  `c_ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `c_comments` varchar(255) DEFAULT '',
  PRIMARY KEY (`c_id`)
) ENGINE=MyISAM AUTO_INCREMENT=25 DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `classes`
--

LOCK TABLES `classes` WRITE;
/*!40000 ALTER TABLE `classes` DISABLE KEYS */;
INSERT INTO `classes` VALUES (23,'по умолчанию','2011-07-23 11:54:00',''),(24,'Master','2011-07-24 08:57:40','коммутация доходов');
/*!40000 ALTER TABLE `classes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `client_services`
--

DROP TABLE IF EXISTS `client_services`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `client_services` (
  `cs_fsid` int(11) NOT NULL DEFAULT '0',
  `cs_year` int(11) NOT NULL DEFAULT '0',
  `cs_month` int(11) NOT NULL DEFAULT '0',
  `cs_aid` int(11) NOT NULL DEFAULT '0',
  `cs_percent` float(7,2) DEFAULT NULL,
  `cs_ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`cs_fsid`,`cs_aid`,`cs_month`,`cs_year`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_services`
--

LOCK TABLES `client_services` WRITE;
/*!40000 ALTER TABLE `client_services` DISABLE KEYS */;
INSERT INTO `client_services` VALUES (67,2011,7,1,8.00,'2011-07-23 12:02:27'),(66,2011,7,1,1.00,'2011-07-23 12:02:27'),(67,2011,7,2,8.00,'2011-07-23 12:23:58'),(66,2011,7,2,1.00,'2011-07-23 12:23:58'),(67,2011,7,3,8.00,'2011-07-24 09:38:33'),(66,2011,7,3,1.00,'2011-07-24 09:38:33'),(66,2019,8,4,0.00,'2019-08-14 14:34:34'),(67,2019,8,4,0.00,'2019-08-14 14:34:34'),(67,2019,8,5,0.00,'2019-08-14 16:23:33'),(66,2019,8,5,0.00,'2019-08-14 16:23:33'),(67,2019,8,6,0.00,'2019-08-14 16:23:42'),(66,2019,8,6,0.00,'2019-08-14 16:23:42');
/*!40000 ALTER TABLE `client_services` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = latin1 */ ;
/*!50003 SET character_set_results = latin1 */ ;
/*!50003 SET collation_connection  = latin1_swedish_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = '' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER sdata_insert BEFORE INSERT ON `client_services` FOR EACH ROW BEGIN SET NEW.cs_month =MONTH(current_timestamp),NEW.cs_year =YEAR(current_timestamp);  END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `client_services_old`
--

DROP TABLE IF EXISTS `client_services_old`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `client_services_old` (
  `cs_fsid` int(11) NOT NULL DEFAULT '0',
  `cs_year` int(11) NOT NULL DEFAULT '0',
  `cs_month` int(11) NOT NULL DEFAULT '0',
  `cs_aid` int(11) NOT NULL DEFAULT '0',
  `cs_percent` float(7,2) DEFAULT NULL,
  PRIMARY KEY (`cs_fsid`,`cs_aid`,`cs_month`,`cs_year`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251 COLLATE=cp1251_ukrainian_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `client_services_old`
--

LOCK TABLES `client_services_old` WRITE;
/*!40000 ALTER TABLE `client_services_old` DISABLE KEYS */;
/*!40000 ALTER TABLE `client_services_old` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `clients_out_operators`
--

DROP TABLE IF EXISTS `clients_out_operators`;
/*!50001 DROP VIEW IF EXISTS `clients_out_operators`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `clients_out_operators` AS SELECT 
 1 AS `o_id`,
 1 AS `o_login`,
 1 AS `a_id`,
 1 AS `a_name`,
 1 AS `a_uah`,
 1 AS `a_email`,
 1 AS `a_class`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `correct_backs`
--

DROP TABLE IF EXISTS `correct_backs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `correct_backs` (
  `cb_id` int(11) NOT NULL AUTO_INCREMENT,
  `cb_date` date DEFAULT NULL,
  `e_type` enum('cash','cashless','auto') DEFAULT NULL,
  `cb_ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cb_rate` float(7,6) DEFAULT NULL,
  `cb_tid1` int(11) DEFAULT NULL,
  `cb_tid2` int(11) DEFAULT NULL,
  `cb_back_tid1` int(11) DEFAULT NULL,
  `cb_back_tid2` int(11) DEFAULT NULL,
  PRIMARY KEY (`cb_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `correct_backs`
--

LOCK TABLES `correct_backs` WRITE;
/*!40000 ALTER TABLE `correct_backs` DISABLE KEYS */;
/*!40000 ALTER TABLE `correct_backs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `credit_logs`
--

DROP TABLE IF EXISTS `credit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `credit_logs` (
  `cl_id` int(11) NOT NULL AUTO_INCREMENT,
  `cl_cid` int(11) NOT NULL DEFAULT '0',
  `cl_ts` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `cl_penalty` double(12,2) NOT NULL DEFAULT '0.00',
  `cl_percent` double(12,2) NOT NULL DEFAULT '0.00',
  `cl_amnt` double(12,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`cl_id`),
  KEY `cl_cid` (`cl_cid`),
  KEY `cl_ts` (`cl_ts`)
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COLLATE=cp1251_ukrainian_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `credit_logs`
--

LOCK TABLES `credit_logs` WRITE;
/*!40000 ALTER TABLE `credit_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `credit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `credits`
--

DROP TABLE IF EXISTS `credits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `credits` (
  `c_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `c_start` datetime DEFAULT NULL,
  `c_planned_finish` datetime DEFAULT NULL,
  `c_aid` int(11) DEFAULT NULL,
  `c_amnt` double(12,2) NOT NULL DEFAULT '0.00',
  `c_currency` enum('UAH','USD','EUR') COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT 'UAH',
  `c_comment` varchar(255) COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT '',
  `c_percent` double(12,2) NOT NULL DEFAULT '0.00',
  `c_amnt2` double(12,2) NOT NULL DEFAULT '0.00',
  `c_oid` int(11) DEFAULT NULL,
  `c_tid` int(11) DEFAULT NULL,
  `c_finish` datetime DEFAULT NULL,
  `c_oid2` int(11) DEFAULT NULL,
  `c_tid2` int(11) DEFAULT NULL,
  `c_free_days` int(11) unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`c_id`),
  KEY `c_start` (`c_start`),
  KEY `c_aid` (`c_aid`),
  KEY `c_amnt` (`c_amnt`),
  KEY `c_currency` (`c_currency`),
  KEY `c_comment` (`c_comment`),
  KEY `c_oid` (`c_oid`),
  KEY `c_tid` (`c_tid`),
  KEY `c_oid2` (`c_oid2`),
  KEY `c_finish` (`c_finish`),
  KEY `c_tid2` (`c_tid2`)
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COLLATE=cp1251_ukrainian_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `credits`
--

LOCK TABLES `credits` WRITE;
/*!40000 ALTER TABLE `credits` DISABLE KEYS */;
/*!40000 ALTER TABLE `credits` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `debug`
--

DROP TABLE IF EXISTS `debug`;
/*!50001 DROP VIEW IF EXISTS `debug`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `debug` AS SELECT 
 1 AS `ct_id`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `docs_exchange_view`
--

DROP TABLE IF EXISTS `docs_exchange_view`;
/*!50001 DROP VIEW IF EXISTS `docs_exchange_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `docs_exchange_view` AS SELECT 
 1 AS `dr_id`,
 1 AS `date`,
 1 AS `dr_amnt`,
 1 AS `dr_comis`,
 1 AS `sum_comis`,
 1 AS `dr_aid`,
 1 AS `dr_fid`,
 1 AS `dr_ts`,
 1 AS `dr_currency`,
 1 AS `dr_ofid_from`,
 1 AS `ct_amnt`,
 1 AS `dp_tid`,
 1 AS `dr_status`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `docs_money`
--

DROP TABLE IF EXISTS `docs_money`;
/*!50001 DROP VIEW IF EXISTS `docs_money`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `docs_money` AS SELECT 
 1 AS `ct_id`,
 1 AS `ct_ts`,
 1 AS `ct_aid`,
 1 AS `ct_amnt`,
 1 AS `ct_currency`,
 1 AS `ct_comment`,
 1 AS `ct_oid`,
 1 AS `ct_tid`,
 1 AS `ct_ts2`,
 1 AS `ct_oid2`,
 1 AS `ct_status`,
 1 AS `ct_tid2`,
 1 AS `ct_date`,
 1 AS `ct_fid`,
 1 AS `ct_fsid`,
 1 AS `ct_tid2_comis`,
 1 AS `ct_ext_commission`,
 1 AS `ct_tid2_ext_com`,
 1 AS `ct_eid`,
 1 AS `ct_comis_percent`,
 1 AS `ct_ex_comis_type`,
 1 AS `ct_infl`,
 1 AS `ct_req`,
 1 AS `col_status`,
 1 AS `col_ts`,
 1 AS `col_color`,
 1 AS `col_oid`,
 1 AS `ct_usd_eq`,
 1 AS `ct_ofid`,
 1 AS `ct_said`,
 1 AS `ct_from_fid2`,
 1 AS `ct_from_drid`,
 1 AS `dr_id`,
 1 AS `dr_comis`,
 1 AS `dr_aid`,
 1 AS `dr_amnt`,
 1 AS `dr_comment`,
 1 AS `dr_fid`,
 1 AS `dr_status`,
 1 AS `dr_ts`,
 1 AS `dr_currency`,
 1 AS `dr_ofid_from`,
 1 AS `dr_oid`,
 1 AS `dr_date`,
 1 AS `dr_close_tid`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `documents_payments`
--

DROP TABLE IF EXISTS `documents_payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `documents_payments` (
  `dp_id` int(11) NOT NULL AUTO_INCREMENT,
  `dp_ctid` int(11) NOT NULL,
  `dp_drid` int(11) NOT NULL,
  `dp_tid` int(11) DEFAULT NULL,
  `dp_amnt` double(12,2) DEFAULT NULL,
  PRIMARY KEY (`dp_id`),
  KEY `a_new_search` (`dp_drid`),
  KEY `a_new_search_amnt` (`dp_amnt`),
  KEY `a_new_search_transaction` (`dp_tid`,`dp_drid`)
) ENGINE=MyISAM AUTO_INCREMENT=66562 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documents_payments`
--

LOCK TABLES `documents_payments` WRITE;
/*!40000 ALTER TABLE `documents_payments` DISABLE KEYS */;
/*!40000 ALTER TABLE `documents_payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `documents_payments_view`
--

DROP TABLE IF EXISTS `documents_payments_view`;
/*!50001 DROP VIEW IF EXISTS `documents_payments_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `documents_payments_view` AS SELECT 
 1 AS `dp_id`,
 1 AS `dr_id`,
 1 AS `dr_date`,
 1 AS `dr_amnt`,
 1 AS `dr_comis`,
 1 AS `sum_comis`,
 1 AS `dr_aid`,
 1 AS `dr_comment`,
 1 AS `dr_fid`,
 1 AS `f_name`,
 1 AS `dr_ts`,
 1 AS `dr_currency`,
 1 AS `dr_ofid_from`,
 1 AS `ct_amnt`,
 1 AS `a_name`,
 1 AS `of_name`,
 1 AS `dp_tid`,
 1 AS `dr_status`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `documents_requests`
--

DROP TABLE IF EXISTS `documents_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `documents_requests` (
  `dr_id` int(11) NOT NULL AUTO_INCREMENT,
  `dr_comis` double(12,9) DEFAULT NULL,
  `dr_aid` int(11) NOT NULL,
  `dr_amnt` double(16,2) DEFAULT NULL,
  `dr_comment` varchar(255) NOT NULL,
  `dr_fid` int(11) NOT NULL,
  `dr_status` enum('created','processed','canceled','deleted') DEFAULT 'created',
  `dr_ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `dr_currency` enum('UAH','USD','EUR') DEFAULT 'UAH',
  `dr_ofid_from` int(11) DEFAULT NULL,
  `dr_oid` int(11) NOT NULL,
  `dr_date` date DEFAULT NULL,
  `dr_close_tid` int(11) DEFAULT '0',
  PRIMARY KEY (`dr_id`),
  KEY `a_index` (`dr_aid`),
  KEY `a_new_search_date` (`dr_date`),
  KEY `a_new_search_currency` (`dr_currency`),
  KEY `a_new_search_ofid` (`dr_ofid_from`),
  KEY `a_new_search_fid` (`dr_fid`),
  KEY `a_new_search_aid` (`dr_aid`),
  KEY `close_trans` (`dr_close_tid`)
) ENGINE=MyISAM AUTO_INCREMENT=37311 DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documents_requests`
--

LOCK TABLES `documents_requests` WRITE;
/*!40000 ALTER TABLE `documents_requests` DISABLE KEYS */;
/*!40000 ALTER TABLE `documents_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `documents_requests_logs`
--

DROP TABLE IF EXISTS `documents_requests_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `documents_requests_logs` (
  `dr_id` int(11) NOT NULL AUTO_INCREMENT,
  `dr_comis` double(12,9) DEFAULT NULL,
  `dr_aid` int(11) NOT NULL,
  `dr_amnt` double(16,2) DEFAULT NULL,
  `dr_comment` varchar(255) NOT NULL,
  `dr_fid` int(11) NOT NULL,
  `dr_status` enum('created','processed','canceled','deleted') DEFAULT 'created',
  `dr_ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `dr_currency` enum('UAH','USD','EUR') DEFAULT 'UAH',
  `dr_ofid_from` int(11) DEFAULT NULL,
  `dr_oid` int(11) DEFAULT NULL,
  `dr_date` date DEFAULT NULL,
  PRIMARY KEY (`dr_id`)
) ENGINE=MyISAM AUTO_INCREMENT=36726 DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documents_requests_logs`
--

LOCK TABLES `documents_requests_logs` WRITE;
/*!40000 ALTER TABLE `documents_requests_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `documents_requests_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `documents_transactions`
--

DROP TABLE IF EXISTS `documents_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `documents_transactions` (
  `dt_id` int(11) NOT NULL AUTO_INCREMENT,
  `dt_amnt` double(12,2) DEFAULT NULL,
  `dt_currency` enum('UAH','USD','EUR') DEFAULT 'UAH',
  `dt_aid` int(11) DEFAULT '0',
  `dt_fid` int(11) DEFAULT NULL,
  `dt_comment` varchar(255) DEFAULT NULL,
  `dt_oid` int(11) NOT NULL,
  `dt_oid2` int(11) NOT NULL,
  `dt_ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `dt_ts2` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `dt_status` enum('created','confirmed','processed','canceled') DEFAULT 'created',
  `dt_ofid` int(11) NOT NULL,
  `dt_date` date DEFAULT NULL,
  `dt_infl` enum('yes','no') DEFAULT 'no',
  `dt_drid` int(11) DEFAULT NULL,
  PRIMARY KEY (`dt_id`)
) ENGINE=MyISAM AUTO_INCREMENT=39554 DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `documents_transactions`
--

LOCK TABLES `documents_transactions` WRITE;
/*!40000 ALTER TABLE `documents_transactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `documents_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `documents_transactions_group_firms`
--

DROP TABLE IF EXISTS `documents_transactions_group_firms`;
/*!50001 DROP VIEW IF EXISTS `documents_transactions_group_firms`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `documents_transactions_group_firms` AS SELECT 
 1 AS `dt_amnt`,
 1 AS `dt_date`,
 1 AS `dt_fid`,
 1 AS `dt_ofid`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `documents_transactions_group_out_firms`
--

DROP TABLE IF EXISTS `documents_transactions_group_out_firms`;
/*!50001 DROP VIEW IF EXISTS `documents_transactions_group_out_firms`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `documents_transactions_group_out_firms` AS SELECT 
 1 AS `dt_amnt`,
 1 AS `dt_date`,
 1 AS `dt_fid`,
 1 AS `dt_ofid`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `documents_transactions_okpo`
--

DROP TABLE IF EXISTS `documents_transactions_okpo`;
/*!50001 DROP VIEW IF EXISTS `documents_transactions_okpo`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `documents_transactions_okpo` AS SELECT 
 1 AS `dt_id`,
 1 AS `dt_amnt`,
 1 AS `dt_currency`,
 1 AS `dt_aid`,
 1 AS `dt_fid`,
 1 AS `dt_comment`,
 1 AS `dt_oid`,
 1 AS `dt_oid2`,
 1 AS `dt_ts`,
 1 AS `dt_ts2`,
 1 AS `dt_status`,
 1 AS `dt_ofid`,
 1 AS `dt_date`,
 1 AS `dt_drid`,
 1 AS `dt_infl`,
 1 AS `dt_okpo`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `documents_transactions_view`
--

DROP TABLE IF EXISTS `documents_transactions_view`;
/*!50001 DROP VIEW IF EXISTS `documents_transactions_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `documents_transactions_view` AS SELECT 
 1 AS `dt_id`,
 1 AS `dt_amnt`,
 1 AS `dt_currency`,
 1 AS `dt_aid`,
 1 AS `dt_fid`,
 1 AS `dt_date`,
 1 AS `dt_comment`,
 1 AS `dt_oid`,
 1 AS `dt_oid2`,
 1 AS `dt_ts`,
 1 AS `dt_ts2`,
 1 AS `dt_status`,
 1 AS `dt_ofid`,
 1 AS `of_oid`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `documents_view_income`
--

DROP TABLE IF EXISTS `documents_view_income`;
/*!50001 DROP VIEW IF EXISTS `documents_view_income`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `documents_view_income` AS SELECT 
 1 AS `dr_id`,
 1 AS `key_field`,
 1 AS `dr_fid`,
 1 AS `okpo`,
 1 AS `dr_ofid_from`,
 1 AS `dr_aid`,
 1 AS `dr_amnt`,
 1 AS `sum_comis`,
 1 AS `percent_comis`,
 1 AS `dr_currency`,
 1 AS `dr_status`,
 1 AS `dr_ts`,
 1 AS `dr_date`,
 1 AS `a_incom_id`,
 1 AS `payed_comis`,
 1 AS `payed_income`,
 1 AS `is_payed`,
 1 AS `debug_is_payed`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `documents_view_income_new`
--

DROP TABLE IF EXISTS `documents_view_income_new`;
/*!50001 DROP VIEW IF EXISTS `documents_view_income_new`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `documents_view_income_new` AS SELECT 
 1 AS `dr_id`,
 1 AS `dr_fid`,
 1 AS `okpo`,
 1 AS `dr_ofid_from`,
 1 AS `dr_aid`,
 1 AS `dr_amnt`,
 1 AS `sum_comis`,
 1 AS `percent_comis`,
 1 AS `dr_currency`,
 1 AS `dr_status`,
 1 AS `dr_ts`,
 1 AS `dr_date`,
 1 AS `a_incom_id`,
 1 AS `dr_close_ts`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `emails`
--

DROP TABLE IF EXISTS `emails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `emails` (
  `em_id` int(11) NOT NULL AUTO_INCREMENT,
  `em_smtp` varchar(255) NOT NULL,
  `em_user` varchar(255) NOT NULL,
  `em_pwd` varchar(255) NOT NULL,
  `em_port` int(11) DEFAULT '25',
  `em_mail` varchar(255) NOT NULL,
  PRIMARY KEY (`em_id`)
) ENGINE=MyISAM AUTO_INCREMENT=7 DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `emails`
--

LOCK TABLES `emails` WRITE;
/*!40000 ALTER TABLE `emails` DISABLE KEYS */;
/*!40000 ALTER TABLE `emails` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exchange`
--

DROP TABLE IF EXISTS `exchange`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `exchange` (
  `e_id` int(11) NOT NULL AUTO_INCREMENT,
  `e_type` enum('cash','cashless','auto','system') COLLATE cp1251_ukrainian_ci DEFAULT 'auto',
  `e_rate_base` double(12,8) DEFAULT NULL,
  `e_rate` double(12,8) DEFAULT NULL,
  `e_tid1` int(11) NOT NULL DEFAULT '0',
  `e_tid2` int(11) NOT NULL DEFAULT '0',
  `e_status` enum('processed','deleted') COLLATE cp1251_ukrainian_ci DEFAULT 'processed',
  `e_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `e_back_tid2` int(11) DEFAULT NULL,
  `e_back_tid1` int(11) DEFAULT NULL,
  `col_status` enum('yes','no') COLLATE cp1251_ukrainian_ci DEFAULT 'no',
  `col_ts` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `col_color` int(11) DEFAULT '16777215',
  PRIMARY KEY (`e_id`),
  KEY `date_exc` (`e_date`)
) ENGINE=MyISAM AUTO_INCREMENT=72442 DEFAULT CHARSET=cp1251 COLLATE=cp1251_ukrainian_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exchange`
--

LOCK TABLES `exchange` WRITE;
/*!40000 ALTER TABLE `exchange` DISABLE KEYS */;
INSERT INTO `exchange` VALUES (72433,'cash',NULL,0.04000000,20,21,'deleted','2019-08-13 21:00:00',23,22,'no','0000-00-00 00:00:00',16777215),(72434,'cash',NULL,1.00000000,22,23,'deleted','2019-08-14 14:49:30',NULL,NULL,'no','0000-00-00 00:00:00',16777215),(72435,'cash',NULL,0.04000000,24,25,'processed','2019-08-13 21:00:00',NULL,NULL,'no','0000-00-00 00:00:00',16777215),(72436,'cash',NULL,0.04000000,3,4,'deleted','2019-08-13 21:00:00',18,17,'no','0000-00-00 00:00:00',16777215),(72437,'cash',0.04000000,0.04000000,11,12,'deleted','2019-08-14 21:00:00',16,15,'no','0000-00-00 00:00:00',16777215),(72438,'cash',1.00000000,25.00000000,15,16,'deleted','2019-08-15 15:29:55',NULL,NULL,'no','0000-00-00 00:00:00',16777215),(72439,'cash',1.00000000,25.00000000,17,18,'deleted','2019-08-15 15:35:31',NULL,NULL,'no','0000-00-00 00:00:00',16777215),(72440,'cash',0.04000000,0.04000000,19,20,'processed','2019-08-14 21:00:00',NULL,NULL,'no','0000-00-00 00:00:00',16777215),(72441,'cash',1.00000000,27.00000000,21,22,'processed','2019-08-14 21:00:00',NULL,NULL,'no','0000-00-00 00:00:00',16777215);
/*!40000 ALTER TABLE `exchange` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `exchange_view`
--

DROP TABLE IF EXISTS `exchange_view`;
/*!50001 DROP VIEW IF EXISTS `exchange_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `exchange_view` AS SELECT 
 1 AS `e_id`,
 1 AS `e_date`,
 1 AS `e_currency1`,
 1 AS `e_currency2`,
 1 AS `t_comment`,
 1 AS `e_amnt1`,
 1 AS `t_ts`,
 1 AS `t_ts1`,
 1 AS `t_ts2`,
 1 AS `e_amnt2`,
 1 AS `o_login`,
 1 AS `o_id`,
 1 AS `a_name`,
 1 AS `a_id`,
 1 AS `e_rate`,
 1 AS `e_rate_base`,
 1 AS `e_type`,
 1 AS `col_status`,
 1 AS `col_ts`,
 1 AS `e_status`,
 1 AS `col_color`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `firewall_settings`
--

DROP TABLE IF EXISTS `firewall_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `firewall_settings` (
  `fs_id` int(11) NOT NULL AUTO_INCREMENT,
  `fs_port` int(11) DEFAULT '443',
  `fs_src_ip` varchar(255) COLLATE cp1251_ukrainian_ci DEFAULT NULL,
  `fs_dst_ip` varchar(255) COLLATE cp1251_ukrainian_ci DEFAULT NULL,
  `fs_status` enum('deleted','actual') COLLATE cp1251_ukrainian_ci DEFAULT 'actual',
  `fs_type` enum('INPUT') COLLATE cp1251_ukrainian_ci DEFAULT 'INPUT',
  `fs_rule` enum('ACCEPT','DROP') COLLATE cp1251_ukrainian_ci DEFAULT 'ACCEPT',
  `fs_oid` int(11) NOT NULL,
  `fs_comment` varchar(255) CHARACTER SET cp1251 DEFAULT NULL,
  `fs_ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fs_number` int(11) DEFAULT '1',
  PRIMARY KEY (`fs_id`)
) ENGINE=MyISAM AUTO_INCREMENT=243 DEFAULT CHARSET=cp1251 COLLATE=cp1251_ukrainian_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `firewall_settings`
--

LOCK TABLES `firewall_settings` WRITE;
/*!40000 ALTER TABLE `firewall_settings` DISABLE KEYS */;
/*!40000 ALTER TABLE `firewall_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `firewall_updates`
--

DROP TABLE IF EXISTS `firewall_updates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `firewall_updates` (
  `fu_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fu_status` enum('not_actual','actual') COLLATE cp1251_ukrainian_ci DEFAULT 'not_actual'
) ENGINE=MEMORY DEFAULT CHARSET=cp1251 COLLATE=cp1251_ukrainian_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `firewall_updates`
--

LOCK TABLES `firewall_updates` WRITE;
/*!40000 ALTER TABLE `firewall_updates` DISABLE KEYS */;
/*!40000 ALTER TABLE `firewall_updates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `firm_reports`
--

DROP TABLE IF EXISTS `firm_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `firm_reports` (
  `fr_id` int(11) NOT NULL AUTO_INCREMENT,
  `fr_ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fr_status` enum('created','assigned') DEFAULT 'created',
  `fr_oid` int(11) NOT NULL,
  `fr_fid` int(11) NOT NULL,
  `fr_date` date NOT NULL,
  PRIMARY KEY (`fr_id`)
) ENGINE=MyISAM AUTO_INCREMENT=5454 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `firm_reports`
--

LOCK TABLES `firm_reports` WRITE;
/*!40000 ALTER TABLE `firm_reports` DISABLE KEYS */;
/*!40000 ALTER TABLE `firm_reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `firm_services`
--

DROP TABLE IF EXISTS `firm_services`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `firm_services` (
  `fs_id` int(11) NOT NULL AUTO_INCREMENT,
  `fs_name` varchar(255) COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT '',
  `fs_status` enum('active','blocked','deleted') COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT 'active',
  `fs_silver_per` double(12,2) NOT NULL DEFAULT '0.00',
  `fs_gold_per` double(12,2) NOT NULL DEFAULT '0.00',
  `fs_platinum_per` double(12,2) NOT NULL DEFAULT '0.00',
  `fs_infinite_per` double(12,2) NOT NULL DEFAULT '0.00',
  `fs_partner_per` double(12,2) NOT NULL DEFAULT '0.00',
  `fs_type` enum('only_in','out') COLLATE cp1251_ukrainian_ci DEFAULT 'only_in',
  PRIMARY KEY (`fs_id`),
  KEY `fs_name` (`fs_name`),
  KEY `fs_status` (`fs_status`)
) ENGINE=InnoDB AUTO_INCREMENT=68 DEFAULT CHARSET=cp1251 COLLATE=cp1251_ukrainian_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `firm_services`
--

LOCK TABLES `firm_services` WRITE;
/*!40000 ALTER TABLE `firm_services` DISABLE KEYS */;
INSERT INTO `firm_services` VALUES (66,'транзит','active',0.00,0.00,0.00,0.00,0.00,'only_in'),(67,'приход','active',0.00,0.00,0.00,0.00,0.00,'only_in');
/*!40000 ALTER TABLE `firm_services` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `firms`
--

DROP TABLE IF EXISTS `firms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `firms` (
  `f_id` int(11) NOT NULL AUTO_INCREMENT,
  `f_name` varchar(255) COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT '',
  `f_ts` datetime DEFAULT CURRENT_TIMESTAMP,
  `f_phones` varchar(255) COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT '',
  `f_status` enum('active','blocked','deleted') COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT 'active',
  `f_services` varchar(255) COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT '||',
  `f_uah` double(12,2) NOT NULL DEFAULT '0.00',
  `f_usd` double(12,2) NOT NULL DEFAULT '0.00',
  `f_eur` double(12,2) NOT NULL DEFAULT '0.00',
  `f_percent` float(7,2) DEFAULT '0.00',
  `f_usd_eq` double(12,2) DEFAULT NULL,
  `f_isres` enum('yes','no') COLLATE cp1251_ukrainian_ci DEFAULT 'yes',
  `f_okpo` varchar(100) COLLATE cp1251_ukrainian_ci DEFAULT '',
  `is_confirm` enum('not_processed','confirmed','not_confirmed') COLLATE cp1251_ukrainian_ci DEFAULT 'not_processed',
  `f_btc` double(12,6) DEFAULT '0.000000',
  PRIMARY KEY (`f_id`),
  KEY `f_name` (`f_name`),
  KEY `f_ts` (`f_ts`),
  KEY `f_phones` (`f_phones`),
  KEY `f_status` (`f_status`),
  KEY `f_services` (`f_services`),
  KEY `f_uah` (`f_uah`),
  KEY `f_usd` (`f_usd`),
  KEY `f_eur` (`f_eur`)
) ENGINE=InnoDB AUTO_INCREMENT=260 DEFAULT CHARSET=cp1251 COLLATE=cp1251_ukrainian_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `firms`
--

LOCK TABLES `firms` WRITE;
/*!40000 ALTER TABLE `firms` DISABLE KEYS */;
INSERT INTO `firms` VALUES (-2,'exchange','2019-08-14 17:48:22','','active','||',0.00,0.00,0.00,0.00,NULL,'yes','','not_processed',0.000000),(-1,'kassa','2019-08-14 15:17:57','','active','||',0.00,0.00,0.00,0.00,NULL,'yes','','not_processed',0.000000),(257,'Тестовая фирма','2011-07-23 14:46:19','','active','|66|67|',1001.00,2013.00,0.00,0.00,NULL,'yes','','not_processed',0.000000),(259,'CryptoBTC','2019-08-15 11:30:28','','active','||',0.00,0.00,0.00,0.00,NULL,'yes','','not_processed',0.000000);
/*!40000 ALTER TABLE `firms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `firms_exchange`
--

DROP TABLE IF EXISTS `firms_exchange`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `firms_exchange` (
  `fe_id` int(11) NOT NULL AUTO_INCREMENT,
  `fe_rate` float(9,8) DEFAULT NULL,
  `fe_ctid1_in` int(11) NOT NULL,
  `fe_ctid2_in` int(11) NOT NULL,
  `fe_ctid1_out` int(11) NOT NULL,
  `fe_ctid2_out` int(11) NOT NULL,
  PRIMARY KEY (`fe_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1266 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `firms_exchange`
--

LOCK TABLES `firms_exchange` WRITE;
/*!40000 ALTER TABLE `firms_exchange` DISABLE KEYS */;
/*!40000 ALTER TABLE `firms_exchange` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `firms_exchange_view`
--

DROP TABLE IF EXISTS `firms_exchange_view`;
/*!50001 DROP VIEW IF EXISTS `firms_exchange_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `firms_exchange_view` AS SELECT 
 1 AS `fe_id`,
 1 AS `fe_rate`,
 1 AS `fe_date`,
 1 AS `fe_ts`,
 1 AS `fe_amnt1`,
 1 AS `fe_amnt2`,
 1 AS `currency1`,
 1 AS `currency2`,
 1 AS `ct_fid`,
 1 AS `fe_comment`,
 1 AS `o_id`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `firms_out_operators`
--

DROP TABLE IF EXISTS `firms_out_operators`;
/*!50001 DROP VIEW IF EXISTS `firms_out_operators`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `firms_out_operators` AS SELECT 
 1 AS `o_id`,
 1 AS `o_login`,
 1 AS `f_id`,
 1 AS `f_name`,
 1 AS `f_ts`,
 1 AS `f_phones`,
 1 AS `f_status`,
 1 AS `f_services`,
 1 AS `f_uah`,
 1 AS `f_usd`,
 1 AS `f_eur`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `firms_transit`
--

DROP TABLE IF EXISTS `firms_transit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `firms_transit` (
  `ft_ctid1` int(11) NOT NULL DEFAULT '0',
  `ft_ctid2` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ft_ctid1`,`ft_ctid2`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `firms_transit`
--

LOCK TABLES `firms_transit` WRITE;
/*!40000 ALTER TABLE `firms_transit` DISABLE KEYS */;
/*!40000 ALTER TABLE `firms_transit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `header_rates`
--

DROP TABLE IF EXISTS `header_rates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `header_rates` (
  `hr_id` int(11) NOT NULL AUTO_INCREMENT,
  `hr_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `hr_rate_mb` varchar(30) DEFAULT '',
  `hr_rate_street` varchar(30) DEFAULT '',
  `hr_rate_cross` varchar(30) DEFAULT '',
  `hr_domi` varchar(255) DEFAULT NULL,
  `hr_rate_cross_street` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`hr_id`)
) ENGINE=MyISAM AUTO_INCREMENT=583 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `header_rates`
--

LOCK TABLES `header_rates` WRITE;
/*!40000 ALTER TABLE `header_rates` DISABLE KEYS */;
/*!40000 ALTER TABLE `header_rates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `joke`
--

DROP TABLE IF EXISTS `joke`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `joke` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `comment` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=2703 DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `joke`
--

LOCK TABLES `joke` WRITE;
/*!40000 ALTER TABLE `joke` DISABLE KEYS */;
INSERT INTO `joke` VALUES (2702,'');
/*!40000 ALTER TABLE `joke` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `kostial_accounts_new_docs`
--

DROP TABLE IF EXISTS `kostial_accounts_new_docs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `kostial_accounts_new_docs` (
  `kand_aid` int(11) NOT NULL,
  `kand_debt` double(12,4) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `kostial_accounts_new_docs`
--

LOCK TABLES `kostial_accounts_new_docs` WRITE;
/*!40000 ALTER TABLE `kostial_accounts_new_docs` DISABLE KEYS */;
/*!40000 ALTER TABLE `kostial_accounts_new_docs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `logs`
--

DROP TABLE IF EXISTS `logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `logs` (
  `l_id` int(11) NOT NULL AUTO_INCREMENT,
  `l_ts` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `l_category` varchar(255) COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT '',
  `l_cat_id` int(11) NOT NULL DEFAULT '0',
  `l_data` text COLLATE cp1251_ukrainian_ci,
  PRIMARY KEY (`l_id`),
  KEY `l_ts` (`l_ts`),
  KEY `l_category` (`l_category`),
  KEY `l_cat_id` (`l_cat_id`)
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COLLATE=cp1251_ukrainian_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `logs`
--

LOCK TABLES `logs` WRITE;
/*!40000 ALTER TABLE `logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `logs_posts`
--

DROP TABLE IF EXISTS `logs_posts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `logs_posts` (
  `log_id` int(11) NOT NULL AUTO_INCREMENT,
  `log_post` varchar(255) COLLATE cp1251_ukrainian_ci NOT NULL,
  `log_ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `log_time` double(12,10) DEFAULT NULL,
  `lp_oid` int(11) DEFAULT NULL,
  PRIMARY KEY (`log_id`)
) ENGINE=MEMORY AUTO_INCREMENT=634 DEFAULT CHARSET=cp1251 COLLATE=cp1251_ukrainian_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `logs_posts`
--

LOCK TABLES `logs_posts` WRITE;
/*!40000 ALTER TABLE `logs_posts` DISABLE KEYS */;
INSERT INTO `logs_posts` VALUES (1,'/cgi-bin/accounts.cgi?do=list','2019-07-14 21:27:38',0.0308140000,67),(2,'/cgi-bin/class.cgi?do=list','2019-07-14 21:27:41',0.0173840000,67),(3,'/cgi-bin/operators.cgi?do=list','2019-07-14 21:27:42',0.0190790000,67),(4,'/cgi-bin/operators.cgi?do=list','2019-07-14 21:27:44',0.0225350000,67),(5,'/cgi-bin/trans.cgi?do=list','2019-07-14 21:27:46',0.0190030000,67),(6,'/cgi-bin/firms.cgi?do=list','2019-07-14 21:27:49',0.0198010000,67),(7,'/cgi-bin/firm_trans.cgi?do=list','2019-07-14 21:27:52',0.0239140000,67),(8,'/cgi-bin/firms.cgi?do=list','2019-07-14 21:27:54',0.0184830000,67),(9,'/cgi-bin/operators.cgi?do=list','2019-07-14 21:28:19',0.0204630000,67),(10,'/cgi-bin/operators.cgi?do=add','2019-07-14 21:28:21',0.0182750000,67),(11,'/cgi-bin/operators.cgi?do=add','2019-07-14 21:44:49',0.0156650000,67),(12,'/cgi-bin/operators.cgi?do=list','2019-07-14 21:44:49',0.0205800000,67),(13,'/cgi-bin/trans.cgi?do=list','2019-07-14 21:45:12',0.0185080000,67),(14,'/cgi-bin/operators.cgi?do=list','2019-07-14 21:45:14',0.0194670000,67),(15,'/cgi-bin/class.cgi?do=list','2019-07-14 21:45:15',0.0196340000,67),(16,'/cgi-bin/class.cgi?do=list','2019-07-14 21:45:15',0.0180670000,67),(17,'/cgi-bin/accounts.cgi?do=list','2019-07-14 21:45:16',0.0199160000,67),(18,'/cgi-bin/accounts.cgi?do=list','2019-07-16 14:34:34',0.0501030000,68),(19,'/cgi-bin/firm_trans.cgi?do=list','2019-07-16 14:35:32',0.0401250000,68),(20,'/cgi-bin/firms.cgi?do=list','2019-07-16 14:36:17',0.0339200000,68),(21,'/cgi-bin/trans.cgi?do=list','2019-07-16 14:36:31',0.0250210000,68),(22,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-07-16 14:37:34',0.0498970000,68),(23,'/cgi-bin/accounts.cgi?do=list','2019-07-16 14:38:10',0.0364820000,68),(24,'/cgi-bin/firms.cgi?do=list','2019-07-18 14:21:59',0.0275840000,68),(25,'/cgi-bin/accounts.cgi?do=list','2019-07-18 14:22:09',0.0255280000,68),(26,'/cgi-bin/firms.cgi?do=list','2019-07-18 14:22:21',0.0180400000,68),(27,'/cgi-bin/accounts.cgi?do=list','2019-07-18 14:23:48',0.0251020000,68),(28,'/cgi-bin/class.cgi?do=list','2019-07-18 14:23:57',0.0148590000,68),(29,'/cgi-bin/firm_trans.cgi?do=list','2019-07-18 14:26:15',0.0247860000,68),(30,'/cgi-bin/cashier_output_dnepr.cgi?do=list','2019-07-18 15:08:26',0.0391440000,68),(31,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-07-18 15:08:31',0.0234170000,68),(32,'/cgi-bin/cashier_output2_dnepr.cgi?do=list','2019-07-18 15:09:37',0.0336860000,68),(33,'/cgi-bin/cashier_output2_dnepr.cgi?do=list','2019-07-18 15:09:37',0.0345430000,68),(34,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-07-18 15:09:45',0.0253010000,68),(35,'/cgi-bin/cash.cgi?do=list','2019-07-18 15:09:52',0.0232380000,68),(36,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-07-18 15:11:00',0.0326810000,68),(37,'/cgi-bin/accounts.cgi?do=list','2019-07-18 15:11:12',0.0227180000,68),(38,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-07-18 15:11:16',0.0220790000,68),(39,'/cgi-bin/cashier_input_before_dnepr.cgi?do=add','2019-07-18 15:11:31',0.0188810000,68),(40,'/cgi-bin/cashier_input_before_dnepr.cgi?do=add','2019-07-18 15:12:41',0.0185440000,68),(41,'/cgi-bin/accounts.cgi?do=list','2019-07-18 15:14:41',0.0217650000,68),(42,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-07-22 16:08:33',0.0455300000,68),(43,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-07-22 16:08:48',0.0254750000,68),(44,'/cgi-bin/accounts.cgi?do=list','2019-08-06 12:52:54',0.0299570000,67),(45,'/cgi-bin/accounts.cgi?do=list','2019-08-06 12:53:43',0.0218420000,68),(46,'/cgi-bin/operators.cgi?do=list','2019-08-06 12:53:58',0.0207880000,67),(47,'/cgi-bin/operators.cgi?do=edit','2019-08-06 12:54:00',0.0201460000,67),(48,'/cgi-bin/operators.cgi?do=list','2019-08-06 12:55:11',0.0218510000,67),(49,'/cgi-bin/operators.cgi?do=edit','2019-08-06 12:55:13',0.0203560000,67),(50,'/cgi-bin/operators.cgi?do=edit','2019-08-06 12:55:18',0.0113380000,67),(51,'/cgi-bin/operators.cgi?do=list','2019-08-06 12:55:18',0.0197300000,67),(52,'/cgi-bin/operators.cgi?do=edit','2019-08-06 13:05:26',0.0221590000,67),(53,'/cgi-bin/operators.cgi?do=edit','2019-08-06 13:05:34',0.0200690000,67),(54,'/cgi-bin/operators.cgi?do=edit','2019-08-06 13:06:45',0.0200700000,67),(55,'/cgi-bin/operators.cgi?do=edit','2019-08-06 13:07:14',0.0170190000,67),(56,'/cgi-bin/operators.cgi?do=list','2019-08-06 13:07:14',0.0237550000,67),(57,'/cgi-bin/accounts.cgi?do=list','2019-08-06 13:07:23',0.0239450000,68),(58,'/cgi-bin/operators.cgi?do=edit','2019-08-06 13:07:28',0.0196330000,67),(59,'/cgi-bin/operators.cgi?do=edit','2019-08-06 13:07:33',0.0105450000,67),(60,'/cgi-bin/operators.cgi?do=list','2019-08-06 13:07:34',0.0184610000,67),(61,'/cgi-bin/accounts.cgi?do=list','2019-08-06 13:07:38',0.0217740000,68),(62,'/cgi-bin/accounts.cgi?do=list','2019-08-06 13:07:40',0.0207060000,68),(63,'/cgi-bin/operators.cgi?do=edit','2019-08-06 13:07:45',0.0172250000,67),(64,'/cgi-bin/operators.cgi?do=edit','2019-08-06 13:07:52',0.0095980000,67),(65,'/cgi-bin/operators.cgi?do=list','2019-08-06 13:07:52',0.0176280000,67),(66,'/cgi-bin/accounts.cgi?do=list','2019-08-06 13:07:55',0.0198620000,68),(67,'/cgi-bin/accounts.cgi?do=list','2019-08-06 13:07:56',0.0210820000,68),(68,'/cgi-bin/accounts.cgi?do=list','2019-08-06 13:07:56',0.0220850000,68),(69,'/cgi-bin/accounts.cgi?do=list','2019-08-06 13:07:56',0.0202330000,68),(70,'/cgi-bin/operators.cgi?do=edit','2019-08-06 13:08:20',0.0219860000,67),(71,'/cgi-bin/operators.cgi?do=edit','2019-08-06 13:08:28',0.0104890000,67),(72,'/cgi-bin/operators.cgi?do=list','2019-08-06 13:08:29',0.0193880000,67),(73,'/cgi-bin/accounts.cgi?do=list','2019-08-06 13:08:34',0.0196990000,68),(74,'/cgi-bin/firms.cgi?do=list','2019-08-06 13:08:44',0.0258050000,68),(75,'/cgi-bin/firms.cgi?do=edit','2019-08-06 13:08:46',0.0198370000,68),(76,'/cgi-bin/class.cgi?do=list','2019-08-06 13:08:53',0.0156880000,68),(77,'/cgi-bin/accounts.cgi?do=list','2019-08-06 13:08:55',0.0201600000,68),(78,'/cgi-bin/operators.cgi?do=edit','2019-08-06 13:09:01',0.0366180000,67),(79,'/cgi-bin/operators.cgi?do=edit','2019-08-06 13:09:07',0.0131450000,67),(80,'/cgi-bin/operators.cgi?do=list','2019-08-06 13:09:07',0.0195060000,67),(81,'/cgi-bin/accounts.cgi?do=list','2019-08-06 13:09:09',0.0194760000,68),(82,'/cgi-bin/accounts.cgi?do=list','2019-08-06 13:09:10',0.0207540000,68),(83,'/cgi-bin/accounts.cgi?do=list','2019-08-06 13:09:11',0.0197630000,68),(84,'/cgi-bin/accounts.cgi?do=list','2019-08-06 13:09:11',0.0186620000,68),(85,'/cgi-bin/accounts.cgi?do=list','2019-08-06 13:09:11',0.0210010000,68),(86,'/cgi-bin/accounts.cgi?do=list','2019-08-06 13:09:21',0.0321260000,68),(87,'/cgi-bin/accounts.cgi?do=list','2019-08-06 13:09:24',0.0245090000,68),(88,'/cgi-bin/operators.cgi?do=edit','2019-08-06 13:09:33',0.0168870000,67),(89,'/cgi-bin/accounts.cgi?do=list','2019-08-06 13:09:38',0.0196040000,67),(90,'/cgi-bin/operators.cgi?do=list','2019-08-06 13:11:54',0.0249310000,67),(91,'/cgi-bin/operators.cgi?do=edit','2019-08-06 13:11:56',0.0208780000,67),(92,'/cgi-bin/operators.cgi?do=edit','2019-08-06 13:12:01',0.0132630000,67),(93,'/cgi-bin/operators.cgi?do=list','2019-08-06 13:12:02',0.0305450000,67),(94,'/cgi-bin/accounts.cgi?do=list','2019-08-06 13:12:06',0.0272480000,68),(95,'/cgi-bin/class.cgi?do=list','2019-08-06 13:12:08',0.0187360000,68),(96,'/cgi-bin/accounts.cgi?do=list','2019-08-06 13:12:09',0.0231830000,68),(97,'/cgi-bin/accounts.cgi?do=list','2019-08-06 13:12:16',0.0230370000,68),(98,'/cgi-bin/accounts.cgi?do=list','2019-08-06 13:12:16',0.0211240000,68),(99,'/cgi-bin/operators.cgi?do=list','2019-08-06 13:35:42',0.0344310000,67),(100,'/cgi-bin/operators.cgi?do=edit','2019-08-06 13:35:45',0.0202450000,67),(101,'/cgi-bin/operators.cgi?do=edit','2019-08-06 13:39:52',0.0130940000,67),(102,'/cgi-bin/operators.cgi?do=list','2019-08-06 13:39:52',0.0274960000,67),(103,'/cgi-bin/operators.cgi?do=edit','2019-08-06 13:39:54',0.0211720000,67),(104,'/cgi-bin/operators.cgi?do=edit','2019-08-06 13:40:00',0.0116530000,67),(105,'/cgi-bin/operators.cgi?do=list','2019-08-06 13:40:00',0.0201990000,67),(106,'/cgi-bin/operators.cgi?do=edit','2019-08-06 13:40:01',0.0221190000,67),(107,'/cgi-bin/operators.cgi?do=edit','2019-08-06 13:40:10',0.0107950000,67),(108,'/cgi-bin/operators.cgi?do=list','2019-08-06 13:40:10',0.0191230000,67),(109,'/cgi-bin/operators.cgi?do=edit','2019-08-06 13:40:12',0.0199650000,67),(110,'/cgi-bin/operators.cgi?do=edit','2019-08-06 13:41:13',0.0108360000,67),(111,'/cgi-bin/operators.cgi?do=edit','2019-08-06 14:12:08',0.0419010000,67),(112,'/cgi-bin/operators.cgi?do=list','2019-08-06 14:12:08',0.0291540000,67),(113,'/cgi-bin/operators.cgi?do=edit','2019-08-06 14:12:10',0.0229150000,67),(114,'/cgi-bin/accounts.cgi?do=list','2019-08-06 14:25:20',0.0278980000,68),(115,'/cgi-bin/operators.cgi?do=edit','2019-08-06 14:33:47',0.0248240000,67),(116,'/cgi-bin/operators.cgi?do=edit','2019-08-06 14:37:58',0.0116450000,67),(117,'/cgi-bin/operators.cgi?do=list','2019-08-06 14:37:58',0.0236040000,67),(118,'/cgi-bin/operators.cgi?do=edit','2019-08-06 14:38:01',0.0215840000,67),(119,'/cgi-bin/accounts.cgi?do=list','2019-08-06 14:38:23',0.0266060000,68),(120,'/cgi-bin/accounts.cgi?do=list','2019-08-06 14:38:24',0.0204350000,68),(121,'/cgi-bin/accounts.cgi?do=list','2019-08-06 14:38:24',0.0210740000,68),(122,'/cgi-bin/accounts.cgi?do=list','2019-08-06 14:38:25',0.0201670000,68),(123,'/cgi-bin/accounts.cgi?do=list','2019-08-06 14:38:25',0.0206200000,68),(124,'/cgi-bin/operators.cgi?do=edit','2019-08-06 14:51:05',0.0324770000,67),(125,'/cgi-bin/operators.cgi?do=edit','2019-08-06 14:51:09',0.0135760000,67),(126,'/cgi-bin/operators.cgi?do=list','2019-08-06 14:51:10',0.0298630000,67),(127,'/cgi-bin/operators.cgi?do=edit','2019-08-06 14:51:11',0.0189920000,67),(128,'/cgi-bin/operators.cgi?do=edit','2019-08-06 14:51:16',0.0121740000,67),(129,'/cgi-bin/operators.cgi?do=list','2019-08-06 14:51:16',0.0255130000,67),(130,'/cgi-bin/operators.cgi?do=edit','2019-08-06 14:51:18',0.0207120000,67),(131,'/cgi-bin/accounts.cgi?do=list','2019-08-06 14:51:24',0.0231340000,67),(132,'/cgi-bin/operators.cgi?do=edit','2019-08-06 14:51:31',0.0117090000,67),(133,'/cgi-bin/operators.cgi?do=list','2019-08-06 14:51:32',0.0189790000,67),(134,'/cgi-bin/accounts.cgi?do=list','2019-08-06 14:51:34',0.0225540000,67),(135,'/cgi-bin/cashier_output_dnepr.cgi?do=list','2019-08-06 14:51:49',0.0369230000,67),(136,'/cgi-bin/cashier_output_dnepr.cgi?do=add','2019-08-06 14:51:54',0.0184430000,67),(137,'/cgi-bin/cashier_output_dnepr.cgi?do=add','2019-08-06 14:52:38',0.0264140000,67),(138,'/cgi-bin/operators.cgi?do=list','2019-08-06 14:53:06',0.0197900000,67),(139,'/cgi-bin/operators.cgi?do=list','2019-08-06 14:53:10',0.0208930000,67),(140,'/cgi-bin/operators.cgi?do=add','2019-08-06 14:53:12',0.0216770000,67),(141,'/cgi-bin/operators.cgi?do=add','2019-08-06 14:53:34',0.0114910000,67),(142,'/cgi-bin/operators.cgi?do=list','2019-08-06 14:53:34',0.0227480000,67),(143,'/cgi-bin/operators.cgi?do=edit','2019-08-06 14:53:47',0.0204100000,67),(144,'/cgi-bin/operators.cgi?do=edit','2019-08-06 14:53:52',0.0128800000,67),(145,'/cgi-bin/operators.cgi?do=list','2019-08-06 14:53:52',0.0211460000,67),(146,'/cgi-bin/accounts.cgi?do=list','2019-08-06 14:53:56',0.0207740000,69),(147,'/cgi-bin/operators.cgi?do=edit','2019-08-06 14:54:03',0.0202960000,67),(148,'/cgi-bin/operators.cgi?do=edit','2019-08-06 14:54:07',0.0109920000,67),(149,'/cgi-bin/operators.cgi?do=list','2019-08-06 14:54:07',0.0200770000,67),(150,'/cgi-bin/accounts.cgi?do=list','2019-08-06 14:54:10',0.0228600000,69),(151,'/cgi-bin/cashier_output_dnepr.cgi?do=list','2019-08-06 14:54:13',0.0305340000,69),(152,'/cgi-bin/cashier_output_dnepr.cgi?do=add','2019-08-06 14:54:20',0.0183650000,69),(153,'/cgi-bin/cashier_output_dnepr.cgi?do=add','2019-08-06 14:54:38',0.0192990000,69),(154,'/cgi-bin/cashier_output_dnepr.cgi?do=add','2019-08-06 14:55:21',0.0197340000,69),(155,'/cgi-bin/cashier_output_dnepr.cgi?do=add','2019-08-06 14:55:26',0.0178110000,69),(156,'/cgi-bin/cashier_output_dnepr.cgi?do=add','2019-08-06 15:02:09',0.0179580000,69),(157,'/cgi-bin/cashier_output_dnepr.cgi?do=list','2019-08-06 15:02:09',0.0259400000,69),(158,'/cgi-bin/cashier_output_dnepr.cgi?do=add','2019-08-06 15:02:52',0.0218330000,69),(159,'/cgi-bin/operators.cgi?do=edit','2019-08-06 15:03:55',0.0294820000,67),(160,'/cgi-bin/operators.cgi?do=edit','2019-08-06 15:07:14',0.0290390000,67),(161,'/cgi-bin/operators.cgi?do=edit','2019-08-06 15:07:21',0.0215840000,67),(162,'/cgi-bin/operators.cgi?do=edit','2019-08-06 15:07:22',0.0198710000,67),(163,'/cgi-bin/operators.cgi?do=edit','2019-08-06 15:07:23',0.0200220000,67),(164,'/cgi-bin/operators.cgi?do=edit','2019-08-06 15:07:24',0.0183440000,67),(165,'/cgi-bin/operators.cgi?do=edit','2019-08-06 15:09:00',0.0219640000,67),(166,'/cgi-bin/cashier_output_dnepr.cgi?do=list','2019-08-06 15:09:14',0.0400540000,67),(167,'/cgi-bin/cashier_output_dnepr.cgi?do=add','2019-08-06 15:09:16',0.0188590000,67),(168,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-06 15:09:23',0.0223090000,67),(169,'/cgi-bin/cashier_input_before_dnepr.cgi?do=add','2019-08-06 15:09:25',0.0198630000,67),(170,'/cgi-bin/cashier_input_before_dnepr.cgi?do=add','2019-08-06 15:09:37',0.0206610000,67),(171,'/cgi-bin/cashier_input_before_dnepr.cgi?do=add','2019-08-06 15:09:41',0.0126630000,67),(172,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-06 15:09:41',0.0237130000,67),(173,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-08-06 15:09:44',0.0237840000,67),(174,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-08-06 15:09:50',0.0248830000,67),(175,'/cgi-bin/firm_trans.cgi?do=list','2019-08-14 09:00:36',0.0341150000,69),(176,'/cgi-bin/firm_trans.cgi?do=list','2019-08-14 09:00:40',0.0286150000,69),(177,'/cgi-bin/firm_trans.cgi?do=list','2019-08-14 09:00:45',0.0256470000,69),(178,'/cgi-bin/firm_trans.cgi?do=list','2019-08-14 09:00:46',0.0284300000,69),(179,'/cgi-bin/firm_trans.cgi?do=list','2019-08-14 09:04:39',0.0726500000,69),(180,'/cgi-bin/firm_trans.cgi?do=list','2019-08-14 09:04:40',0.0258350000,69),(181,'/cgi-bin/firm_trans.cgi?do=list','2019-08-14 09:15:18',0.0797910000,69),(182,'/cgi-bin/accounts.cgi?do=list','2019-08-14 09:15:28',0.0368730000,69),(183,'/cgi-bin/firm_trans.cgi?do=list','2019-08-14 09:15:30',0.0255770000,69),(184,'/cgi-bin/firm_trans.cgi?do=list','2019-08-14 09:15:43',0.0253120000,69),(185,'/cgi-bin/firm_trans.cgi?do=list','2019-08-14 09:15:47',0.0288160000,69),(186,'/cgi-bin/cashier_output_dnepr.cgi?do=list','2019-08-14 09:15:48',0.0434820000,69),(187,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-14 09:15:50',0.0312630000,69),(188,'/cgi-bin/cashier_output_dnepr.cgi?do=list','2019-08-14 09:15:51',0.0295480000,69),(189,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-14 09:15:53',0.0282890000,69),(190,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-14 09:15:57',0.0273810000,69),(191,'/cgi-bin/cashier_input_before_dnepr.cgi?do=edit','2019-08-14 09:18:23',0.0626680000,69),(192,'/cgi-bin/accounts.cgi?do=list','2019-08-14 09:20:32',0.0697730000,69),(193,'/cgi-bin/accounts.cgi?do=list','2019-08-14 09:25:23',0.0993470000,69),(194,'/cgi-bin/accounts.cgi?do=list','2019-08-14 09:25:24',0.0295380000,69),(195,'/cgi-bin/accounts.cgi?do=list','2019-08-14 09:29:01',0.0883050000,69),(196,'/cgi-bin/operators.cgi?do=list','2019-08-14 09:31:17',0.0351310000,67),(197,'/cgi-bin/operators.cgi?do=edit','2019-08-14 09:31:20',0.0276800000,67),(198,'/cgi-bin/operators.cgi?do=edit','2019-08-14 09:31:50',0.0188820000,67),(199,'/cgi-bin/operators.cgi?do=list','2019-08-14 09:31:51',0.0272200000,67),(200,'/cgi-bin/accounts.cgi?do=list','2019-08-14 09:31:53',0.0280850000,69),(201,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-14 09:32:25',0.0364710000,69),(202,'/cgi-bin/cashier_output_dnepr.cgi?do=list','2019-08-14 09:32:27',0.0411770000,69),(203,'/cgi-bin/cashier_output_dnepr.cgi?do=list','2019-08-14 09:32:30',0.0316810000,69),(204,'/cgi-bin/cashier_output_dnepr.cgi?do=list','2019-08-14 09:32:34',0.0312510000,69),(205,'/cgi-bin/cashier_output_dnepr.cgi?do=list','2019-08-14 09:32:38',0.0307910000,69),(206,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-14 09:32:44',0.0320080000,69),(207,'/cgi-bin/operators.cgi?do=list','2019-08-14 09:33:10',0.0349680000,67),(208,'/cgi-bin/operators.cgi?do=list_out','2019-08-14 09:33:11',0.0334420000,67),(209,'/cgi-bin/operators.cgi?do=list','2019-08-14 09:33:13',0.0281760000,67),(210,'/cgi-bin/cashier_output2_dnepr.cgi?do=list','2019-08-14 09:33:18',0.0453280000,67),(211,'/cgi-bin/cashier_output2_dnepr.cgi?do=list','2019-08-14 09:33:18',0.0463060000,67),(212,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-08-14 09:33:22',0.0287620000,67),(213,'/cgi-bin/cashier_output2_dnepr.cgi?do=list','2019-08-14 09:33:24',0.0313540000,67),(214,'/cgi-bin/cashier_output2_dnepr.cgi?do=list','2019-08-14 09:33:24',0.0321030000,67),(215,'/cgi-bin/cashier_output2_dnepr.cgi?do=list','2019-08-14 09:33:29',0.0312050000,67),(216,'/cgi-bin/cashier_output2_dnepr.cgi?do=list','2019-08-14 09:33:29',0.0321100000,67),(217,'/cgi-bin/cashier_output2_dnepr.cgi?do=edit','2019-08-14 09:33:32',0.0241720000,67),(218,'/cgi-bin/cashier_output2_dnepr.cgi?do=edit','2019-08-14 09:33:34',0.0456120000,67),(219,'/cgi-bin/cashier_output2_dnepr.cgi?do=list','2019-08-14 09:33:34',0.0337210000,67),(220,'/cgi-bin/cashier_output2_dnepr.cgi?do=list','2019-08-14 09:33:34',0.0349830000,67),(221,'/cgi-bin/accounts.cgi?do=list','2019-08-14 09:33:47',0.0280700000,69),(222,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-08-14 09:33:57',0.0284750000,67),(223,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-08-14 09:34:01',0.0428670000,67),(224,'/cgi-bin/cashier_input_dnepr.cgi?do=edit','2019-08-14 09:34:05',0.0269590000,67),(225,'/cgi-bin/cashier_input_dnepr.cgi?do=edit','2019-08-14 09:34:07',0.0345270000,67),(226,'/cgi-bin/cashier_input_dnepr.cgi?do=edit','2019-08-14 09:34:09',0.0353600000,67),(227,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-08-14 09:34:09',0.0314810000,67),(228,'/cgi-bin/accounts.cgi?do=list','2019-08-14 09:34:13',0.0413440000,67),(229,'/cgi-bin/accounts.cgi?do=list','2019-08-14 09:34:13',0.0292690000,67),(230,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-14 09:34:19',0.0286040000,67),(231,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-08-14 09:34:25',0.0351380000,67),(232,'/cgi-bin/cashier_output_dnepr.cgi?do=add','2019-08-14 09:34:27',0.0138390000,67),(233,'/cgi-bin/cashier_output_dnepr.cgi?do=add','2019-08-14 09:34:27',0.0266810000,67),(234,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-14 09:34:42',0.0284050000,67),(235,'/cgi-bin/cashier_input_before_dnepr.cgi?do=add','2019-08-14 09:34:44',0.0246670000,67),(236,'/cgi-bin/cashier_input_before_dnepr.cgi?do=add','2019-08-14 09:34:53',0.0247760000,67),(237,'/cgi-bin/cashier_input_before_dnepr.cgi?do=add','2019-08-14 09:34:55',0.0147830000,67),(238,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-14 09:34:55',0.0280700000,67),(239,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-08-14 09:35:11',0.0467830000,67),(240,'/cgi-bin/cashier_input_dnepr.cgi?do=edit','2019-08-14 09:35:13',0.0267700000,67),(241,'/cgi-bin/cashier_input_dnepr.cgi?do=edit','2019-08-14 09:35:15',0.0238290000,67),(242,'/cgi-bin/cashier_input_dnepr.cgi?do=edit','2019-08-14 09:35:16',0.0323930000,67),(243,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-08-14 09:35:17',0.0300490000,67),(244,'/cgi-bin/accounts.cgi?do=list','2019-08-14 09:35:20',0.0300510000,67),(245,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-08-14 09:35:52',0.0320310000,67),(246,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-14 09:35:54',0.0314500000,67),(247,'/cgi-bin/firm_trans.cgi?do=list','2019-08-14 09:36:22',0.0236600000,67),(248,'/cgi-bin/firm_trans.cgi?do=list','2019-08-14 09:36:31',0.0295820000,67),(249,'/cgi-bin/accounts.cgi?do=list','2019-08-14 09:37:33',0.0394810000,67),(250,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-14 09:37:47',0.0508020000,67),(251,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-14 09:38:13',0.0521870000,67),(252,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-14 09:38:16',0.0369870000,67),(253,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-14 09:38:31',0.0413400000,67),(254,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-14 09:40:46',0.0943490000,67),(255,'/cgi-bin/cashier_output_dnepr.cgi?do=list','2019-08-14 09:41:01',0.0317090000,67),(256,'/cgi-bin/firm_trans.cgi?do=list','2019-08-14 09:41:53',0.0295830000,67),(257,'/cgi-bin/firms.cgi?do=list','2019-08-14 09:45:44',0.0253990000,67),(258,'/cgi-bin/firms.cgi?do=edit','2019-08-14 09:45:47',0.0226810000,67),(259,'/cgi-bin/firm_trans.cgi?do=list','2019-08-14 09:45:52',0.0320750000,67),(260,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-14 10:45:00',0.0374440000,69),(261,'/cgi-bin/cashier_output_dnepr.cgi?do=list','2019-08-14 10:45:05',0.0483000000,69),(262,'/cgi-bin/firm_trans.cgi?do=list','2019-08-14 10:45:10',0.0238010000,69),(263,'/cgi-bin/firm_trans.cgi?do=list','2019-08-14 10:45:16',0.0250810000,69),(264,'/cgi-bin/firm_trans.cgi?do=list','2019-08-14 10:45:25',0.0251930000,69),(265,'/cgi-bin/cashier_output_dnepr.cgi?do=list','2019-08-14 10:45:31',0.0292410000,69),(266,'/cgi-bin/firm_trans.cgi?do=list','2019-08-14 10:45:33',0.0254810000,69),(267,'/cgi-bin/firm_trans.cgi?do=list','2019-08-14 10:49:39',0.0862170000,69),(268,'/cgi-bin/cashier_output_dnepr.cgi?do=list','2019-08-14 10:49:44',0.0418690000,69),(269,'/cgi-bin/cashier_output_dnepr.cgi?do=add','2019-08-14 10:49:46',0.0253040000,69),(270,'/cgi-bin/cashier_output_dnepr.cgi?do=add','2019-08-14 10:53:47',0.0730400000,69),(271,'/cgi-bin/cashier_output_dnepr.cgi?do=add','2019-08-14 10:54:19',0.0239660000,69),(272,'/cgi-bin/cashier_output_dnepr.cgi?do=add','2019-08-14 10:54:24',0.0253260000,69),(273,'/cgi-bin/cashier_output_dnepr.cgi?do=add','2019-08-14 10:54:26',0.0239430000,69),(274,'/cgi-bin/cashier_output_dnepr.cgi?do=add','2019-08-14 10:54:35',0.0281220000,69),(275,'/cgi-bin/cashier_output_dnepr.cgi?do=add','2019-08-14 10:54:40',0.0237990000,69),(276,'/cgi-bin/cashier_output_dnepr.cgi?do=list','2019-08-14 10:54:40',0.0461180000,69),(277,'/cgi-bin/accounts.cgi?do=list','2019-08-14 10:55:00',0.0444940000,69),(278,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-14 10:56:59',0.1112340000,69),(279,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-14 11:07:02',0.1090130000,69),(280,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-14 11:08:08',0.0821090000,69),(281,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-14 11:09:15',0.0881250000,69),(282,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-14 11:41:02',0.0937980000,69),(283,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-14 11:42:32',0.0799040000,69),(284,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-14 11:42:34',0.0368700000,69),(285,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-14 11:51:40',0.0717830000,69),(286,'/cgi-bin/cash.cgi?do=list','2019-08-14 12:09:13',0.0919680000,67),(287,'/cgi-bin/cash.cgi?do=list','2019-08-14 12:09:19',0.0316170000,67),(288,'/cgi-bin/cash.cgi?do=non_list','2019-08-14 12:09:22',0.0309110000,67),(289,'/cgi-bin/cash.cgi?do=list','2019-08-14 12:09:24',0.0308610000,67),(290,'/cgi-bin/firms.cgi?do=list','2019-08-14 12:09:42',0.0262340000,67),(291,'/cgi-bin/accounts.cgi?do=list','2019-08-14 12:13:27',0.0667000000,69),(292,'/cgi-bin/accounts.cgi?do=list','2019-08-14 12:16:11',0.0551370000,69),(293,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-14 12:16:16',0.0517870000,69),(294,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-14 12:18:00',0.0500810000,69),(295,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-14 12:22:45',0.0774480000,69),(296,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-14 12:22:48',0.0308780000,69),(297,'/cgi-bin/cashier_output_dnepr.cgi?do=list','2019-08-14 12:23:30',0.0368530000,67),(298,'/cgi-bin/cashier_output_dnepr.cgi?do=list','2019-08-14 12:23:37',0.0337070000,67),(299,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-14 12:23:39',0.0275960000,67),(300,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-14 12:23:43',0.0279090000,67),(301,'/cgi-bin/cashier_input_before_dnepr.cgi?do=add','2019-08-14 12:23:47',0.0239250000,67),(302,'/cgi-bin/cashier_input_before_dnepr.cgi?do=add','2019-08-14 12:23:58',0.0272720000,67),(303,'/cgi-bin/cashier_input_before_dnepr.cgi?do=add','2019-08-14 12:24:03',0.0177110000,67),(304,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-14 12:24:04',0.0370830000,67),(305,'/cgi-bin/operators.cgi?do=list','2019-08-14 12:24:12',0.0372040000,67),(306,'/cgi-bin/operators.cgi?do=edit','2019-08-14 12:24:17',0.0324390000,67),(307,'/cgi-bin/operators.cgi?do=edit','2019-08-14 12:24:24',0.0168890000,67),(308,'/cgi-bin/operators.cgi?do=list','2019-08-14 12:24:24',0.0257480000,67),(309,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-08-14 12:24:29',0.0288590000,69),(310,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-08-14 12:24:33',0.0374610000,69),(311,'/cgi-bin/cashier_input_dnepr.cgi?do=edit','2019-08-14 12:24:35',0.0235850000,69),(312,'/cgi-bin/cashier_input_dnepr.cgi?do=edit','2019-08-14 12:24:38',0.0253490000,69),(313,'/cgi-bin/cashier_input_dnepr.cgi?do=edit','2019-08-14 12:24:41',0.0411990000,69),(314,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-08-14 12:24:41',0.0336170000,69),(315,'/cgi-bin/accounts.cgi?do=list','2019-08-14 12:24:47',0.0294070000,69),(316,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-14 12:24:50',0.0379430000,69),(317,'/cgi-bin/operators.cgi?do=edit','2019-08-14 13:51:57',0.0636420000,67),(318,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-08-14 13:55:34',0.0696610000,69),(319,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-14 13:58:55',0.0809120000,67),(320,'/cgi-bin/cashier_input_before_dnepr.cgi?do=add','2019-08-14 13:58:57',0.0207780000,67),(321,'/cgi-bin/cashier_input_before_dnepr.cgi?do=add','2019-08-14 13:59:07',0.0245160000,67),(322,'/cgi-bin/cashier_input_before_dnepr.cgi?do=add','2019-08-14 13:59:13',0.0220900000,67),(323,'/cgi-bin/cashier_input_before_dnepr.cgi?do=add','2019-08-14 13:59:17',0.0115740000,67),(324,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-14 13:59:17',0.0324740000,67),(325,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-08-14 13:59:27',0.0257190000,69),(326,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-08-14 13:59:34',0.0244820000,69),(327,'/cgi-bin/cashier_input_dnepr.cgi?do=edit','2019-08-14 13:59:39',0.0232040000,69),(328,'/cgi-bin/firm_trans.cgi?do=list','2019-08-14 14:03:59',0.0313670000,67),(329,'/cgi-bin/trans.cgi?do=list','2019-08-14 14:04:38',0.0195230000,67),(330,'/cgi-bin/cashier_output_dnepr.cgi?do=list','2019-08-14 14:05:07',0.0416310000,67),(331,'/cgi-bin/correctings.cgi?do=list','2019-08-14 14:05:15',0.0226370000,67),(332,'/cgi-bin/correctings.cgi?do=list','2019-08-14 14:05:24',0.0210470000,67),(333,'/cgi-bin/correctings.cgi?do=edit','2019-08-14 14:05:36',0.0179880000,67),(334,'/cgi-bin/firms.cgi?do=list','2019-08-14 14:05:50',0.0208270000,67),(335,'/cgi-bin/firm_trans.cgi?do=list','2019-08-14 14:05:55',0.0232420000,67),(336,'/cgi-bin/class.cgi?do=list','2019-08-14 14:06:02',0.0197660000,67),(337,'/cgi-bin/accounts.cgi?do=list','2019-08-14 14:06:03',0.0304110000,67),(338,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-08-14 14:07:32',0.0271590000,69),(339,'/cgi-bin/cashier_output_dnepr.cgi?do=list','2019-08-14 14:07:45',0.0243530000,69),(340,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-08-14 14:07:50',0.0219090000,69),(341,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-14 14:09:13',0.0414730000,69),(342,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-08-14 14:09:17',0.0248000000,69),(343,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-14 14:09:19',0.0250550000,69),(344,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-14 14:09:23',0.0230010000,69),(345,'/cgi-bin/cashier_output_dnepr.cgi?do=list','2019-08-14 14:09:24',0.0247070000,69),(346,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-14 14:09:25',0.0207640000,69),(347,'/cgi-bin/firm_trans.cgi?do=list','2019-08-14 14:09:47',0.0207390000,69),(348,'/cgi-bin/firm_trans.cgi?do=list','2019-08-14 14:09:50',0.0251980000,69),(349,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-08-14 14:14:23',0.0444540000,69),(350,'/cgi-bin/cashier_input_dnepr.cgi?do=edit','2019-08-14 14:14:31',0.0212620000,69),(351,'/cgi-bin/cashier_input_dnepr.cgi?do=edit','2019-08-14 14:14:35',0.0205210000,69),(352,'/cgi-bin/cashier_input_dnepr.cgi?do=edit','2019-08-14 14:14:37',0.0402860000,69),(353,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-08-14 14:14:37',0.0255670000,69),(354,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-08-14 14:14:44',0.0304730000,69),(355,'/cgi-bin/class.cgi?do=list','2019-08-14 14:15:38',0.0200720000,67),(356,'/cgi-bin/emails.cgi?do=list','2019-08-14 14:15:54',0.0195490000,67),(357,'/cgi-bin/operators.cgi?do=list','2019-08-14 14:16:11',0.0371500000,67),(358,'/cgi-bin/joke.cgi?do=list','2019-08-14 14:16:14',0.0217900000,67),(359,'/cgi-bin/joke.cgi?do=add','2019-08-14 14:16:17',0.0090540000,67),(360,'/cgi-bin/joke.cgi?do=list','2019-08-14 14:16:17',0.0182670000,67),(361,'/cgi-bin/operators.cgi?do=list','2019-08-14 14:16:25',0.0203640000,67),(362,'/cgi-bin/operators.cgi?do=edit','2019-08-14 14:16:27',0.0223690000,67),(363,'/cgi-bin/operators.cgi?do=edit','2019-08-14 14:16:51',0.0139150000,67),(364,'/cgi-bin/operators.cgi?do=list','2019-08-14 14:16:51',0.0197720000,67),(365,'/cgi-bin/accounts.cgi?do=list','2019-08-14 14:16:57',0.0240180000,67),(366,'/cgi-bin/docs.cgi?do=list','2019-08-14 14:17:00',0.0135680000,67),(367,'/cgi-bin/cashier_output2_dnepr.cgi?do=list','2019-08-14 14:17:01',0.0424720000,67),(368,'/cgi-bin/cashier_output2_dnepr.cgi?do=list','2019-08-14 14:17:01',0.0440530000,67),(369,'/cgi-bin/firm_trans.cgi?do=list','2019-08-14 14:17:05',0.0274950000,67),(370,'/cgi-bin/firms.cgi?do=list','2019-08-14 14:17:06',0.0231280000,67),(371,'/cgi-bin/operators.cgi?do=list','2019-08-14 14:17:34',0.0194250000,67),(372,'/cgi-bin/operators.cgi?do=list','2019-08-14 14:17:37',0.0200870000,67),(373,'/cgi-bin/operators.cgi?do=edit','2019-08-14 14:17:39',0.0240270000,67),(374,'/cgi-bin/operators.cgi?do=edit','2019-08-14 14:17:50',0.0130500000,67),(375,'/cgi-bin/operators.cgi?do=list','2019-08-14 14:17:50',0.0218230000,67),(376,'/cgi-bin/operators.cgi?do=edit','2019-08-14 14:17:59',0.0197080000,67),(377,'/cgi-bin/operators.cgi?do=edit','2019-08-14 14:19:07',0.0314890000,67),(378,'/cgi-bin/operators.cgi?do=edit','2019-08-14 14:19:34',0.0183220000,67),(379,'/cgi-bin/operators.cgi?do=list','2019-08-14 14:19:35',0.0237310000,67),(380,'/cgi-bin/operators.cgi?do=list','2019-08-14 14:19:45',0.0271030000,67),(381,'/cgi-bin/plugins.cgi?do=add','2019-08-14 14:19:54',0.0188320000,67),(382,'/cgi-bin/conv.cgi?do=list','2019-08-14 14:20:03',0.0258200000,67),(383,'/cgi-bin/conv.cgi?do=add','2019-08-14 14:20:08',0.0223510000,67),(384,'/cgi-bin/accounts.cgi?do=list','2019-08-14 14:33:56',0.0312970000,67),(385,'/cgi-bin/accounts.cgi?do=list','2019-08-14 14:34:34',0.0235410000,67),(386,'/cgi-bin/accounts.cgi?do=list','2019-08-14 14:42:19',0.0292700000,67),(387,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-14 14:42:25',0.0370630000,67),(388,'/cgi-bin/conv.cgi?do=list','2019-08-14 14:45:57',0.0226870000,67),(389,'/cgi-bin/firms.cgi?do=list','2019-08-14 14:48:12',0.0612640000,67),(390,'/cgi-bin/firms.cgi?do=add','2019-08-14 14:48:15',0.0185970000,67),(391,'/cgi-bin/firms.cgi?do=add','2019-08-14 14:48:22',0.0121290000,67),(392,'/cgi-bin/firms.cgi?do=list','2019-08-14 14:48:23',0.0215110000,67),(393,'/cgi-bin/firms.cgi?do=list','2019-08-14 14:49:20',0.0223630000,67),(394,'/cgi-bin/accounts.cgi?do=list','2019-08-14 14:49:52',0.0251980000,67),(395,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-14 14:49:57',0.0373760000,67),(396,'/cgi-bin/cashier_output2_dnepr.cgi?do=list','2019-08-14 14:50:55',0.0445000000,67),(397,'/cgi-bin/cashier_output2_dnepr.cgi?do=list','2019-08-14 14:50:55',0.0452260000,67),(398,'/cgi-bin/cashier_output_dnepr.cgi?do=list','2019-08-14 14:50:59',0.0291550000,67),(399,'/cgi-bin/cashier_output2_dnepr.cgi?do=list','2019-08-14 14:51:02',0.0355600000,67),(400,'/cgi-bin/cashier_output2_dnepr.cgi?do=list','2019-08-14 14:51:02',0.0361290000,67),(401,'/cgi-bin/cashier_output2_dnepr.cgi?do=list','2019-08-14 14:51:05',0.0271780000,67),(402,'/cgi-bin/cashier_output2_dnepr.cgi?do=list','2019-08-14 14:51:05',0.0277550000,67),(403,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-08-14 14:51:07',0.0270590000,67),(404,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-08-14 14:51:17',0.0314020000,67),(405,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-08-14 14:53:13',0.0555220000,69),(406,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-14 14:53:18',0.0235960000,69),(407,'/cgi-bin/cashier_output_dnepr.cgi?do=list','2019-08-14 14:53:19',0.0279300000,69),(408,'/cgi-bin/operators.cgi?do=list','2019-08-14 14:53:28',0.0202580000,67),(409,'/cgi-bin/operators.cgi?do=edit','2019-08-14 14:53:37',0.0216150000,67),(410,'/cgi-bin/operators.cgi?do=edit','2019-08-14 14:54:45',0.0217000000,67),(411,'/cgi-bin/operators.cgi?do=list','2019-08-14 14:54:46',0.0265130000,67),(412,'/cgi-bin/cashier_output_dnepr.cgi?do=list','2019-08-14 14:54:49',0.0253960000,69),(413,'/cgi-bin/cashier_output_dnepr.cgi?do=list','2019-08-14 14:54:51',0.0238080000,69),(414,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-14 14:54:57',0.0243460000,69),(415,'/cgi-bin/cashier_input_before_dnepr.cgi?do=add','2019-08-14 14:54:59',0.0188230000,69),(416,'/cgi-bin/cashier_input_before_dnepr.cgi?do=add','2019-08-14 14:55:12',0.0330270000,69),(417,'/cgi-bin/cashier_input_before_dnepr.cgi?do=add','2019-08-14 14:55:15',0.0152410000,69),(418,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-14 14:55:15',0.0263100000,69),(419,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-08-14 14:55:19',0.0267050000,69),(420,'/cgi-bin/cashier_input_dnepr.cgi?do=edit','2019-08-14 14:55:21',0.0180520000,69),(421,'/cgi-bin/cashier_input_dnepr.cgi?do=edit','2019-08-14 14:55:24',0.0198640000,69),(422,'/cgi-bin/cashier_input_dnepr.cgi?do=edit','2019-08-14 14:55:25',0.0360110000,69),(423,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-08-14 14:55:26',0.0243470000,69),(424,'/cgi-bin/accounts.cgi?do=list','2019-08-14 14:55:27',0.0198080000,69),(425,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-14 14:55:33',0.0367260000,69),(426,'/cgi-bin/accounts.cgi?do=list','2019-08-14 14:55:59',0.0214540000,69),(427,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-14 14:56:03',0.0293540000,69),(428,'/cgi-bin/trans.cgi?do=list','2019-08-14 15:00:16',0.0248260000,67),(429,'/cgi-bin/trans.cgi?do=list','2019-08-14 15:00:19',0.0179720000,67),(430,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-08-14 15:00:20',0.0329020000,67),(431,'/cgi-bin/firm_trans.cgi?do=list','2019-08-14 15:00:23',0.0222830000,67),(432,'/cgi-bin/firm_trans.cgi?do=list','2019-08-14 15:00:30',0.0202740000,67),(433,'/cgi-bin/accounts.cgi?do=list','2019-08-14 15:08:59',0.0662150000,67),(434,'/cgi-bin/operators.cgi?do=list','2019-08-14 15:09:03',0.0272320000,67),(435,'/cgi-bin/operators.cgi?do=edit','2019-08-14 15:09:06',0.0215910000,67),(436,'/cgi-bin/operators.cgi?do=edit','2019-08-14 15:09:17',0.0139400000,67),(437,'/cgi-bin/operators.cgi?do=list','2019-08-14 15:09:18',0.0221130000,67),(438,'/cgi-bin/accounts.cgi?do=list','2019-08-14 15:09:21',0.0276120000,67),(439,'/cgi-bin/operators.cgi?do=list','2019-08-14 15:33:31',0.0258940000,67),(440,'/cgi-bin/operators.cgi?do=edit','2019-08-14 15:33:34',0.0209740000,67),(441,'/cgi-bin/accounts.cgi?do=list','2019-08-14 15:57:09',0.0443800000,67),(442,'/cgi-bin/accounts.cgi?do=list','2019-08-14 15:58:29',0.0304400000,69),(443,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-14 15:59:24',0.0504610000,69),(444,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-14 15:59:29',0.0258800000,69),(445,'/cgi-bin/cashier_output2_dnepr.cgi?do=list','2019-08-14 15:59:31',0.0262930000,69),(446,'/cgi-bin/cashier_output2_dnepr.cgi?do=list','2019-08-14 15:59:31',0.0267700000,69),(447,'/cgi-bin/cash.cgi?do=list','2019-08-14 15:59:34',0.0253840000,69),(448,'/cgi-bin/cash.cgi?do=non_list','2019-08-14 15:59:37',0.0258340000,69),(449,'/cgi-bin/cash.cgi?do=list','2019-08-14 15:59:39',0.0268540000,69),(450,'/cgi-bin/operators.cgi?do=list','2019-08-14 16:00:11',0.0278900000,69),(451,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-08-14 16:00:18',0.0261180000,69),(452,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-14 16:00:19',0.0249190000,69),(453,'/cgi-bin/cashier_input_before_dnepr.cgi?do=add','2019-08-14 16:00:23',0.0196990000,69),(454,'/cgi-bin/cashier_output_dnepr.cgi?do=list','2019-08-14 16:00:29',0.0264340000,67),(455,'/cgi-bin/cashier_output_dnepr.cgi?do=add','2019-08-14 16:00:34',0.0220310000,67),(456,'/cgi-bin/cashier_output_dnepr.cgi?do=add','2019-08-14 16:02:47',0.0207640000,67),(457,'/cgi-bin/cashier_input_before_dnepr.cgi?do=add','2019-08-14 16:02:56',0.0207100000,69),(458,'/cgi-bin/firm_trans.cgi?do=list','2019-08-14 16:03:23',0.0392700000,69),(459,'/cgi-bin/rates.cgi?do=add','2019-08-14 16:08:38',0.0209410000,69),(460,'/cgi-bin/rates.cgi?do=add','2019-08-14 16:09:08',0.0189710000,69),(461,'/cgi-bin/rates.cgi?do=add','2019-08-14 16:09:21',0.0205180000,69),(462,'/cgi-bin/rates.cgi?do=add','2019-08-14 16:09:32',0.0212280000,69),(463,'/cgi-bin/rates.cgi?do=add','2019-08-14 16:09:45',0.0216530000,69),(464,'/cgi-bin/lite/firm_input_ajax.cgi?do=add_many','2019-08-14 16:22:13',99.9999999999,69),(465,'/cgi-bin/lite/firm_input_ajax.cgi?do=edit','2019-08-14 16:22:27',99.9999999999,69),(466,'/cgi-bin/accounts.cgi?do=list','2019-08-14 16:23:13',0.0464130000,67),(467,'/cgi-bin/accounts.cgi?do=list','2019-08-14 16:23:33',0.0245740000,67),(468,'/cgi-bin/accounts.cgi?do=list','2019-08-14 16:23:42',0.0239920000,67),(469,'/cgi-bin/lite/firm_input_ajax.cgi?do=add_many','2019-08-14 16:25:01',99.9999999999,69),(470,'/cgi-bin/lite/firm_input_ajax.cgi?do=add_common_confirm','2019-08-14 16:25:11',99.9999999999,69),(471,'/cgi-bin/lite/firm_input_ajax.cgi?do=add_many','2019-08-14 16:28:07',99.9999999999,69),(472,'/cgi-bin/lite/firm_input_ajax.cgi?do=edit','2019-08-14 16:28:16',99.9999999999,69),(473,'/cgi-bin/lite/firm_input_ajax.cgi?do=edit','2019-08-14 16:28:18',99.9999999999,69),(474,'/cgi-bin/accounts.cgi?do=list','2019-08-14 16:28:23',0.0248080000,69),(475,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-14 16:28:28',0.0351340000,69),(476,'/cgi-bin/lite/firm_output_ajax.cgi?do=add_many','2019-08-14 16:28:40',99.9999999999,69),(477,'/cgi-bin/lite/firm_output_ajax.cgi?do=add_common_confirm','2019-08-14 16:28:48',99.9999999999,69),(478,'/cgi-bin/lite/firm_output_ajax.cgi?do=add_common_do','2019-08-14 16:28:50',99.9999999999,69),(479,'/cgi-bin/accounts.cgi?do=list','2019-08-14 16:28:53',0.0218380000,69),(480,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-14 16:28:56',0.0261710000,69),(481,'/cgi-bin/accounts.cgi?do=list','2019-08-14 16:29:08',0.0250060000,67),(482,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-14 16:29:14',0.0332710000,67),(483,'/cgi-bin/cashier_input_before_dnepr.cgi?do=add','2019-08-14 16:29:18',0.0217210000,67),(484,'/cgi-bin/accounts.cgi?do=list','2019-08-15 07:41:41',0.0364000000,69),(485,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-15 07:41:58',0.0401990000,69),(486,'/cgi-bin/operators.cgi?do=list','2019-08-15 07:52:44',0.0740530000,69),(487,'/cgi-bin/operators.cgi?do=edit','2019-08-15 07:52:55',0.0261980000,69),(488,'/cgi-bin/operators.cgi?do=edit','2019-08-15 07:56:13',0.0712470000,69),(489,'/cgi-bin/operators.cgi?do=edit','2019-08-15 07:56:21',0.0157860000,69),(490,'/cgi-bin/operators.cgi?do=list','2019-08-15 07:56:21',0.0288310000,69),(491,'/cgi-bin/conv.cgi?do=list','2019-08-15 07:56:33',0.0238390000,69),(492,'/cgi-bin/conv.cgi?do=add','2019-08-15 07:57:07',0.0262880000,69),(493,'/cgi-bin/firms.cgi?do=list','2019-08-15 07:57:34',0.0267130000,69),(494,'/cgi-bin/operators.cgi?do=list','2019-08-15 07:57:38',0.0331680000,69),(495,'/cgi-bin/operators.cgi?do=edit','2019-08-15 07:57:41',0.0224860000,69),(496,'/cgi-bin/operators.cgi?do=edit','2019-08-15 07:58:06',0.0199690000,69),(497,'/cgi-bin/operators.cgi?do=list','2019-08-15 07:58:07',0.0292460000,69),(498,'/cgi-bin/trans.cgi?do=list','2019-08-15 07:58:09',0.0276350000,69),(499,'/cgi-bin/trans.cgi?do=add','2019-08-15 07:58:11',0.0212030000,69),(500,'/cgi-bin/firms.cgi?do=list','2019-08-15 07:58:19',0.0213680000,69),(501,'/cgi-bin/firm_trans.cgi?do=list','2019-08-15 07:59:09',0.0450010000,69),(502,'/cgi-bin/operators.cgi?do=list','2019-08-15 08:00:42',0.0232100000,69),(503,'/cgi-bin/operators.cgi?do=edit','2019-08-15 08:00:44',0.0312340000,69),(504,'/cgi-bin/operators.cgi?do=edit','2019-08-15 08:00:56',0.0137480000,69),(505,'/cgi-bin/operators.cgi?do=list','2019-08-15 08:00:56',0.0229200000,69),(506,'/cgi-bin/accounts.cgi?do=list','2019-08-15 08:01:56',0.0256860000,69),(507,'/cgi-bin/operators.cgi?do=list','2019-08-15 08:01:57',0.0217930000,69),(508,'/cgi-bin/operators.cgi?do=edit','2019-08-15 08:02:01',0.0263040000,69),(509,'/cgi-bin/firm_trans.cgi?do=list','2019-08-15 08:02:21',0.0379490000,69),(510,'/cgi-bin/operators.cgi?do=list','2019-08-15 08:03:51',0.0329710000,69),(511,'/cgi-bin/operators.cgi?do=edit','2019-08-15 08:03:53',0.0325870000,69),(512,'/cgi-bin/firm_trans.cgi?do=list','2019-08-15 08:05:20',0.0520220000,69),(513,'/cgi-bin/lite/firm_input_ajax.cgi?do=add_many','2019-08-15 08:07:20',99.9999999999,69),(514,'/cgi-bin/lite/firm_input_ajax.cgi?do=add_many','2019-08-15 08:08:10',99.9999999999,69),(515,'/cgi-bin/lite/firm_input_ajax.cgi?do=add_common_confirm','2019-08-15 08:08:22',99.9999999999,69),(516,'/cgi-bin/lite/firm_input_ajax.cgi?do=add_common_do','2019-08-15 08:08:25',99.9999999999,69),(517,'/cgi-bin/cash.cgi?do=list','2019-08-15 08:10:22',0.0890720000,69),(518,'/cgi-bin/lite/firm_input_ajax.cgi?do=add_many','2019-08-15 08:12:02',99.9999999999,69),(519,'/cgi-bin/lite/firm_input_ajax.cgi?do=add_many','2019-08-15 08:13:56',99.9999999999,69),(520,'/cgi-bin/operators.cgi?do=list','2019-08-15 08:14:14',0.0590930000,69),(521,'/cgi-bin/operators.cgi?do=edit','2019-08-15 08:14:17',0.0239540000,69),(522,'/cgi-bin/operators.cgi?do=edit','2019-08-15 08:14:30',0.0179390000,69),(523,'/cgi-bin/operators.cgi?do=list','2019-08-15 08:14:30',0.0221610000,69),(524,'/cgi-bin/rates.cgi?do=add','2019-08-15 08:14:43',0.0195110000,69),(525,'/cgi-bin/rates.cgi?do=add','2019-08-15 08:14:52',0.0205970000,69),(526,'/cgi-bin/rates.cgi?do=add','2019-08-15 08:14:54',0.0120320000,69),(527,'/cgi-bin/rates.cgi?do=add','2019-08-15 08:14:56',0.0189890000,69),(528,'/cgi-bin/rates.cgi?do=add','2019-08-15 08:15:00',0.0181640000,69),(529,'/cgi-bin/rates.cgi?do=add','2019-08-15 08:15:12',0.0196700000,69),(530,'/cgi-bin/rates.cgi?do=add','2019-08-15 08:15:14',0.0109880000,69),(531,'/cgi-bin/rates.cgi?do=add','2019-08-15 08:15:22',0.0200520000,69),(532,'/cgi-bin/rates.cgi?do=list','2019-08-15 08:15:29',0.0206020000,69),(533,'/cgi-bin/rates.cgi?do=add','2019-08-15 08:15:34',0.0189630000,69),(534,'/cgi-bin/rates.cgi?do=add','2019-08-15 08:16:10',0.0300260000,69),(535,'/cgi-bin/rates.cgi?do=add','2019-08-15 08:16:13',0.0118010000,69),(536,'/cgi-bin/operators.cgi?do=list','2019-08-15 08:24:50',0.0648670000,69),(537,'/cgi-bin/firms.cgi?do=list','2019-08-15 08:30:13',0.0385130000,69),(538,'/cgi-bin/firms.cgi?do=add','2019-08-15 08:30:15',0.0238020000,69),(539,'/cgi-bin/firms.cgi?do=add','2019-08-15 08:30:28',0.0137510000,69),(540,'/cgi-bin/firms.cgi?do=list','2019-08-15 08:30:28',0.0234770000,69),(541,'/cgi-bin/operators.cgi?do=list','2019-08-15 08:34:14',0.0279940000,69),(542,'/cgi-bin/operators.cgi?do=list','2019-08-15 08:34:16',0.0246070000,69),(543,'/cgi-bin/operators.cgi?do=list_out','2019-08-15 08:34:17',0.0258750000,69),(544,'/cgi-bin/operators.cgi?do=list_out','2019-08-15 08:34:28',0.0230690000,69),(545,'/cgi-bin/operators.cgi?do=list_out','2019-08-15 08:34:29',0.0246240000,69),(546,'/cgi-bin/accounts.cgi?do=list','2019-08-15 08:39:10',0.0736670000,69),(547,'/cgi-bin/operators.cgi?do=list','2019-08-15 09:06:55',0.0306260000,67),(548,'/cgi-bin/operators.cgi?do=edit','2019-08-15 09:06:57',0.0246860000,67),(549,'/cgi-bin/operators.cgi?do=edit','2019-08-15 09:07:04',0.0156910000,67),(550,'/cgi-bin/operators.cgi?do=list','2019-08-15 09:07:04',0.0236650000,67),(551,'/cgi-bin/accounts.cgi?do=list','2019-08-15 09:09:30',0.0387690000,67),(552,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-15 09:09:36',0.0401080000,67),(553,'/cgi-bin/cashier_output_dnepr.cgi?do=list','2019-08-15 09:10:40',0.0530900000,67),(554,'/cgi-bin/cashier_output_dnepr.cgi?do=add','2019-08-15 09:10:42',0.0206690000,67),(555,'/cgi-bin/cashier_input_dnepr.cgi?do=list','2019-08-15 09:15:34',0.0713770000,67),(556,'/cgi-bin/cashier_output_dnepr.cgi?do=list','2019-08-15 09:16:30',0.0582280000,67),(557,'/cgi-bin/cashier_output_dnepr.cgi?do=add','2019-08-15 09:16:46',0.0273820000,67),(558,'/cgi-bin/lite/firm_input_ajax.cgi?do=add_many','2019-08-15 09:32:02',99.9999999999,67),(559,'/cgi-bin/operators.cgi?do=list','2019-08-15 09:33:52',0.0432840000,67),(560,'/cgi-bin/operators.cgi?do=edit','2019-08-15 09:33:54',0.0234820000,67),(561,'/cgi-bin/operators.cgi?do=edit','2019-08-15 09:33:59',0.0219470000,67),(562,'/cgi-bin/operators.cgi?do=list','2019-08-15 09:34:53',0.0218320000,67),(563,'/cgi-bin/operators.cgi?do=edit','2019-08-15 09:34:56',0.0235870000,67),(564,'/cgi-bin/accounts.cgi?do=list','2019-08-15 09:47:24',0.0796810000,67),(565,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-15 09:47:31',0.0444260000,67),(566,'/cgi-bin/operators.cgi?do=list','2019-08-15 10:02:46',0.0723420000,67),(567,'/cgi-bin/cash.cgi?do=list','2019-08-15 10:04:22',0.0590720000,67),(568,'/cgi-bin/accounts.cgi?do=list','2019-08-15 13:01:02',0.0561140000,67),(569,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-15 13:01:05',0.0569330000,67),(570,'/cgi-bin/cashier_output2_dnepr.cgi?do=list','2019-08-15 13:01:16',0.0495790000,67),(571,'/cgi-bin/cashier_output2_dnepr.cgi?do=list','2019-08-15 13:01:16',0.0506520000,67),(572,'/cgi-bin/cashier_output_dnepr.cgi?do=list','2019-08-15 13:01:19',0.0281430000,67),(573,'/cgi-bin/cashier_output_dnepr.cgi?do=add','2019-08-15 13:01:21',0.0254380000,67),(574,'/cgi-bin/operators.cgi?do=list','2019-08-15 13:25:20',0.0758690000,67),(575,'/cgi-bin/operators.cgi?do=edit','2019-08-15 13:25:23',0.0239550000,67),(576,'/cgi-bin/operators.cgi?do=list','2019-08-15 13:26:06',0.0244680000,67),(577,'/cgi-bin/operators.cgi?do=edit','2019-08-15 13:26:11',0.0246670000,67),(578,'/cgi-bin/operators.cgi?do=edit','2019-08-15 13:26:17',0.0163050000,67),(579,'/cgi-bin/operators.cgi?do=list','2019-08-15 13:26:17',0.0229570000,67),(580,'/cgi-bin/operators.cgi?do=edit','2019-08-15 13:26:20',0.0239080000,67),(581,'/cgi-bin/operators.cgi?do=edit','2019-08-15 13:26:24',0.0254850000,67),(582,'/cgi-bin/operators.cgi?do=edit','2019-08-15 13:26:29',0.0136070000,67),(583,'/cgi-bin/operators.cgi?do=list','2019-08-15 13:26:30',0.0225190000,67),(584,'/cgi-bin/firms.cgi?do=list','2019-08-15 13:26:36',0.0244050000,67),(585,'/cgi-bin/firm_trans.cgi?do=list','2019-08-15 13:26:38',0.0349450000,67),(586,'/cgi-bin/firm_trans.cgi?do=list','2019-08-15 13:32:53',0.1010460000,67),(587,'/cgi-bin/operators.cgi?do=list','2019-08-15 13:33:00',0.0237740000,67),(588,'/cgi-bin/operators.cgi?do=edit','2019-08-15 13:33:02',0.0271310000,67),(589,'/cgi-bin/operators.cgi?do=edit','2019-08-15 13:33:07',0.0256460000,67),(590,'/cgi-bin/operators.cgi?do=edit','2019-08-15 13:33:13',0.0171640000,67),(591,'/cgi-bin/operators.cgi?do=list','2019-08-15 13:33:13',0.0252530000,67),(592,'/cgi-bin/cashier_output_dnepr.cgi?do=add','2019-08-15 13:51:06',0.0307490000,67),(593,'/cgi-bin/cashier_output_dnepr.cgi?do=add','2019-08-15 13:55:40',0.0684000000,67),(594,'/cgi-bin/cashier_output_dnepr.cgi?do=add','2019-08-15 13:55:43',0.0229950000,67),(595,'/cgi-bin/cashier_output_dnepr.cgi?do=add','2019-08-15 13:55:46',0.0199080000,67),(596,'/cgi-bin/cashier_output_dnepr.cgi?do=add','2019-08-15 13:55:56',0.0222200000,67),(597,'/cgi-bin/cashier_output_dnepr.cgi?do=add','2019-08-15 13:56:15',0.0348520000,67),(598,'/cgi-bin/cashier_output_dnepr.cgi?do=add','2019-08-15 13:56:38',0.0192300000,67),(599,'/cgi-bin/cashier_output_dnepr.cgi?do=list','2019-08-15 13:56:39',0.0381900000,67),(600,'/cgi-bin/cashier_output2_dnepr.cgi?do=list','2019-08-15 13:56:54',0.0241580000,67),(601,'/cgi-bin/cashier_output2_dnepr.cgi?do=list','2019-08-15 13:56:54',0.0246520000,67),(602,'/cgi-bin/cashier_output2_dnepr.cgi?do=edit','2019-08-15 13:56:57',0.0214960000,67),(603,'/cgi-bin/cashier_output2_dnepr.cgi?do=edit','2019-08-15 13:56:59',0.0274710000,67),(604,'/cgi-bin/cashier_output2_dnepr.cgi?do=list','2019-08-15 13:56:59',0.0269940000,67),(605,'/cgi-bin/cashier_output2_dnepr.cgi?do=list','2019-08-15 13:56:59',0.0277080000,67),(606,'/cgi-bin/accounts.cgi?do=list','2019-08-15 13:57:02',0.0249550000,67),(607,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-15 13:57:05',0.0357210000,67),(608,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-15 14:01:27',0.0847010000,67),(609,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-15 14:01:30',0.0316010000,67),(610,'/cgi-bin/cashier_output2_dnepr.cgi?do=list','2019-08-15 14:01:33',0.0271090000,67),(611,'/cgi-bin/cashier_output2_dnepr.cgi?do=list','2019-08-15 14:01:33',0.0277880000,67),(612,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-15 14:01:34',0.0280610000,67),(613,'/cgi-bin/cashier_output_dnepr.cgi?do=list','2019-08-15 14:01:39',0.0263460000,67),(614,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-15 14:01:43',0.0248540000,67),(615,'/cgi-bin/cashier_input_before_dnepr.cgi?do=list','2019-08-15 14:03:08',0.0722080000,67),(616,'/cgi-bin/operators.cgi?do=list','2019-08-15 14:04:32',0.0439580000,67),(617,'/cgi-bin/operators.cgi?do=edit','2019-08-15 14:04:34',0.0262230000,67),(618,'/cgi-bin/operators.cgi?do=edit','2019-08-15 14:04:44',0.0166380000,67),(619,'/cgi-bin/operators.cgi?do=list','2019-08-15 14:04:44',0.0246220000,67),(620,'/cgi-bin/operators.cgi?do=edit','2019-08-15 14:04:47',0.0227500000,67),(621,'/cgi-bin/operators.cgi?do=edit','2019-08-15 14:07:48',0.0598520000,67),(622,'/cgi-bin/operators.cgi?do=edit','2019-08-15 14:08:40',0.0231950000,67),(623,'/cgi-bin/operators.cgi?do=list','2019-08-15 14:08:40',0.0348350000,67),(624,'/cgi-bin/accounts.cgi?do=list','2019-08-15 14:28:17',0.0668830000,67),(625,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-15 14:28:19',0.0504530000,67),(626,'/cgi-bin/accounts.cgi?do=list','2019-08-15 15:29:59',0.0287740000,69),(627,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-15 15:30:01',0.0720440000,69),(628,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-15 15:31:28',0.0507450000,69),(629,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-15 15:31:31',0.0302800000,69),(630,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-15 15:39:34',0.0893180000,67),(631,'/cgi-bin/accounts.cgi?do=list','2019-08-15 15:40:21',0.0266370000,67),(632,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-15 15:40:23',0.0452680000,67),(633,'/cgi-bin/accounts_reports.cgi?do=list','2019-08-15 15:44:14',0.0897090000,67);
/*!40000 ALTER TABLE `logs_posts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `month_works`
--

DROP TABLE IF EXISTS `month_works`;
/*!50001 DROP VIEW IF EXISTS `month_works`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `month_works` AS SELECT 
 1 AS `m`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `non_cash_atrium`
--

DROP TABLE IF EXISTS `non_cash_atrium`;
/*!50001 DROP VIEW IF EXISTS `non_cash_atrium`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `non_cash_atrium` AS SELECT 
 1 AS `ct_amnt`,
 1 AS `ct_date`,
 1 AS `ct_currency`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `non_cash_dnepr`
--

DROP TABLE IF EXISTS `non_cash_dnepr`;
/*!50001 DROP VIEW IF EXISTS `non_cash_dnepr`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `non_cash_dnepr` AS SELECT 
 1 AS `ct_amnt`,
 1 AS `ct_date`,
 1 AS `ct_currency`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `non_cash_kiev`
--

DROP TABLE IF EXISTS `non_cash_kiev`;
/*!50001 DROP VIEW IF EXISTS `non_cash_kiev`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `non_cash_kiev` AS SELECT 
 1 AS `ct_amnt`,
 1 AS `ct_date`,
 1 AS `ct_currency`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `non_cash_odessa`
--

DROP TABLE IF EXISTS `non_cash_odessa`;
/*!50001 DROP VIEW IF EXISTS `non_cash_odessa`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `non_cash_odessa` AS SELECT 
 1 AS `ct_amnt`,
 1 AS `ct_date`,
 1 AS `ct_currency`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `non_resident_payments`
--

DROP TABLE IF EXISTS `non_resident_payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `non_resident_payments` (
  `nrp_id` int(11) NOT NULL AUTO_INCREMENT,
  `nrp_ctid` int(11) NOT NULL,
  `nrp_date` date DEFAULT NULL,
  `nrp_currency` enum('USD','EUR') DEFAULT NULL,
  `nrp_fid` int(11) NOT NULL,
  `nrp_number` int(11) NOT NULL,
  PRIMARY KEY (`nrp_id`)
) ENGINE=MyISAM AUTO_INCREMENT=743 DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `non_resident_payments`
--

LOCK TABLES `non_resident_payments` WRITE;
/*!40000 ALTER TABLE `non_resident_payments` DISABLE KEYS */;
/*!40000 ALTER TABLE `non_resident_payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `oper_sessions`
--

DROP TABLE IF EXISTS `oper_sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `oper_sessions` (
  `os_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `os_session` varchar(32) COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT '',
  `os_oid` int(11) unsigned NOT NULL DEFAULT '0',
  `os_created` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `os_ip` varchar(32) COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT '',
  `os_expired` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `os_status` enum('active','deleted') COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT 'active',
  PRIMARY KEY (`os_id`),
  KEY `os_session` (`os_session`),
  KEY `os_oid` (`os_oid`),
  KEY `os_created` (`os_created`),
  KEY `os_expired` (`os_expired`),
  KEY `os_status` (`os_status`)
) ENGINE=MEMORY AUTO_INCREMENT=17 DEFAULT CHARSET=cp1251 COLLATE=cp1251_ukrainian_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `oper_sessions`
--

LOCK TABLES `oper_sessions` WRITE;
/*!40000 ALTER TABLE `oper_sessions` DISABLE KEYS */;
INSERT INTO `oper_sessions` VALUES (1,'1ddedcac0af04a8ecdd3332343d33efd',67,'2019-07-15 00:27:32','45.76.83.100','2019-07-15 10:27:32','deleted'),(2,'c52ec26a9a2d9b3fced5f499ef480525',68,'2019-07-15 11:17:37','95.67.31.149','2019-07-15 21:17:37','deleted'),(3,'11a478bdfbb0d116912e53204cb2dc12',68,'2019-07-15 11:19:09','95.67.31.149','2019-07-15 21:19:09','deleted'),(4,'a230b0325a2b5bb886c1008d1d2ccf17',68,'2019-07-15 21:55:53','95.67.31.149','2019-07-16 07:55:53','deleted'),(5,'d2386fb7c8628cdabc7dc684efded2c5',68,'2019-07-15 21:58:04','95.67.31.149','2019-07-16 07:58:04','deleted'),(6,'6157764eaeaeb1194f4563207157f245',68,'2019-07-16 17:33:22','46.211.64.106','2019-07-17 03:33:22','deleted'),(7,'f993f7930873879f88243cd9d2b02cd6',68,'2019-07-18 17:20:21','46.182.84.181','2019-07-19 03:20:21','deleted'),(8,'78d2907d54bcdddc8f29217c4a3d0691',68,'2019-07-22 19:08:07','46.211.109.38','2019-07-23 05:08:07','deleted'),(9,'b4e56b9a0ea87285c768baaabc0781f7',67,'2019-08-06 15:52:49','176.187.114.22','2019-08-07 01:52:49','deleted'),(10,'6ff212e9cb5c526d0998d52a149b240f',68,'2019-08-06 15:53:41','176.187.114.22','2019-08-07 01:53:41','deleted'),(11,'a6a6d1eefcb1627da34694f4b8fd1df0',68,'2019-08-06 16:08:42','176.187.114.22','2019-08-07 02:08:42','deleted'),(12,'cf43b63aee844c8963614c8f31033cbd',69,'2019-08-06 17:53:42','176.187.114.22','2019-08-07 03:53:42','active'),(13,'81cf8ce1ff3d8817ef8d6f8e67a327d8',67,'2019-08-14 11:45:39','45.76.83.100','2019-08-14 21:45:39','deleted'),(14,'e54c00859f5c4955ff3cf0b3ba94a770',69,'2019-08-14 12:00:34','45.76.83.100','2019-08-14 22:00:34','active'),(15,'35a459cad8f6a0c9d36cf9e6796eef31',67,'2019-08-15 10:41:02','45.76.83.100','2019-08-15 20:41:02','active'),(16,'78996ebbbdef9dd38930c5b0f131e1e7',69,'2019-08-15 10:41:32','45.76.83.100','2019-08-15 20:41:32','active');
/*!40000 ALTER TABLE `oper_sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `operators`
--

DROP TABLE IF EXISTS `operators`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `operators` (
  `o_id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `o_login` varchar(255) COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT '',
  `o_password` varchar(255) COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT '',
  `o_privileges` text COLLATE cp1251_ukrainian_ci,
  `o_status` enum('active','blocked','deleted') COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT 'active',
  `o_session_data` text COLLATE cp1251_ukrainian_ci,
  `o_type` enum('in','out') COLLATE cp1251_ukrainian_ci DEFAULT 'in',
  `o_greeding` varchar(255) COLLATE cp1251_ukrainian_ci DEFAULT NULL,
  `o_menu_type` enum('grid','line') COLLATE cp1251_ukrainian_ci DEFAULT 'line',
  `o_accounts` text COLLATE cp1251_ukrainian_ci,
  `o_accounts_view` text COLLATE cp1251_ukrainian_ci,
  PRIMARY KEY (`o_id`),
  KEY `o_login` (`o_login`),
  KEY `o_status` (`o_status`)
) ENGINE=InnoDB AUTO_INCREMENT=70 DEFAULT CHARSET=cp1251 COLLATE=cp1251_ukrainian_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `operators`
--

LOCK TABLES `operators` WRITE;
/*!40000 ALTER TABLE `operators` DISABLE KEYS */;
INSERT INTO `operators` VALUES (67,'mysterio','d804cd9cc0c42b0652bab002f67858ab803c40c6','|joke|reports_analytic|firm_out|class|fservice|transfers|account|oper|firm_list|correct|all_firms|firm_in|correct_back|exch_odessa|cash_dnepr|cash_in_before_dnepr|cash_in_dnepr|trans|report|cash_out2_dnepr|firms_exchange|cash_out_dnepr|exchange|settings|transit|firm|cash_in_one_dnepr|firm_in2|','active','\n12345678\0\0\0\0\0\0\n	this_year\0\0\0ct_date\nfilter\0\0\0action\n\0\0\0\0ct_aid\n\0	\0\0\0ct_status\n\0\n\0\0\0ct_comment\n\n2019-08-14\0\0\0ct_date_from\ncash_in_before_dnepr\0\0\0right\n\n2019-08-14\n\0\0\0ct_date_to\ntime_filterperiod\0\0\0type_time_filter\n\0\0\0\0ct_currency\n\0\0\0\0ct_amnt\n\0\0\0\0del_to\0\0\0cash_in_before_dnepr\0\0\0\n1\0\0\0del_to\n257\0\0\0ct_fid\n	firm_list\0\0\0right\nall_time\0\0\0ct_date\nfilter\0\0\0action	\0\0\0firm_list\0\0\0\n\0\0\0\0ct_aid\nfilter\0\0\0action\n	this_year\0\0\0ct_date\n\0\n\0\0\0ct_comment\n\0	\0\0\0ct_status\n\n2019-08-14\0\0\0ct_date_from\n\rcash_in_dnepr\0\0\0right\n\n2019-08-14\n\0\0\0ct_date_to\n\0\0\0\0ct_currency\ntime_filterperiod\0\0\0type_time_filter\n\0\0\0\0ct_amnt\n\0\0\0\0del_to\r\0\0\0cash_in_dnepr\0\0\0\nlist\0\0\0do\noper\0\0\0right\0\0\0oper\0\0\0\nsettings\0\0\0right\n	list_tabs\0\0\0do\0\0\0settings\0\0\0\nget_list_accounts_income\0\0\0do\nreport\0\0\0right\0\0\0report\0\0\0\nlist\0\0\0do\nexchange\0\0\0right\0\0\0exchange\0\0\0\ncash_out2_dnepr\0\0\0right\n\n2019-08-14\0\0\0ct_date_from\n\0\n\0\0\0ct_comment\n\0	\0\0\0ct_status\n\0\0\0\0ct_aid\nfilter\0\0\0action\n	this_year\0\0\0ct_date\n\0\0\0\0del_to\n\0\0\0\0ct_amnt\n\0\0\0\0ct_currency\ntime_filterperiod\0\0\0type_time_filter\n\n2019-08-14\n\0\0\0ct_date_to\0\0\0cash_out2_dnepr\0\0\0\0\0\0\0reports_analytic\0\0\0\n\0\0\0\0del_to\n\0\0\0\0ct_amnt\ntime_filterperiod\0\0\0type_time_filter\n\0\0\0\0ct_currency\n\n2019-08-14\n\0\0\0ct_date_to\n\0\0\0\0ct_fid\ncorrect\0\0\0right\n\n2019-08-14\0\0\0ct_date_from\n\0\n\0\0\0ct_comment\n	this_year\0\0\0ct_date\nfilter\0\0\0action\0\0\0correct\0\0\0\nall_time\0\0\0ct_date\n3\0\0\0ct_aid\nfilter\0\0\0action\naccount\0\0\0right\nlist\0\0\0do\0\0\0account\0\0\0\nfirm_out\0\0\0right\n\0\0\0\0ct_fid\n\n2019-08-14\0\0\0ct_date_from\n\0\n\0\0\0ct_comment\n\0	\0\0\0ct_status\nfilter\0\0\0action\n	this_year\0\0\0ct_date\n\0\0\0\0del_to\n\0\0\0\0ct_ofid\n\0\0\0\0ct_amnt\n\0\0\0\0ct_currency\ntime_filterperiod\0\0\0type_time_filter\n\n2019-08-14\n\0\0\0ct_date_to\n\0\0\0\0out_firm\0\0\0firm_out\r\0\0\0\n\0\0\0\0ct_aid\nfilter\0\0\0action\n	this_year\0\0\0ct_date\n\0\n\0\0\0ct_comment\n\0	\0\0\0ct_status\n\n2019-08-14\0\0\0ct_date_from\n\0\0\0\0ct_fid\nfirm_in2\0\0\0right\n\n2019-08-14\n\0\0\0ct_date_to\n\0\0\0\0ct_currency\ntime_filterperiod\0\0\0type_time_filter\n\0\0\0\0ct_amnt\n\0\0\0\0del_to\0\0\0firm_in2\0\0\0\ndu\0\0\0right\nlist\0\0\0do\nПросмотреть\0\0\0Просмотреть\n1\0\0\0resident\n\n2019-08-14\0\0\0date\0\0\0du\0\0\0\ntime_filterperiod\0\0\0type_time_filter\n\0\0\0\0ct_currency\n\n2019-08-14\n\0\0\0ct_date_to\n\0\0\0\0del_to\n\0\0\0\0ct_amnt\n\0	\0\0\0ct_status\n\0\n\0\0\0ct_comment\n	this_year\0\0\0ct_date\n\0\0\0\0ct_aid\nfilter\0\0\0action\ncash_out_dnepr\0\0\0right\n\n2019-08-14\0\0\0ct_date_from\0\0\0cash_out_dnepr\0\0\0\n\0\0\0\0ct_fid\nfirm_in\0\0\0right\n\n2019-08-14\0\0\0ct_date_from\n\0\n\0\0\0ct_comment\n	this_year\0\0\0ct_date\nfilter\0\0\0action\n\0\0\0\0del_to\n\0\0\0\0ct_amnt\ntime_filterperiod\0\0\0type_time_filter\n\0\0\0\0ct_currency\n\0\0\0\0ct_req\n\n2019-08-14\n\0\0\0ct_date_to\0\0\0firm_in\0\0\0\n\ncash_dnepr\0\0\0right\nlist\0\0\0do\nfilter\0\0\0action\nall_time\0\0\0ct_date\n\0\0\0cash_dnepr','in','','line',NULL,NULL),(68,'maria','d804cd9cc0c42b0652bab002f67858ab803c40c6','|account|class|firm|','deleted','\n12345678\0\0\0\n\0\0\0\n\0	\0\0\0a_is_debt\nfilter\0\0\0action\n\0\0\0\0del_to\n67\0\0\0a_oid\n\0\0\0\0a_issubs\nMaster\0\0\0a_class\nactive\0\0\0a_status\naccount\0\0\0right\n\0\0\0\0a_id\n\0\0\0\0a_name\0\0\0account','in','hello world','line','|2|','|2|'),(69,'maria','d804cd9cc0c42b0652bab002f67858ab803c40c6','|firm_in|cash_in_dnepr|exchange|correct_back|oper|report|firm_list|cash_out_dnepr|cash_in_before_dnepr|du|firm|settings|cash_out2_dnepr|account|firm_in2|firm_out|correct|transfers|rates|cash_dnepr|credit_perms|','active','\n12345678\0\0\0\n\0\0\0\n\0\0\0\0e_currency2\n\0\0\0\0e_currency1\nfilter\0\0\0action\ntime_filterperiod\0\0\0type_time_filter\n\n2019-08-15	\0\0\0e_date_to\n	this_year\0\0\0e_date\n\0\0\0\0a_id\nexchange\0\0\0right\n\0\0\0\0del_to\n\n2019-08-15\0\0\0e_date_from\0\0\0exchange\0\0\0\n\n2019-08-14\n\0\0\0ct_date_to\ntime_filterperiod\0\0\0type_time_filter\nfilter\0\0\0action\n\0\n\0\0\0ct_comment\n\n2019-08-14\0\0\0ct_date_from\n\0	\0\0\0ct_status\n	this_year\0\0\0ct_date\n\0\0\0\0ct_amnt\n\0\0\0\0ct_currency\n\0\0\0\0del_to\n\rcash_in_dnepr\0\0\0right\n\0\0\0\0ct_aid\r\0\0\0cash_in_dnepr\0\0\0\n\ncash_dnepr\0\0\0right\nall_time\0\0\0ct_date\nlist\0\0\0do\nfilter\0\0\0action\n\0\0\0cash_dnepr\0\0\0\n\0\0\0\0ct_currency\n\0	\0\0\0ct_status\n	this_year\0\0\0ct_date\n\0\0\0\0ct_amnt\ncash_in_before_dnepr\0\0\0right\n\0\0\0\0ct_aid\n\0\0\0\0del_to\n\n2019-08-14\n\0\0\0ct_date_to\ntime_filterperiod\0\0\0type_time_filter\nfilter\0\0\0action\n\0\n\0\0\0ct_comment\n\n2019-08-14\0\0\0ct_date_from\0\0\0cash_in_before_dnepr\0\0\0\n\0\0\0\0out_firm\n\0	\0\0\0ct_status\n	this_year\0\0\0ct_date\n\0\0\0\0ct_amnt\n\0\0\0\0ct_currency\n\0\0\0\0del_to\nfirm_out\0\0\0right\n\n2019-08-14\n\0\0\0ct_date_to\n\0\0\0\0ct_ofid\nfilter\0\0\0action\ntime_filterperiod\0\0\0type_time_filter\n\0\n\0\0\0ct_comment\n\n2019-08-14\0\0\0ct_date_from\n257\0\0\0ct_fid\0\0\0firm_out\0\0\0\n1\0\0\0del_to\naccount\0\0\0right\n3\0\0\0ct_aid\nall_time\0\0\0ct_date\nfilter\0\0\0action\0\0\0account\0\0\0\nlist\0\0\0do\n	all_firms\0\0\0right\n\n2019-08-15\0\0\0date\nПросмотреть\0\0\0Просмотреть	\0\0\0all_firms\0\0\0\nall_time\0\0\0ct_date\nfilter\0\0\0action\n	firm_list\0\0\0right\n257\0\0\0ct_fid	\0\0\0firm_list\0\0\0\n\0\0\0\0del_to\nfirm_in\0\0\0right\ntoday\0\0\0ct_date\n\0\0\0\0ct_amnt\n\0\0\0\0ct_currency\n\n2019-08-14\0\0\0ct_date_from\n\0\0\0\0ct_fid\n\0\0\0\0ct_req\n\0\n\0\0\0ct_comment\ntime_filterperiod\0\0\0type_time_filter\nfilter\0\0\0action\n\n2019-08-14\n\0\0\0ct_date_to\0\0\0firm_in\0\0\0\nlist_out\0\0\0do\noper\0\0\0right\0\0\0oper\0\0\0\0\0\0\0report\r\0\0\0\n\0\0\0\0ct_aid\nfirm_in2\0\0\0right\n\0\0\0\0del_to\n\0\0\0\0ct_currency\n\0	\0\0\0ct_status\n	this_year\0\0\0ct_date\n\0\0\0\0ct_amnt\n\0\n\0\0\0ct_comment\n\n2019-08-14\0\0\0ct_date_from\n\0\0\0\0ct_fid\n\n2019-08-14\n\0\0\0ct_date_to\ntime_filterperiod\0\0\0type_time_filter\nfilter\0\0\0action\0\0\0firm_in2\0\0\0\n\n2019-08-14\n\0\0\0ct_date_to\ntime_filterperiod\0\0\0type_time_filter\nfilter\0\0\0action\n\0\n\0\0\0ct_comment\n\n2019-08-14\0\0\0ct_date_from\n\0\0\0\0ct_currency\n\0	\0\0\0ct_status\n\0\0\0\0ct_amnt\n	this_year\0\0\0ct_date\ncash_out_dnepr\0\0\0right\n\0\0\0\0ct_aid\n\0\0\0\0del_to\0\0\0cash_out_dnepr\0\0\0\nlist\0\0\0do\nrates\0\0\0right\0\0\0rates','in','','line',NULL,NULL);
/*!40000 ALTER TABLE `operators` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `operators_accounts_access_view`
--

DROP TABLE IF EXISTS `operators_accounts_access_view`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `operators_accounts_access_view` (
  `oaav_aid` int(11) NOT NULL,
  `oaav_oid` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `operators_accounts_access_view`
--

LOCK TABLES `operators_accounts_access_view` WRITE;
/*!40000 ALTER TABLE `operators_accounts_access_view` DISABLE KEYS */;
INSERT INTO `operators_accounts_access_view` VALUES (3,69),(3,67),(1,67),(3,68),(1,68),(2,68),(1,69);
/*!40000 ALTER TABLE `operators_accounts_access_view` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `operators_accounts_cashier_out`
--

DROP TABLE IF EXISTS `operators_accounts_cashier_out`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `operators_accounts_cashier_out` (
  `oaco_id` int(11) NOT NULL AUTO_INCREMENT,
  `oaco_oid` int(11) DEFAULT NULL,
  `oaco_aid` int(11) DEFAULT NULL,
  PRIMARY KEY (`oaco_id`)
) ENGINE=MyISAM AUTO_INCREMENT=363068 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `operators_accounts_cashier_out`
--

LOCK TABLES `operators_accounts_cashier_out` WRITE;
/*!40000 ALTER TABLE `operators_accounts_cashier_out` DISABLE KEYS */;
INSERT INTO `operators_accounts_cashier_out` VALUES (363028,68,4),(363037,68,5),(363001,68,3),(363000,68,1),(362999,68,2),(363040,68,5),(363031,68,4),(363067,67,3),(363043,68,6),(363059,69,3),(363066,67,1),(363046,68,6),(363058,69,1);
/*!40000 ALTER TABLE `operators_accounts_cashier_out` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `operators_clients`
--

DROP TABLE IF EXISTS `operators_clients`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `operators_clients` (
  `oc_oid` int(11) NOT NULL DEFAULT '0',
  `oc_aid` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`oc_oid`,`oc_aid`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `operators_clients`
--

LOCK TABLES `operators_clients` WRITE;
/*!40000 ALTER TABLE `operators_clients` DISABLE KEYS */;
/*!40000 ALTER TABLE `operators_clients` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `operators_firms`
--

DROP TABLE IF EXISTS `operators_firms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `operators_firms` (
  `of_oid` int(11) NOT NULL DEFAULT '0',
  `of_fid` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`of_fid`,`of_oid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `operators_firms`
--

LOCK TABLES `operators_firms` WRITE;
/*!40000 ALTER TABLE `operators_firms` DISABLE KEYS */;
/*!40000 ALTER TABLE `operators_firms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `operators_notes`
--

DROP TABLE IF EXISTS `operators_notes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `operators_notes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `date` date DEFAULT NULL,
  `comment` varchar(255) DEFAULT NULL,
  `title` varchar(60) DEFAULT NULL,
  `o_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MEMORY DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `operators_notes`
--

LOCK TABLES `operators_notes` WRITE;
/*!40000 ALTER TABLE `operators_notes` DISABLE KEYS */;
/*!40000 ALTER TABLE `operators_notes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `out_firms`
--

DROP TABLE IF EXISTS `out_firms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `out_firms` (
  `of_id` int(11) NOT NULL AUTO_INCREMENT,
  `of_okpo` varchar(100) DEFAULT NULL,
  `of_name` varchar(255) NOT NULL,
  `of_ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `of_oid` int(11) DEFAULT NULL,
  PRIMARY KEY (`of_id`)
) ENGINE=MyISAM AUTO_INCREMENT=9430 DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `out_firms`
--

LOCK TABLES `out_firms` WRITE;
/*!40000 ALTER TABLE `out_firms` DISABLE KEYS */;
/*!40000 ALTER TABLE `out_firms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `out_firms_cashier_transactions`
--

DROP TABLE IF EXISTS `out_firms_cashier_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `out_firms_cashier_transactions` (
  `ofct_id` int(11) NOT NULL AUTO_INCREMENT,
  `ofct_ctid` int(11) NOT NULL,
  `ofct_ofid` int(11) NOT NULL,
  PRIMARY KEY (`ofct_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `out_firms_cashier_transactions`
--

LOCK TABLES `out_firms_cashier_transactions` WRITE;
/*!40000 ALTER TABLE `out_firms_cashier_transactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `out_firms_cashier_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `out_firms_history`
--

DROP TABLE IF EXISTS `out_firms_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `out_firms_history` (
  `ofh_id` int(11) NOT NULL AUTO_INCREMENT,
  `ofh_ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ofh_ofid` int(11) NOT NULL,
  `ofh_oid` int(11) DEFAULT NULL,
  `ofh_old_name` varchar(255) DEFAULT NULL,
  `ofh_old_okpo` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`ofh_id`)
) ENGINE=MyISAM AUTO_INCREMENT=23 DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `out_firms_history`
--

LOCK TABLES `out_firms_history` WRITE;
/*!40000 ALTER TABLE `out_firms_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `out_firms_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `out_firms_okpo`
--

DROP TABLE IF EXISTS `out_firms_okpo`;
/*!50001 DROP VIEW IF EXISTS `out_firms_okpo`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `out_firms_okpo` AS SELECT 
 1 AS `of_id`,
 1 AS `of_okpo`,
 1 AS `of_name`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `owners`
--

DROP TABLE IF EXISTS `owners`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `owners` (
  `ow_id` int(11) NOT NULL AUTO_INCREMENT,
  `ow_aid` int(11) NOT NULL,
  `ow_percent_incom` float(3,2) NOT NULL,
  `ow_percent_office` float(3,2) NOT NULL,
  `ow_is_system` enum('yes','no') DEFAULT 'no',
  PRIMARY KEY (`ow_id`)
) ENGINE=MyISAM AUTO_INCREMENT=365 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `owners`
--

LOCK TABLES `owners` WRITE;
/*!40000 ALTER TABLE `owners` DISABLE KEYS */;
/*!40000 ALTER TABLE `owners` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `owners_without`
--

DROP TABLE IF EXISTS `owners_without`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `owners_without` (
  `ow_id` int(11) NOT NULL AUTO_INCREMENT,
  `ow_aid` int(11) NOT NULL,
  `ow_percent_incom` float(3,2) NOT NULL,
  `ow_percent_office` float(3,2) NOT NULL,
  `ow_is_system` enum('yes','no') DEFAULT 'no',
  PRIMARY KEY (`ow_id`)
) ENGINE=MyISAM AUTO_INCREMENT=364 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `owners_without`
--

LOCK TABLES `owners_without` WRITE;
/*!40000 ALTER TABLE `owners_without` DISABLE KEYS */;
/*!40000 ALTER TABLE `owners_without` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `penalties`
--

DROP TABLE IF EXISTS `penalties`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `penalties` (
  `p_id` int(11) NOT NULL AUTO_INCREMENT,
  `p_tid` int(11) NOT NULL,
  `p_date_from` date DEFAULT NULL,
  `p_date_to` date DEFAULT NULL,
  `p_percent` float DEFAULT NULL,
  `p_oid` int(11) NOT NULL,
  `p_aid` int(11) NOT NULL,
  `p_amnt` float(7,2) DEFAULT NULL,
  `p_status` enum('created','deleted') DEFAULT 'created',
  PRIMARY KEY (`p_id`)
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `penalties`
--

LOCK TABLES `penalties` WRITE;
/*!40000 ALTER TABLE `penalties` DISABLE KEYS */;
/*!40000 ALTER TABLE `penalties` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `plugins`
--

DROP TABLE IF EXISTS `plugins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plugins` (
  `p_id` int(11) NOT NULL AUTO_INCREMENT,
  `p_name` varchar(255) NOT NULL,
  `p_code` mediumtext,
  `p_oid` int(11) DEFAULT NULL,
  `p_ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `p_last_oid_edited` int(11) DEFAULT NULL,
  `p_last_ts_edited` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `p_desc` varchar(255) NOT NULL,
  `p_prototype` text,
  `p_presql` text,
  PRIMARY KEY (`p_id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plugins`
--

LOCK TABLES `plugins` WRITE;
/*!40000 ALTER TABLE `plugins` DISABLE KEYS */;
/*!40000 ALTER TABLE `plugins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `rates`
--

DROP TABLE IF EXISTS `rates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `rates` (
  `r_id` int(11) NOT NULL AUTO_INCREMENT,
  `r_ts` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `r_currency1` enum('UAH','USD','EUR') COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT 'UAH',
  `r_currency2` enum('UAH','USD','EUR') COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT 'UAH',
  `r_type` enum('cash','cashless') COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT 'cash',
  `r_rate` float(7,6) DEFAULT NULL,
  `r_oid` int(11) DEFAULT NULL,
  PRIMARY KEY (`r_id`),
  KEY `r_ts` (`r_ts`),
  KEY `r_currency1` (`r_currency1`),
  KEY `r_currency2` (`r_currency2`),
  KEY `r_type` (`r_type`),
  KEY `r_rate` (`r_rate`),
  KEY `r_oid` (`r_oid`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=cp1251 COLLATE=cp1251_ukrainian_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `rates`
--

LOCK TABLES `rates` WRITE;
/*!40000 ALTER TABLE `rates` DISABLE KEYS */;
INSERT INTO `rates` VALUES (1,'2019-08-15 11:14:54','UAH','USD','cash',0.040000,69),(2,'2019-08-15 11:15:14','USD','UAH','cash',1.000000,69),(3,'2019-08-15 11:16:13','UAH','USD','cash',9.999999,69);
/*!40000 ALTER TABLE `rates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reports`
--

DROP TABLE IF EXISTS `reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reports` (
  `cr_id` int(11) NOT NULL AUTO_INCREMENT,
  `cr_ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cr_comments` varchar(255) DEFAULT NULL,
  `cr_xml_detailes` mediumblob,
  `cr_last_ts` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `cr_tids` text,
  `cr_status` enum('created','deleted') DEFAULT 'created',
  `cr_delta` double(12,2) DEFAULT '0.00',
  `cr_income` double(12,2) DEFAULT NULL,
  PRIMARY KEY (`cr_id`)
) ENGINE=MyISAM AUTO_INCREMENT=144 DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reports`
--

LOCK TABLES `reports` WRITE;
/*!40000 ALTER TABLE `reports` DISABLE KEYS */;
/*!40000 ALTER TABLE `reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reports_in_mail`
--

DROP TABLE IF EXISTS `reports_in_mail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reports_in_mail` (
  `rm_id` int(11) NOT NULL AUTO_INCREMENT,
  `rm_date1` date DEFAULT NULL,
  `rm_date2` date DEFAULT NULL,
  `rm_date3` date DEFAULT NULL,
  `rm_id_mail` int(11) DEFAULT NULL,
  `rm_firm` varchar(500) DEFAULT NULL,
  `rm_out_firm` varchar(500) DEFAULT NULL,
  `rm_okpo` varchar(50) DEFAULT NULL,
  `rm_accounts` varchar(500) DEFAULT NULL,
  `rm_sum1` double DEFAULT NULL,
  `rm_sum2` double DEFAULT NULL,
  `rm_sum3` double DEFAULT NULL,
  `rm_sum4` double DEFAULT NULL,
  `rm_sum5` double DEFAULT NULL,
  `rm_sum6` double DEFAULT NULL,
  `rm_pay_form` varchar(100) DEFAULT NULL,
  `rm_accounts_id` int(11) DEFAULT NULL,
  `rm_date_add` date DEFAULT NULL,
  PRIMARY KEY (`rm_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2075 DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reports_in_mail`
--

LOCK TABLES `reports_in_mail` WRITE;
/*!40000 ALTER TABLE `reports_in_mail` DISABLE KEYS */;
/*!40000 ALTER TABLE `reports_in_mail` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reports_mail`
--

DROP TABLE IF EXISTS `reports_mail`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reports_mail` (
  `rm_id` int(11) NOT NULL,
  `rm_date` datetime NOT NULL,
  `rm_size` int(11) NOT NULL,
  `rm_status` enum('new','processed','parsed') NOT NULL DEFAULT 'new'
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reports_mail`
--

LOCK TABLES `reports_mail` WRITE;
/*!40000 ALTER TABLE `reports_mail` DISABLE KEYS */;
/*!40000 ALTER TABLE `reports_mail` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reports_rate`
--

DROP TABLE IF EXISTS `reports_rate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reports_rate` (
  `rr_id` int(11) NOT NULL AUTO_INCREMENT,
  `rr_date` date DEFAULT NULL,
  `rr_rate` float(7,2) DEFAULT NULL,
  PRIMARY KEY (`rr_id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reports_rate`
--

LOCK TABLES `reports_rate` WRITE;
/*!40000 ALTER TABLE `reports_rate` DISABLE KEYS */;
/*!40000 ALTER TABLE `reports_rate` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reports_without`
--

DROP TABLE IF EXISTS `reports_without`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reports_without` (
  `cr_id` int(11) NOT NULL AUTO_INCREMENT,
  `cr_ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cr_comments` varchar(255) DEFAULT NULL,
  `cr_xml_detailes` mediumblob,
  `cr_last_ts` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `cr_tids` text,
  `cr_status` enum('created','deleted') DEFAULT 'created',
  `cr_delta_usd` double(12,2) DEFAULT '0.00',
  `cr_delta_eur` double(12,2) DEFAULT '0.00',
  `cr_delta_uah` double(12,2) DEFAULT '0.00',
  `cr_income_usd` double(12,2) DEFAULT NULL,
  `cr_income_eur` double(12,2) DEFAULT NULL,
  `cr_income_uah` double(12,2) DEFAULT NULL,
  `cr_system_state` mediumblob,
  PRIMARY KEY (`cr_id`)
) ENGINE=MyISAM AUTO_INCREMENT=766 DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reports_without`
--

LOCK TABLES `reports_without` WRITE;
/*!40000 ALTER TABLE `reports_without` DISABLE KEYS */;
/*!40000 ALTER TABLE `reports_without` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reports_without_analytic`
--

DROP TABLE IF EXISTS `reports_without_analytic`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reports_without_analytic` (
  `cr_id` int(11) NOT NULL AUTO_INCREMENT,
  `cr_ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cr_comments` varchar(255) DEFAULT NULL,
  `cr_xml_detailes` mediumblob,
  `cr_last_ts` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `cr_status` enum('created','deleted') DEFAULT 'created',
  `cr_delta_usd` double(12,2) DEFAULT '0.00',
  `cr_delta_eur` double(12,2) DEFAULT '0.00',
  `cr_delta_uah` double(12,2) DEFAULT '0.00',
  `cr_income_usd` double(12,2) DEFAULT NULL,
  `cr_income_eur` double(12,2) DEFAULT NULL,
  `cr_income_uah` double(12,2) DEFAULT NULL,
  `cr_system_state` mediumblob,
  PRIMARY KEY (`cr_id`)
) ENGINE=MyISAM AUTO_INCREMENT=7348 DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reports_without_analytic`
--

LOCK TABLES `reports_without_analytic` WRITE;
/*!40000 ALTER TABLE `reports_without_analytic` DISABLE KEYS */;
/*!40000 ALTER TABLE `reports_without_analytic` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reports_without_temp`
--

DROP TABLE IF EXISTS `reports_without_temp`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `reports_without_temp` (
  `cr_id` int(11) NOT NULL AUTO_INCREMENT,
  `cr_ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `cr_comments` varchar(255) DEFAULT NULL,
  `cr_xml_detailes` mediumblob,
  `cr_last_ts` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `cr_tids` varchar(255) DEFAULT NULL,
  `cr_status` enum('created','deleted') DEFAULT 'created',
  `cr_delta_usd` double(12,2) DEFAULT '0.00',
  `cr_delta_eur` double(12,2) DEFAULT '0.00',
  `cr_delta_uah` double(12,2) DEFAULT '0.00',
  PRIMARY KEY (`cr_id`)
) ENGINE=MyISAM AUTO_INCREMENT=75 DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reports_without_temp`
--

LOCK TABLES `reports_without_temp` WRITE;
/*!40000 ALTER TABLE `reports_without_temp` DISABLE KEYS */;
/*!40000 ALTER TABLE `reports_without_temp` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `services_class`
--

DROP TABLE IF EXISTS `services_class`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `services_class` (
  `sc_fsid` int(11) NOT NULL DEFAULT '0',
  `sc_cid` int(11) NOT NULL DEFAULT '0',
  `sc_percent` float(7,2) DEFAULT '0.00',
  PRIMARY KEY (`sc_fsid`,`sc_cid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `services_class`
--

LOCK TABLES `services_class` WRITE;
/*!40000 ALTER TABLE `services_class` DISABLE KEYS */;
INSERT INTO `services_class` VALUES (66,23,1.00),(67,23,8.00),(66,24,0.00),(67,24,0.00);
/*!40000 ALTER TABLE `services_class` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `stat_operators`
--

DROP TABLE IF EXISTS `stat_operators`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `stat_operators` (
  `o_id` int(11) NOT NULL AUTO_INCREMENT,
  `o_password` varchar(255) DEFAULT NULL,
  `o_login` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`o_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `stat_operators`
--

LOCK TABLES `stat_operators` WRITE;
/*!40000 ALTER TABLE `stat_operators` DISABLE KEYS */;
/*!40000 ALTER TABLE `stat_operators` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_rates`
--

DROP TABLE IF EXISTS `system_rates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_rates` (
  `sr_id` int(11) NOT NULL AUTO_INCREMENT,
  `sr_uah_nal` double(12,8) DEFAULT NULL,
  `sr_uah_domi` double(12,8) DEFAULT NULL,
  `sr_eur_nal` double(12,8) DEFAULT NULL,
  `sr_eur_domi` double(12,8) DEFAULT NULL,
  `sr_date` date DEFAULT NULL,
  `sr_uah_avarage` double(12,10) DEFAULT NULL,
  `sr_eur_avarage` double(12,10) DEFAULT NULL,
  PRIMARY KEY (`sr_id`)
) ENGINE=MyISAM AUTO_INCREMENT=1441 DEFAULT CHARSET=cp1251;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_rates`
--

LOCK TABLES `system_rates` WRITE;
/*!40000 ALTER TABLE `system_rates` DISABLE KEYS */;
/*!40000 ALTER TABLE `system_rates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `trans_view`
--

DROP TABLE IF EXISTS `trans_view`;
/*!50001 DROP VIEW IF EXISTS `trans_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `trans_view` AS SELECT 
 1 AS `t_id`,
 1 AS `t_ts_mysql`,
 1 AS `t_ts`,
 1 AS `t_aid1`,
 1 AS `t_aid2`,
 1 AS `class_id1`,
 1 AS `class1`,
 1 AS `class_id2`,
 1 AS `class2`,
 1 AS `t_amnt`,
 1 AS `t_currency`,
 1 AS `t_comment`,
 1 AS `t_oid`,
 1 AS `a_name1`,
 1 AS `a_name2`,
 1 AS `o_login`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `transactions`
--

DROP TABLE IF EXISTS `transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transactions` (
  `t_id` int(11) NOT NULL AUTO_INCREMENT,
  `t_ts` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `t_aid1` int(11) NOT NULL DEFAULT '0',
  `t_aid2` int(11) NOT NULL DEFAULT '0',
  `t_amnt` double(22,10) DEFAULT NULL,
  `t_currency` enum('UAH','USD','EUR') COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT 'UAH',
  `t_comment` varchar(255) COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT '',
  `t_oid` int(11) DEFAULT NULL,
  `t_status` enum('no','system') COLLATE cp1251_ukrainian_ci DEFAULT 'no',
  `col_status` enum('yes','no') COLLATE cp1251_ukrainian_ci DEFAULT 'no',
  `col_ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_status` enum('processed','deleted') COLLATE cp1251_ukrainian_ci DEFAULT 'processed',
  `t_amnt_before2` double(12,2) DEFAULT NULL,
  `t_amnt_before1` double(12,2) DEFAULT NULL,
  `col_color` int(11) DEFAULT '16777215',
  PRIMARY KEY (`t_id`),
  KEY `t_aid1` (`t_aid1`),
  KEY `t_aid2` (`t_aid2`),
  KEY `t_amnt` (`t_amnt`),
  KEY `t_currency` (`t_currency`),
  KEY `t_comment` (`t_comment`),
  KEY `operator_transactions` (`t_oid`),
  KEY `currency_transactions` (`t_currency`),
  KEY `benfrec_transactions` (`t_aid1`,`t_aid2`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=cp1251 COLLATE=cp1251_ukrainian_ci
/*!50100 PARTITION BY RANGE (t_id)
(PARTITION p0 VALUES LESS THAN (573966) ENGINE = InnoDB,
 PARTITION p1 VALUES LESS THAN (800000) ENGINE = InnoDB,
 PARTITION p2 VALUES LESS THAN (950000) ENGINE = InnoDB,
 PARTITION p3 VALUES LESS THAN (1100000) ENGINE = InnoDB,
 PARTITION p4 VALUES LESS THAN (1300000) ENGINE = InnoDB) */;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transactions`
--

LOCK TABLES `transactions` WRITE;
/*!40000 ALTER TABLE `transactions` DISABLE KEYS */;
INSERT INTO `transactions` VALUES (1,'2019-08-14 17:55:25',3,1,0.0000000000,'UAH','Комиссия при вводе нала ',69,'no','no','2019-08-14 14:55:25','processed',0.00,0.00,16777215),(2,'2019-08-14 17:55:25',-1,3,2000.0000000000,'UAH','Ввод наличных',69,'no','no','2019-08-14 14:55:25','processed',0.00,0.00,16777215),(3,'2019-08-14 17:55:55',3,-5,1000.0000000000,'UAH','нал. обмен  на , базовый курс не задан',69,'no','no','2019-08-14 14:55:55','processed',0.00,2000.00,16777215),(4,'2019-08-14 17:55:55',-5,3,40.0000000000,'USD','нал. обмен  на , базовый курс не задан',69,'no','no','2019-08-14 14:55:55','processed',0.00,0.00,16777215),(5,'2019-08-14 19:28:18',-4,3,1000.0000000000,'UAH','Ввод безналом',69,'no','no','2019-08-14 16:28:18','processed',1000.00,0.00,16777215),(6,'2019-08-14 19:28:18',-4,3,1001.0000000000,'UAH','Ввод безналом',69,'no','no','2019-08-14 16:28:18','processed',2000.00,-1000.00,16777215),(7,'2019-08-14 19:28:50',3,-4,1000.0000000000,'UAH','Ввод безналом',69,'no','no','2019-08-14 16:28:50','processed',-2001.00,3001.00,16777215),(8,'2019-08-15 11:08:25',-4,3,1000.0000000000,'USD','Ввод безналом',69,'no','no','2019-08-15 08:08:25','processed',40.00,0.00,16777215),(9,'2019-08-15 11:08:25',-4,3,1000.0000000000,'USD','Ввод безналом',69,'no','no','2019-08-15 08:08:25','processed',1040.00,-1000.00,16777215),(10,'2019-08-15 11:08:25',-4,3,13.0000000000,'USD','Ввод безналом',69,'no','no','2019-08-15 08:08:25','processed',2040.00,-2000.00,16777215),(11,'2019-08-15 12:09:05',3,-5,1000.0000000000,'UAH','нал. обмен  на , базовый курс не задан',67,'no','no','2019-08-15 09:09:05','processed',1000.00,2001.00,16777215),(12,'2019-08-15 12:09:05',-5,3,40.0000000000,'USD','нал. обмен  на , базовый курс не задан',67,'no','no','2019-08-15 09:09:05','processed',2053.00,-40.00,16777215),(13,'2019-08-15 16:56:59',3,1,1.1998775635,'UAH','Вывод наличными',67,'no','no','2019-08-15 13:56:59','processed',0.00,1001.00,16777215),(14,'2019-08-15 16:56:59',3,-1,118.7878787879,'UAH','Вывод наличными',67,'no','no','2019-08-15 13:56:59','processed',-2000.00,999.80,16777215),(15,'2019-08-15 18:29:55',3,-5,40.0000000000,'USD','Откат обмена  #72437',69,'no','no','2019-08-15 15:29:55','processed',-80.00,2093.00,16777215),(16,'2019-08-15 18:29:55',-5,3,1000.0000000000,'UAH','Откат обмена  #72437',69,'no','no','2019-08-15 15:29:55','processed',881.01,2000.00,16777215),(17,'2019-08-15 18:35:31',3,-5,40.0000000000,'USD','Откат обмена  #72436',69,'no','no','2019-08-15 15:35:31','processed',-40.00,2053.00,16777215),(18,'2019-08-15 18:35:31',-5,3,1000.0000000000,'UAH','Откат обмена  #72436',69,'no','no','2019-08-15 15:35:31','processed',1881.01,1000.00,16777215),(19,'2019-08-15 18:39:53',3,-5,1000.0000000000,'UAH','нал. обмен  на , базовый курс не задан',67,'no','no','2019-08-15 15:39:53','processed',0.00,2881.01,16777215),(20,'2019-08-15 18:39:54',-5,3,40.0000000000,'USD','нал. обмен  на , базовый курс не задан',67,'no','no','2019-08-15 15:39:54','processed',2013.00,0.00,16777215),(21,'2019-08-15 18:40:17',3,-5,40.0000000000,'USD','нал. обмен  на , базовый курс не задан',67,'no','no','2019-08-15 15:40:17','processed',-40.00,2053.00,16777215),(22,'2019-08-15 18:40:17',-5,3,1080.0000000000,'UAH','нал. обмен  на , базовый курс не задан',67,'no','no','2019-08-15 15:40:17','processed',1881.01,1000.00,16777215);
/*!40000 ALTER TABLE `transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transactions_old`
--

DROP TABLE IF EXISTS `transactions_old`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transactions_old` (
  `t_id` int(11) NOT NULL AUTO_INCREMENT,
  `t_ts` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `t_aid1` int(11) NOT NULL DEFAULT '0',
  `t_aid2` int(11) NOT NULL DEFAULT '0',
  `t_amnt` double(22,10) DEFAULT NULL,
  `t_currency` enum('UAH','USD','EUR') COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT 'UAH',
  `t_comment` varchar(255) COLLATE cp1251_ukrainian_ci NOT NULL DEFAULT '',
  `t_oid` int(11) DEFAULT NULL,
  `t_status` enum('no','system') COLLATE cp1251_ukrainian_ci DEFAULT 'no',
  `col_status` enum('yes','no') COLLATE cp1251_ukrainian_ci DEFAULT 'no',
  `col_ts` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `del_status` enum('processed','deleted') COLLATE cp1251_ukrainian_ci DEFAULT 'processed',
  `t_amnt_before2` double(12,2) DEFAULT NULL,
  `t_amnt_before1` double(12,2) DEFAULT NULL,
  `col_color` int(11) DEFAULT '16777215',
  PRIMARY KEY (`t_id`),
  KEY `t_aid1` (`t_aid1`),
  KEY `t_aid2` (`t_aid2`),
  KEY `t_amnt` (`t_amnt`),
  KEY `t_currency` (`t_currency`),
  KEY `t_comment` (`t_comment`),
  KEY `t_oid` (`t_oid`),
  KEY `amnt_transactions` (`t_amnt`),
  KEY `operator_transactions` (`t_oid`),
  KEY `currency_transactions` (`t_currency`),
  KEY `benfrec_transactions` (`t_aid1`,`t_aid2`)
) ENGINE=InnoDB DEFAULT CHARSET=cp1251 COLLATE=cp1251_ukrainian_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transactions_old`
--

LOCK TABLES `transactions_old` WRITE;
/*!40000 ALTER TABLE `transactions_old` DISABLE KEYS */;
/*!40000 ALTER TABLE `transactions_old` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `transfers`
--

DROP TABLE IF EXISTS `transfers`;
/*!50001 DROP VIEW IF EXISTS `transfers`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `transfers` AS SELECT 
 1 AS `at_id`,
 1 AS `t_id`,
 1 AS `t_amnt`,
 1 AS `o_login`,
 1 AS `o_id`,
 1 AS `t_currency`,
 1 AS `t_aid1`,
 1 AS `t_aid2`,
 1 AS `t_date`,
 1 AS `t_comment`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `transit_view`
--

DROP TABLE IF EXISTS `transit_view`;
/*!50001 DROP VIEW IF EXISTS `transit_view`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `transit_view` AS SELECT 
 1 AS `ct_id1`,
 1 AS `ct_id2`,
 1 AS `f_name1`,
 1 AS `f_name2`,
 1 AS `f_id1`,
 1 AS `f_id2`,
 1 AS `amnt`,
 1 AS `currency`,
 1 AS `o_id`,
 1 AS `ts`,
 1 AS `date`,
 1 AS `o_login`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `usd_cards`
--

DROP TABLE IF EXISTS `usd_cards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `usd_cards` (
  `us_aid` int(11) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usd_cards`
--

LOCK TABLES `usd_cards` WRITE;
/*!40000 ALTER TABLE `usd_cards` DISABLE KEYS */;
/*!40000 ALTER TABLE `usd_cards` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary table structure for view `year_works`
--

DROP TABLE IF EXISTS `year_works`;
/*!50001 DROP VIEW IF EXISTS `year_works`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `year_works` AS SELECT 
 1 AS `d`*/;
SET character_set_client = @saved_cs_client;

--
-- Final view structure for view `accounts_reports_table_union`
--

/*!50001 DROP VIEW IF EXISTS `accounts_reports_table_union`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `accounts_reports_table_union` AS select `accounts_reports_table`.`ct_id` AS `ct_id`,`accounts_reports_table`.`ct_aid` AS `ct_aid`,`accounts_reports_table`.`ct_comment` AS `ct_comment`,`accounts_reports_table`.`ct_oid` AS `ct_oid`,`accounts_reports_table`.`o_login` AS `o_login`,`accounts_reports_table`.`ct_fid` AS `ct_fid`,`accounts_reports_table`.`f_name` AS `f_name`,`accounts_reports_table`.`ct_amnt` AS `ct_amnt`,`accounts_reports_table`.`ct_currency` AS `ct_currency`,`accounts_reports_table`.`comission` AS `comission`,`accounts_reports_table`.`result_amnt` AS `result_amnt`,`accounts_reports_table`.`ct_comis_percent` AS `ct_comis_percent`,`accounts_reports_table`.`ct_ext_commission` AS `ct_ext_commission`,`accounts_reports_table`.`ct_date` AS `ct_date`,`accounts_reports_table`.`e_currency2` AS `e_currency2`,`accounts_reports_table`.`rate` AS `rate`,`accounts_reports_table`.`ct_eid` AS `ct_eid`,`accounts_reports_table`.`ct_ex_comis_type` AS `ct_ex_comis_type`,`accounts_reports_table`.`ts` AS `ts`,`accounts_reports_table`.`col_status` AS `col_status`,`accounts_reports_table`.`col_ts` AS `col_ts`,`accounts_reports_table`.`ct_status` AS `ct_status`,`accounts_reports_table`.`col_color` AS `col_color` from `accounts_reports_table` union all select `accounts_reports_table_archive`.`ct_id` AS `ct_id`,`accounts_reports_table_archive`.`ct_aid` AS `ct_aid`,`accounts_reports_table_archive`.`ct_comment` AS `ct_comment`,`accounts_reports_table_archive`.`ct_oid` AS `ct_oid`,`accounts_reports_table_archive`.`o_login` AS `o_login`,`accounts_reports_table_archive`.`ct_fid` AS `ct_fid`,`accounts_reports_table_archive`.`f_name` AS `f_name`,`accounts_reports_table_archive`.`ct_amnt` AS `ct_amnt`,`accounts_reports_table_archive`.`ct_currency` AS `ct_currency`,`accounts_reports_table_archive`.`comission` AS `comission`,`accounts_reports_table_archive`.`result_amnt` AS `result_amnt`,`accounts_reports_table_archive`.`ct_comis_percent` AS `ct_comis_percent`,`accounts_reports_table_archive`.`ct_ext_commission` AS `ct_ext_commission`,`accounts_reports_table_archive`.`ct_date` AS `ct_date`,`accounts_reports_table_archive`.`e_currency2` AS `e_currency2`,`accounts_reports_table_archive`.`rate` AS `rate`,`accounts_reports_table_archive`.`ct_eid` AS `ct_eid`,`accounts_reports_table_archive`.`ct_ex_comis_type` AS `ct_ex_comis_type`,`accounts_reports_table_archive`.`ts` AS `ts`,`accounts_reports_table_archive`.`col_status` AS `col_status`,`accounts_reports_table_archive`.`col_ts` AS `col_ts`,`accounts_reports_table_archive`.`ct_status` AS `ct_status`,`accounts_reports_table_archive`.`col_color` AS `col_color` from `accounts_reports_table_archive` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `accounts_view`
--

/*!50001 DROP VIEW IF EXISTS `accounts_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `accounts_view` AS select `accounts`.`a_id` AS `a_id`,`accounts`.`a_name` AS `a_name`,`accounts`.`a_issubs` AS `a_issubs`,`accounts`.`a_ts` AS `a_ts`,`accounts`.`a_phones` AS `a_phones`,`accounts`.`a_status` AS `a_status`,`classes`.`c_name` AS `a_class`,`accounts`.`a_aid` AS `a_aid`,`accounts`.`a_uah` AS `a_uah`,`accounts`.`a_usd` AS `a_usd`,`accounts`.`a_eur` AS `a_eur`,`accounts`.`a_isproject` AS `a_isproject`,`accounts`.`a_email` AS `a_email`,`accounts`.`a_oid` AS `a_oid`,`accounts`.`a_incom_id` AS `a_incom_id`,`accounts_num_records`.`anr_num` AS `a_records_number`,`operators_accounts_access_view`.`oaav_aid` AS `oaav_aid`,`operators_accounts_access_view`.`oaav_oid` AS `oaav_oid` from (((`accounts` join `classes`) join `accounts_num_records`) join `operators_accounts_access_view`) where ((`classes`.`c_id` = `accounts`.`a_class`) and (`accounts_num_records`.`anr_aid` = `accounts`.`a_id`) and (`operators_accounts_access_view`.`oaav_aid` = `accounts`.`a_id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `back`
--

/*!50001 DROP VIEW IF EXISTS `back`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `back` AS select `cashier_transactions`.`ct_id` AS `ct_id` from (((`cashier_transactions` left join `exchange_view` on((`exchange_view`.`e_id` = `cashier_transactions`.`ct_eid`))) left join `firms` on((`cashier_transactions`.`ct_fid` = `firms`.`f_id`))) left join `operators` on((`cashier_transactions`.`ct_oid2` = `operators`.`o_id`))) where ((`cashier_transactions`.`ct_aid` = 715) and (`cashier_transactions`.`ct_amnt` > 0) and (`cashier_transactions`.`ct_status` in (_cp1251'processed',_cp1251'deleted',_cp1251'returned'))) union all select `cashier_transactions`.`ct_id` AS `ct_id` from (((`cashier_transactions` left join `exchange_view` on((`exchange_view`.`e_id` = `cashier_transactions`.`ct_eid`))) left join `firms` on((`cashier_transactions`.`ct_fid` = `firms`.`f_id`))) left join `operators` on((`cashier_transactions`.`ct_oid2` = `operators`.`o_id`))) where ((`cashier_transactions`.`ct_aid` = 715) and (`cashier_transactions`.`ct_amnt` < 0) and (`cashier_transactions`.`ct_status` in (_cp1251'processed',_cp1251'deleted',_cp1251'returned'))) union all select `exchange_view`.`e_id` AS `e_id` from (`exchange_view` join `firms`) where ((`exchange_view`.`a_id` = 715) and (`firms`.`f_id` = -(2)) and (`exchange_view`.`e_type` <> 'auto')) union all select `transactions`.`t_id` AS `t_id` from ((`transactions` join `operators`) join `accounts`) where ((`accounts`.`a_id` = 715) and 1 and (`operators`.`o_id` = `transactions`.`t_oid`) and (((`transactions`.`t_aid1` > 1) and (`transactions`.`t_aid2` > 1)) or (`transactions`.`t_status` = _cp1251'system')) and (`accounts`.`a_id` = `transactions`.`t_aid1`)) union all select `transactions`.`t_id` AS `t_id` from ((`transactions` join `operators`) join `accounts`) where ((`accounts`.`a_id` = 715) and 1 and (`operators`.`o_id` = `transactions`.`t_oid`) and (((`transactions`.`t_aid1` > 1) and (`transactions`.`t_aid2` > 1)) or (`transactions`.`t_status` = _cp1251'system')) and (`accounts`.`a_id` = `transactions`.`t_aid2`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `cash_atrium`
--

/*!50001 DROP VIEW IF EXISTS `cash_atrium`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `cash_atrium` AS select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts2` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_fid` = -(34)) and (`cashier_transactions`.`ct_amnt` > 0) and (`cashier_transactions`.`ct_status` in (_cp1251'processed',_cp1251'returned')) and (`cashier_transactions`.`ct_currency` = _cp1251'UAH')) group by cast(`cashier_transactions`.`ct_ts2` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts2` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_amnt` < 0) and (`cashier_transactions`.`ct_fid` = -(34)) and (`cashier_transactions`.`ct_status` in (_cp1251'processed',_cp1251'returned')) and (`cashier_transactions`.`ct_currency` = _cp1251'UAH')) group by cast(`cashier_transactions`.`ct_ts2` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts2` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_fid` = -(34)) and (`cashier_transactions`.`ct_amnt` > 0) and (`cashier_transactions`.`ct_status` in (_cp1251'processed',_cp1251'returned')) and (`cashier_transactions`.`ct_currency` = _cp1251'USD')) group by cast(`cashier_transactions`.`ct_ts2` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts2` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_amnt` < 0) and (`cashier_transactions`.`ct_fid` = -(34)) and (`cashier_transactions`.`ct_status` in (_cp1251'processed',_cp1251'returned')) and (`cashier_transactions`.`ct_currency` = _cp1251'USD')) group by cast(`cashier_transactions`.`ct_ts2` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts2` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_fid` = -(34)) and (`cashier_transactions`.`ct_amnt` > 0) and (`cashier_transactions`.`ct_status` in (_cp1251'processed',_cp1251'returned')) and (`cashier_transactions`.`ct_currency` = _cp1251'EUR')) group by cast(`cashier_transactions`.`ct_ts2` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts2` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_amnt` < 0) and (`cashier_transactions`.`ct_fid` = -(34)) and (`cashier_transactions`.`ct_status` in (_cp1251'processed',_cp1251'returned')) and (`cashier_transactions`.`ct_currency` = _cp1251'EUR')) group by cast(`cashier_transactions`.`ct_ts2` as date) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `cash_dnepr`
--

/*!50001 DROP VIEW IF EXISTS `cash_dnepr`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `cash_dnepr` AS select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts2` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_fid` = -(1)) and (`cashier_transactions`.`ct_amnt` > 0) and (`cashier_transactions`.`ct_status` in (_cp1251'processed',_cp1251'returned')) and (`cashier_transactions`.`ct_currency` = _cp1251'UAH')) group by cast(`cashier_transactions`.`ct_ts2` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts2` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_amnt` < 0) and (`cashier_transactions`.`ct_fid` = -(1)) and (`cashier_transactions`.`ct_status` in (_cp1251'processed',_cp1251'returned')) and (`cashier_transactions`.`ct_currency` = _cp1251'UAH')) group by cast(`cashier_transactions`.`ct_ts2` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts2` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_fid` = -(1)) and (`cashier_transactions`.`ct_amnt` > 0) and (`cashier_transactions`.`ct_status` in (_cp1251'processed',_cp1251'returned')) and (`cashier_transactions`.`ct_currency` = _cp1251'USD')) group by cast(`cashier_transactions`.`ct_ts2` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts2` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_amnt` < 0) and (`cashier_transactions`.`ct_fid` = -(1)) and (`cashier_transactions`.`ct_status` in (_cp1251'processed',_cp1251'returned')) and (`cashier_transactions`.`ct_currency` = _cp1251'USD')) group by cast(`cashier_transactions`.`ct_ts2` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts2` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_fid` = -(1)) and (`cashier_transactions`.`ct_amnt` > 0) and (`cashier_transactions`.`ct_status` in (_cp1251'processed',_cp1251'returned')) and (`cashier_transactions`.`ct_currency` = _cp1251'EUR')) group by cast(`cashier_transactions`.`ct_ts2` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts2` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_amnt` < 0) and (`cashier_transactions`.`ct_fid` = -(1)) and (`cashier_transactions`.`ct_status` in (_cp1251'processed',_cp1251'returned')) and (`cashier_transactions`.`ct_currency` = _cp1251'EUR')) group by cast(`cashier_transactions`.`ct_ts2` as date) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `cash_kiev`
--

/*!50001 DROP VIEW IF EXISTS `cash_kiev`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `cash_kiev` AS select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts2` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_fid` = -(33)) and (`cashier_transactions`.`ct_amnt` > 0) and (`cashier_transactions`.`ct_status` in (_cp1251'processed',_cp1251'returned')) and (`cashier_transactions`.`ct_currency` = _cp1251'UAH')) group by cast(`cashier_transactions`.`ct_ts2` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts2` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_amnt` < 0) and (`cashier_transactions`.`ct_fid` = -(33)) and (`cashier_transactions`.`ct_status` in (_cp1251'processed',_cp1251'returned')) and (`cashier_transactions`.`ct_currency` = _cp1251'UAH')) group by cast(`cashier_transactions`.`ct_ts2` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts2` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_fid` = -(33)) and (`cashier_transactions`.`ct_amnt` > 0) and (`cashier_transactions`.`ct_status` in (_cp1251'processed',_cp1251'returned')) and (`cashier_transactions`.`ct_currency` = _cp1251'USD')) group by cast(`cashier_transactions`.`ct_ts2` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts2` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_amnt` < 0) and (`cashier_transactions`.`ct_fid` = -(33)) and (`cashier_transactions`.`ct_status` in (_cp1251'processed',_cp1251'returned')) and (`cashier_transactions`.`ct_currency` = _cp1251'USD')) group by cast(`cashier_transactions`.`ct_ts2` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts2` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_fid` = -(33)) and (`cashier_transactions`.`ct_amnt` > 0) and (`cashier_transactions`.`ct_status` in (_cp1251'processed',_cp1251'returned')) and (`cashier_transactions`.`ct_currency` = _cp1251'EUR')) group by cast(`cashier_transactions`.`ct_ts2` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts2` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_amnt` < 0) and (`cashier_transactions`.`ct_fid` = -(33)) and (`cashier_transactions`.`ct_status` in (_cp1251'processed',_cp1251'returned')) and (`cashier_transactions`.`ct_currency` = _cp1251'EUR')) group by cast(`cashier_transactions`.`ct_ts2` as date) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `cash_odessa`
--

/*!50001 DROP VIEW IF EXISTS `cash_odessa`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `cash_odessa` AS select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts2` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_fid` = -(35)) and (`cashier_transactions`.`ct_amnt` > 0) and (`cashier_transactions`.`ct_status` in (_cp1251'processed',_cp1251'returned')) and (`cashier_transactions`.`ct_currency` = _cp1251'UAH')) group by cast(`cashier_transactions`.`ct_ts2` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts2` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_amnt` < 0) and (`cashier_transactions`.`ct_fid` = -(35)) and (`cashier_transactions`.`ct_status` in (_cp1251'processed',_cp1251'returned')) and (`cashier_transactions`.`ct_currency` = _cp1251'UAH')) group by cast(`cashier_transactions`.`ct_ts2` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts2` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_fid` = -(35)) and (`cashier_transactions`.`ct_amnt` > 0) and (`cashier_transactions`.`ct_status` in (_cp1251'processed',_cp1251'returned')) and (`cashier_transactions`.`ct_currency` = _cp1251'USD')) group by cast(`cashier_transactions`.`ct_ts2` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts2` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_amnt` < 0) and (`cashier_transactions`.`ct_fid` = -(35)) and (`cashier_transactions`.`ct_status` in (_cp1251'processed',_cp1251'returned')) and (`cashier_transactions`.`ct_currency` = _cp1251'USD')) group by cast(`cashier_transactions`.`ct_ts2` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts2` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_fid` = -(35)) and (`cashier_transactions`.`ct_amnt` > 0) and (`cashier_transactions`.`ct_status` in (_cp1251'processed',_cp1251'returned')) and (`cashier_transactions`.`ct_currency` = _cp1251'EUR')) group by cast(`cashier_transactions`.`ct_ts2` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts2` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_amnt` < 0) and (`cashier_transactions`.`ct_fid` = -(35)) and (`cashier_transactions`.`ct_status` in (_cp1251'processed',_cp1251'returned')) and (`cashier_transactions`.`ct_currency` = _cp1251'EUR')) group by cast(`cashier_transactions`.`ct_ts2` as date) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `cashier_transactions_comis`
--

/*!50001 DROP VIEW IF EXISTS `cashier_transactions_comis`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `cashier_transactions_comis` AS select `cashier_transactions`.`ct_id` AS `ct_id`,`cashier_transactions`.`ct_ts` AS `ct_ts`,`cashier_transactions`.`ct_aid` AS `ct_aid`,`cashier_transactions`.`ct_amnt` AS `ct_amnt`,`cashier_transactions`.`ct_currency` AS `ct_currency`,`cashier_transactions`.`ct_comment` AS `ct_comment`,`cashier_transactions`.`ct_oid` AS `ct_oid`,`cashier_transactions`.`ct_tid` AS `ct_tid`,`cashier_transactions`.`ct_ts2` AS `ct_ts2`,`cashier_transactions`.`ct_oid2` AS `ct_oid2`,`cashier_transactions`.`ct_status` AS `ct_status`,`cashier_transactions`.`ct_tid2` AS `ct_tid2`,`cashier_transactions`.`ct_date` AS `ct_date`,`cashier_transactions`.`ct_fid` AS `ct_fid`,`cashier_transactions`.`ct_fsid` AS `ct_fsid`,`cashier_transactions`.`ct_tid2_comis` AS `ct_tid2_comis`,`cashier_transactions`.`ct_ext_commission` AS `ct_ext_commission`,`cashier_transactions`.`ct_tid2_ext_com` AS `ct_tid2_ext_com`,`cashier_transactions`.`ct_eid` AS `ct_eid`,`cashier_transactions`.`ct_comis_percent` AS `ct_comis_percent`,`cashier_transactions`.`ct_ex_comis_type` AS `ct_ex_comis_type`,`cashier_transactions`.`ct_infl` AS `ct_infl`,`cashier_transactions`.`ct_req` AS `ct_req`,`cashier_transactions`.`col_status` AS `col_status`,`cashier_transactions`.`col_ts` AS `col_ts`,`cashier_transactions`.`col_color` AS `col_color`,`cashier_transactions`.`ct_usd_eq` AS `ct_usd_eq`,((2 * `cashier_transactions`.`ct_amnt`) / (((2 * ((1 - (`cashier_transactions`.`ct_comis_percent` / 100)) * 100)) / `cashier_transactions`.`ct_comis_percent`) - 1)) AS `ct_comis_result` from `cashier_transactions` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `clients_out_operators`
--

/*!50001 DROP VIEW IF EXISTS `clients_out_operators`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `clients_out_operators` AS select `operators`.`o_id` AS `o_id`,`operators`.`o_login` AS `o_login`,`accounts`.`a_id` AS `a_id`,`accounts`.`a_name` AS `a_name`,`accounts`.`a_uah` AS `a_uah`,`accounts`.`a_email` AS `a_email`,`accounts`.`a_class` AS `a_class` from ((`accounts` join `operators`) join `operators_clients`) where ((`accounts`.`a_id` = `operators_clients`.`oc_aid`) and (`operators`.`o_id` = `operators_clients`.`oc_oid`) and (`accounts`.`a_status` = _cp1251'active')) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `debug`
--

/*!50001 DROP VIEW IF EXISTS `debug`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `debug` AS select `cashier_transactions`.`ct_id` AS `ct_id` from (((`cashier_transactions` left join `exchange_view` on((`exchange_view`.`e_id` = `cashier_transactions`.`ct_eid`))) left join `firms` on((`cashier_transactions`.`ct_fid` = `firms`.`f_id`))) left join `operators` on((`cashier_transactions`.`ct_oid2` = `operators`.`o_id`))) where ((`cashier_transactions`.`ct_aid` = 246) and (`cashier_transactions`.`ct_amnt` > 0) and (`cashier_transactions`.`ct_status` in (_cp1251'processed',_cp1251'deleted',_cp1251'returned'))) union all select `cashier_transactions`.`ct_id` AS `ct_id` from (((`cashier_transactions` left join `exchange_view` on((`exchange_view`.`e_id` = `cashier_transactions`.`ct_eid`))) left join `firms` on((`cashier_transactions`.`ct_fid` = `firms`.`f_id`))) left join `operators` on((`cashier_transactions`.`ct_oid2` = `operators`.`o_id`))) where ((`cashier_transactions`.`ct_aid` = 246) and (`cashier_transactions`.`ct_amnt` < 0) and (`cashier_transactions`.`ct_status` in (_cp1251'processed',_cp1251'deleted',_cp1251'returned'))) union all select `exchange_view`.`e_id` AS `e_id` from (`exchange_view` join `firms`) where ((`exchange_view`.`a_id` = 246) and (`firms`.`f_id` = -(2)) and (`exchange_view`.`e_type` <> 'auto')) union all select `transactions`.`t_id` AS `t_id` from ((`transactions` join `operators`) join `accounts`) where ((`accounts`.`a_id` = 246) and 1 and (`operators`.`o_id` = `transactions`.`t_oid`) and (((`transactions`.`t_aid1` > 1) and (`transactions`.`t_aid2` > 1)) or (`transactions`.`t_status` = _cp1251'system')) and (`accounts`.`a_id` = `transactions`.`t_aid1`)) union all select `transactions`.`t_id` AS `t_id` from ((`transactions` join `operators`) join `accounts`) where ((`accounts`.`a_id` = 246) and 1 and (`operators`.`o_id` = `transactions`.`t_oid`) and (((`transactions`.`t_aid1` > 1) and (`transactions`.`t_aid2` > 1)) or (`transactions`.`t_status` = _cp1251'system')) and (`accounts`.`a_id` = `transactions`.`t_aid2`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `docs_exchange_view`
--

/*!50001 DROP VIEW IF EXISTS `docs_exchange_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `docs_exchange_view` AS select `documents_requests`.`dr_id` AS `dr_id`,cast(`transactions`.`t_ts` as date) AS `date`,`documents_requests`.`dr_amnt` AS `dr_amnt`,`documents_requests`.`dr_comis` AS `dr_comis`,(`documents_requests`.`dr_comis` * (`documents_requests`.`dr_amnt` / 100)) AS `sum_comis`,`documents_requests`.`dr_aid` AS `dr_aid`,`documents_requests`.`dr_fid` AS `dr_fid`,`documents_requests`.`dr_ts` AS `dr_ts`,`documents_requests`.`dr_currency` AS `dr_currency`,`documents_requests`.`dr_ofid_from` AS `dr_ofid_from`,`transactions`.`t_amnt` AS `ct_amnt`,`documents_payments`.`dp_tid` AS `dp_tid`,`documents_requests`.`dr_status` AS `dr_status` from ((`documents_payments` join `documents_requests`) join `transactions`) where (1 and (`documents_payments`.`dp_drid` = `documents_requests`.`dr_id`) and (`documents_payments`.`dp_tid` = `transactions`.`t_id`) and (`transactions`.`t_amnt` <> 0)) union all select `documents_requests`.`dr_id` AS `dr_id`,cast(`transactions`.`t_ts` as date) AS `date`,`documents_requests`.`dr_amnt` AS `dr_amnt`,`documents_requests`.`dr_comis` AS `dr_comis`,(`documents_requests`.`dr_comis` * (`documents_requests`.`dr_amnt` / 100)) AS `sum_comis`,`documents_requests`.`dr_aid` AS `dr_aid`,`documents_requests`.`dr_fid` AS `dr_fid`,`documents_requests`.`dr_ts` AS `dr_ts`,`documents_requests`.`dr_currency` AS `dr_currency`,`documents_requests`.`dr_ofid_from` AS `dr_ofid_from`,(-(1) * `transactions`.`t_amnt`) AS `ct_amnt`,`documents_requests`.`dr_close_tid` AS `dr_close_tid`,`documents_requests`.`dr_status` AS `dr_status` from (`documents_requests` join `transactions`) where (1 and (`documents_requests`.`dr_close_tid` = `transactions`.`t_id`) and (`transactions`.`t_amnt` <> 0) and (`documents_requests`.`dr_close_tid` is not null)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `docs_money`
--

/*!50001 DROP VIEW IF EXISTS `docs_money`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `docs_money` AS select `cashier_transactions`.`ct_id` AS `ct_id`,`cashier_transactions`.`ct_ts` AS `ct_ts`,`cashier_transactions`.`ct_aid` AS `ct_aid`,`cashier_transactions`.`ct_amnt` AS `ct_amnt`,`cashier_transactions`.`ct_currency` AS `ct_currency`,`cashier_transactions`.`ct_comment` AS `ct_comment`,`cashier_transactions`.`ct_oid` AS `ct_oid`,`cashier_transactions`.`ct_tid` AS `ct_tid`,`cashier_transactions`.`ct_ts2` AS `ct_ts2`,`cashier_transactions`.`ct_oid2` AS `ct_oid2`,`cashier_transactions`.`ct_status` AS `ct_status`,`cashier_transactions`.`ct_tid2` AS `ct_tid2`,`cashier_transactions`.`ct_date` AS `ct_date`,`cashier_transactions`.`ct_fid` AS `ct_fid`,`cashier_transactions`.`ct_fsid` AS `ct_fsid`,`cashier_transactions`.`ct_tid2_comis` AS `ct_tid2_comis`,`cashier_transactions`.`ct_ext_commission` AS `ct_ext_commission`,`cashier_transactions`.`ct_tid2_ext_com` AS `ct_tid2_ext_com`,`cashier_transactions`.`ct_eid` AS `ct_eid`,`cashier_transactions`.`ct_comis_percent` AS `ct_comis_percent`,`cashier_transactions`.`ct_ex_comis_type` AS `ct_ex_comis_type`,`cashier_transactions`.`ct_infl` AS `ct_infl`,`cashier_transactions`.`ct_req` AS `ct_req`,`cashier_transactions`.`col_status` AS `col_status`,`cashier_transactions`.`col_ts` AS `col_ts`,`cashier_transactions`.`col_color` AS `col_color`,`cashier_transactions`.`col_oid` AS `col_oid`,`cashier_transactions`.`ct_usd_eq` AS `ct_usd_eq`,`cashier_transactions`.`ct_ofid` AS `ct_ofid`,`cashier_transactions`.`ct_said` AS `ct_said`,`cashier_transactions`.`ct_from_fid2` AS `ct_from_fid2`,`cashier_transactions`.`ct_from_drid` AS `ct_from_drid`,`documents_requests`.`dr_id` AS `dr_id`,`documents_requests`.`dr_comis` AS `dr_comis`,`documents_requests`.`dr_aid` AS `dr_aid`,`documents_requests`.`dr_amnt` AS `dr_amnt`,`documents_requests`.`dr_comment` AS `dr_comment`,`documents_requests`.`dr_fid` AS `dr_fid`,`documents_requests`.`dr_status` AS `dr_status`,`documents_requests`.`dr_ts` AS `dr_ts`,`documents_requests`.`dr_currency` AS `dr_currency`,`documents_requests`.`dr_ofid_from` AS `dr_ofid_from`,`documents_requests`.`dr_oid` AS `dr_oid`,`documents_requests`.`dr_date` AS `dr_date`,`documents_requests`.`dr_close_tid` AS `dr_close_tid` from (`cashier_transactions` join `documents_requests`) where (`cashier_transactions`.`ct_from_drid` = `documents_requests`.`dr_id`) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `documents_payments_view`
--

/*!50001 DROP VIEW IF EXISTS `documents_payments_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `documents_payments_view` AS select `documents_payments`.`dp_id` AS `dp_id`,`documents_requests`.`dr_id` AS `dr_id`,`documents_requests`.`dr_date` AS `dr_date`,`documents_requests`.`dr_amnt` AS `dr_amnt`,`documents_requests`.`dr_comis` AS `dr_comis`,(`documents_requests`.`dr_comis` * (`documents_requests`.`dr_amnt` / 100)) AS `sum_comis`,`documents_requests`.`dr_aid` AS `dr_aid`,`documents_requests`.`dr_comment` AS `dr_comment`,`documents_requests`.`dr_fid` AS `dr_fid`,`firms`.`f_name` AS `f_name`,`documents_requests`.`dr_ts` AS `dr_ts`,`documents_requests`.`dr_currency` AS `dr_currency`,`documents_requests`.`dr_ofid_from` AS `dr_ofid_from`,`transactions`.`t_amnt` AS `ct_amnt`,`accounts`.`a_name` AS `a_name`,`out_firms`.`of_name` AS `of_name`,`documents_payments`.`dp_tid` AS `dp_tid`,`documents_requests`.`dr_status` AS `dr_status` from ((((((`cashier_transactions` join `documents_payments`) join `documents_requests`) join `accounts`) join `firms`) join `out_firms`) join `transactions`) where ((`cashier_transactions`.`ct_id` = `documents_payments`.`dp_ctid`) and (`documents_payments`.`dp_drid` = `documents_requests`.`dr_id`) and (`documents_payments`.`dp_tid` = `transactions`.`t_id`) and (`documents_requests`.`dr_aid` = `accounts`.`a_id`) and (`documents_requests`.`dr_fid` = `firms`.`f_id`) and (`out_firms`.`of_id` = `documents_requests`.`dr_ofid_from`) and (`transactions`.`t_amnt` <> 0) and ((`cashier_transactions`.`ct_status` = _cp1251'processed') or (`cashier_transactions`.`ct_id` = 0))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `documents_transactions_group_firms`
--

/*!50001 DROP VIEW IF EXISTS `documents_transactions_group_firms`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `documents_transactions_group_firms` AS select sum(`documents_transactions`.`dt_amnt`) AS `dt_amnt`,`documents_transactions`.`dt_date` AS `dt_date`,`documents_transactions`.`dt_fid` AS `dt_fid`,`documents_transactions`.`dt_ofid` AS `dt_ofid` from `documents_transactions` where (`documents_transactions`.`dt_status` <> _cp1251'canceled') group by `documents_transactions`.`dt_fid`,concat(year(`documents_transactions`.`dt_date`),_latin1'-',month(`documents_transactions`.`dt_date`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `documents_transactions_group_out_firms`
--

/*!50001 DROP VIEW IF EXISTS `documents_transactions_group_out_firms`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `documents_transactions_group_out_firms` AS select sum(`documents_transactions`.`dt_amnt`) AS `dt_amnt`,`documents_transactions`.`dt_date` AS `dt_date`,`documents_transactions`.`dt_fid` AS `dt_fid`,`documents_transactions`.`dt_ofid` AS `dt_ofid` from `documents_transactions` where (`documents_transactions`.`dt_status` <> _cp1251'canceled') group by `documents_transactions`.`dt_ofid`,concat(year(`documents_transactions`.`dt_date`),_latin1'-',month(`documents_transactions`.`dt_date`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `documents_transactions_okpo`
--

/*!50001 DROP VIEW IF EXISTS `documents_transactions_okpo`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `documents_transactions_okpo` AS select `documents_transactions`.`dt_id` AS `dt_id`,`documents_transactions`.`dt_amnt` AS `dt_amnt`,`documents_transactions`.`dt_currency` AS `dt_currency`,`documents_transactions`.`dt_aid` AS `dt_aid`,`documents_transactions`.`dt_fid` AS `dt_fid`,`documents_transactions`.`dt_comment` AS `dt_comment`,`documents_transactions`.`dt_oid` AS `dt_oid`,`documents_transactions`.`dt_oid2` AS `dt_oid2`,`documents_transactions`.`dt_ts` AS `dt_ts`,`documents_transactions`.`dt_ts2` AS `dt_ts2`,`documents_transactions`.`dt_status` AS `dt_status`,`documents_transactions`.`dt_ofid` AS `dt_ofid`,`documents_transactions`.`dt_date` AS `dt_date`,`documents_transactions`.`dt_drid` AS `dt_drid`,`documents_transactions`.`dt_infl` AS `dt_infl`,`out_firms`.`of_okpo` AS `dt_okpo` from (`documents_transactions` join `out_firms`) where (`documents_transactions`.`dt_ofid` = `out_firms`.`of_id`) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `documents_transactions_view`
--

/*!50001 DROP VIEW IF EXISTS `documents_transactions_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `documents_transactions_view` AS select `documents_transactions`.`dt_id` AS `dt_id`,`documents_transactions`.`dt_amnt` AS `dt_amnt`,`documents_transactions`.`dt_currency` AS `dt_currency`,`documents_transactions`.`dt_aid` AS `dt_aid`,`documents_transactions`.`dt_fid` AS `dt_fid`,`documents_transactions`.`dt_date` AS `dt_date`,`documents_transactions`.`dt_comment` AS `dt_comment`,`documents_transactions`.`dt_oid` AS `dt_oid`,`documents_transactions`.`dt_oid2` AS `dt_oid2`,`documents_transactions`.`dt_ts` AS `dt_ts`,`documents_transactions`.`dt_ts2` AS `dt_ts2`,`documents_transactions`.`dt_status` AS `dt_status`,`documents_transactions`.`dt_ofid` AS `dt_ofid`,`operators_firms`.`of_oid` AS `of_oid` from (`documents_transactions` join `operators_firms`) where (`operators_firms`.`of_fid` = `documents_transactions`.`dt_fid`) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `documents_view_income`
--

/*!50001 DROP VIEW IF EXISTS `documents_view_income`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `documents_view_income` AS select `documents_requests`.`dr_id` AS `dr_id`,concat(`documents_requests`.`dr_fid`,'_',`documents_requests`.`dr_aid`,'_',`documents_requests`.`dr_currency`,'_',`documents_requests`.`dr_ofid_from`) AS `key_field`,`documents_requests`.`dr_fid` AS `dr_fid`,`documents_requests`.`dr_ofid_from` AS `okpo`,`documents_requests`.`dr_ofid_from` AS `dr_ofid_from`,`documents_requests`.`dr_aid` AS `dr_aid`,`documents_requests`.`dr_amnt` AS `dr_amnt`,(`documents_requests`.`dr_comis` * (`documents_requests`.`dr_amnt` / 100)) AS `sum_comis`,`documents_requests`.`dr_comis` AS `percent_comis`,`documents_requests`.`dr_currency` AS `dr_currency`,`documents_requests`.`dr_status` AS `dr_status`,`documents_requests`.`dr_ts` AS `dr_ts`,`documents_requests`.`dr_date` AS `dr_date`,`accounts`.`a_id` AS `a_incom_id`,sum(`documents_payments`.`dp_amnt`) AS `payed_comis`,if(`documents_requests`.`dr_comis`,(`documents_requests`.`dr_amnt` * (sum(`documents_payments`.`dp_amnt`) / (`documents_requests`.`dr_comis` * (`documents_requests`.`dr_amnt` / 100)))),0) AS `payed_income`,if(sum(`documents_payments`.`dp_amnt`),(((`documents_requests`.`dr_comis` * (`documents_requests`.`dr_amnt` / 100)) / sum(`documents_payments`.`dp_amnt`)) <= 1.01),0) AS `is_payed`,((`documents_requests`.`dr_comis` * (`documents_requests`.`dr_amnt` / 100)) / sum(`documents_payments`.`dp_amnt`)) AS `debug_is_payed` from ((`documents_requests` join `accounts`) join `documents_payments`) where ((`documents_payments`.`dp_drid` = `documents_requests`.`dr_id`) and (`accounts`.`a_incom_id` = `documents_requests`.`dr_aid`)) group by `documents_requests`.`dr_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `documents_view_income_new`
--

/*!50001 DROP VIEW IF EXISTS `documents_view_income_new`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `documents_view_income_new` AS select `documents_requests`.`dr_id` AS `dr_id`,`documents_requests`.`dr_fid` AS `dr_fid`,`documents_requests`.`dr_ofid_from` AS `okpo`,`documents_requests`.`dr_ofid_from` AS `dr_ofid_from`,`documents_requests`.`dr_aid` AS `dr_aid`,`documents_requests`.`dr_amnt` AS `dr_amnt`,(`documents_requests`.`dr_comis` * (`documents_requests`.`dr_amnt` / 100)) AS `sum_comis`,`documents_requests`.`dr_comis` AS `percent_comis`,`documents_requests`.`dr_currency` AS `dr_currency`,`documents_requests`.`dr_status` AS `dr_status`,`documents_requests`.`dr_ts` AS `dr_ts`,`documents_requests`.`dr_date` AS `dr_date`,`accounts`.`a_id` AS `a_incom_id`,`transactions`.`t_ts` AS `dr_close_ts` from (((`documents_requests` join `accounts`) join `documents_payments`) join `transactions`) where ((`documents_requests`.`dr_close_tid` = `transactions`.`t_id`) and (`documents_payments`.`dp_drid` = `documents_requests`.`dr_id`) and (`accounts`.`a_incom_id` = `documents_requests`.`dr_aid`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `exchange_view`
--

/*!50001 DROP VIEW IF EXISTS `exchange_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `exchange_view` AS select `exchange`.`e_id` AS `e_id`,`exchange`.`e_date` AS `e_date`,`from`.`t_currency` AS `e_currency1`,`to`.`t_currency` AS `e_currency2`,`from`.`t_comment` AS `t_comment`,`from`.`t_amnt` AS `e_amnt1`,`from`.`t_ts` AS `t_ts`,`from`.`t_ts` AS `t_ts1`,`to`.`t_ts` AS `t_ts2`,`to`.`t_amnt` AS `e_amnt2`,`operators`.`o_login` AS `o_login`,`operators`.`o_id` AS `o_id`,`accounts`.`a_name` AS `a_name`,`accounts`.`a_id` AS `a_id`,`exchange`.`e_rate` AS `e_rate`,`exchange`.`e_rate_base` AS `e_rate_base`,`exchange`.`e_type` AS `e_type`,`exchange`.`col_status` AS `col_status`,`exchange`.`col_ts` AS `col_ts`,`exchange`.`e_status` AS `e_status`,`exchange`.`col_color` AS `col_color` from ((((`transactions` `from` join `transactions` `to`) join `exchange`) join `operators`) join `accounts`) where ((`from`.`t_id` = `exchange`.`e_tid1`) and (`to`.`t_id` = `exchange`.`e_tid2`) and (`accounts`.`a_id` = `from`.`t_aid1`) and (`operators`.`o_id` = `from`.`t_oid`) and (`exchange`.`e_status` in (_cp1251'processed',_cp1251'deleted'))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `firms_exchange_view`
--

/*!50001 DROP VIEW IF EXISTS `firms_exchange_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `firms_exchange_view` AS select `firms_exchange`.`fe_id` AS `fe_id`,`firms_exchange`.`fe_rate` AS `fe_rate`,`f`.`ct_date` AS `fe_date`,`f`.`ct_ts` AS `fe_ts`,`f`.`ct_amnt` AS `fe_amnt1`,`t`.`ct_amnt` AS `fe_amnt2`,`f`.`ct_currency` AS `currency1`,`t`.`ct_currency` AS `currency2`,`t`.`ct_fid` AS `ct_fid`,`t`.`ct_comment` AS `fe_comment`,`t`.`ct_oid` AS `o_id` from ((`firms_exchange` join `cashier_transactions` `f`) join `cashier_transactions` `t`) where ((`f`.`ct_id` = `firms_exchange`.`fe_ctid2_in`) and (`t`.`ct_id` = `firms_exchange`.`fe_ctid2_out`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `firms_out_operators`
--

/*!50001 DROP VIEW IF EXISTS `firms_out_operators`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `firms_out_operators` AS select `operators`.`o_id` AS `o_id`,`operators`.`o_login` AS `o_login`,`firms`.`f_id` AS `f_id`,`firms`.`f_name` AS `f_name`,`firms`.`f_ts` AS `f_ts`,`firms`.`f_phones` AS `f_phones`,`firms`.`f_status` AS `f_status`,`firms`.`f_services` AS `f_services`,`firms`.`f_uah` AS `f_uah`,`firms`.`f_usd` AS `f_usd`,`firms`.`f_eur` AS `f_eur` from ((`firms` join `operators_firms`) join `operators`) where ((`operators_firms`.`of_fid` = `firms`.`f_id`) and (`operators`.`o_id` = `operators_firms`.`of_oid`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `month_works`
--

/*!50001 DROP VIEW IF EXISTS `month_works`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `month_works` AS select month(`cashier_transactions`.`ct_ts`) AS `m` from `cashier_transactions` group by month(`cashier_transactions`.`ct_ts`) having (`m` <> 0) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `non_cash_atrium`
--

/*!50001 DROP VIEW IF EXISTS `non_cash_atrium`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `non_cash_atrium` AS select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_fid` = -(34)) and (`cashier_transactions`.`ct_amnt` > 0) and (`cashier_transactions`.`ct_status` = _cp1251'created') and (`cashier_transactions`.`ct_currency` = _cp1251'UAH')) group by cast(`cashier_transactions`.`ct_ts` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_amnt` < 0) and (`cashier_transactions`.`ct_fid` = -(34)) and (`cashier_transactions`.`ct_status` = _cp1251'created') and (`cashier_transactions`.`ct_currency` = _cp1251'UAH')) group by cast(`cashier_transactions`.`ct_ts` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_fid` = -(34)) and (`cashier_transactions`.`ct_amnt` > 0) and (`cashier_transactions`.`ct_status` = _cp1251'created') and (`cashier_transactions`.`ct_currency` = _cp1251'USD')) group by cast(`cashier_transactions`.`ct_ts` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_amnt` < 0) and (`cashier_transactions`.`ct_fid` = -(34)) and (`cashier_transactions`.`ct_status` = _cp1251'created') and (`cashier_transactions`.`ct_currency` = _cp1251'USD')) group by cast(`cashier_transactions`.`ct_ts` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_fid` = -(34)) and (`cashier_transactions`.`ct_amnt` > 0) and (`cashier_transactions`.`ct_status` = _cp1251'created') and (`cashier_transactions`.`ct_currency` = _cp1251'EUR')) group by cast(`cashier_transactions`.`ct_ts` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_amnt` < 0) and (`cashier_transactions`.`ct_fid` = -(34)) and (`cashier_transactions`.`ct_status` = _cp1251'created') and (`cashier_transactions`.`ct_currency` = _cp1251'EUR')) group by cast(`cashier_transactions`.`ct_ts` as date) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `non_cash_dnepr`
--

/*!50001 DROP VIEW IF EXISTS `non_cash_dnepr`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `non_cash_dnepr` AS select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_fid` = -(1)) and (`cashier_transactions`.`ct_amnt` > 0) and (`cashier_transactions`.`ct_status` = _cp1251'created') and (`cashier_transactions`.`ct_currency` = _cp1251'UAH')) group by cast(`cashier_transactions`.`ct_ts` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_amnt` < 0) and (`cashier_transactions`.`ct_fid` = -(1)) and (`cashier_transactions`.`ct_status` = _cp1251'created') and (`cashier_transactions`.`ct_currency` = _cp1251'UAH')) group by cast(`cashier_transactions`.`ct_ts` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_fid` = -(1)) and (`cashier_transactions`.`ct_amnt` > 0) and (`cashier_transactions`.`ct_status` = _cp1251'created') and (`cashier_transactions`.`ct_currency` = _cp1251'USD')) group by cast(`cashier_transactions`.`ct_ts` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_amnt` < 0) and (`cashier_transactions`.`ct_fid` = -(1)) and (`cashier_transactions`.`ct_status` = _cp1251'created') and (`cashier_transactions`.`ct_currency` = _cp1251'USD')) group by cast(`cashier_transactions`.`ct_ts` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_fid` = -(1)) and (`cashier_transactions`.`ct_amnt` > 0) and (`cashier_transactions`.`ct_status` = _cp1251'created') and (`cashier_transactions`.`ct_currency` = _cp1251'EUR')) group by cast(`cashier_transactions`.`ct_ts` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_amnt` < 0) and (`cashier_transactions`.`ct_fid` = -(1)) and (`cashier_transactions`.`ct_status` = _cp1251'created') and (`cashier_transactions`.`ct_currency` = _cp1251'EUR')) group by cast(`cashier_transactions`.`ct_ts` as date) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `non_cash_kiev`
--

/*!50001 DROP VIEW IF EXISTS `non_cash_kiev`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `non_cash_kiev` AS select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_fid` = -(33)) and (`cashier_transactions`.`ct_amnt` > 0) and (`cashier_transactions`.`ct_status` = _cp1251'created') and (`cashier_transactions`.`ct_currency` = _cp1251'UAH')) group by cast(`cashier_transactions`.`ct_ts` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_amnt` < 0) and (`cashier_transactions`.`ct_fid` = -(33)) and (`cashier_transactions`.`ct_status` = _cp1251'created') and (`cashier_transactions`.`ct_currency` = _cp1251'UAH')) group by cast(`cashier_transactions`.`ct_ts` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_fid` = -(33)) and (`cashier_transactions`.`ct_amnt` > 0) and (`cashier_transactions`.`ct_status` = _cp1251'created') and (`cashier_transactions`.`ct_currency` = _cp1251'USD')) group by cast(`cashier_transactions`.`ct_ts` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_amnt` < 0) and (`cashier_transactions`.`ct_fid` = -(33)) and (`cashier_transactions`.`ct_status` = _cp1251'created') and (`cashier_transactions`.`ct_currency` = _cp1251'USD')) group by cast(`cashier_transactions`.`ct_ts` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_fid` = -(33)) and (`cashier_transactions`.`ct_amnt` > 0) and (`cashier_transactions`.`ct_status` = _cp1251'created') and (`cashier_transactions`.`ct_currency` = _cp1251'EUR')) group by cast(`cashier_transactions`.`ct_ts` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_amnt` < 0) and (`cashier_transactions`.`ct_fid` = -(33)) and (`cashier_transactions`.`ct_status` = _cp1251'created') and (`cashier_transactions`.`ct_currency` = _cp1251'EUR')) group by cast(`cashier_transactions`.`ct_ts` as date) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `non_cash_odessa`
--

/*!50001 DROP VIEW IF EXISTS `non_cash_odessa`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `non_cash_odessa` AS select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_fid` = -(35)) and (`cashier_transactions`.`ct_amnt` > 0) and (`cashier_transactions`.`ct_status` = _cp1251'created') and (`cashier_transactions`.`ct_currency` = _cp1251'UAH')) group by cast(`cashier_transactions`.`ct_ts` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_amnt` < 0) and (`cashier_transactions`.`ct_fid` = -(35)) and (`cashier_transactions`.`ct_status` = _cp1251'created') and (`cashier_transactions`.`ct_currency` = _cp1251'UAH')) group by cast(`cashier_transactions`.`ct_ts` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_fid` = -(35)) and (`cashier_transactions`.`ct_amnt` > 0) and (`cashier_transactions`.`ct_status` = _cp1251'created') and (`cashier_transactions`.`ct_currency` = _cp1251'USD')) group by cast(`cashier_transactions`.`ct_ts` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_amnt` < 0) and (`cashier_transactions`.`ct_fid` = -(35)) and (`cashier_transactions`.`ct_status` = _cp1251'created') and (`cashier_transactions`.`ct_currency` = _cp1251'USD')) group by cast(`cashier_transactions`.`ct_ts` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_fid` = -(35)) and (`cashier_transactions`.`ct_amnt` > 0) and (`cashier_transactions`.`ct_status` = _cp1251'created') and (`cashier_transactions`.`ct_currency` = _cp1251'EUR')) group by cast(`cashier_transactions`.`ct_ts` as date) union all select sum(`cashier_transactions`.`ct_amnt`) AS `ct_amnt`,cast(`cashier_transactions`.`ct_ts` as date) AS `ct_date`,`cashier_transactions`.`ct_currency` AS `ct_currency` from `cashier_transactions` where ((`cashier_transactions`.`ct_amnt` < 0) and (`cashier_transactions`.`ct_fid` = -(35)) and (`cashier_transactions`.`ct_status` = _cp1251'created') and (`cashier_transactions`.`ct_currency` = _cp1251'EUR')) group by cast(`cashier_transactions`.`ct_ts` as date) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `out_firms_okpo`
--

/*!50001 DROP VIEW IF EXISTS `out_firms_okpo`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `out_firms_okpo` AS select `out_firms`.`of_id` AS `of_id`,`out_firms`.`of_okpo` AS `of_okpo`,`out_firms`.`of_name` AS `of_name` from `out_firms` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `trans_view`
--

/*!50001 DROP VIEW IF EXISTS `trans_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `trans_view` AS select `transactions`.`t_id` AS `t_id`,`transactions`.`t_ts` AS `t_ts_mysql`,date_format(`transactions`.`t_ts`,_utf8'%d.%m.%Y %H:%i') AS `t_ts`,`transactions`.`t_aid1` AS `t_aid1`,`transactions`.`t_aid2` AS `t_aid2`,`classes1`.`c_id` AS `class_id1`,`classes1`.`c_name` AS `class1`,`classes2`.`c_id` AS `class_id2`,`classes2`.`c_name` AS `class2`,`transactions`.`t_amnt` AS `t_amnt`,`transactions`.`t_currency` AS `t_currency`,`transactions`.`t_comment` AS `t_comment`,`transactions`.`t_oid` AS `t_oid`,`a1`.`a_name` AS `a_name1`,`a2`.`a_name` AS `a_name2`,`operators`.`o_login` AS `o_login` from (((((`transactions` left join `accounts` `a2` on((`a2`.`a_id` = `transactions`.`t_aid2`))) left join `operators` on((`operators`.`o_id` = `transactions`.`t_oid`))) left join `accounts` `a1` on((`transactions`.`t_aid1` = `a1`.`a_id`))) left join `classes` `classes1` on((`classes1`.`c_id` = `a1`.`a_class`))) left join `classes` `classes2` on((`classes2`.`c_id` = `a2`.`a_class`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `transfers`
--

/*!50001 DROP VIEW IF EXISTS `transfers`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `transfers` AS select `accounts_transfers`.`at_id` AS `at_id`,`transactions`.`t_id` AS `t_id`,`transactions`.`t_amnt` AS `t_amnt`,`operators`.`o_login` AS `o_login`,`operators`.`o_id` AS `o_id`,`transactions`.`t_currency` AS `t_currency`,`transactions`.`t_aid1` AS `t_aid1`,`transactions`.`t_aid2` AS `t_aid2`,`transactions`.`t_ts` AS `t_date`,`transactions`.`t_comment` AS `t_comment` from ((`transactions` join `accounts_transfers`) join `operators`) where ((`transactions`.`t_oid` = `operators`.`o_id`) and (`transactions`.`t_id` = `accounts_transfers`.`at_tid`) and (`accounts_transfers`.`at_status` = _latin1'processed')) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `transit_view`
--

/*!50001 DROP VIEW IF EXISTS `transit_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8 */;
/*!50001 SET character_set_results     = utf8 */;
/*!50001 SET collation_connection      = utf8_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `transit_view` AS select `firms_transit`.`ft_ctid1` AS `ct_id1`,`firms_transit`.`ft_ctid2` AS `ct_id2`,`f_from`.`f_name` AS `f_name1`,`f_to`.`f_name` AS `f_name2`,`f_from`.`f_id` AS `f_id1`,`f_to`.`f_id` AS `f_id2`,`from`.`ct_amnt` AS `amnt`,`from`.`ct_currency` AS `currency`,`to`.`ct_oid` AS `o_id`,`to`.`ct_ts` AS `ts`,`to`.`ct_date` AS `date`,`operators`.`o_login` AS `o_login` from (((((`firms_transit` join `operators`) join `cashier_transactions` `from`) join `cashier_transactions` `to`) join `firms` `f_from`) join `firms` `f_to`) where ((`firms_transit`.`ft_ctid1` = `from`.`ct_id`) and (`firms_transit`.`ft_ctid2` = `to`.`ct_id`) and (`f_from`.`f_id` = `from`.`ct_fid`) and (`f_to`.`f_id` = `to`.`ct_fid`) and (`to`.`ct_oid` = `operators`.`o_id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `year_works`
--

/*!50001 DROP VIEW IF EXISTS `year_works`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = latin1 */;
/*!50001 SET character_set_results     = latin1 */;
/*!50001 SET collation_connection      = latin1_swedish_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `year_works` AS select year(`cashier_transactions`.`ct_ts`) AS `d` from `cashier_transactions` group by year(`cashier_transactions`.`ct_ts`) having (`d` <> 0) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2019-08-15 18:46:28
