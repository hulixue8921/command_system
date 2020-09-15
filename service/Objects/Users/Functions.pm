#
#===============================================================================
#
#         FILE: Users.pm
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: hlx (), hulixue@xiankan.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 05/22/2020 04:12:38 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use 5.010;

package Objects::Users::Functions;
use Objects::Common::Log;
use Objects::Common::Utf8;
use utf8;

sub userInfo {
    my $self       = shift;
    my $username   = shift;
    my $json       = $self->{Data}->{json};
    my $mem        = $self->{Data}->{mem};
    my $mysqlpools = $self->{Data}->{mysql};

    my $tmp = $mem->get( 'user' . '_' . $username );

    #查看缓存，如果存在缓存信息
    if ($tmp) {
        $tmp = $json->decode($tmp);
        return $tmp;
    }
    else {

        #没有缓存，查看数据库
        my $dbh = $mysqlpools->get();
        my $sth = $dbh->prepare("select * from user where name= ?");
        $sth->execute($username);
        my $result = {};
        while ( my $ref = $sth->fetchrow_hashref() ) {
            &Objects::Common::Utf8::enUtf8( $ref, {}, 0 );
            $result = $ref;
            $dbh->commit();
            $mysqlpools->put($dbh);
        }
        return $result;
    }
}

sub projectInfo {

    #具体角色的项目信息
    my $self       = shift;
    my $roleid     = shift;
    my $json       = $self->{Data}->{json};
    my $mem        = $self->{Data}->{mem};
    my $mysqlpools = $self->{Data}->{mysql};
    my $result     = [];

    #管理员不需要查询缓存
    if ( $roleid eq '1' ) {
        my $dbh = $mysqlpools->get();
        my $sth = $dbh->prepare('select id, name from project');
        $sth->execute();
        while ( my $ref = $sth->fetchrow_hashref() ) {
            &Objects::Common::Utf8::enUtf8( $ref, {}, 0 );
            push @$result, $ref;
        }
        $dbh->commit();
        $mysqlpools->put($dbh);
        return $result;
    }

    my $tmp = $mem->get( 'role' . '_' . $roleid );
    if ($tmp) {
        $tmp = $json->decode($tmp);
        return $tmp;
    }
    else {
        my $dbh = $mysqlpools->get();
        my $sth = $dbh->prepare(
'select project.id,project.name from role left join r_p on role.id = r_p.roleid left join project on r_p.projectid = project.id where role.id = ? '
        );
        $sth->execute($roleid);
        while ( my $ref = $sth->fetchrow_hashref() ) {
            &Objects::Common::Utf8::enUtf8( $ref, {}, 0 );
            push @$result, $ref;
        }
        $dbh->commit();
        $mysqlpools->put($dbh);
        return $result;
    }

}

sub orderInfo {
    #具体项目下的指令信息
    my $self       = shift;
    my $pid        = shift;
    my $json       = $self->{Data}->{json};
    my $mem        = $self->{Data}->{mem};
    my $mysqlpools = $self->{Data}->{mysql};
    my $result     = [];

    my $tmp = $mem->get( 'project' . '_' . $pid );
    if ($tmp) {
        $tmp = $json->decode($tmp);
        return $tmp;
    }
    else {
        my $dbh = $mysqlpools->get();
        my $sth = $dbh->prepare('select * from `order` where projectid = ?');
        $sth->execute($pid);
        while ( my $ref = $sth->fetchrow_hashref() ) {
            &Objects::Common::Utf8::enUtf8( $ref, {}, 0 );
            push @$result, $ref;
        }
        $dbh->commit();
        $mysqlpools->put($dbh);
        return $result;
    }
}

sub orderInfoHandle {
    my $self = shift;
    my $json = $self->{Data}->{json};
    my $mem  = $self->{Data}->{mem};
}

1
