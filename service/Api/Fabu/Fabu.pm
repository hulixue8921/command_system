#
#===============================================================================
#
#         FILE: Fabu.pm
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: hlx (), hulixue@xiankan.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 02/01/2021 04:36:06 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;
use utf8;

package Api::Fabu::Fabu;
use Api::Fabu::FabuFun;
use Api::Common::Sql;
use POE;
use 5.010;
use Encode;

my $api = {
    fabu         => \&fabu,
    getfabuinfo  => \&getFabuInfo,
    addfabu      => \&addfabu,         ##cms权限
    getallfabu   => \&getallfabu,
    delfabus     => \&delfabus,        ## cms 权限
    updatefabu   => \&updatefabu,      ## cms 权限
    addrole      => \&addrole,         ## cms 权限
    rolefabuinfo => \&rolefabuinfo,    ## cms 权限 role fabu关联信息
    rolefabuupdate =>
      \&rolefabuupdate,    ## cms 权限，更新role fabu 关联信息
    roleuserinfo   => \&roleuserinfo,      ##cms 权限,role user 关联信息
    userinfo       => \&userinfo,          ##cms 权限，
    roleuserupdate => \&roleuserupdate,    ##cms 权限

};

sub Control {
    my $mysql     = shift;
    my $mem       = shift;
    my $receData  = shift;
    my $sessionid = shift;

    unless (defined $receData->{apiName}
        and defined $api->{ $receData->{apiName} } )
    {
        $poe_kernel->yield( 'sent', $mem->{status}->{lack} );
        return;
    }
    else {
        unless ( exists $mem->{id}->{$sessionid} ) {
            $poe_kernel->yield( 'sent', $mem->{status}->{noauth} );
        }
        else {

            #进入流程
            $api->{ $receData->{apiName} }
              ->( $mysql, $mem, $receData, $sessionid );
        }
    }

}

sub getFabuInfo {
    my $mysql     = shift;
    my $mem       = shift;
    my $receData  = shift;
    my $sessionid = shift;

    # {modelName=>'fabu', apiName=>'getFabuInfo'}

    unless ( exists $mem->{id}->{$sessionid} ) {
        $poe_kernel->yield( 'sent', $mem->{status}->{noauth} );
        return;
    }

    my $dbh = $mysql->get();
    my $sql =
"select fabu.id , fabu.projectname,`right`.env_id from user left join model_fabu_role as role  on user.roleid_fabu = role.id left join model_fabu_role_fabu as `right`  on role.id = `right`.role_id  left join model_fabu_fabu as fabu on `right`.fabu_id= fabu.id  where user.name = ? ;";

    my $results =
      Api::Common::Sql::select( $dbh, [ $sql, [ $mem->{id}->{$sessionid} ] ] );
    my $temp = {};

    foreach my $in ( 0 .. $#$results ) {
        my @temp = keys %$temp;
        if ( grep { $_ eq $results->[$in]->{projectname} } @temp ) {
            push @{ $temp->{ $results->[$in]->{projectname} }->{envids} },
              $results->[$in]->{env_id};
        }
        else {
            $temp->{ $results->[$in]->{projectname} }->{projectname} =
              $results->[$in]->{projectname};
            $temp->{ $results->[$in]->{projectname} }->{id} =
              $results->[$in]->{id};
            $temp->{ $results->[$in]->{projectname} }->{envids} =
              [ $results->[$in]->{env_id} ];
        }

    }

    $poe_kernel->yield(
        'sent',
        {
            data      => $temp,
            modelName => $receData->{modelName},
            apiName   => $receData->{apiName},
            code      => 200,
        }
    );

    $dbh->commit();
    $mysql->put($dbh);

}

sub fabu {
    my $mysql     = shift;
    my $mem       = shift;
    my $receData  = shift;
    my $sessionid = shift;

    #{modelName=>'fabu',apiName=>'fabu','version'=>'',projectid=>'',envid=>''}
    unless (defined $receData->{version}
        and defined $receData->{projectid}
        and defined $receData->{envid}
        and $receData->{version}
        and $receData->{projectid}
        and $receData->{envid} )
    {
        $poe_kernel->yield( 'sent', $mem->{status}->{lack} );
        return;

    }

    my $dbh = $mysql->get();

    my $result =
      Api::Fabu::FabuFun::checkRight( $dbh, $mem, $receData, $sessionid );
    if ( $#$result >= 0 ) {
        if ( Api::Fabu::FabuFun::lock( $mem, $receData ) eq 0 ) {
            $poe_kernel->yield( 'sent', $mem->{status}->{running} );
            $dbh->commit();
            $mysql->put($dbh);
            return 0;
        }
        Api::Fabu::FabuFun::action( $dbh, $mem, $receData, $sessionid );
    }
    else {
        $poe_kernel->yield( 'sent', $mem->{status}->{noright} );
    }

    $dbh->commit();
    $mysql->put($dbh);
}

sub addfabu {
    my $mysql     = shift;
    my $mem       = shift;
    my $receData  = shift;
    my $sessionid = shift;

#{modelName=>'fabu',apiName=>'fabu','git'=>'','scriptname'=>'' ,'qaips'=>'','onlineips'=>'',name=>''}

    ###此处需要鉴权，查看role
    if ( $mem->{roleid_fabu_cms}->{ $mem->{id}->{$sessionid} } eq 0 ) {
        $poe_kernel->yield( 'sent', $mem->{status}->{noright} );
        return;
    }

    #检查参数
    unless (defined $receData->{git}
        and defined $receData->{scriptname}
        and defined $receData->{qaips}
        and defined $receData->{onlineips}
        and defined $receData->{name}
        and $receData->{git}
        and $receData->{scriptname}
        and $receData->{qaips}
        and $receData->{onlineips}
        and $receData->{name} )
    {
        $poe_kernel->yield( 'sent', $mem->{status}->{lack} );
        return;
    }

    my $dbh = $mysql->get();
    my $sql =
'insert into model_fabu_fabu (git,scriptname,qaips,onlineips,projectname ) values (?,?,?,?,?)';
    Api::Common::Sql::insert_update_delete(
        $dbh,
        [
            $sql,
            [
                $receData->{git},   $receData->{scriptname},
                $receData->{qaips}, $receData->{onlineips},
                $receData->{name}
            ]
        ]
      )
      ? $poe_kernel->yield( 'sent', $mem->{status}->{ok} )
      : $poe_kernel->yield( 'sent', $mem->{status}->{fail} );

    $dbh->commit();
    $mysql->put($dbh);
}

sub getallfabu {
    my $mysql     = shift;
    my $mem       = shift;
    my $receData  = shift;
    my $sessionid = shift;

    #{modelName=>'fabu',apiName=>'getallfabu'}

    my $dbh    = $mysql->get();
    my $sql    = 'select * from model_fabu_fabu';
    my $result = Api::Common::Sql::select( $dbh, [ $sql, [] ] );
    $poe_kernel->yield(
        'sent',
        {
            'modelName' => 'fabu',
            'apiName'   => 'getallfabu',
            'data'      => $result,
            'code'      => 200
        }
    );

    $dbh->commit();
    $mysql->put($dbh);

}

sub delfabus {
    my $mysql     = shift;
    my $mem       = shift;
    my $receData  = shift;
    my $sessionid = shift;

    #{modelName=>'fabu',apiName=>'delfabus',id=>['','','']}
    ###此处需要鉴权，查看role
    if ( $mem->{roleid_fabu_cms}->{ $mem->{id}->{$sessionid} } eq 0 ) {
        $poe_kernel->yield( 'sent', $mem->{status}->{noright} );
        return;
    }

    unless ( defined $receData->{id} and ref $receData->{id} eq 'ARRAY' ) {
        $poe_kernel->yield( 'sent', $mem->{status}->{lack} );
        return;
    }
    ##鉴权操作
    ##执行操作
    my $dbh  = $mysql->get();
    my $sql  = 'delete from model_fabu_fabu where id = ?';
    my $sql1 = 'delete from model_fabu_role_fabu where fabu_id = ?';
    foreach my $id ( @{ $receData->{id} } ) {
        Api::Common::Sql::insert_update_delete( $dbh, [ $sql,  [$id] ] );
        Api::Common::Sql::insert_update_delete( $dbh, [ $sql1, [$id] ] );
    }

    if ( $dbh->commit() ) {
        $poe_kernel->yield( 'sent', $mem->{status}->{ok} );
    }
    else {
        $poe_kernel->yield( 'sent', $mem->{status}->{fail} );
    }
    $mysql->put($dbh);

}

sub updatefabu {
    my $mysql     = shift;
    my $mem       = shift;
    my $receData  = shift;
    my $sessionid = shift;
    ###此处需要鉴权，查看role
    if ( $mem->{roleid_fabu_cms}->{ $mem->{id}->{$sessionid} } eq 0 ) {
        $poe_kernel->yield( 'sent', $mem->{status}->{noright} );
        return;
    }

    unless (defined $receData->{id}
        and defined $receData->{name}
        and defined $receData->{git}
        and defined $receData->{scriptname}
        and defined $receData->{qaips}
        and defined $receData->{onlineips}
        and $receData->{id}
        and $receData->{name}
        and $receData->{git}
        and $receData->{scriptname}
        and $receData->{qaips}
        and $receData->{onlineips} )
    {
        $poe_kernel->yield( 'sent', $mem->{status}->{lack} );
        return;
    }
    ##鉴权操作
    ##执行操作
    my $dbh = $mysql->get();
    my $sql =
'update model_fabu_fabu set projectname= ?,git=?,scriptname=?,qaips=?,onlineips=? where id =?  ';
    my $result = Api::Common::Sql::insert_update_delete(
        $dbh,
        [
            $sql,
            [
                $receData->{name},       $receData->{git},
                $receData->{scriptname}, $receData->{qaips},
                $receData->{onlineips},  $receData->{id}
            ]
        ]
    );

    if ( $dbh->commit() and $result eq 1 ) {
        $poe_kernel->yield( 'sent', $mem->{status}->{ok} );
    }
    else {
        $poe_kernel->yield( 'sent', $mem->{status}->{fail} );
    }
    $mysql->put($dbh);
}

sub addrole {
    my $mysql     = shift;
    my $mem       = shift;
    my $receData  = shift;
    my $sessionid = shift;

    #{modelName=>'fabu',apiName=>'addrole',data=>[{fabuid=>'',envid=>''},{}] }

    ###此处需要鉴权，查看role
    if ( $mem->{roleid_fabu_cms}->{ $mem->{id}->{$sessionid} } eq 0 ) {
        $poe_kernel->yield( 'sent', $mem->{status}->{noright} );
        return;
    }
    unless (defined $receData->{rolename}
        and defined $receData->{data}
        and $receData->{rolename}
        and ref $receData->{data} eq 'ARRAY' )
    {
        $poe_kernel->yield( 'sent', $mem->{status}->{lack} );
        return;
    }

    ##鉴权操作
    ##执行操作
    my $dbh = $mysql->get();
    my $sql = 'insert into model_fabu_role (name) values (?)';
    my $insertResult =
      Api::Common::Sql::insert_update_delete( $dbh,
        [ $sql, [ $receData->{rolename} ] ] );
    $sql = 'select id from model_fabu_role where name = ?';
    my $result =
      Api::Common::Sql::select( $dbh, [ $sql, [ $receData->{rolename} ] ] );

    $sql =
'insert into model_fabu_role_fabu (role_id,fabu_id,env_id) values (?,?,?)';
    foreach my $data ( @{ $receData->{data} } ) {
        Api::Common::Sql::insert_update_delete( $dbh,
            [ $sql, [ $result->[0]->{id}, $data->{fabuid}, $data->{envid} ] ] );

    }
    my $if_data = 0;
    $sql = 'select id from model_fabu_fabu where id = ?';
    foreach my $data ( @{ $receData->{data} } ) {
        my $temp =
          Api::Common::Sql::select( $dbh, [ $sql, [ $data->{fabuid} ] ] );
        if ( $#$temp eq '-1' ) {
            $if_data = 0;
            last;
        }
        else {
            $if_data = 1;
        }

    }

    unless ( $insertResult eq 1 and $if_data eq 1 ) {
        $poe_kernel->yield( 'sent', $mem->{status}->{fail} );
        $dbh->rollback();
        $mysql->put($dbh);
        return;
    }

    if ( $dbh->commit() ) {
        $poe_kernel->yield( 'sent', $mem->{status}->{ok} );
    }
    else {
        $poe_kernel->yield( 'sent', $mem->{status}->{fail} );
    }
    $mysql->put($dbh);
}

sub rolefabuinfo {
    my $mysql     = shift;
    my $mem       = shift;
    my $receData  = shift;
    my $sessionid = shift;

    ##鉴权操作
    ###此处需要鉴权，查看role
    if ( $mem->{roleid_fabu_cms}->{ $mem->{id}->{$sessionid} } eq 0 ) {
        $poe_kernel->yield( 'sent', $mem->{status}->{noright} );
        return;
    }
    ##执行操作
    my $dbh = $mysql->get();
    my $sql =
'select role.id, role.name,fabu.projectname,rf.env_id from model_fabu_role as role left join model_fabu_role_fabu as rf on role.id=rf.role_id left join model_fabu_fabu as fabu on rf.fabu_id=fabu.id';
    my $result = Api::Common::Sql::select( $dbh, [ $sql, [] ] );
    my $Data = {};
    foreach my $data (@$result) {
        push @{ $Data->{ $data->{name} } },
          {
            projectname => $data->{projectname},
            envid       => $data->{env_id},
            'roleid'    => $data->{id}
          };
    }

    $poe_kernel->yield(
        'sent',
        {
            modelName => 'fabu',
            apiName   => 'rolefabuinfo',
            data      => $Data,
            code      => 200
        }
    );
    $dbh->commit();
    $mysql->put($dbh);
}

sub rolefabuupdate {
    my $mysql     = shift;
    my $mem       = shift;
    my $receData  = shift;
    my $sessionid = shift;

#{modelName=>'fabu',apiName=>'rolefabuupdate',data=>{roleid=>'',fabuid=>'',envid=>''} }

    ###此处需要鉴权，查看role
    if ( $mem->{roleid_fabu_cms}->{ $mem->{id}->{$sessionid} } eq 0 ) {
        $poe_kernel->yield( 'sent', $mem->{status}->{noright} );
        return;
    }

    unless ( defined $receData->{data} and ref $receData->{data} eq 'HASH' ) {
        $poe_kernel->yield( 'sent', $mem->{status}->{lack} );
        return;
    }

    ##鉴权操作
    ##执行操作
    my $dbh = $mysql->get();
    my $sql = 'delete from model_fabu_role_fabu where role_id=?';
    Api::Common::Sql::insert_update_delete( $dbh,
        [ $sql, [ $receData->{data}->{roleid} ] ] );
    $sql =
'insert into model_fabu_role_fabu (role_id ,fabu_id,env_id) values(?,?,?)';
    foreach my $data ( @{ $receData->{data}->{data} } ) {
        Api::Common::Sql::insert_update_delete(
            $dbh,
            [
                $sql,
                [
                    $receData->{data}->{roleid}, $data->{fabuid}, $data->{envid}
                ]
            ]
        );
    }

    if ( $dbh->commit() ) {
        $poe_kernel->yield( 'sent', $mem->{status}->{ok} );
    }
    else {
        $poe_kernel->yield( 'sent', $mem->{status}->{fail} );
    }
    $mysql->put($dbh);
}

sub roleuserinfo {
    my $mysql     = shift;
    my $mem       = shift;
    my $receData  = shift;
    my $sessionid = shift;
    ##鉴权操作
    ###此处需要鉴权，查看role
    if ( $mem->{roleid_fabu_cms}->{ $mem->{id}->{$sessionid} } eq 0 ) {
        $poe_kernel->yield( 'sent', $mem->{status}->{noright} );
        return;
    }
    ##执行操作
    my $dbh = $mysql->get();
    my $sql =
'select role.name as rname, role.id as rid,user.name as uname,user.id as uid from model_fabu_role as role left join user on user.roleid_fabu=role.id ;';
    my $result = Api::Common::Sql::select( $dbh, [ $sql, [] ] );
    my $data = {};
    foreach my $item (@$result) {
        push @{ $data->{ $item->{rname} } },
          {
            'uname' => $item->{uname},
            'uid'   => $item->{uid},
            'rid'   => $item->{rid}
          };
    }

    $poe_kernel->yield( 'sent', { 'data' => $data, code => 200 } );
    $dbh->commit();
    $mysql->put($dbh);
}

sub userinfo {
    my $mysql     = shift;
    my $mem       = shift;
    my $receData  = shift;
    my $sessionid = shift;
    ##鉴权操作
    ###此处需要鉴权，查看role
    if ( $mem->{roleid_fabu_cms}->{ $mem->{id}->{$sessionid} } eq 0 ) {
        $poe_kernel->yield( 'sent', $mem->{status}->{noright} );
        return;
    }

    ##执行操作
    my $dbh    = $mysql->get();
    my $sql    = 'select name as uname,roleid_fabu as rid, id as uid from user';
    my $result = Api::Common::Sql::select( $dbh, [ $sql, [] ] );
    $poe_kernel->yield( 'sent', { data => $result, code => 200 } );
    $dbh->commit();
    $mysql->put($dbh);
}

sub roleuserupdate {
    my $mysql     = shift;
    my $mem       = shift;
    my $receData  = shift;
    my $sessionid = shift;

#{modelname=>'faubu' ,apiName=>'roleuserupdate' , data=>{roleid=>1, data=>['',''] } }
    ###此处需要鉴权，查看role
    if ( $mem->{roleid_fabu_cms}->{ $mem->{id}->{$sessionid} } eq 0 ) {
        $poe_kernel->yield( 'sent', $mem->{status}->{noright} );
        return;
    }

    unless ( defined $receData->{data} and ref $receData->{data} eq 'HASH' ) {
        $poe_kernel->yield( 'sent', $mem->{status}->{lack} );
        return;
    }
    ##鉴权操作
    ##执行操作
    my $dbh = $mysql->get();

    my $sqlini = 'update user set roleid_fabu = 0 where roleid_fabu = ? ';
    Api::Common::Sql::insert_update_delete( $dbh,
        [ $sqlini, [ $receData->{data}->{roleid} ] ] );

    my $sql = 'update user set roleid_fabu = ? where id =? ';

    foreach my $uid ( @{ $receData->{data}->{data} } ) {
        Api::Common::Sql::insert_update_delete( $dbh,
            [ $sql, [ $receData->{data}->{roleid}, $uid ] ] );
    }

    if ( $dbh->commit() ) {
        $poe_kernel->yield( 'sent', $mem->{status}->{ok} );
    }
    else {
        $poe_kernel->yield( 'sent', $mem->{status}->{fail} );
    }
    $mysql->put($dbh);

}

1;

