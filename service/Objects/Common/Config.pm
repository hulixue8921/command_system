#
#===============================================================================
#
#         FILE: Config.pm
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: hlx (), hulixue@xiankan.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 11/08/2019 10:14:44 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

package Objects::Common::Config;
use 5.010;
use Data::Dumper;

sub new {
    my $class = shift;
    my $file  = shift;
    my $info  = { file => $file };
    my $ConfigKey;

    die "没有参数:" unless $file;

    open Read, $file or die "没有文件： $file !!!!";

    while (<Read>) {
        if ( $_ =~ /\[(\w+)\]:/ ) {
            $ConfigKey = $1;
        }
        elsif ( $_ =~ /(.*)=(.*)/ ) {
            $info->{$ConfigKey}->{$1} = $2;
        } 
        else {
            die "配置文件格式有错误 ！！！"
        }
    }

    bless $info, $class;
}

sub getValue {
    my $self = shift;
    my $moduleKey=shift;
    my $key=shift;
    return []  unless $moduleKey &&  $key;
    return $self->{$moduleKey}->{$key}
}

1
