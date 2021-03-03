#
#===============================================================================
#
#         FILE: Sql.pm
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: hlx (), hulixue@xiankan.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 02/02/2021 05:46:35 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;


package Api::Common::Sql;
use 5.010;
use utf8;
use Encode;

sub sql {
    my $dbh = shift;
    my $sql = shift;
    my $result;

   # say $sql->[0];
    use Data::Dumper;
    #say Dumper $sql;
    my $sth = eval { $dbh->prepare( $sql->[0] ) };

    if ( $sql->[1] ) {
         $result= eval { $sth->execute( @{ $sql->[1] } ) };
    }
    else {
         $result = eval { $sth->execute() } ;
    }

    unless  ($result) {
        return 0;
    }

    return $sth;

}

sub select {
    my $dbh    = shift;
    my $sql    = shift;
    my $result = [];

    my $sth = &sql( $dbh, $sql );
    eval {
        while ( my $ref = $sth->fetchrow_hashref() ) {
            foreach my $key (keys %{$ref}) {
                Encode::_utf8_on($ref->{$key});
            }
            push @$result, $ref;
        }
    };
   return $result;
}

sub insert_update_delete {
    my $dbh    = shift;
    my $sql    = shift;
    my $result=&sql( $dbh, $sql );
    if ($result eq 0 ) {
        return 0;
    } else {
        return 1;
    }
} 

1
