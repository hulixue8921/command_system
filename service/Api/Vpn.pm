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

package Api::Vpn;
use POE;
use 5.010;
use Cwd;
use Objects::Common::Config;
use Api::Common::MyFork;
use Api::Common::Lock;

my $api = {
    listUsers => \&listUsers,
    addUser   => \&addUser,
    delUser   => \&delUser
};
my $root       = getcwd;
my $scriptPath = $root . '/Script/Vpn/';
my $config     = Objects::Common::Config->new( $root . '/etc/sys.config' );
my $mailHtml   = $root . '/Html/openvpn.html';
my $vpns       = {
    'officeVpn' => {
        ip     => $config->getValue( 'Vpn', 'officeIp' ),
        passwd => $config->getValue( 'Vpn', 'officePasswd' ),
    },
    'overseaVpn' => {
        ip     => $config->getValue( 'Vpn', 'overseaIp' ),
        passwd => $config->getValue( 'Vpn', 'overseaPasswd' ),
    },

};

my $mailUser   = $config->getValue( 'Mail', 'user' );
my $mailPasswd = $config->getValue( 'Mail', 'passwd' );
my $mailAddr   = $config->getValue( 'Mail', 'addr' );

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

sub listUsers {
    my $mysql     = shift;
    my $mem       = shift;
    my $receData  = shift;
    my $sessionid = shift;

    unless ( defined $receData->{env} and $receData->{env} ) {
        die "用户模块必要参数缺失!!!";
    }
    else {
        # 防止单用户刷接口
        Api::Common::Lock::lock( $mem, $receData->{apiName} );
        Api::Common::MyFork::newFork(
            [
                'perl',
                $scriptPath . 'listUsers.pl',
                $vpns->{ $receData->{env} }->{ip},
                $vpns->{ $receData->{env} }->{passwd},

            ],
            $sessionid,
            $mem,
            $receData->{apiName},
            sub { }
        );
    }
}

sub addUser {
    my $mysql     = shift;
    my $mem       = shift;
    my $receData  = shift;
    my $sessionid = shift;

    unless (defined $receData->{env}
        and defined $receData->{user}
        and defined $receData->{token}
        and $receData->{env}
        and $receData->{user}
        and $receData->{token} )
    {
        die "用户模块必要参数缺失!!!";
    }
    else {
        Api::Common::Lock::lock( $mem, $receData->{apiName} );
        Api::Common::MyFork::newFork(
            [
                "bash",
                $scriptPath . 'addUser.sh',
                $vpns->{ $receData->{env} }->{ip},
                $receData->{user},
                $vpns->{ $receData->{env} }->{passwd},
                $mailUser,
                $mailPasswd,
                $mailAddr,
                $mailHtml,
            ],
            $sessionid,
            $mem,
            $receData->{apiName},
            sub {
            }
        );
    }
}

sub delUser {
    my $mysql     = shift;
    my $mem       = shift;
    my $receData  = shift;
    my $sessionid = shift;

    unless (
            defined $receData->{env}
        and defined $receData->{user}

        and defined $receData->{token}
        and $receData->{env}
        and $receData->{user}
        and $receData->{token}
      )
    {
        die "用户模块必要参数缺失!!!";
    }
    else {
        Api::Common::Lock::lock( $mem, $receData->{apiName} );
        Api::Common::MyFork::newFork(
            [
                "bash",
                $scriptPath . 'delUser.sh',
                $vpns->{ $receData->{env} }->{ip},
                $receData->{user},
                $vpns->{ $receData->{env} }->{passwd},
            ],
            $sessionid,
            $mem,
            $receData->{apiName},
            sub { }
        );
    }
}

1
