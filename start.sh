/usr/sbin/httpd -k start
/etc/init.d/nagios start

echo 'Waiting for Nagios to start'
while [ ! -f /usr/local/nagios/var/status.dat ]
do
    printf '.'
    sleep 2
done

echo 
java -jar /opt/nagios-api.jar file -f /usr/local/nagios/var/status.dat -p 5000