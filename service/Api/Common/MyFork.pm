#
#===============================================================================
#
#         FILE: Fabu.pm
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: hlx (), hulixue@xiankan.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 02/01/2021 04:36:06 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

package Api::Common::MyFork;
use Api::Common::Sql;
use POE;
use POE::Wheel::Run;
use JSON;
use Api::Common::Lock;
use Encode;
use 5.010;

sub P (&) {
    $_[0];
}

sub newFork {
    my $script    = shift;
    my $sessionid = shift;
    my $mem       = shift;
    my $data      = shift;
    my $fun       = shift;
    POE::Session->create(
        inline_states => {
            _start           => \&on_start,
            got_child_stdout => \&on_child_stdout,
            got_child_stderr => \&on_child_stderr,
            got_child_close  => \&on_child_close,
            got_child_signal => \&on_child_signal
        },
        args => [ $script, $sessionid, $mem, $data, $fun ],
    );
}

sub on_start {
    my $script = $_[ARG0];
    $_[HEAP]{sessionid} = $_[ARG1];
    $_[HEAP]{mem}       = $_[ARG2];
    $_[HEAP]{data}      = $_[ARG3];
    $_[HEAP]{fun}       = $_[ARG4];

    my $child = POE::Wheel::Run->new(

        Program     => $script,
        StdoutEvent => "got_child_stdout",
        StderrEvent => "got_child_stderr",
        CloseEvent  => "got_child_close",
    );

    $poe_kernel->sig_child( $child->PID, "got_child_signal" );
    $_[HEAP]{children_by_wid}{ $child->ID }  = $child;
    $_[HEAP]{children_by_pid}{ $child->PID } = $child;

}

sub on_child_stdout {
    my ( $stdout_line, $wheel_id ) = @_[ ARG0, ARG1 ];
    my $child = $_[HEAP]{children_by_wid}{$wheel_id};
    my $json  = JSON->new->utf8->allow_nonref;
    my $data  = eval { $json->decode($stdout_line) };
    my $id    = $_[HEAP]{sessionid};
    my $fun   = $_[HEAP]{fun};
    my $p     = P {
        $fun->($data);
        $poe_kernel->post( $id, 'sent', $data );
    };
    if ($data) {
        $p->();
    }
}

sub on_child_stderr {
    my ( $stderr_line, $wheel_id ) = @_[ ARG0, ARG1 ];
    my $child = $_[HEAP]{children_by_wid}{$wheel_id};
    Api::Common::Lock::unlock( $_[HEAP]{mem}, $_[HEAP]{data} );
    $poe_kernel->post( $_[HEAP]{sessionid},
        'sent',
        { code => '404', data => { message => "接口程序异常". " error: ". Encode::decode_utf8($stderr_line) } } );
    delete $_[HEAP]{sessionid};
}

sub on_child_close {
    my $wheel_id = $_[ARG0];
    my $child    = delete $_[HEAP]{children_by_wid}{$wheel_id};
    Api::Common::Lock::unlock( $_[HEAP]{mem}, $_[HEAP]{data} );
    delete $_[HEAP]{sessionid};
    unless ( defined $child ) {
        return;
    }
    delete $_[HEAP]{children_by_pid}{ $child->PID };
}

sub on_child_signal {
    my $child = delete $_[HEAP]{children_by_pid}{ $_[ARG1] };
    Api::Common::Lock::unlock( $_[HEAP]{mem}, $_[HEAP]{data} );
    delete $_[HEAP]{sessionid};
    return unless defined $child;
    delete $_[HEAP]{children_by_wid}{ $child->ID };
}

1;

