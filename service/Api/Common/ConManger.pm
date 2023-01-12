#
#===============================================================================
#
#         FILE: SessionMange.pm
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: hlx (), hulixue@xiankan.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 02/02/2021 06:00:29 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

package Api::Common::ConManger;
use Api::Common::Sql;

sub create {
    my $mem          = shift;
    my $user         = shift;
    my $sessionid    = shift;
    my $mysql        = shift;
    my $randomString = shift;

    $mem->{id}->{$sessionid}->{user}       = $user;
    $mem->{id}->{$sessionid}->{token}      = $randomString;
    $mem->{token}->{$randomString}->{user} = $user;
    $mem->{user}->{$user}->{id}            = $sessionid;
}

sub getUser {
    my $mem          = shift;
    my $token = shift;
    return $mem->{token}->{$token}->{user};
}

1
