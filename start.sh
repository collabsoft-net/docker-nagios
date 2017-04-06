#!/bin/bash

/usr/sbin/httpd -k start
/usr/local/nagios/bin/nagios -d /config/nagios.cfg

echo 'Waiting for Nagios to start'
until [ -s /data/status.dat ]; do
  sleep 2
done

java -jar /opt/nagios-api.jar file -f /data/status.dat -p 5000 -d &> /dev/null &

tail -f -n 5000 /data/nagios.log