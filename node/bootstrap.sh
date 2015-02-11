#!/bin/bash

rm /tmp/*.pid

# disable iptables firewall
/etc/init.d/iptables save
/etc/init.d/iptables stop

# Force Ipv6 to stop
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
echo 1 > /proc/sys/net/ipv6/conf/default/disable_ipv6

## dnsmaq record format
## echo "host-record=$container,$new_ip" > /opt/docker/dnsmasq.d/0host_$container
IP="$(/bin/hostname -i)"
SERVER="$(/bin/hostname)"
echo -e "host-record=$SERVER, $IP" | ssh root@ambari.luck.com "cat >> /etc/dnsmasq.d/0hosts"
echo -e "host-record=$SERVER, $IP" | ssh root@ambari.luck.com "cat >> /etc/dnsmasq.d/0hosts_$SERVER"
ssh root@ambari.luck.com "/usr/sbin/dnsmasq restart"
#/etc/dnsmasq.d/0hosts

ptr-record=$IP.in-addr.arpa.,"node1"

serf members -status=alive | while read line ;do
NEXT_HOST=$(echo $line|cut -d' ' -f 1)
NEXT_SHORT=${NEXT_HOST%%.*}
NEXT_ADDR=$(echo $line|cut -d' ' -f 2)
NEXT_IP=${NEXT_ADDR%%:*}
echo address=\"/$NEXT_HOST/$NEXT_SHORT/$NEXT_IP\"
IFS='.' read A B C D <<< "$NEXT_IP"
echo ptr-record=$D.$C.$B.$A.in-addr.arpa,$NEXT_HOST
done > /etc/dnsmasq.d/0hosts

ptr-record=2.8.168.192.in-addr.arpa.,"novo2-comm"
address=/novo2-comm/192.168.8.2
cname=novo2,novo2-comm
dhcp-host=192.168.8.3,e4:1f:13:7a:b8:4a,novo3-comm,1440m


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
