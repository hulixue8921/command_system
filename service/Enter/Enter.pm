#
#===============================================================================
#
#         FILE: User.pm
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: hlx (), hulixue@xiankan.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 11/08/2019 10:15:37 AM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

package Enter::Enter;
use 5.010;
use utf8;
use Data::Dumper;

use Objects::Users::Users;
use Objects::Datas::Datas;
use Objects::Common::Log;

sub mySplit {
    my $sessionid = shift;
    my $mem       = shift;
    my $mysql     = shift;
    my $data      = shift;
    my $json      = shift;
    my $config    = shift;
    my $log       = Objects::Common::Log->new( $config, __PACKAGE__ );

    my $Data =
      Objects::Datas::Datas->new( $sessionid, $mem, $mysql, $data, $json,
        $config, );

    my $user = Objects::Users::Users->new($Data);

    #程序入口配置表
    my $tab = {
        user_load         => sub { $user->load() },
        user_getOrder     => sub { $user->getOrder() },
        user_getOrderCssData => sub { $user->getOrderCssData() },
        user_execOrder    => sub { $user->execOrder() },
    };

    ###用户输入数据检测
    unless ( ref $data eq 'HASH' ) {
        return 1;
    }

    my @tmp = keys %$data;

    my $request_object = $tmp[0];

    return unless $request_object;

    return unless ref $data->{$request_object} eq 'HASH';

    return
      unless exists $data->{$request_object}->{action}
          and exists $data->{$request_object}->{username};
    return
      unless
        exists $tab->{ $request_object . '_'
                . $data->{$request_object}->{action} };
    #进入逻辑程序
    $tab->{ $request_object . '_' . $data->{$request_object}->{action} }->();

}

1
