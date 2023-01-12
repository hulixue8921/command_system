#
#===============================================================================
#
#         FILE: BindEvent.pm
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: hlx (), hulixue@xiankan.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 01/28/2021 03:39:58 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

package MySocket::BindEvent;

use POE;
use JSON;
use 5.010;
use utf8;
use Encode;
use Try::Tiny;

my $json = JSON->new->utf8->allow_nonref;

sub create {
    *MySocket::BindEvent::dataHandle = shift;
    *MySocket::BindEvent::stopHandle = shift;

    my $event = {
        receveDataHandle => *MySocket::BindEvent::receveDataHandle,
        stop             => *MySocket::BindEvent::stop,
        sent             => *MySocket::BindEvent::sentDataHandle,
        sentRow          => *MySocket::BindEvent::sentDataHandleRow,

    };
    return $event;
}

sub receveDataHandle {
    my $data = $_[ARG0];
    Encode::_utf8_off($data);
    my $x = eval {
        my $datajson = eval { $json->decode($data) };
        unless ($datajson) {
            die "数据不是json !!!";
        }
        if ( ref $datajson eq 'HASH' ) {
            *MySocket::BindEvent::dataHandle->( $datajson, $_[SESSION]->ID,$_[HEAP]{ip} );
        }
        else {
            die "json数据格式不对,不是{}";
        }
    };

    if ($@) {
        $poe_kernel->yield( 'sent',
            { code => '404', data => { message => $@ } } );
    }

}

sub stop {
    ####需要清理数据
    *MySocket::BindEvent::stopHandle->( $_[SESSION]->ID );
    delete $_[HEAP]{con};
    delete $_[HEAP]{hand};
    delete $_[HEAP]{ip};
}

sub sentDataHandle {
    my $data = $_[ARG0];
    chomp $data;
    my $Data = $json->encode($data);
    my $len  = length($Data) + 2;
    say $Data . '     ' . $len;
    $_[HEAP]{con}->put( pack( 'N', $len ) . $Data ) if exists $_[HEAP]{con};
}

sub sentDataHandleRow {
    my $data = $_[ARG0];
    chomp $data;
    &Objects::Common::Utf8::enUtf8($data);
    my $Data = $json->encode($data);
    $_[HEAP]{con}->put($Data) if exists $_[HEAP]{con};
}

1
