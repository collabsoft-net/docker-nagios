FROM centos:latest

## Environment variables
ENV VERSION 4.3.1
ENV PLUGINS_VERSION 2.1.4
ENV API_VERSION 1.0.1
ENV FPING_VERSION 3.10

ENV NAGIOS_USERNAME=nagiosadmin
ENV NAGIOS_PASSWORD=nagiosadmin

## Install & prepare dependencies, Nagios Core and Nagios Plugins
RUN yum -y update; yum clean all; \
	yum -y install \
	java-1.8.0-openjdk \
	wget \
	tar \
	httpd \
	php \
	make \
	perl \
	gcc \
	glibc \
	glibc-common \
	gd \
	gd-devel \
	openssl \
	openssl-devel \
	openssh-clients \
	samba-client \
	net-snmp \
	net-snmp-utils \
	openssh \
	bind-utils \ 
	freeradius-devel \
	openldap-devel \
	libdbi-devel \
	postgresql-devel \
	mysql-devel \
	perl-CPAN; \
	\
	perl -MCPAN -Mlocal::lib=~/perl5 -e 'my $c = "CPAN::HandleConfig"; $c->load(doit => 1, autoconfig => 1); $c->edit(prerequisites_policy => "follow"); $c->edit(build_requires_install_policy => "yes"); $c->commit'; \
	cpan install \
	Test::More \
	Digest::MD5 \
	Crypt::CBC \
	Net::SNMP; \
	\
	mkdir /tmp/fping; \
	wget http://fping.org/dist/fping-$FPING_VERSION.tar.gz --output-document=/tmp/fping.tar.gz; \
	cd /tmp; tar -xaf /tmp/fping.tar.gz --strip-components=1 --directory=/tmp/fping/; \
	cd /tmp/fping; \
	./configure; \
	make all; \
	make install; \
	chmod u+s /bin/ping; \
	rm -rf /tmp/fping; \
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
	./configure --with-command-group=nagcmd; \
	make all; \
	make install; \
	make install-init; \
	make install-config; \
	make install-commandmode; \
	make install-webconf; \
	rm -rf /tmp/nagios; \
	rm -rf /tmp/nagios.tar.gz; \
	\
	mkdir /tmp/nagios-plugins; \
	wget http://www.nagios-plugins.org/download/nagios-plugins-$PLUGINS_VERSION.tar.gz --output-document=/tmp/nagios-plugins.tar.gz; \
	cd /tmp; tar -xaf /tmp/nagios-plugins.tar.gz --strip-components=1 --directory=/tmp/nagios-plugins/; \
	cd /tmp/nagios-plugins; \
	./configure --with-nagios-user=nagios --with-nagios-group=nagios; \
	make all; \
	make install; \
	rm -rf /tmp/nagios-plugins; \
	rm -rf /tmp/nagios-plugins.tar.gz; \
	\
	htpasswd -bc /usr/local/nagios/etc/htpasswd.users $NAGIOS_USERNAME $NAGIOS_PASSWORD; \
	echo "RedirectMatch ^/$ /nagios" > /etc/httpd/conf.d/redirect.conf; \
	echo "ProxyPass /api http://localhost:5000" > /etc/httpd/conf.d/nagios-api.conf; \
	echo "ProxyPassReverse /api http://localhost:5000" >> /etc/httpd/conf.d/nagios-api.conf; \
	echo "ProxyPass /rest http://localhost:5000/rest" >> /etc/httpd/conf.d/nagios-api.conf; \
	echo "ProxyPassReverse /rest http://localhost:5000/rest" >> /etc/httpd/conf.d/nagios-api.conf; \
	\
	mv /usr/local/nagios/etc /config; \
	ln -s /config /usr/local/nagios/etc; \
	chown -R nagios:nagcmd /config; \
	\
	mkdir -p /usr/local/nagios/var/spool/checkresults; \
	mv /usr/local/nagios/var /data; \
	ln -s /data /usr/local/nagios/var; \
	chown -R nagios:nagcmd /data; \
	\
	/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg;

## Download Nagios API
ADD http://repository.collabsoft.net/releases/net/collabsoft/nagios-api/$API_VERSION/nagios-api-$API_VERSION-jar-with-dependencies.jar /opt/nagios-api.jar;

## Copy startup script
COPY ./start.sh /opt/start.sh
RUN chmod +x /opt/start.sh

## Expose ports and volumes
EXPOSE 80
EXPOSE 5000
VOLUME /config
VOLUME /data

## Run the start script
CMD /opt/start.sh