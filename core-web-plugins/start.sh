#!/bin/bash

/usr/sbin/httpd -k start
/usr/local/nagios/bin/nagios -d /usr/local/nagios/etc/nagios.cfg

echo 'Waiting for Nagios to start'
until [ -s /data/status.dat ]; do
  sleep 2
done

tail -f -n 5000 /data/nagios.log