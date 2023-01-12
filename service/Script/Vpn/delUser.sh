#!/bin/bash
ip="$1"
user="$2"
passwd="$3"

ssh root@$ip bash /sysadmin/bin/vpn/vpnUserDel.sh $user $passwd

echo '{"code":"200"}'

