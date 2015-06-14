/usr/sbin/httpd -k start
/etc/init.d/nagios start

tail -f -n 5000 /data/nagios.log
