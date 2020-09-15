#
#===============================================================================
#
#         FILE: Users.pm
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: hlx (), hulixue@xiankan.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 05/22/2020 04:12:38 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use 5.010;
use utf8;

package Objects::Datas::Datas;
use Objects::Common::Log;
use POE;

sub new {
    my $class    = shift;
    my $conid    = shift;
    my $mem      = shift;
    my $mysql    = shift;
    my $data     = shift;
    my $json     = shift;
    my $config   = shift;
    my $infoCode = shift;
    my $log      = Objects::Common::Log->new( $config, __PACKAGE__ );

    bless {
        sessionid => $conid,
        mem       => $mem,
        mysql     => $mysql,
        data      => $data,
        json      => $json,
        config    => $config,
        infoCode  => $infoCode,
        log       => $log,
    }, $class;

}


1
