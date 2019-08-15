-- phpMyAdmin SQL Dump
-- version 3.2.3
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Sep 09, 2010 at 12:09 PM
-- Server version: 5.1.40
-- PHP Version: 5.3.1

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- Database: `fsb`
--

-- --------------------------------------------------------

--
-- Table structure for table `reports_in_mail`
--

-- --------------------------------------------------------

--
-- Table structure for table `reports_in_mail`
--

CREATE TABLE IF NOT EXISTS `reports_in_mail` (
  `rm_id` int(11) NOT NULL AUTO_INCREMENT,
  `rm_date1` date NOT NULL,
  `rm_date2` date NOT NULL,
  `rm_date3` date NOT NULL,
  `rm_id_mail` int(11) NOT NULL,
  `rm_firm` varchar(500) NOT NULL,
  `rm_out_firm` varchar(500) NOT NULL,
  `rm_okpo` varchar(50) NOT NULL,
  `rm_accounts` varchar(500) NOT NULL,
  `rm_sum1` double NOT NULL,
  `rm_sum2` double NOT NULL,
  `rm_sum3` double NOT NULL,
  `rm_sum4` double NOT NULL,
  `rm_sum5` double NOT NULL,
  `rm_sum6` double NOT NULL,
  `rm_pay_form` varchar(100) NOT NULL,
  `rm_accounts_id` int(11) NOT NULL,
  `rm_date_add` date NOT NULL,
  PRIMARY KEY (`rm_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=cp1251 AUTO_INCREMENT=101 ;

-- --------------------------------------------------------
-- --------------------------------------------------------

--
-- Table structure for table `reports_mail`
--

CREATE TABLE IF NOT EXISTS `reports_mail` (
  `rm_id` int(11) NOT NULL,
  `rm_date` datetime NOT NULL,
  `rm_size` int(11) NOT NULL,
  `rm_status` enum('new','processed','parsed') NOT NULL DEFAULT 'new'
) ENGINE=MyISAM DEFAULT CHARSET=cp1251;
