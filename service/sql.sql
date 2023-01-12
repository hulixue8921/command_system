
create table IF NOT EXISTS `user` (`id` int(11) NOT NULL AUTO_INCREMENT,`name` varchar(20),`passwd` varchar(20),`roleid_cmdb` int(11) NOT NULL DEFAULT 0,  PRIMARY KEY (`id`), UNIQUE key (name) ) engine=INNODB  DEFAULT CHARSET=utf8;


