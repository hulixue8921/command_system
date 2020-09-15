#
#===============================================================================
#
#         FILE: InnerOrder.pm
#
#  DESCRIPTION:
#
#        FILES: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: hlx (), hulixue@xiankan.com
# ORGANIZATION:
#      VERSION: 1.0
#      CREATED: 06/04/2020 03:35:16 PM
#     REVISION: ---
#===============================================================================

use strict;
use warnings;

package Objects::Users::Order::Data;
use 5.010;
use POE;
use Data::Dumper;
use utf8;
use Encode;

our @ISA = qw(Exporter);
our @EXPORT =
  qw (delUser updateUserRole userRole  delRole roleAddproject roleUnbindproject roleProject delProject projectOrder  delOrder updateProjectOrder  addOrder delcache);

sub commonSelect {
    my $self      = shift;
    my $sqlselect = shift;

    my $dbh = $self->{Data}->{mysql}->get();
    my $sth = $dbh->prepare($sqlselect);
    $sth->execute();
    my $result = [];
    while ( my $ref = $sth->fetchrow_hashref() ) {
        push @$result, $ref;
    }
    $dbh->commit;
    $self->{Data}->{mysql}->put($dbh);
    return $result;

}

sub delUser {
    my $self  = shift;
    my $order = shift;
    my $result =
      &commonSelect( $self, 'select id , name from user where roleid != 1' );
    $order->{data} = {};
    foreach my $ref (@$result) {
        Encode::_utf8_on($ref->{name});
        $order->{data}->{1}->{ $ref->{name} } = $ref->{id};
    }
    return $order;
}

sub userRole {
    my $self   = shift;
    my $order  = shift;
    my $result = &commonSelect( $self,
'select u.name as uname,r.name as rname from user as u left join role as r on u.roleid=r.id where u.roleid !=-1'
    );
    $order->{data} = {};
    foreach my $ref (@$result) {
        Encode::_utf8_on($ref->{uname});
        Encode::_utf8_on($ref->{rname});
        $order->{data}->{1}->{ $ref->{uname} . '-' . $ref->{rname} } = '';
    }
    return $order;
}

sub delRole {
    my $self  = shift;
    my $order = shift;
    my $result =
      &commonSelect( $self, 'select id , name from role where id != 1' );
    $order->{data} = {};
    foreach my $ref (@$result) {
        Encode::_utf8_on($ref->{name});
        $order->{data}->{1}->{ $ref->{name} } = $ref->{id};
    }
    return $order;
}

sub updateUserRole {
    my $self  = shift;
    my $order = shift;
    $order->{data} = {};

    my $alluser =
      &commonSelect( $self, 'select id , name from user where roleid !=1' );
    my $allrole =
      &commonSelect( $self, 'select id , name from role where id != 1 ' );
    foreach my $ref (@$alluser) {
        Encode::_utf8_on($ref->{name});
        $order->{data}->{1}->{ $ref->{name} } = $ref->{id};
    }
    foreach my $ref (@$allrole) {
        Encode::_utf8_on($ref->{name});
        $order->{data}->{2}->{ $ref->{name} } = $ref->{id};
    }
    $order->{data}->{2}->{'匿名角色'} = -1;
    return $order;
}

sub roleAddproject {
    my $self  = shift;
    my $order = shift;
    $order->{data} = {};

    my $roles =
      &commonSelect( $self, 'select id , name from role where id != 1' );
    my $projects =
      &commonSelect( $self, 'select id , name from project where root != 1' );
    foreach my $ref (@$roles) {
        Encode::_utf8_on($ref->{name});
        $order->{data}->{1}->{ $ref->{name} } = $ref->{id};
    }
    foreach my $ref (@$projects) {
        Encode::_utf8_on($ref->{name});
        $order->{data}->{2}->{ $ref->{name} } = $ref->{id};
    }
    return $order;
}

sub roleProject {
    my $self  = shift;
    my $order = shift;
    $order->{data} = {};
    my $result = &commonSelect( $self,
'select r.name as rname, p.name as pname from role as r left join r_p on r.id=r_p.roleid left join project as p on r_p.projectid=p.id'
    );

    foreach my $ref (@$result) {
        Encode::_utf8_on($ref->{rname});
        Encode::_utf8_on($ref->{pname});
        $order->{data}->{1}->{ $ref->{rname} . '-' . $ref->{pname} } = '';
    }

    return $order;
}

sub delProject {
    my $self  = shift;
    my $order = shift;
    $order->{data} = {};

    my $result =
      &commonSelect( $self, 'select id , name from project where root !=1' );

    foreach my $ref (@$result) {
        Encode::_utf8_on($ref->{name});
        $order->{data}->{1}->{ $ref->{name} } = $ref->{id};
    }

    return $order;
}

sub projectOrder {
    my $self  = shift;
    my $order = shift;
    $order->{data} = {};
    my $result =
      &commonSelect( $self, 'select p.name as pname,o.name as oname from project as p left join `order` as o on p.id=o.projectid' );
    foreach my $ref (@$result) {
        Encode::_utf8_on($ref->{pname});
        Encode::_utf8_on($ref->{oname});
        $order->{data}->{1}->{ $ref->{pname}.'-'.$ref->{oname} } = '';
    }
    return $order;
}

sub delOrder {
    my $self  = shift;
    my $order = shift;
    $order->{data} = {};
    my $result =
      &commonSelect( $self, 'select o.id as oid ,o.name as oname from project as p left join `order` as o on p.id=o.projectid where p.root!=1' );
    foreach my $ref (@$result) {
        Encode::_utf8_on($ref->{oname});
        $order->{data}->{1}->{ $ref->{oname} } = $ref->{oid};
    }
    return $order;
}

sub updateProjectOrder {
    my $self  = shift;
    my $order = shift;
    $order->{data} = {};
    my $projects=&commonSelect($self, 'select id , name from project where root !=1');
    my $orders=&commonSelect($self, 'select o.id as oid ,o.name as oname from project as p left join `order` as o on p.id=o.projectid where p.root !=1');
    foreach my $ref (@$projects) {
        Encode::_utf8_on($ref->{name});
        $order->{data}->{1}->{ $ref->{name} } = $ref->{id};
    }
    foreach my $ref (@$orders) {
        Encode::_utf8_on($ref->{oname});
        $order->{data}->{2}->{ $ref->{oname} } = $ref->{oid};
    }
    return $order;
}

 sub  addOrder {
    my $self  = shift;
    my $order = shift;
    $order->{data} = {};
    my $projects=&commonSelect($self, 'select id , name from project where root !=1');
    foreach my $ref (@$projects) {
        Encode::_utf8_on($ref->{name});
        $order->{data}->{4}->{ $ref->{name} } = $ref->{id};
    }
        $order->{data}->{5}->{'否'} = 0;
        $order->{data}->{5}->{'是'} = 1;

    return $order;
 }

sub delcache {
    my $self  = shift;
    my $order = shift;
    my $mem=$self->{Data}->{mem};
    $order->{data} = {};
    my $keys=$mem->keys();
    foreach my $key (@$keys) {
        next if $key=~/^user_/;
        next if $key eq 'config';
        $order->{data}->{1}->{$key} = 1;
    }

    return $order;
};

1
