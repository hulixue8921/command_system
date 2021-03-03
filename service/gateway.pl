#!/usr/bin/env perl
#===============================================================================
#
#         FILE: 1.pl
#
#        USAGE: ./1.pl
#
#  DESCRIPTION:
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: hlx (), hulixue@xiankan.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 11/19/18 02:16:24
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;
use Encode;
use POE qw (Wheel::SocketFactory Wheel::ReadWrite Wheel::FollowTail);
use MySocket::Bind;
use MySocket::BindEvent;
use Objects::Common::Mysql;
use Objects::Common::Config;
use Api::User;
use Api::Fabu::Fabu;
use JSON;

my $config = Objects::Common::Config->new( $ARGV[0] );
my $mysql  = Objects::Common::Mysql->new($config);
my $json   = JSON->new->utf8->allow_nonref;

my $mem = {
    api => {
        user => *Api::User::Control,
        fabu => *Api::Fabu::Fabu::Control,
    },
    status => {
        lack   => { code => 404, info => '缺参数，或者参数值错误 ' },
        ok     => { code => 200, info => '执行完毕' },
        abort  => { code => 403, info => '服务器执行异常' },
        noauth => { code => 500, info => '缺少认证' },
        noright => { code => 500, info => '缺少权限' },
        running => { code => 501, info => '某用户正在执行相关操作' },
        fail    => { code => 502, info => '执行失败' },
    },
};

###单连接数据处理逻辑
my $dataHandle = sub {
    my $receData  = shift;
    my $sessionId = shift;
    my $result;

    ####进入数据逻辑处理
    unless ( ref $receData eq 'HASH'
        and defined $mem->{api}->{ $receData->{modelName} } )
    {
        $poe_kernel->yield( 'sent', $mem->{status}->{lack} );
    }
    else {

        #开始处理数据
        $mem->{api}->{ $receData->{modelName} }
          ->( $mysql, $mem, $receData, $sessionId );

    }

};

#连接断开处理
my $stopHandle = sub {
    my $sessionid = shift;

    delete $mem->{id}->{$sessionid};
};

*MySocket::Bind::start->(
    {
        ##接收数据处理$dataHandle,
        # 连接断了后的处理 $stopHandle;
        event => *MySocket::BindEvent::create->( $dataHandle, $stopHandle ),
        port  => $config->getValue( 'Sys1',                   'ListenPort' )
    }
);

$poe_kernel->run();
