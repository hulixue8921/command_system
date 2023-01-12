#!/usr/bin/env perl
#===============================================================================
#
#         FILE: listUserOffic.pl
#
#        USAGE: ./listUserOffic.pl  
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
#      CREATED: 2022年11月11日 15时58分43秒
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;
use 5.010;
use JSON;
my $json   = JSON->new->utf8->allow_nonref;
my $data={code => '200' , data => { data => []}};
open (H , "ssh root\@$ARGV[0] \"cat /data/openvpn/pki/index.txt | grep '^V' | awk '{print\\\$NF}' | awk -F = '{print\\\$NF}'\"  |  " );

while (<H>) {
    chomp;
    push  @{$data->{data}->{data}} , $_;
}
close H;

say $json->encode($data);
