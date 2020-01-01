FROM ubuntu:18.04

## Build arguments
ARG VERSION

## Environment variables
ENV VERSION ${VERSION:-4.0.0}

## Install & prepare dependencies and Nagios Core
RUN apt-get -y update; \
	apt-get -y install \
	unzip \
	wget \
	make \
	gcc \
	apache2 \
  perl; \
	\
	/usr/sbin/useradd -m nagios; \
	/usr/sbin/groupadd nagcmd; \
	/usr/sbin/usermod -a -G nagcmd nagios; \
	/usr/sbin/usermod -a -G nagcmd apache; \
	\
	mkdir /tmp/nagios; \
	wget http://downloads.sourceforge.net/project/nagios/nagios-4.x/nagios-$VERSION/nagios-$VERSION.tar.gz --output-document=/tmp/nagios.tar.gz; \
	cd /tmp; tar -xaf /tmp/nagios.tar.gz --strip-components=1 --directory=/tmp/nagios/; \
	cd /tmp/nagios; \
	./configure --with-command-group=nagcmd --with-httpd-conf=/etc/apache2/sites-available; \
	make all; \
	make install; \
	make install-init; \
	make install-commandmode; \
	make install-webconf; \
	rm -rf /tmp/nagios; \
	rm -rf /tmp/nagios.tar.gz; \
	\
	echo "RedirectMatch ^/$ /nagios" > /etc/apache2/sites-available/redirect.conf; \
	\
	mkdir /config; \
	rm -rf /usr/local/nagios/etc; \
	ln -s /config /usr/local/nagios/etc; \
	chown -R nagios:nagcmd /config; \
	\
	mkdir -p /usr/local/nagios/var/spool/checkresults; \
	mv /usr/local/nagios/var /data; \
	ln -s /data /usr/local/nagios/var; \
	chown -R nagios:nagcmd /data; \
	\
	apt-get -y remove \
	unzip \
	wget \
	make \
	gcc; \
  apt -y autoremove;

## Copy startup script
COPY ./start.sh /opt/start.sh
RUN chmod +x /opt/start.sh

## Expose ports and volumes
EXPOSE 80
VOLUME /config
VOLUME /data

## Run the start script
CMD /opt/start.sh