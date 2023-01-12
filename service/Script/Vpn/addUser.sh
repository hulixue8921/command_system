#!/bin/bash
ip="$1"
user="$2"
passwd="$3"
mailUser="$4"
mailPasswd="$5"
mailAddr="$6"
data="$7"

ssh root@$ip bash /sysadmin/bin/vpn/vpnUserAdd.sh $user $passwd
scp root@$ip:/data/openvpn/conf/*-"$user".ovpn /tmp/.
#swaks --auth --server $mailAddr --au $mailUser --ap $mailPasswd  --from $mailUser --to $user@gustochain.com --h-Subject: "openVpn" --body "$data" -tls --attach /tmp/*-"$user".ovpn --add-header "MIME-Version: 1.0" --add-header "Content-Type: text/html;charset=utf-8"
swaks --auth --server $mailAddr --au $mailUser --ap $mailPasswd  --from $mailUser --to $user@gustochain.com --h-Subject: "openVpn"  -tls --attach-type "text/html;charset=utf-8" --attach - < $data  --attach /tmp/*-"$user".ovpn
rm -rf /tmp/*-"$user".ovpn

echo '{"code":"200"}'

