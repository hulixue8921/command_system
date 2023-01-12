create table IF NOT EXISTS `cmdb_info` (`id` int(11) NOT NULL AUTO_INCREMENT,`key` varchar(30) ,`value` varchar(60) ,  PRIMARY KEY (`id`) ,index (`key`)) engine=INNODB  DEFAULT CHARSET=utf8;

