/* create table if not exists model_fabu_project () engine=INNODB  DEFAULT CHARSET=utf8;*/

create table IF NOT EXISTS `user` (`id` int(11) NOT NULL AUTO_INCREMENT,`name` varchar(20),`passwd` varchar(20),`roleid_fabu` int(11) NOT NULL DEFAULT 0,`roleid_fabu_cms` int(11) not null default 0 ,  PRIMARY KEY (`id`), UNIQUE key (name) ) engine=INNODB  DEFAULT CHARSET=utf8;


create table if not exists `model_fabu_fabu` (`id` int(11) not null auto_increment,projectname varchar(20) , git varchar(20) not null , scriptname varchar(20) not null default 'fabu.sh',qaips varchar(30) , onlineips varchar(30),PRIMARY KEY (`id`) , UNIQUE key(projectname) )  engine=INNODB  DEFAULT CHARSET=utf8;



/*  权限控制 */
create table if not exists model_fabu_role (id int (11) not null auto_increment,name varchar(20) , PRIMARY KEY (`id`) , UNIQUE key(name)) engine=INNODB  DEFAULT CHARSET=utf8;


create table if not exists model_fabu_role_fabu (id int(11) not null auto_increment,role_id int(11) not null default 0 , fabu_id int(11) not null default 0,  env_id int(11) not null default 0 comment '1 测试环境 2 正式环境' ,  PRIMARY KEY (`id`)) engine=INNODB  DEFAULT CHARSET=utf8;
