#!/bin/bash

rm /tmp/*.pid

# disable iptables firewall
/etc/init.d/iptables save
/etc/init.d/iptables stop

# Force Ipv6 to stop
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
echo 1 > /proc/sys/net/ipv6/conf/default/disable_ipv6


IP="$(/bin/hostname -i)"
SERVER="$(/bin/hostname)"

#update hosts
echo -e "$IP      $SERVER" | ssh root@ambari.luck.com "cat >> /etc/hosts"

## dnsmaq record format
## echo "host-record=$container,$new_ip" > /opt/docker/dnsmasq.d/0host_$container
#echo -e "host-record=$SERVER, $IP" | ssh root@ambari.luck.com "cat >> /etc/dnsmasq.d/0hosts"
#echo -e "host-record=$SERVER, $IP" | ssh root@ambari.luck.com "cat >> /etc/dnsmasq.d/0hosts_$SERVER"
#ssh root@ambari.luck.com "/usr/sbin/dnsmasq restart"
#/etc/dnsmasq.d/0hosts

# sync with time server
#ntpdate pool.ntp.org
ntpdate timeserver.svl.ibm.com
service ntpd start

# start ssh server
service sshd start

#start ambari agent
#/usr/sbin/ambari-agent start

if [[ $1 = "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 = "-bash" ]]; then
  /bin/bash
fi
