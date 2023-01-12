create table `user` (`id` int(11) NOT NULL AUTO_INCREMENT,`name` varchar(20),`passwd` varchar(20),`roleid_cmdb` int(11) NOT NULL DEFAULT 2,  PRIMARY KEY (`id`), UNIQUE key (name) );

insert into `user` (`id` , `name`,`passwd` ,  `roleid_cmdb`) values (1, 'root', '12345678', 1);

create table  `role_cmdb` (`id` int(11) NOT NULL AUTO_INCREMENT,`name` varchar(20),`jq` varchar(1) not null default '0' comment '机器' , `mysql` varchar(1) not null default '0',`redis` varchar(1) not null default '0',`mongodb` varchar(1) not null default '0', `mq` varchar(1) not null default '0', `kafka`varchar(1) not null default '0', `cx` varchar(1) not null default '0' comment '程序',`admin` varchar(1) not null default '0', PRIMARY KEY (`id`), UNIQUE key (`name`));

insert into role_cmdb (`id`,`name`,`jq`,`mysql`,`redis`,`mongodb`,`mq`,`kafka`,`cx`,`admin`) values(1,'root','1','1','1','1','1','1','1','1');
insert into role_cmdb (`id` , `name`) values(2, 'anonymous');

create table  `cmdb_jq` (`id` int(11) NOT NULL AUTO_INCREMENT,`name` varchar(20),`project` varchar(20) ,`admin` varchar(10) not null default 'root',`passwd` varchar(60), `ip` varchar(20) ,`location` varchar(20),`bindip` varchar(20) not null default 0 , `type` varchar(10) comment '服务器类型', `cpu` int(1) not null default 1, `memG` int (4) not null default 0 , `diskG` int(4) not null default 0 , PRIMARY KEY (`id`), UNIQUE key (`location`,`ip` , `name`)) ;

create table `cmdb_info` (`id` int(11) NOT NULL AUTO_INCREMENT,`key` varchar(30) ,`value` varchar(120) ,  PRIMARY KEY (`id`) ,index (`key`));

insert into `cmdb_info`  (`key`, `value` ) values ('jq_type', '云主机,虚拟机');
insert into `cmdb_info`  (`key`, `value` ) values ('jq_location', '腾讯云-yongche,aws-test,aws-online');
insert into `cmdb_info`  (`key`, `value` ) values ('project', '用车,shaoing,cplake,shop');
insert into `cmdb_info`  (`key`, `value` ) values ('cx_env', 'php-fpm,php-psf,php-watch,php-super,php-mc,java,java-tomcat,mc,psf');

create table `cmdb_cx` (`id` int(11) NOT NULL AUTO_INCREMENT,`name` varchar(30),`project` varchar(20) ,`codePath` varchar(60) , `logPath` varchar(60),`env` varchar(15),`git` varchar(60),`dns` varchar(60), PRIMARY KEY (`id`),unique key (`name`,`env`, `project`));

create table `cmdb_cx_jq` (`id` int(11) not null auto_increment,`jq_id` int(11) , `cx_id` int(11), primary key(`id`));
