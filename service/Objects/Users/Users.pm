#
#===============================================================================
#
#         FILE: Users.pm
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: hlx (), hulixue@xiankan.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 05/22/2020 04:12:38 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use 5.010;

package Objects::Users::Users;
use Objects::Common::Log;
use Objects::Common::Utf8;
use Objects::Users::Order::Data;
use Objects::Users::Order::Exec;
use Objects::Users::Functions;
use Objects::Common::Utf8;
use POE;
use utf8;
use Data::Dumper;

sub new {
    my $class = shift;
    my $Data  = shift;
    my $log   = Objects::Common::Log->new( $Data->{config}, __PACKAGE__ );

    bless {
        log  => $log,
        Data => $Data,
    }, $class;

}

sub reg {
    my $self = shift;
    my $dbh  = $self->{Data}->{mysql}->get();
    my $sth  = $dbh->prepare('select * from user where name = ?');
    $sth->execute( $self->{Data}->{data}->{user}->{username} );
    while ( my $ref = $sth->fetchrow_hashref() ) {
        $poe_kernel->yield( 'sent', { info => '此账号名已存在' } );
        &Objects::Common::Utf8::enUtf8( $ref, {}, 0 );
        $self->{Data}->{mem}
          ->set( 'user' . '_' . $self->{Data}->{data}->{user}->{username},
            $self->{Data}->{json}->encode($ref) );
        $dbh->commit;
        $self->{Data}->{mysql}->put($dbh);
        return;
    }

    $sth = $dbh->prepare('insert into user (name , passwd) values (?,?) ');
    $sth->execute(
        $self->{Data}->{data}->{user}->{username},
        $self->{Data}->{data}->{user}->{passwd}
    );
    $dbh->commit;
    $self->{Data}->{mysql}->put($dbh);
    $poe_kernel->yield( 'sent', { info => '注册成功' } );
    my $tmp->{sessionid} = $self->{Data}->{sessionid};
    $tmp->{roleid} = '-1';
    $tmp->{name}   = $self->{Data}->{data}->{user}->{username};
    $tmp->{passwd} = $self->{Data}->{data}->{user}->{passwd};
    $self->{Data}->{mem}
      ->set( 'user' . '_' . $self->{Data}->{data}->{user}->{username},
        $self->{Data}->{json}->encode($tmp) );
}

sub load {
    my $self = shift;
    return unless exists $self->{Data}->{data}->{user}->{passwd};
    return unless exists $self->{Data}->{data}->{user}->{username};
    my $username  = $self->{Data}->{data}->{user}->{username};
    my $passwd    = $self->{Data}->{data}->{user}->{passwd};
    my $json      = $self->{Data}->{json};
    my $sessionid = $self->{Data}->{sessionid};
    my $mem       = $self->{Data}->{mem};

    my $result = &Objects::Users::Functions::userInfo( $self, $username );

    if (%$result) {
        if ( $result->{passwd} eq $passwd ) {
            ##密码正确
            if ( exists $result->{sessionid} ) {
                if ( $result->{sessionid} eq $sessionid ) {
                    ##重复登录提交
                    $poe_kernel->yield( 'sent',
                        { info => '请不要重复提交' } );
                }
                else {
                    ##多次异地登录,更新缓存用户信息
                    $poe_kernel->post(
                        $result->{sessionid},
                        'sent',
                        {
                            info =>
                              '您已另地登录，被踢下线 ！！！'
                        }
                    );
                    $poe_kernel->yield( 'sent',
                        { info => '登录成功！！！' } );
                    $result->{sessionid} = $sessionid;
                    $mem->set( 'user' . '_' . $username,
                        $json->encode($result) );
                    $self->RolegetProject();
                }
            }
            else {
                ##首次登陆,并缓存用户信息，并发送相关项目信息
                $result->{sessionid} = $sessionid;
                $poe_kernel->yield( 'sent',
                    { info => '登录成功！！！' } );
                $mem->set( 'user' . '_' . $username, $json->encode($result) );
                $self->RolegetProject();
            }

        }
        else {
            ##密码错误
            $poe_kernel->yield( 'sent', { info => '密码错误！！！' } );
            return;
        }
    }
    else {

        #不存在此用户，走注册流程
        $self->reg();
    }

}

sub RolegetProject {
    my $self = shift;
    return unless $self->checkSession();
    my $username  = $self->{Data}->{data}->{user}->{username};
    my $passwd    = $self->{Data}->{data}->{user}->{passwd};
    my $json      = $self->{Data}->{json};
    my $sessionid = $self->{Data}->{sessionid};
    my $mem       = $self->{Data}->{mem};

    #查询缓存：用户信息，用户信息必须存缓存
    my $tmp = $self->{Data}->{mem}->get( 'user' . '_' . $username );
    $tmp = $self->{Data}->{json}->decode($tmp);
    my $result =
      &Objects::Users::Functions::projectInfo( $self, $tmp->{roleid} );

    #发送项目信息
    foreach my $ref (@$result) {
        $poe_kernel->yield( 'sent',
            { project => { action => 'add', data => $ref } } );
    }

    #缓存非管理员的项目信息
    unless ( $tmp->{roleid} eq 1 ) {
        $mem->set( 'role_' . $tmp->{roleid}, $json->encode($result) );
    }
}

sub getOrder {
    my $self = shift;
    my $mem  = $self->{Data}->{mem};
    my $json = $self->{Data}->{json};
    return unless $self->checkSession();
    return unless exists $self->{Data}->{data}->{user}->{pid};
    my $pid = $self->{Data}->{data}->{user}->{pid};

    #具体项目下的指令信息
    my $result = &Objects::Users::Functions::orderInfo( $self, $pid );
    if ($result) {
        $poe_kernel->yield( 'sent',
            { order => { action => 'add', data => $result } } );
    }

    #缓存具体项目下的原始指令信息
    $mem->set( 'project_' . $pid, $json->encode($result) );
    return;
}

sub getOrderCssData {
    my $self = shift;
    return unless $self->checkSession();
    return unless exists $self->{Data}->{data}->{user}->{oid};
    return unless exists $self->{Data}->{data}->{user}->{pid};
    my $pid = $self->{Data}->{data}->{user}->{pid};
    my $result = &Objects::Users::Functions::orderInfo( $self, $pid );

    if ($result) {
        foreach my $ref (@$result) {
            if ( $ref->{id} eq $self->{Data}->{data}->{user}->{oid} ) {

                #命令表单中需要填充一些数据
                my $cssDataTab = {
                    'delUser'        => sub { &delUser( $self,        $ref ) },
                    'updateUserRole' => sub { &updateUserRole( $self, $ref ) },
                    'userRole'       => sub { &userRole( $self,       $ref ) },
                    'delRole'        => sub { &delRole( $self,        $ref ) },
                    'roleAddproject' => sub { &roleAddproject( $self, $ref ) },
                    'roleUnbindproject' =>
                      sub { &roleAddproject( $self, $ref ) },
                    'roleProject'  => sub { &roleProject( $self,  $ref ) },
                    'delProject'   => sub { &delProject( $self,   $ref ) },
                    'projectOrder' => sub { &projectOrder( $self, $ref ) },
                    'delOrder'     => sub { &delOrder( $self,     $ref ) },
                    'updateProjectOrder' =>
                      sub { &updateProjectOrder( $self, $ref ) },
                    'addOrder' => sub { &addOrder( $self, $ref ) },
                    'delcache' => sub { &delcache( $self, $ref ) },
                };
                if ( exists $cssDataTab->{ $ref->{name} } ) {
                    my $tmpresult = $cssDataTab->{ $ref->{name} }->();
                    $poe_kernel->yield( 'sent',
                        { css => { data => $tmpresult } } );
                }
                else {
                    $ref->{data} = {};
                    $poe_kernel->yield( 'sent', { css => { data => $ref } } );
                }
            }
        }
    }
    return;
}

sub execOrder {
    my $self = shift;
    return unless $self->checkSession();
    return unless exists $self->{Data}->{data}->{user}->{oid};
    return unless exists $self->{Data}->{data}->{user}->{pid};
    my $oid      = $self->{Data}->{data}->{user}->{oid};
    my $pid      = $self->{Data}->{data}->{user}->{pid};
    my $username = $self->{Data}->{data}->{user}->{username};
    my $mem      = $self->{Data}->{mem};
    my $json     = $self->{Data}->{json};
    my $rid = $json->decode( $mem->get( 'user' . '_' . $username ) )->{roleid};
    ##需要鉴权操作
    my $result = &safe( $self, $rid, $pid, $oid );
    unless ( $result eq 1 ) {
        $poe_kernel->yield( 'sent',
            { info => '没有权限操作 ！！！' } );
        return;
    }
    ##判断是否可以并发执行
    ###开始执行操作
    my $orders = &Objects::Users::Functions::orderInfo( $self, $pid );
    my $order;
    foreach my $o (@$orders) {
        if ( $o->{id} eq $oid ) {
            $order = $o;
            if (    $o->{binfa} eq 0
                and $mem->get( 'binfa' . '_' . $order->{name} ) )
            {
                $poe_kernel->yield(
                    'sent',
                    {
                        info =>
'此指令已有用户在执行，且不能并发执行！！'
                    }
                );
                return;
            }
        }
    }
    my $execTab = {
        delUser => sub {
            &Objects::Users::Order::Exec::delUser( $self, $order );
        },
        updateUserRole => sub {
            &Objects::Users::Order::Exec::updateUserRole( $self, $order );
        },
        userRole => sub { return 1; },
        addRole  => sub {
            &Objects::Users::Order::Exec::addRole( $self, $order );
        },
        delRole => sub {
            &Objects::Users::Order::Exec::delRole( $self, $order );
        },
        roleAddproject => sub {
            &Objects::Users::Order::Exec::roleAddproject( $self, $order );
        },
        roleUnbindproject => sub {
            &Objects::Users::Order::Exec::roleUnbindproject( $self, $order );
        },
        roleProject => sub { return 1; },
        addProject  => sub {
            &Objects::Users::Order::Exec::addProject( $self, $order );
        },
        delProject => sub {
            &Objects::Users::Order::Exec::delProject( $self, $order );
        },
        projectOrder => sub { return 1; },
        addOrder     => sub {
            &Objects::Users::Order::Exec::addOrder( $self, $order );
        },
        delOrder => sub {
            &Objects::Users::Order::Exec::delOrder( $self, $order );
        },
        updateProjectOrder => sub {
            &Objects::Users::Order::Exec::updateProjectOrder( $self, $order );
        },
        delcache => sub {
            &Objects::Users::Order::Exec::delcache( $self, $order );
          }
    };
    if ( exists $execTab->{ $order->{name} } ) {
        ##需要内部执行
        my $result = $execTab->{ $order->{name} }->();
        if ( $result eq 1 ) {
            $poe_kernel->yield( 'sent',
                { info => $order->{name} . ' ' . '执行成功' } );
        }
        else {
            $poe_kernel->yield( 'sent',
                { info => $order->{name} . ' ' . '执行失败' } );
        }
    }
    else {
        ##需要外部执行, 信息已存在$order(数据库中原始数据) $self（客户端带过来的数据)
        ##是否需要上锁
        if ($order->{binfa} eq 0) {
            #上锁
             $mem->set('binfa'.'_'.$order->{name},1);
        }
        ##检测client 传过来的数据
        &Encode::_utf8_off($order->{css});
        my $css=$json->decode($order->{css});
         my $data=$self->{Data}->{data}->{user}->{data};
         my $Data;
         unless (keys %$css  eq keys %$data) {
             $poe_kernel->yield('sent' , {info => '参数有问题！！！'});
             #解锁
             $mem->del('binfa'.'_'.$order->{name});
             return;
         }
         foreach my $key ( sort {$a <=> $b}  keys %$data) {
             $Data= $Data.$data->{$key}." ";
         }
         
         system("$order->{path}  $Data $username:$order->{name} & ");
    }

}

sub safe {
    my $self = shift;
    my $rid  = shift;
    my $pid  = shift;
    my $oid  = shift;
    if ( $rid eq 1 ) {
        return 1;
    }
    my $projects = &Objects::Users::Functions::projectInfo( $self, $rid );
    my $orders  = &Objects::Users::Functions::orderInfo( $self, $pid );
    my $result1 = [];
    my $result2 = [];

    foreach my $p (@$projects) {
        push @$result1, $p->{id};
    }

    foreach my $o (@$orders) {
        push @$result2, $o->{id};
    }

    if ( $pid ~~ @$result1 and $oid ~~ @$result2 ) {
        return 1;
    }
    else {
        return 0;
    }

}

sub checkSession {
    my $self = shift;
    return unless exists $self->{Data}->{data}->{user}->{username};
    my $tmp =
      $self->{Data}->{mem}
      ->get( 'user' . '_' . $self->{Data}->{data}->{user}->{username} );

    if ($tmp) {
        $tmp = $self->{Data}->{json}->decode($tmp);
        if ( $self->{Data}->{sessionid} eq $tmp->{sessionid} ) {
            if ( exists $tmp->{id} ) {
                return 1;
            }
            else {
                $poe_kernel->post( $self->{Data}->{sessionid},
                    'sent',
                    { info => '你是注册新用户，请联系管理员' } );
                return 0;
            }
        }
        else {
            $poe_kernel->post( $self->{Data}->{sessionid},
                'sent', { info => '请先登录' } );
            return 0;
        }
    }
    else {
        $poe_kernel->post( $self->{Data}->{sessionid},
            'sent', { info => '请先登录' } );
        return 0;
    }
}

1
