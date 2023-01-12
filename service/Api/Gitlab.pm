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

package Api::Gitlab;
use POE;
use 5.010;
use Cwd;
use Objects::Common::Config;
use Api::Common::MyFork;
use Api::Common::Lock;

my $api         = { listTags => \&listTags };
my $root        = getcwd;
my $scriptPath  = $root . '/Script/Gitlab/';
my $config      = Objects::Common::Config->new( $root . '/etc/sys.config' );
my $gitlabUrl   = $config->getValue( 'Gitlab', 'url' );
my $gitlabToken = $config->getValue( 'Gitlab', 'token' );

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

sub listTags {
    my $mysql     = shift;
    my $mem       = shift;
    my $receData  = shift;
    my $sessionid = shift;

    unless ( defined $receData->{projectName} and $receData->{projectName} ) {
        die "用户模块必要参数缺失!!!";
    }
    else {
        # 防止单用户刷接口
        my $gitHub = $config->getValue( 'K8sGitlab', $receData->{projectName} );
        Api::Common::Lock::lock(
            $mem,
            {
                modelName   => $receData->{modelName},
                apiName     => $receData->{apiName},
                projectName => $receData->{projectName},
                token       => $receData->{token}
            }
        );
        Api::Common::MyFork::newFork(
            [
                '/usr/local/python3/bin/python3', $scriptPath . 'listTags.py',
                $gitlabUrl,                       $gitlabToken,
                $gitHub
            ],
            $sessionid,
            $mem,
            {
                modelName   => $receData->{modelName},
                apiName     => $receData->{apiName},
                projectName => $receData->{projectName},
                token       => $receData->{token}
            },
            sub { }
        );
    }
}

1
