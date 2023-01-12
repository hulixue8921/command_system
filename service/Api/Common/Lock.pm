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
use Encode;
use utf8;
package Api::Common::Lock;
use 5.010;
sub lock {
    my $mem    = shift;
    my $data   = shift;
    my $string = &myString($data);
    if ( $mem->{lock}->{$string} ) {
        die "触发了幂等性, 请不要重复提交或许某人也在执行这操作!!!";
    }
    $mem->{lock}->{$string} = 1;
}

sub unlock {
    my $mem    = shift;
    my $data   = shift;
    my $string = &myString($data);
    delete $mem->{lock}->{$string} if defined $mem->{lock}->{$string};
}

sub myString {
    my $data = shift;
    if ( ref $data eq 'HASH' ) {
        my $x = [];
        foreach my $key ( sort keys %$data ) {
            my $result = &myString( $data->{$key} );
            push @$x, $key . 'HASH' . $result;
        }
        my $r = '';
        for my $i (@$x) {
            $r = $r . $i;
        }
        return $r;
    }
    elsif ( ref $data eq 'ARRAY' ) {
        my $x = [];
        foreach my $i ( 0 .. $#$data ) {
            my $result = &myString( $data->[$i] );
            push @$x, $i . 'ARRAY' . $result;
        }
        my $r = '';
        for my $i (@$x) {
            $r = $r . $i;
        }
        return $r;
    }
    else {
        return $data;
    }

}

1
