#
#===============================================================================
#
#         FILE: User.pm
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: hlx (), hulixue@xiankan.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 01/29/2021 04:47:31 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

package Api::K8s;
use POE;
use 5.010;
use Cwd;
use Objects::Common::Config;
use Api::Common::MyFork;
use Api::Common::Lock;

my $api = {
    listPods => \&listPods,
    restart  => \&restart,
    podNum   => \&podNum
};
my $root       = getcwd;
my $scriptPath = $root . '/Script/K8s/';

sub Control {
    my $mysql     = shift;
    my $mem       = shift;
    my $receData  = shift;
    my $sessionid = shift;

    unless (defined $receData->{apiName}
        and defined $api->{ $receData->{apiName} } )
    {
        die "用户模块必要参数缺失!!!";
    }
    else {
        $api->{ $receData->{apiName} }->( $mysql, $mem, $receData, $sessionid );
    }

}

sub listPods {
    my $mysql     = shift;
    my $mem       = shift;
    my $receData  = shift;
    my $sessionid = shift;

    unless (defined $receData->{env}
        and defined $receData->{token}
        and $receData->{env}
        and $receData->{token} )
    {
        die "用户模块必要参数缺失!!!";
    }
    else {
        if ( exists $mem->{token}->{ $receData->{token} } ) {

            # 防止单用户刷接口
            Api::Common::Lock::lock( $mem, $receData->{token} );
            Api::Common::MyFork::newFork(
                [ 'perl', $scriptPath . 'listPods.pl', $receData->{env} ],
                $sessionid, $mem, $receData->{token}, sub { } );
        }
        else {
            $poe_kernel->yield( 'sent', { code => '204', data => {} } );
        }

    }
}

sub restart {
    my $mysql     = shift;
    my $mem       = shift;
    my $receData  = shift;
    my $sessionid = shift;

    unless (defined $receData->{service}
        and defined $receData->{token}
        and $receData->{service}
        and $receData->{token} )
    {
        die "用户模块必要参数缺失!!!";
    }
    else {
        if ( exists $mem->{token}->{ $receData->{token} } ) {

            # 防止单用户刷接口
            Api::Common::Lock::lock(
                $mem,
                {
                    modelName => $receData->{modelName},
                    apiName   => $receData->{apiName},
                    service   => $receData->{service},
                }
            );
            Api::Common::MyFork::newFork(
                [ 'perl', $scriptPath . 'restart.pl', $receData->{service} ],
                $sessionid,
                $mem,
                {
                    modelName => $receData->{modelName},
                    apiName   => $receData->{apiName},
                    service   => $receData->{service},
                },
                sub { }
            );
        }
        else {
            $poe_kernel->yield( 'sent', { code => '204', data => {} } );
        }

    }

}

sub podNum {
    my $mysql     = shift;
    my $mem       = shift;
    my $receData  = shift;
    my $sessionid = shift;

    unless (defined $receData->{service}
        and defined $receData->{token}
        and defined $receData->{number} )
    {
        die "用户模块必要参数缺失!!!";
    }
    else {
        if ( exists $mem->{token}->{ $receData->{token} } ) {

            # 防止单用户刷接口
            Api::Common::Lock::lock(
                $mem,
                {
                    modelName => $receData->{modelName},
                    apiName   => $receData->{apiName},
                    service   => $receData->{service},
                }
            );
            Api::Common::MyFork::newFork(
                [
                    'perl',               $scriptPath . 'podNum.pl',
                    $receData->{service}, $receData->{number}
                ],
                $sessionid,
                $mem,
                {
                    modelName => $receData->{modelName},
                    apiName   => $receData->{apiName},
                    service   => $receData->{service},
                },
                sub { }
            );
        }
        else {
            $poe_kernel->yield( 'sent', { code => '204', data => {} } );
        }

    }

}

1
