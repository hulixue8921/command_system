#
#===============================================================================
#
#         FILE: Mysql.pm
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: hlx (), hulixue@xiankan.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 11/11/2019 02:31:21 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

package Objects::Common::Mysql;
use 5.010;
use DBD::mysql;
use POE;

sub new {
    my $class    = shift;
    my $config   = shift;
    my $username = $config->getValue( 'Mysql', 'UserName' );
    my $passwd   = $config->getValue( 'Mysql', 'PassWord' );
    my $db       = $config->getValue( 'Mysql', 'DB' );
    my $host     = $config->getValue( 'Mysql', 'HostIp' );
    my $port     = $config->getValue( 'Mysql', 'Port' );
    my $conn     = $config->getValue( 'Mysql', 'connects' );
    my $reconn   = $config->getValue( 'Mysql', 'reconnect' );
    my $cons     = [];

    die "$ARGV[0] config 配置文件有错误 ！！！"
      unless $username
          && $passwd
          && $host
          && $db
          && $port
          && $conn
          && $reconn;

    my $add = sub {
        my $dsn = "DBI:mysql:database=$db;host=$host;port=$port";
        my $dbh =
          DBI->connect( $dsn, $username, $passwd,
            { RaiseError => 0, AutoCommit => 0 } );
        $dbh->do("SET NAMES utf8");
        push @$cons, $dbh;

    };

    for ( my $a = 0 ; $a < $conn ; $a = $a + 1 ) {
        $add->();
    }

    POE::Session->create(
        inline_states => {
            _start => sub {
                $poe_kernel->alarm_add( check => time() + $reconn );
            },
            check => sub {
                foreach my $i ( sort { $a < $b } ( 0 .. $#{$cons} ) ) {
                    my $r = eval { $cons->[$i]->ping };
                    if ( $r and $r eq 1 ) {
                    }
                    else {
                        $cons->[$i]->commit;
                        splice @$cons, $i, 1;
                        $add->();
                    }
                }
                $poe_kernel->alarm_add( '_start' => time() + $reconn );
            },

        }
    );

    bless { cons => $cons, }, $class;

}

sub get {
    my $self = shift;
    return shift @{ $self->{cons} };
}

sub put {
    my $self = shift;
    my $dbh  = shift;
    push @{ $self->{cons} }, $dbh;
}

1

