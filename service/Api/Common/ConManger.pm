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
    my $mem       = shift;
    my $user      = shift;
    my $sessionid = shift;
    my $mysql = shift;

    #多次登录、注册，都把这连接绑定在第一次登录的身份上
    unless ( exists $mem->{id}->{$sessionid} ) {
        $mem->{id}->{$sessionid} = $user;
        ##
        my $dbh=$mysql->get();
        my $sql='select roleid_fabu_cms from user where name = ? ';
        my $result=Api::Common::Sql::select($dbh,[$sql,[$user]]);
        $mem->{roleid_fabu_cms}->{$user}=$result->[0]->{roleid_fabu_cms};

        $dbh->commit();
        $mysql->put($dbh);
    }
}

1
