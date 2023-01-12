
create table `cmdb_cx` (`id` int(11) NOT NULL AUTO_INCREMENT,`name` varchar(30) ,`codePath` varchar(60) , `logPath` varchar(60),`env` varchar(15),`locationId` int(11), PRIMARY KEY (`id`) );

create table `cmdb_cx_jq` (`id` int(11) not null auto_increment,`jq_id` int(11) , `cx_id` int(11), primary key(`id`));
