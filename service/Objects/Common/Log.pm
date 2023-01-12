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

package Objects::Common::Log;
use 5.010;
use POE;
use FindBin qw($Bin);
use Log::Log4perl qw(get_logger);

our $logfile;

sub new {
    my $class       = shift;
    my $config      = shift;
    my $packagename = shift;
    $logfile     = $config->getValue( 'Sys', 'Sys_log' );


    my $log = get_logger($packagename);

    Log::Log4perl::init_and_watch( $config->getValue( 'Sys', 'Sys_log_config' ),
        60 );

    return $log;

}

sub set_log_name {
    return $logfile;
}

1
