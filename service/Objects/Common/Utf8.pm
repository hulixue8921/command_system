#
#===============================================================================
#
#         FILE: Utf8.pm
#
#  DESCRIPTION: 
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: hlx (), hulixue@xiankan.com
# ORGANIZATION: 
#      VERSION: 1.0
#      CREATED: 06/03/2020 05:31:48 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
 
package Objects::Common::Utf8;
use utf8;

sub enUtf8 {
    my $data   = shift;
    my $Father = shift;
    my $key    = shift;

    if ( ref $data eq 'HASH' ) {
        foreach my $key ( keys %$data ) {
            &enUtf8( $data->{$key}, $data, $key );
        }
    }
    elsif ( ref $data eq 'ARRAY' ) {
        foreach my $i ( 0 .. $#$data ) {
            &enUtf8( $data->[$i], $data, $i );
        }
    }
    else {
        if ( ref $Father eq 'HASH' ) {
            Encode::_utf8_on( $Father->{$key} );
        }
        elsif ( ref $Father eq 'ARRAY' ) {
            Encode::_utf8_on( $Father->[$key] );
        }
    }
}

1
