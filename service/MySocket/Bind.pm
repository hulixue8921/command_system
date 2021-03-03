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
use Encode;

package MySocket::Bind;

use 5.010;
use POE qw (Wheel::SocketFactory Wheel::ReadWrite Wheel::FollowTail);
use Socket qw (AF_INET inet_ntop);
use JSON;
use utf8;

my $json = JSON->new->utf8->allow_nonref;

our $data;

sub start {
    $data = shift;

    POE::Session->create(
        inline_states => {
            _start      => \&Listen,
            listen_fail => \&Listen_fail,
            connected   => \&Connected,
        },
    );
}

sub Listen {
    my $config = $data->{config};
    my $port   = POE::Wheel::SocketFactory->new(
        BindPort       => $data->{port},
        SocketProtocol => 'tcp',
        SuccessEvent   => 'connected',
        FailureEvent   => 'listen_fail',
        Reuse          => 'on',
    );
    $_[HEAP]{port} = $port;
}

sub Listen_fail {
    say 'service:' . $data->{port} . " 启动失败 ！！！";
    die;
}

sub Connected {
    my $hand = $_[ARG0];
    my $peer_host = inet_ntop( AF_INET, $_[ARG1] );
    POE::Session->create(
        inline_states => {
            _start   => \&Bind_con,
            receve   => \&{ $data->{event}->{receveDataHandle} },
            sent     => \&{ $data->{event}->{sent} },
            sentRow  => \&{ $data->{event}->{sentRow} },
            lose_con => \&Losecon,
            _stop    => \&{ $data->{event}->{stop} },
        },
        args => [ $hand, $peer_host ],
    );
}

sub Bind_con {
    my $hand = $_[ARG0];
    $_[HEAP]{hand} = $hand;
    $_[HEAP]{ip}   = $_[ARG1];
    $_[HEAP]{con}  = POE::Wheel::ReadWrite->new(
        Handle     => $hand,
        InputEvent => "receve",
        ErrorEvent => "lose_con",
    );
}

sub Losecon {
    $poe_kernel->yield('_stop');
}

1
