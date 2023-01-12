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

package Api::Tree;
use POE;
use Api::Common::Sql;
use Api::Common::ConManger;
use Data::Dumper;
use 5.010;

sub Control {
    my $k8s1 = { 'lyrra-k8s-dev'  => '' };
    my $k8s2 = { 'lyrra-k8s-test' => '' };
    my $k8s3 = { 'lyrra-k8s-pre'  => '' };
    my $k8s4 = { 'lyrra-k8s-prod' => '' };
    my $k8s5 = { 'fu-k8s-dev'  => '' };
    my $k8s6 = { 'fu-k8s-test' => '' };
    my $k8s7 = { 'fu-k8s-pre'  => '' };
    my $k8s8 = { 'fu-k8s-prod' => '' };
    my $k8s9 = { 'show-k8s-dev'  => '' };
    my $k8s10 = { 'show-k8s-test' => '' };
    my $k8s11 = { 'show-k8s-pre'  => '' };
    my $k8s12 = { 'show-k8s-prod' => '' };


    my $k8sLyrra       = { 'lyrra-k8s' => [ $k8s1, $k8s2, $k8s3, $k8s4 ] };
    my $k8sFuturemusic = { 'fu-k8s' => [ $k8s5, $k8s6, $k8s7, $k8s8 ] };
    my $k8sShow = { 'show-k8s' => [ $k8s9, $k8s10, $k8s11, $k8s12 ] };

    my $officVpn   = { 'officeVpn'  => '' };
    my $kunlunVpn  = { 'kunlunVpn'  => '' };
    my $overseaVpn = { 'overseaVpn' => '' };
    my $data       = [
        { 'lyrra'       => [$k8sLyrra] },
        { 'vpn'         => [ $officVpn, $overseaVpn ] },
        { 'futuremusic' => [$k8sFuturemusic] },
        { 'show' => [$k8sShow] }
    ];

    my $tempData = {
        0 => sub {
            delete $data->[0]->{'lyrra'}->[0]->{'lyrra-k8s'}->[3];
            delete $data->[1];
            delete $data->[2]->{'futuremusic'}->[0]->{'fu-k8s'}->[3];
            delete $data->[3]->{'show'}->[0]->{'show-k8s'}->[3];
        },
        2 => sub { }
    };
    my $mysql     = shift;
    my $mem       = shift;
    my $receData  = shift;
    my $sessionid = shift;

    unless ( defined $receData->{token} and $receData->{token} ) {
        die "用户模块缺少必要参数！！！";
    }
    else {
        my $user = Api::Common::ConManger::getUser( $mem, $receData->{token} );
        my $dbh = $mysql->get();
        my $result = Api::Common::Sql::select( $dbh,
            [ 'select treeId from user where name = ?', [$user] ] );
        $dbh->commit();
        $mysql->put($dbh);

        my $treeId = $result->[0]->{treeId};

        if ( defined $tempData->{$treeId} ) {
            $tempData->{$treeId}->();
        }

        $poe_kernel->yield( 'sent', { code => '200', data => $data } );
    }
}

1
