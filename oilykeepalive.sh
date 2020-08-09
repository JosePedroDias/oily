#!/bin/bash

netstat -tulpn | grep '0.0.0.0:52225' > /dev/null 2>/dev/null
a=$(echo $?)
if test $a -ne 0
then
	cd /root/oily/ && lua server.lua >> /var/log/oily/oily.log 2>&1 &
	echo "restarted"
else
	echo "running"
fi

# place it on: /usr/local/bin/oilykeepalive.sh

# add to crontab with
# crontab -e

## restart oily server every minute
#* * * * * /usr/local/bin/oilykeepalive.sh

# check it works with
# crontab -l

# log will reside in /var/log/oily/oily.log