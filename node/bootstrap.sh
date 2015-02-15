#!/bin/bash

rm /tmp/*.pid

# disable iptables firewall
/etc/init.d/iptables save
/etc/init.d/iptables stop

# Force Ipv6 to stop
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
echo 1 > /proc/sys/net/ipv6/conf/default/disable_ipv6

# sync with time server
#ntpdate pool.ntp.org
ntpdate timeserver.svl.ibm.com
service ntpd start

# start ssh server
service sshd start

#start ambari agent
#/usr/sbin/ambari-agent start


IP="$(/bin/hostname -i)"
REVERSE_IP=$(printf %s "$IP." | tac -s.)in-addr.arpa
SERVER="$(/bin/hostname)"

/etc/updatedns.sh

#update hosts
#echo -e "$IP      $SERVER" | ssh root@ambari.luck.com "cat >> /etc/hosts"

## dnsmaq record format
## address=/node1.luck.com/172.17.3.48
## ptr-record=48.3.17.172.in-addr.arpa,node1.luck.com
echo -e "address=/$SERVER/$IP" | ssh root@ambari.luck.com "cat >> /etc/dnsmasq.d/0hosts"
echo -e "ptr-record=$REVERSE_IP.in-addr.arpa,$SERVER" | ssh root@ambari.luck.com "cat >> /etc/dnsmasq.d/0hosts"
ssh root@ambari.luck.com "pgrep dnsmasq | xargs -i -t kill -9 {}; /usr/sbin/dnsmasq start"

echo "all boostrap commands executed"

if [[ $1 = "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 = "-bash" ]]; then
  /bin/bash
fi
