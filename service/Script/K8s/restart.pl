#!/usr/bin/env perl
#===============================================================================
#
#         FILE: restart.pl
#
#        USAGE: ./restart.pl
#
#  DESCRIPTION:
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: hlx (), hulixue@xiankan.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 2022年11月25日 15时53分04秒
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;
use JSON;
my $json = JSON->new->utf8->allow_nonref;
my $data = { code => '200', data => { data => [] } };

sub restart {
    my $ip         = shift;
    my $service    = shift;
    my $deployment = $service . "-deployment";
    open( H,
        "ssh root\@$ip \"kubectl rollout restart deployment  $deployment\"  |  "
    );

    while (<H>) {
        chomp;
        push @{ $data->{data}->{data} }, $_;
    }

    close H;
}
my $env = {
    dev  => "172.100.2.204",
    test => "172.100.2.204",
    pre  => "172.100.2.204",
    prod => "172.20.2.243"
};

my $service = $ARGV[0];

if ( $service =~ /-dev$|-test$|-pre$/ ) {
    &restart( $env->{dev}, $service );
}
elsif ( $service =~ /-prod$/ ) {
    &restart( $env->{prod}, $service );
}
else {
    &restart( $env->{prod}, $service );
}

say $json->encode($data);

