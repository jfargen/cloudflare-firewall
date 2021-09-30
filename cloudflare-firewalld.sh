#!/bin/bash

PORT=80
CURMD5SUM=`curl https://www.cloudflare.com/ips-v4 > current-ips-v4; md5sum current-ips-v4 | awk ' { print $1 } '`
LASTMD5SUM=`md5sum last-ips-v4 | awk ' { print $1 } '`

#curl https://www.cloudflare.com/ips-v4 > current-ips-v4
echo "$LASTMD5SUM"
echo "$CURMD5SUM"

if [ "$LASTMD5SUM" != "$CURMD5SUM" ]
then
  /bin/firewall-cmd --info-zone=public | /bin/grep 'port="80"' | /bin/xargs -I{} firewall-cmd --zone=public --remove-rich-rule={}
  mv current-ips-v4 last-ips-v4
    for ip in `cat last-ips-v4`; do
        echo ${ip};firewall-cmd --zone=public --add-rich-rule="rule family='ipv4' source address='${ip}' port protocol='tcp' port='${PORT}' accept"; sleep 2
    done
else
  date >> /var/log/cloudflare-firewall.log
  echo "Current and Last Cloudflare IPs matched" >> /var/log/cloudflare-firewall.log
  exit 0
fi
