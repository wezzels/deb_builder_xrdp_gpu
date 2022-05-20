#!/usr/bin/bash
ip4=$(/sbin/ip -o -4 addr list eth0 | awk '{print $4}' | cut -d/ -f1)
cat /etc/yum.repos.d/*.repo > local-rhel8.repo
sed -i "s#file:///var/repo#http://${ip4}#g" ./local-rhel8.repo
cp -f local-rhel8.repo /var/repo/local-rhel8.repo
cat /var/repo/local-rhel8.repo
#End
