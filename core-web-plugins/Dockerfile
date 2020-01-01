FROM ubuntu:18.04

## Build arguments
ARG VERSION

## Environment variables
ENV VERSION ${VERSION:-4.0.0}
ENV PLUGINS_VERSION 2.3.1
ENV API_VERSION 1.0.1
ENV FPING_VERSION 3.10

ENV NAGIOS_USERNAME=nagiosadmin
ENV NAGIOS_PASSWORD=nagiosadmin

## Install & prepare dependencies and Nagios Core
RUN apt-get -y update; \
	DEBIAN_FRONTEND=noninteractive apt-get -yq install \
	unzip \
	wget \
  gcc \
  make \
  libc6 \
  build-essential \
  autoconf \
  libmcrypt-dev \
  libssl-dev \
  bc \
  gawk \
  dc \
  snmp \
  libnet-snmp-perl \
  gettext \ 
  libpqxx3-dev \
  libdbi-dev \
  libldap2-dev \
  libmysqlclient-dev \
  dnsutils \
  smbclient \
  qstat \
  fping \
  opensmtpd \
  ssh \
  apache2 \
  perl; \
	\
	perl -MCPAN -Mlocal::lib=~/perl5 -e 'my $c = "CPAN::HandleConfig"; $c->load(doit => 1, autoconfig => 1); $c->edit(prerequisites_policy => "follow"); $c->edit(build_requires_install_policy => "yes"); $c->commit'; \
	cpan install \
	Test::More \
	Digest::MD5 \
	Crypt::CBC \
	Net::SNMP; \
	\
	mkdir /tmp/freeradius; \
  wget https://github.com/FreeRADIUS/freeradius-client/archive/release_1_1_7.tar.gz --output-document=/tmp/freeradius.tar.gz; \
	cd /tmp; tar -xaf /tmp/freeradius.tar.gz --strip-components=1 --directory=/tmp/freeradius/; \
	cd /tmp/freeradius; \
	./configure; \
	make all; \
	make install; \
	rm -rf /tmp/freeradius*; \
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
	echo "RedirectMatch ^/$ /nagios" > /etc/apache2/sites-available/redirect.conf; \
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
	/usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg; \
	\
	apt-get -y remove \
	unzip \
	wget \
  gcc \
  make; \
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