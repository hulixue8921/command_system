#
#===============================================================================
#
#         FILE: Init.pm
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: hlx (), hulixue@xiankan.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 05/20/2020 10:02:46 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

use 5.010;

package Init::Init;
use Encode;
use utf8;

sub Init {
    my $sql        = shift;
    my $config     = shift;
    my $initRoot   = $config->getValue( 'Sys', 'Init_user' );
    my $initPasswd = $config->getValue( 'Sys', 'Init_passwd' );

    my $dbindb = "ENGINE=InnoDB AUTO_INCREMENT=0 DEFAULT CHARSET=utf8;";
    my $dbh    = $sql->get();
    ###用户表结构
    $dbh->do(
"create table IF NOT EXISTS `user` (`id` int(11) NOT NULL AUTO_INCREMENT,name varchar(11) DEFAULT NULL,passwd varchar(41) DEFAULT NULL,roleid int(11) NOT NULL DEFAULT '-1', status int(3) not null default '1', PRIMARY KEY (`id`),  UNIQUE KEY `uname`(`name`)) $dbindb "
    );
    ###角色表结构
    $dbh->do(
"create table IF NOT EXISTS `role` (`id` int(11) NOT NULL AUTO_INCREMENT,`name` varchar(11) DEFAULT NULL, PRIMARY KEY (`id`),UNIQUE KEY `rname`(`name`)) $dbindb "
    );
    ##项目表结构
    $dbh->do(
"create table IF NOT EXISTS `project` (`id` int(11) NOT NULL AUTO_INCREMENT, `name` varchar(100) DEFAULT NULL, `root` int(1) not null default 0 ,PRIMARY KEY (`id`), UNIQUE KEY `pname`(`name`)) $dbindb"
    );
    ##命令表结构
    $dbh->do(
"create table IF NOT EXISTS `order` (`id` int(11) NOT NULL AUTO_INCREMENT, `name` varchar(20) DEFAULT NULL,`path` varchar(100) not null  default 0 ,`css` varchar(300) not null default '{}' , `projectid` int(11) not null default '0', `data` varchar(20) not null default '{}', `binfa` int(3) not null default 0  , PRIMARY KEY (`id`), UNIQUE KEY `oname`(`name`)) $dbindb"
    );
    ##角色、项目关联表
    $dbh->do(
"create table if not exists `r_p` (`id` int(11) not null auto_increment , `roleid` int(11),`projectid` int(11) , primary key(`id`), UNIQUE KEY `r_p`(`roleid`,`projectid`)) $dbindb"
    );

    ###初始化管理员
    $dbh->prepare("insert into user (name,passwd, roleid) values (?, ? ,?);")
      ->execute( $initRoot, $initPasswd, 1 );
    $dbh->prepare("insert into role (id ,name) values (?, ? );")
      ->execute( 1, 'admin' );

    $dbh->do(
        "insert into project (id , name, root) values (1 ,'用户管理', 1)");
    $dbh->do(
        "insert into project (id , name, root) values (2 ,'角色管理',1)");
    $dbh->do(
        "insert into project (id , name, root) values (3 ,'项目管理',1)");
    $dbh->do(
        "insert into project (id , name, root) values (4 ,'指令管理',1)");
    $dbh->do(
        "insert into project (id , name, root) values (5 ,'缓存管理',1)");
    $dbh->do("insert into `r_p` (roleid , projectid ) values (1 , 1) ");
    $dbh->do("insert into `r_p` (roleid , projectid ) values (1 , 2) ");
    $dbh->do("insert into `r_p` (roleid , projectid ) values (1 , 3) ");
    $dbh->do("insert into `r_p` (roleid , projectid ) values (1 , 4) ");
    $dbh->do("insert into `r_p` (roleid , projectid ) values (1 , 5) ");
    my $sth = $dbh->prepare(
        "insert into `order` (name , projectid,css) values (?,?,?)");
    use JSON;
    my $json = JSON->new->utf8->allow_nonref;
    my $sth1 =
      $dbh->prepare("insert into `order` (projectid,css ,name) values (?,?,?)");
    $sth1->execute(
        1,
        $json->encode(
            {
                1 => {
                    name => '用户名',
                    data => { source => '1', expectGet => 'v' }
                }
            }
        ),
        'delUser'
    );
    $sth1->execute(
        1,
        $json->encode(
            {
                1 => {
                    name => '用户名',
                    data => { source => '1', expectGet => 'v' }
                },
                2 => {
                    name => '角色名',
                    data => { source => '1', expectGet => 'v' }
                },
            }
        ),
        'updateUserRole'
    );
    $sth1->execute(
        '1',
        $json->encode(
            {
                1 => {
                    name => '用户-角色',
                    data => { source => '1', expectGet => 'k' }
                }
            }
        ),
        'userRole'
    );
    $sth1->execute(
        '2',
        $json->encode(
            {
                1 => {
                    name => '角色名',
                    data => { source => 0, expectGet => 'k' }
                }
            }
        ),
        'addRole'
    );
    $sth1->execute(
        2,
        $json->encode(
            {
                1 => {
                    name => '角色名',
                    data => { source => '1', expectGet => 'v' }
                }
            }
        ),
        'delRole'
    );
    $sth1->execute(
        2,
        $json->encode(
            {
                1 => {
                    name => '角色名',
                    data => { source => '1', expectGet => 'v' }
                },
                2 => {
                    name => '项目名',
                    data => { source => '1', expectGet => 'v' }
                }
            }
        ),
        'roleAddproject'
    );
    $sth1->execute(
        2,
        $json->encode(
            {
                1 => {
                    name => '角色名',
                    data => { source => '1', expectGet => 'v' }
                },
                2 => {
                    name => '项目名',
                    data => { source => '1', expectGet => 'v' }
                },
            }
        ),
        'roleUnbindproject'
    );
    $sth1->execute(
        2,
        $json->encode(
            {
                1 => {
                    name => '角色-项目',
                    data => { source => '1', expectGet => 'k' }
                }
            }
        ),
        'roleProject'
    );
    $sth1->execute(
        3,
        $json->encode(
            {
                1 => {
                    name => '项目名',
                    data => { source => 0, expectGet => 'k' }
                }
            }
        ),
        'addProject'
    );
    $sth1->execute(
        3,
        $json->encode(
            {
                1 => {
                    name => '项目名',
                    data => { source => '1', expectGet => 'v' }
                }
            }
        ),
        'delProject'
    );
    $sth1->execute(
        3,
        $json->encode(
            {
                1 => {
                    name => '项目-指令',
                    data => { source => '1', expectGet => 'k' }
                }
            }
        ),
        'projectOrder'
    );
    $sth1->execute(
        4,
        $json->encode(
            {
                1 => {
                    name => '指令名',
                    data => { source => 0, expectGet => 'k' }
                },
                2 =>
                  { name => '路径', data => { source => 0, expectGet => 'k' } },
                3 => {
                    name => '参数定义',
                    data => { source => 0, expectGet => 'k' }
                },
                4 => {
                    name => '归属项目',
                    data => { source => "1", expectGet => 'v' }
                },
                5=> {
                    name => '是否可以并发',
                    data => {source =>'1' , expectGet => 'v'}
                },
            }
        ),
        'addOrder'
    );
    $sth1->execute(
        4,
        $json->encode(
            {
                1 => {
                    name => '指令名',
                    data => { source => '1', expectGet => 'v' }
                }
            }
        ),
        'delOrder'
    );
    $sth1->execute(
        4,
        $json->encode(
            {
                1 => {
                    name => '项目名',
                    data => { source => '1', expectGet => 'v' }
                },
                2 => {
                    name => '指令名',
                    data => { source => '1', expectGet => 'v' }
                },
            }
        ),
        'updateProjectOrder'
    );
    $sth1->execute(
        5,
        $json->encode(
            {
                1 =>
                  { name => 'key', data => { source => '1', expectGet => 'k' } }
            }
        ),
        'delcache'
    );

    $dbh->commit;
    $sql->put($dbh);
}

1

