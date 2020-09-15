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

    die "$ARGV[0] config 配置文件有错误 ！！！"
      unless $username
          && $passwd
          && $host
          && $db
          && $port
          && $conn
          && $reconn;

    bless {
        cons     => [],
        username => $username,
        passwd   => $passwd,
        db       => $db,
        host     => $host,
          port   => $port,
        conn   => $conn,
        reconn => $reconn
    }, $class;

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

sub delete {
    my $self  = shift;
    my $index = shift;
    splice @{ $self->{cons} }, $index, 1;
}

sub add {
    my $self = shift;
    my $conn = shift;
    push @{ $self->{cons} }, $conn;
}

sub pool {
    my $self      = shift;
    my $sessionid = shift;

    my $dsn =
      "DBI:mysql:database=$self->{db};host=$self->{host};port=$self->{port}";

    while ( $self->{conn} > 0 ) {
        my $dbh =
          DBI->connect( $dsn, $self->{username}, $self->{passwd},
            { RaiseError => 0, AutoCommit => 0 } );
        $dbh->do("SET NAMES utf8");
        if ($dbh) {
            $self->add($dbh);
            $self->{conn}--;
        }
    }

    $poe_kernel->yield('mysqlping');
}

sub defendPool {
    my $self = shift;
    foreach my $i ( sort { $a < $b } ( 0 .. $#{ $self->{cons} } ) ) {
        my $r = eval { $self->{cons}->[$i]->ping };
        if ( $r and $r eq 1 ) {
        }
        else {
            $self->{cons}->[$i]->commit;
            $self->delete($i);
        }
    }

    if ( $#{ $self->{cons} } < 4 ) {
        $self->{conn} = 4 - $#{ $self->{cons} };
        $poe_kernel->alarm_add( '_start' => time() + $self->{reconn} );
    }
    else {
        $poe_kernel->alarm_add( mysqlping => time() + $self->{reconn} );
    }
}

1

