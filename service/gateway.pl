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
use Api::Tree;
use Api::K8s;
use Api::Gitlab;
use Api::Vpn;
use Api::Ci;
use JSON;
use Try::Tiny;
use Cwd;

my $root   = getcwd;
my $config = Objects::Common::Config->new( $root . '/etc/sys.config' );
my $mysql  = Objects::Common::Mysql->new($config);
my $json   = JSON->new->utf8->allow_nonref;

my $mem = {
    api => {
        user => *Api::User::Control,
        tree => *Api::Tree::Control,
        k8s  => *Api::K8s::Control,
        gitlab  => *Api::Gitlab::Control,
        vpn  => *Api::Vpn::Control,
        ci  => *Api::Ci::Control,
    },
};

###单连接数据处理逻辑
my $dataHandle = sub {
    my $receData  = shift;
    my $sessionId = shift;
    my $ip        = shift;
    my $result;
    $mem->{id}->{$sessionId}->{ip} = $ip;

    use Data::Dumper;
    say Dumper $receData;
    ####进入数据逻辑处理
    try {
        unless ( exists $receData->{modelName} ) {
            die "必要传参:modelName 缺失!!!";
        }
        unless ( exists $mem->{api}->{ $receData->{modelName} } ) {
            die "$receData->{modelName} 模块不存在!!!";
        }
        $mem->{api}->{ $receData->{modelName} }
          ->( $mysql, $mem, $receData, $sessionId );
    }
    catch {
        die "error: $_";
    }
    finally {
        return 1;
    }

};

#连接断开处理
my $stopHandle = sub {
    my $sessionid = shift;
    try {
        delete $mem->{token}->{ $mem->{id}->{$sessionid}->{token} }
          if exists $mem->{id}->{$sessionid}->{token};
        delete $mem->{user}->{ $mem->{id}->{$sessionid}->{user} }
          if exists $mem->{id}->{$sessionid}->{user};
        delete $mem->{id}->{$sessionid};
    }
    catch {} finally {};
};

*MySocket::Bind::start->(
    {
        ##接收数据处理$dataHandle,
        # 连接断了后的处理 $stopHandle;
        event => *MySocket::BindEvent::create->( $dataHandle, $stopHandle ),
        port  => $config->getValue( 'Sys',                    'ListenPort' )
    }
);

$poe_kernel->run();
