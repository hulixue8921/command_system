#
#===============================================================================
#
#         FILE: Mem.pm
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: hlx (), hulixue@xiankan.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 11/11/2019 10:40:19 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

package Objects::Common::Mem;
use 5.010;
use utf8;

sub new {
    my $class  = shift;
    my $config = shift;
    my $self   = { config => $config };
    bless $self, $class;
}


sub set {
    my $self  = shift;
    my $key   = shift;
    my $value = shift;
    #bug 修复，config 是本身的属性， 不能作为key 存储
    return 0 if $key eq 'config';
    Encode::_utf8_on($key);
    $self->{$key} = $value;
}

sub get {
    my $self = shift;
    my $key  = shift;
    return $self->{$key} if exists $self->{$key};
    return;
}

sub keys {
    my $self   = shift;
    my @result = keys %$self;
    return \@result;
}

sub voteKey {
    my $self = shift;
    my $key  = shift;
    return 0 unless $key;
    unless ( exists $self->{$key} ) {
        return 0;
    }
    else {
        return 1;
    }
}

sub del {
    my $self = shift;
    my $key  = shift;
    return 0 unless $key;
    delete $self->{$key};
}


1

