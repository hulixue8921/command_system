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

package Api::Ci;
use POE;
use 5.010;
use Cwd;
use Objects::Common::Config;
use Api::Common::MyFork;
use Api::Common::Lock;

my $api        = { fabu => \&fabu, };
my $root       = getcwd;
my $scriptPath = $root . '/Script/Ci/';

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

sub fabu {
    my $mysql     = shift;
    my $mem       = shift;
    my $receData  = shift;
    my $sessionid = shift;

    unless (defined $receData->{env}
        and defined $receData->{git}
        and defined $receData->{tag}
        and defined $receData->{service}
        and $receData->{env}
        and $receData->{git}
        and $receData->{service}
        and $receData->{tag} )
    {
        die "用户模块必要参数缺失!!!";
    }
    else {
        # 防止单用户刷接口
        unless ( exists $mem->{token}->{ $receData->{token} } ) {
            $poe_kernel->yield( 'sent', { 'code' => '204', data => {} } );
            die "token 无效";
        }
        Api::Common::Lock::lock(
            $mem,
            {
                apiName   => $receData->{apiName},
                modelName => $receData->{modelName},
                env       => $receData->{env},
                git       => $receData->{git}
            }
        );
        Api::Common::MyFork::newFork(
            [
                'bash',
                $scriptPath . 'fabu.sh',
                $receData->{env}, $receData->{git}, $receData->{tag},
                $receData->{service}

            ],
            $sessionid,
            $mem,
            {
                apiName   => $receData->{apiName},
                modelName => $receData->{modelName},
                env       => $receData->{env},
                git       => $receData->{git}
            },
            sub { }
        );
        say ("bash fabu.sh $receData->{env}  $receData->{git}  $receData->{tag}  $receData->{service}");
    }
}

1
