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

package Api::Fabu::FabuFun;
use Api::Common::Sql;
use POE;
use POE::Wheel::Run;
use JSON;
use 5.010;

my $json = JSON->new->utf8->allow_nonref;

sub lock {
    my $mem      = shift;
    my $receData = shift;
    if (
        defined $mem->{lock}->{
                $receData->{modelName}
              . $receData->{apiName}
              . $receData->{projectid}
              . $receData->{envid}
        }
      )
    {
        return 0;
    }
    else {
        $mem->{lock}->{ $receData->{modelName}
              . $receData->{apiName}
              . $receData->{projectid}
              . $receData->{envid} } = 1;
        return 1;
    }
}

sub unlock {
    my $mem      = shift;
    my $receData = shift;
    delete $mem->{lock}->{ $receData->{modelName}
          . $receData->{apiName}
          . $receData->{projectid}
          . $receData->{envid} };
}

sub checkRight {
    my $dbh       = shift;
    my $mem       = shift;
    my $receData  = shift;
    my $sessionid = shift;
    my $result;

    return [] unless defined $mem->{id}->{$sessionid};

    $result = Api::Common::Sql::select(
        $dbh,
        [
'select  `right`.env_id from user left join model_fabu_role as role  on user.roleid_fabu = role.id left join model_fabu_role_fabu as `right`  on role.id = `right`.role_id where user.name =? and `right`.fabu_id =? and `right`.env_id = ?',
            [
                $mem->{id}->{$sessionid}, $receData->{projectid},
                $receData->{envid}
            ]
        ]
    );

    return $result;

}

sub action {
    my $dbh       = shift;
    my $mem       = shift;
    my $receData  = shift;
    my $sessionid = shift;

    my $sql;

    if ( $receData->{envid} eq 2 or $receData->{envid} eq '02' ) {
        $sql =
'select git,scriptname,onlineips as ip  from model_fabu_fabu where id = ? ';
    }
    elsif ( $receData->{envid} eq 1 or $receData->{envid} eq '01' ) {
        $sql =
'select git,scriptname,qaips as ip from model_fabu_fabu where id = ? ';
    }

    my $result =
      Api::Common::Sql::select( $dbh, [ $sql, [ $receData->{projectid} ] ] );

    ###开启多进程
    POE::Session->create(
        inline_states => {
            _start           => \&on_start,
            got_child_stdout => \&on_child_stdout,
            got_child_stderr => \&on_child_stderr,
            got_child_close  => \&on_child_close,
            got_child_signal => \&on_child_signal
        },
        args => [ $result, $mem, $receData, $sessionid ],
    );

    sub on_start {
        my $result = $_[ARG0];
        $_[HEAP]{mem}       = $_[ARG1];
        $_[HEAP]{receData}  = $_[ARG2];
        $_[HEAP]{sessionid} = $_[ARG3];

        my $child = POE::Wheel::Run->new(

            Program => [
                "/root/project/service/Api/Fabu/Script/fabu.sh",
                $result->[0]->{git},
                $result->[0]->{ip}
            ],
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
        my $data = eval { $json->decode($stdout_line) };
        if ($data) {
            $poe_kernel->post( $_[HEAP]{sessionid}, 'sent', $data );
        }
    }

    sub on_child_stderr {
        my ( $stderr_line, $wheel_id ) = @_[ ARG0, ARG1 ];
        my $child = $_[HEAP]{children_by_wid}{$wheel_id};
    }

    sub on_child_close {
        my $wheel_id = $_[ARG0];
        my $child    = delete $_[HEAP]{children_by_wid}{$wheel_id};
        &unlock( $_[HEAP]{mem}, $_[HEAP]{receData}, $_[HEAP]{sessionid} )
          if defined $_[HEAP]{mem}
              and defined $_[HEAP]{receData}
              and defined $_[HEAP]{sessionid};
        delete $_[HEAP]{mem};
        delete $_[HEAP]{receData};
        delete $_[HEAP]{sessionid};
        unless ( defined $child ) {
            return;
        }
        delete $_[HEAP]{children_by_pid}{ $child->PID };
    }

    sub on_child_signal {
        my $child = delete $_[HEAP]{children_by_pid}{ $_[ARG1] };
        &unlock( $_[HEAP]{mem}, $_[HEAP]{receData}, $_[HEAP]{sessionid} )
          if defined $_[HEAP]{mem}
              and defined $_[HEAP]{receData}
              and defined $_[HEAP]{sessionid};
        delete $_[HEAP]{mem};
        delete $_[HEAP]{receData};
        delete $_[HEAP]{sessionid};
        return unless defined $child;
        delete $_[HEAP]{children_by_wid}{ $child->ID };
    }

}

1;

