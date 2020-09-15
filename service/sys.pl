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
use Socket qw (AF_INET inet_ntop);
use Data::Dumper;
use JSON;
use Objects::Common::Config;
use Objects::Common::Mem;
use Objects::Common::Mysql;
use Objects::Common::Log;
use Objects::Common::Utf8;
use Init::Init;
use Enter::Enter;

my $config = Objects::Common::Config->new( $ARGV[0] );
my $mem    = Objects::Common::Mem->new($config);
my $mysql  = Objects::Common::Mysql->new($config);
my $log    = Objects::Common::Log->new( $config, __PACKAGE__ );

my $json = JSON->new->utf8->allow_nonref;

####监听打印日志
POE::Session->create(
    inline_states => {
        _start => sub {
            $_[HEAP]{log} = POE::Wheel::FollowTail->new(
                Filename   => $config->{Log}->{LogFile},
                InputEvent => "getlog",
            );
        },
        getlog => sub {
            my $loginfo = $_[ARG0];
            my ( $username, $ordername , $other ) = split /:/, $loginfo;
            my $tmp = $mem->get( 'user' . '_' . $username );

            #解锁
            $mem->del( 'binfa' . '_' . $ordername );
            ##给在线用户发送通知！！！
            if ($tmp) {
                my $tmp = $json->decode($tmp);
                $poe_kernel->post( $tmp->{sessionid}, 'sent',
                    { info => $ordername . ":执行完毕 $other" } );
            }
        },
    },
);

########mysql session #####
POE::Session->create(
    inline_states => {
        _start    => \&MysqlConnect,
        mysqlping => \&MysqlPing,
    },

);

sub MysqlConnect {
    $mysql->pool();
}

sub MysqlPing {
    $mysql->defendPool();
}

##########初始化数据库
##########
##########
if ( $ARGV[1] ) {
    Init::Init::Init( $mysql, $config ) if $ARGV[1] eq 'init';
    exit;
}

POE::Session->create(
    inline_states => {
        _start      => \&Listen,
        listen_fail => \&Listen_fail,
        connected   => \&Connected,
    },

);

sub Listen {
    my $port = POE::Wheel::SocketFactory->new(
        BindPort       => $config->getValue( 'Sys', 'ListenPort' ),
        SocketProtocol => 'tcp',
        SuccessEvent   => 'connected',
        FailureEvent   => 'listen_fail',
        Reuse          => 'on',
    );
    $_[HEAP]{port} = $port;
}

sub Listen_fail {
    say $config->getValue( 'Sys', 'ListenPort' ) . " 启动失败 ！！！";
}

sub Connected {
    my $hand = $_[ARG0];

    my $peer_host = inet_ntop( AF_INET, $_[ARG1] );

    POE::Session->create(
        inline_states => {
            _start   => \&Bind_con,
            receve   => \&Receve,
            lose_con => \&Losecon,
            sent     => \&Sent,
            _stop    => \&Stop,
        },
        args => [$hand],
    );
}

sub Bind_con {
    my $hand = $_[ARG0];
    $_[HEAP]{hand} = $hand;
    $_[HEAP]{con}  = POE::Wheel::ReadWrite->new(
        Handle     => $hand,
        InputEvent => "receve",
        ErrorEvent => "lose_con",
    );
}

sub Receve {
    my $data = $_[ARG0];
    Encode::_utf8_off($data);
    my $datajson = eval { $json->decode($data) };
    Encode::_utf8_on($data);
    if ($datajson) {
        Enter::Enter::mySplit( $_[SESSION]->ID, $mem, $mysql, $datajson, $json,
            $config );
    }
    else {
        $log->error(
            'sessionid: ' . $_[SESSION]->ID . "  请求数据错误 $data" );
        return;
    }

    $log->info( "sessionid: " . $_[SESSION]->ID . '  receve ' . $data );

}

sub Sent {
    my $data = $_[ARG0];
    chomp $data;
    &Objects::Common::Utf8::enUtf8( $data, {}, 0 );
    my $Data = $json->encode($data);
    $log->info( "sessionid:" . $_[SESSION]->ID . '   sent ' . $Data );
    my $len = length($Data) + 2;
    $_[HEAP]{con}->put( pack( 'N', $len ) . $Data );
}

sub Losecon {
    $poe_kernel->yield('_stop');
}

sub Stop {
    $log->info( 'sessionid: ' . $_[SESSION]->ID . "断开连接" );
    delete $_[HEAP]{con};
    delete $_[HEAP]{hand};
}

$poe_kernel->run;

