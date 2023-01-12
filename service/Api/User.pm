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

package Api::User;
use POE;
use Api::Common::Sql;
use Api::Common::ConManger;
use Data::Dumper;
use 5.010;
use Cwd;
use Objects::Common::Config;

my $api = {
    load => \&Load,
    reg  => \&Reg,
};

sub Control {
    my $mysql     = shift;
    my $mem       = shift;
    my $receData  = shift;
    my $sessionid = shift;
    my $root      = getcwd;
    my $config    = Objects::Common::Config->new( $root . '/etc/sys.config' );
    my $version   = $config->getValue( 'Sys', 'Version' );

    unless (defined $receData->{apiName}
        and defined $api->{ $receData->{apiName} }
        and defined $receData->{username}
        and defined $receData->{passwd}
        and defined $receData->{version}
        and $receData->{username}
        and $receData->{version}
        and $receData->{passwd} )
    {
        die "用户模块必要参数缺失!!!";
    }
    else {
        unless ( $receData->{version} eq $version ) {
            die "客户端版本需要更新!!!";
        }
        $api->{ $receData->{apiName} }->( $mysql, $mem, $receData, $sessionid );
    }

}

sub Load {
    my $mysql     = shift;
    my $mem       = shift;
    my $receData  = shift;
    my $sessionid = shift;

    my $maxLenth     = 18;
    my @dataSource   = ( 0 .. 9, 'a' .. 'z', 'A' .. 'Z' );
    my $randomString = join '',
      map { $dataSource[ int rand @dataSource ] } 0 .. ( $maxLenth - 1 );

    my $dbh    = $mysql->get();
    my $result = Api::Common::Sql::select(
        $dbh,
        [
            'select id from user where name =? and passwd =?',
            [ $receData->{username}, $receData->{passwd} ]
        ]
    );

    if ( $#$result >= 0 ) {
        Api::Common::ConManger::create( $mem, $receData->{username},
            $sessionid, $mysql, $randomString );
        $poe_kernel->yield( 'sent',
            { code => '200', data => { token => $randomString } } );
        $dbh->commit();
        $mysql->put($dbh);
    }
    else {
        $dbh->commit();
        $mysql->put($dbh);
        die "用户名或密码不正确!!!";
    }

}

sub Reg {
    my $mysql     = shift;
    my $mem       = shift;
    my $receData  = shift;
    my $sessionid = shift;

    my $maxLenth     = 18;
    my @dataSource   = ( 0 .. 9, 'a' .. 'z', 'A' .. 'Z' );
    my $randomString = join '',
      map { $dataSource[ int rand @dataSource ] } 0 .. ( $maxLenth - 1 );

    my $dbh = $mysql->get();
    my $result =
      Api::Common::Sql::select( $dbh,
        [ 'select id from user where name =? ', [ $receData->{username} ] ] );

    if ( $#$result >= 0 ) {
        $dbh->commit();
        $mysql->put($dbh);
        die "用户名已存在!!!";
    }
    else {
        my $result = Api::Common::Sql::insert_update_delete(
            $dbh,
            [
                'insert into user (name, passwd) values (?, ?)',
                [ $receData->{username}, $receData->{passwd} ]
            ]
        );
        unless ( $result eq 0 ) {
            $poe_kernel->yield( 'sent',
                { code => '200', data => { token => $randomString } } );
            $dbh->commit();
            $mysql->put($dbh);
            Api::Common::ConManger::create( $mem, $receData->{username},
                $sessionid, $mysql, $randomString );
        }
        else {
            $dbh->commit();
            $mysql->put($dbh);
            die "注册失败!!!";
        }

    }

}

1
