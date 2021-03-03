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

my $api = {
    load => \&Load,
    reg  => \&Reg,
};

sub Control {
    my $mysql     = shift;
    my $mem       = shift;
    my $receData  = shift;
    my $sessionid = shift;

    unless (defined $receData->{apiName}
        and defined $api->{ $receData->{apiName} }
        and defined $receData->{username}
        and defined $receData->{passwd}
        and $receData->{username}
        and $receData->{passwd} )
    {
        $poe_kernel->yield( 'sent', $mem->{status}->{lack} );
    }
    else {
        $api->{ $receData->{apiName} }->( $mysql, $mem, $receData, $sessionid );
    }

}

sub Load {
    my $mysql     = shift;
    my $mem       = shift;
    my $receData  = shift;
    my $sessionid = shift;

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
            $sessionid,$mysql );
        $poe_kernel->yield( 'sent', $mem->{status}->{ok} );
    }
    else {
        $poe_kernel->yield( 'sent', $mem->{status}->{abort} );
    }
    $dbh->commit();
    $mysql->put($dbh);

}

sub Reg {
    my $mysql     = shift;
    my $mem       = shift;
    my $receData  = shift;
    my $sessionid = shift;

    my $dbh = $mysql->get();
    my $result =
      Api::Common::Sql::select( $dbh,
        [ 'select id from user where name =? ', [ $receData->{username} ] ] );
    
    if ( $#$result >= 0 ) {
        $poe_kernel->yield( 'sent', $mem->{status}->{abort} );
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
            $poe_kernel->yield( 'sent', $mem->{status}->{ok} );
            Api::Common::ConManger::create( $mem, $receData->{username},
                $sessionid,$mysql );
        }
        else {
            $poe_kernel->yield( 'sent', $mem->{status}->{abort} );
        }

    }

    $dbh->commit();
    $mysql->put($dbh);

}

1
