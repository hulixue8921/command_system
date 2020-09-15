#
#===============================================================================
#
#         FILE: InnerOrder.pm
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: hlx (), hulixue@xiankan.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 06/04/2020 03:35:16 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

package Objects::Users::Order::Exec;
use 5.010;
use POE;
use Data::Dumper;
use utf8;
use Encode;
use Objects::Common::Utf8;

sub iflock {
    my $order = shift;
    if ( $order->{binfa} eq 0 ) {
        return 1;
    }
    else {
        return 0;
    }
}

sub delCache {
    my $mem = shift;
    my $key = shift;
    $mem->del($key);
}

sub delUser {
    my $self       = shift;
    my $order      = shift;
    my $data       = $self->{Data}->{data}->{user}->{data};
    my $mem        = $self->{Data}->{mem};
    my $json       = $self->{Data}->{json};
    my $mysqlpools = $self->{Data}->{mysql};
    my $result     = &iflock($order);
    return unless exists $data->{1};
    ##判断是否需要上锁
    if ( $result eq 1 ) {
        $mem->set( 'binfa' . '_' . $order->{name}, 1 );
    }
    my $dbh  = $mysqlpools->get();
    my $sth0 = $dbh->prepare('select name from user where id =?');
    my $sth1 = $dbh->prepare('delete from user where id =?');
    $sth0->execute( $data->{1} );
    while ( my $ref = $sth0->fetchrow_hashref() ) {
        &Objects::Common::Utf8::enUtf8( $ref, {}, 0 );

        #用户信息在缓存中的删除
        &delCache( $mem, 'user' . '_' . $ref->{name} );
    }
    $sth1->execute( $data->{1} );
    $dbh->commit();
    $mysqlpools->put($dbh);

    ##执行完毕，释放锁
    $mem->del( 'binfa' . '_' . $order->{name} );
    return 1;
}

sub updateUserRole {
    my $self       = shift;
    my $order      = shift;
    my $data       = $self->{Data}->{data}->{user}->{data};
    my $mem        = $self->{Data}->{mem};
    my $json       = $self->{Data}->{json};
    my $mysqlpools = $self->{Data}->{mysql};
    my $result     = &iflock($order);
    return unless exists $data->{1};
    return unless exists $data->{2};
    ##判断是否需要上锁
    if ( $result eq 1 ) {
        $mem->set( 'binfa' . '_' . $order->{name}, 1 );
    }
    my $dbh  = $mysqlpools->get();
    my $sth0 = $dbh->prepare('select name from user where id=?');
    my $sth1 = $dbh->prepare('update user set roleid=? where id=?');
    $sth0->execute( $data->{1} );
    while ( my $ref = $sth0->fetchrow_hashref() ) {
        &Objects::Common::Utf8::enUtf8( $ref, {}, 0 );
        my $tmp = $mem->get( 'user' . '_' . $ref->{name} );
        if ($tmp) {

            #用户信息在缓存中的删除
            $tmp = $json->decode($tmp);
            $poe_kernel->post(
                $tmp->{sessionid},
                'sent',
                {
                    info =>
'您的角色已变动，您需要退出重新登录！！！'
                }
            );
            &delCache( $mem, 'user' . '_' . $ref->{name} );
        }

    }
    $sth1->execute( $data->{2}, $data->{1} );
    $dbh->commit();
    $mysqlpools->put($dbh);

    ##执行完毕，释放锁
    $mem->del( 'binfa' . '_' . $order->{name} );
    return 1;
}

sub addRole {
    my $self       = shift;
    my $order      = shift;
    my $data       = $self->{Data}->{data}->{user}->{data};
    my $mem        = $self->{Data}->{mem};
    my $json       = $self->{Data}->{json};
    my $mysqlpools = $self->{Data}->{mysql};
    my $result     = &iflock($order);
    return unless exists $data->{1};
    ##判断是否需要上锁
    if ( $result eq 1 ) {
        $mem->set( 'binfa' . '_' . $order->{name}, 1 );
    }
    my $dbh = $mysqlpools->get();
    my $sth = $dbh->prepare('insert into role (name) values (?)');
    $sth->execute( $data->{1} );
    $dbh->commit();
    $mysqlpools->put($dbh);
    ##执行完毕，释放锁
    $mem->del( 'binfa' . '_' . $order->{name} );
    return 1;
}

sub delRole {
    my $self       = shift;
    my $order      = shift;
    my $data       = $self->{Data}->{data}->{user}->{data};
    my $mem        = $self->{Data}->{mem};
    my $json       = $self->{Data}->{json};
    my $mysqlpools = $self->{Data}->{mysql};
    my $result     = &iflock($order);
    return unless exists $data->{1};
    ##判断是否需要上锁
    if ( $result eq 1 ) {
        $mem->set( 'binfa' . '_' . $order->{name}, 1 );
    }
    my $dbh = $mysqlpools->get();
    my $sth = $dbh->prepare('delete from role where id=?');
    $sth->execute( $data->{1} );
    $dbh->commit();
    $mysqlpools->put($dbh);

    my $keys = $mem->keys();
    foreach my $key (@$keys) {
        if ( $key =~ /^user_/ ) {
            my $tmp = $json->decode( $mem->get($key) );
            if ( $tmp->{roleid} eq $data->{1} ) {
                $poe_kernel->post(
                    $tmp->{sessionid},
                    'sent',
                    {
                        info =>
'您的角色信息已删除，需要你重新登录!!!!'
                    }
                );
                &delCache( $mem, $key );
            }
        }
    }

    ##执行完毕，释放锁
    $mem->del( 'binfa' . '_' . $order->{name} );
    return 1;
}

sub roleAddproject {
    my $self       = shift;
    my $order      = shift;
    my $data       = $self->{Data}->{data}->{user}->{data};
    my $mem        = $self->{Data}->{mem};
    my $json       = $self->{Data}->{json};
    my $mysqlpools = $self->{Data}->{mysql};
    my $result     = &iflock($order);
    return unless exists $data->{1};
    return unless exists $data->{2};
    ##判断是否需要上锁
    if ( $result eq 1 ) {
        $mem->set( 'binfa' . '_' . $order->{name}, 1 );
    }
    my $dbh = $mysqlpools->get();
    my $sth0 =
      $dbh->prepare('select * from r_p where roleid=?  and projectid=?');
    $sth0->execute( $data->{1}, $data->{2} );
    ###确定role 添加了新的项目
    unless ( my $ref = $sth0->fetchrow_hashref() ) {
        my $sth1 =
          $dbh->prepare('insert into r_p (roleid , projectid) values (?,?)');
        $sth1->execute( $data->{1}, $data->{2} );
        my $sth2 = $dbh->prepare('select * from project where id= ?');
        $sth2->execute( $data->{2} );
        my $project;
        while ( my $ref = $sth2->fetchrow_hashref() ) {
            &Objects::Common::Utf8::enUtf8( $ref, {}, 0 );
            $project = $ref;
        }

        #通知在线相关用户添加新项目操作；
        my $keys = $mem->keys();
        foreach my $key (@$keys) {
            if ( $key =~ /^user_/ ) {
                my $tmp = $json->decode( $mem->get($key) );
                if ( $tmp->{roleid} eq $data->{1} ) {
                    $poe_kernel->post( $tmp->{sessionid}, 'sent',
                        { project => { action => 'add', data => $project } } );
                }
            }
        }
    }
    $dbh->commit();
    $mysqlpools->put($dbh);

    ##缓存处处理
    &delCache( $mem, 'role' . '_' . $data->{1} );

    ##执行完毕，释放锁
    $mem->del( 'binfa' . '_' . $order->{name} );
    return 1;
}

sub roleUnbindproject {
    my $self       = shift;
    my $order      = shift;
    my $data       = $self->{Data}->{data}->{user}->{data};
    my $mem        = $self->{Data}->{mem};
    my $json       = $self->{Data}->{json};
    my $mysqlpools = $self->{Data}->{mysql};
    my $result     = &iflock($order);
    return unless exists $data->{1};
    return unless exists $data->{2};
    ##判断是否需要上锁
    if ( $result eq 1 ) {
        $mem->set( 'binfa' . '_' . $order->{name}, 1 );
    }
    my $dbh = $mysqlpools->get();
    my $sth0 =
      $dbh->prepare('select * from r_p where roleid=? and projectid=?');
    $sth0->execute( $data->{1}, $data->{2} );

    #确定角色项目存在关联关系
    if ( my $ref = $sth0->fetchrow_hashref() ) {
        &Objects::Common::Utf8::enUtf8( $ref, {}, 0 );
        my $sth1 =
          $dbh->prepare('delete from r_p where roleid=? and projectid=?');
        $sth1->execute( $data->{1}, $data->{2} );
        my $sth2 = $dbh->prepare('select * from project where id =?');
        $sth2->execute( $data->{2} );
        my $project = $sth2->fetchrow_hashref();
        &Objects::Common::Utf8::enUtf8( $project, {}, 0 );

        #通知相关在线用户删除项目
        my $keys = $mem->keys();
        foreach my $key (@$keys) {
            if ( $key =~ /^user_/ ) {
                my $tmp = $json->decode( $mem->get($key) );
                if ( $tmp->{roleid} eq $data->{1} ) {
                    $poe_kernel->post( $tmp->{sessionid}, 'sent',
                        { project => { action => 'del', data => $project } } );
                }
            }
        }
    }

    $dbh->commit();
    $mysqlpools->put($dbh);
    ###缓存清理
    &delCache( $mem, 'role' . '_' . $data->{1} );
    ##执行完毕，释放锁
    $mem->del( 'binfa' . '_' . $order->{name} );
    return 1;
}

sub addProject {
    my $self       = shift;
    my $order      = shift;
    my $data       = $self->{Data}->{data}->{user}->{data};
    my $mem        = $self->{Data}->{mem};
    my $json       = $self->{Data}->{json};
    my $mysqlpools = $self->{Data}->{mysql};
    my $result     = &iflock($order);
    return unless exists $data->{1};
    ##判断是否需要上锁
    if ( $result eq 1 ) {
        $mem->set( 'binfa' . '_' . $order->{name}, 1 );
    }
    my $dbh  = $mysqlpools->get();
    my $sth  = $dbh->prepare('insert into project (name) values (?)');
    my $sth1 = $dbh->prepare('select * from project where name =?');
    $sth->execute( $data->{1} );
    $sth1->execute( $data->{1} );
    my $project = $sth1->fetchrow_hashref();
    &Objects::Common::Utf8::enUtf8( $project, {}, 0 );

    #缓存处理
    &delCache( $mem, 'role' . '_' . 1 );
    $poe_kernel->yield( 'sent',
        { project => { action => 'add', data => $project } } );
    $dbh->commit();
    $mysqlpools->put($dbh);

    ##执行完毕，释放锁
    $mem->del( 'binfa' . '_' . $order->{name} );
    return 1;
}

sub delProject {
    my $self       = shift;
    my $order      = shift;
    my $data       = $self->{Data}->{data}->{user}->{data};
    my $mem        = $self->{Data}->{mem};
    my $json       = $self->{Data}->{json};
    my $mysqlpools = $self->{Data}->{mysql};
    my $result     = &iflock($order);
    return unless exists $data->{1};
    ##判断是否需要上锁
    if ( $result eq 1 ) {
        $mem->set( 'binfa' . '_' . $order->{name}, 1 );
    }
    my $dbh  = $mysqlpools->get();
    my $sth0 = $dbh->prepare('delete from project where id=?');
    my $sth1 =
      $dbh->prepare('update `order` set projectid =0 where projectid=?');
    my $sth2 = $dbh->prepare('delete from r_p where projectid=?');
    my $sth3 = $dbh->prepare('select roleid from r_p where projectid=?');
    my $sth4 = $dbh->prepare('select * from project where id=?');
    $sth3->execute( $data->{1} );
    $sth4->execute( $data->{1} );
    my $project = $sth4->fetchrow_hashref();
    &Objects::Common::Utf8::enUtf8( $project, {}, 0 );

    while ( my $ref = $sth3->fetchrow_hashref() ) {
        &Objects::Common::Utf8::enUtf8( $ref, {}, 0 );
        ##清除缓存
        &delCache( $mem, 'role' . '_' . $ref->{roleid} );
        &delCache( $mem, 'project' . '_' . $project->{id} );
        ###通知在线相关用户删除项目
        my $keys = $mem->keys();
        foreach my $key (@$keys) {
            if ( $key =~ /^user_/ ) {
                my $tmp = $json->decode( $mem->get($key) );
                if ( $tmp->{roleid} eq $ref->{roleid} ) {
                    $poe_kernel->post( $tmp->{sessionid}, 'sent',
                        { project => { action => 'del', data => $project } } );
                }
            }
        }

    }
    $sth0->execute( $data->{1} );
    $sth1->execute( $data->{1} );
    $sth2->execute( $data->{1} );
    $dbh->commit();
    $mysqlpools->put($dbh);
    $poe_kernel->yield( 'sent',
        { project => { action => 'del', data => $project } } );

    ##执行完毕，释放锁
    $mem->del( 'binfa' . '_' . $order->{name} );
    return 1;
}

sub addOrder {
    my $self       = shift;
    my $order      = shift;
    my $data       = $self->{Data}->{data}->{user}->{data};
    my $mem        = $self->{Data}->{mem};
    my $json       = $self->{Data}->{json};
    my $mysqlpools = $self->{Data}->{mysql};
    my $result     = &iflock($order);
    return unless exists $data->{1};
    return unless exists $data->{2};
    return unless exists $data->{3};
    return unless exists $data->{4};
    return unless exists $data->{5};
    my $css;
    my @csses=split /-/ ,$data->{3};
    foreach my $i (0..$#csses) {
          my ($name, $p)=split /_/ , $csses[$i];
          my ($source , $expectGet)=split /,/ ,$p;
          $css->{$i+1}->{name}=$name;
          $css->{$i+1}->{data}->{source}=$source;
          $css->{$i+1}->{data}->{expectGet}=$expectGet;
    }
    ##判断是否需要上锁
    if ( $result eq 1 ) {
        $mem->set('binfa' . '_' . $order->{name}, 1 );
    }
    my $dbh  = $mysqlpools->get();
    my $sth0 = $dbh->prepare('select * from `order` where name =?');
    $sth0->execute( $data->{1} );

    if ( my $ref = $sth0->fetchrow_hashref() ) {
        $poe_kernel->yield(
            'sent',
            {
                info => $data->{1} . ' '
                  . '此指令已存在，请重新命名'
            }
        );
    }

    my $sth1 = $dbh->prepare(
'insert into `order` (name , path,css,projectid,binfa) values (?,?,?,?,?)'
    );
    $sth1->execute( $data->{1}, $data->{2}, $json->encode($css), $data->{4},
        $data->{5} );

    $dbh->commit();
    $mysqlpools->put($dbh);
    ##缓存清理
    my $keys = $mem->keys();
    foreach my $key (@$keys) {
        if ( $key =~ /^project_/ ) {
            &delCache( $mem, $key );
        }
    }
    ##执行完毕，释放锁
    $mem->del( 'binfa' . '_' . $order->{name} );
    return 1;
}

sub delOrder {
    my $self       = shift;
    my $order      = shift;
    my $data       = $self->{Data}->{data}->{user}->{data};
    my $mem        = $self->{Data}->{mem};
    my $json       = $self->{Data}->{json};
    my $mysqlpools = $self->{Data}->{mysql};
    my $result     = &iflock($order);
    return unless exists $data->{1};
    ##判断是否需要上锁
    if ( $result eq 1 ) {
        $mem->set( 'binfa' . '_' . $order->{name}, 1 );
    }

    my $dbh = $mysqlpools->get();
    my $sth = $dbh->prepare('delete from `order` where id =? ');
    $sth->execute( $data->{1} );
    $dbh->commit();
    $mysqlpools->put($dbh);

    #缓存处理,删除所有prject 与order 的关联
    my $keys = $mem->keys();
    foreach my $key (@$keys) {
        if ( $key =~ /^project_/ ) {
            &delCache( $mem, $key );
        }
    }

    ##执行完毕，释放锁
    $mem->del( 'binfa' . '_' . $order->{name} );
    return 1;
}

sub updateProjectOrder {
    my $self       = shift;
    my $order      = shift;
    my $data       = $self->{Data}->{data}->{user}->{data};
    my $mem        = $self->{Data}->{mem};
    my $json       = $self->{Data}->{json};
    my $mysqlpools = $self->{Data}->{mysql};
    my $result     = &iflock($order);
    return unless exists $data->{1};
    return unless exists $data->{2};
    ##判断是否需要上锁
    if ( $result eq 1 ) {
        $mem->set( 'binfa' . '_' . $order->{name}, 1 );
    }
    my $dbh = $mysqlpools->get();
    my $sth0 =
      $dbh->prepare('select * from `order` where projectid=? and id=? ');
    $sth0->execute( $data->{1}, $data->{2} );
    unless ( my $ref = $sth0->fetchrow_hashref() ) {
        my $sth1 = $dbh->prepare('update `order` set projectid=? where id=?');
        $sth1->execute( $data->{1}, $data->{2} );
        ##清除缓存中所有project与role的关联
        my $keys = $mem->keys();
        foreach my $key (@$keys) {
            if ( $key =~ /^project_/ ) {
                &delCache( $mem, $key );
            }
        }
    }
    $dbh->commit();
    $mysqlpools->put($dbh);

    ##执行完毕，释放锁
    $mem->del( 'binfa' . '_' . $order->{name} );
    return 1;
}

sub delcache {
    my $self  = shift;
    my $order = shift;
    my $data  = $self->{Data}->{data}->{user}->{data};
    my $mem   = $self->{Data}->{mem};
    my $json  = $self->{Data}->{json};
    return unless exists $data->{1};
    return if $data->{1} eq 'config';    ##mem 类的一个重要安全bug;
    &delCache( $mem, $data->{1} );
    return 1;
}

1
