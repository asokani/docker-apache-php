FROM phusion/baseimage:0.9.18
MAINTAINER Webmaster <webmaster@netfinity.cz>

RUN apt-get update && \
  apt-get -y install git apache2 libapache2-mod-php5 \
        php5-mysql php5-mcrypt php5-curl \
        joe libapache2-mod-jk mc \
	proftpd-basic proftpd-mod-sqlite sqlite3 openssl \ 
        pwgen php5-tidy php5-cli php5-gd php5-imagick \
        php5-memcache php5-tidy wget postfix mailutils

RUN a2enmod ssl
RUN a2enmod rewrite

# startup scripts
RUN mkdir -p /etc/my_init.d

# letsencrypt
ADD acme_tiny.py /opt/acme_tiny.py

# apache2 service
RUN mkdir /etc/service/apache
ADD apache.sh /etc/service/apache/run
ADD apache-ssl.conf /etc/apache2/mods-available/ssl.conf
# letsencrypt
RUN mkdir -p /app-cert/.well-known/acme-challenge
ADD letsencrypt-startup.sh /etc/my_init.d/letsencrypt.sh

RUN rm /etc/apache2/sites-available/*
RUN rm /etc/apache2/sites-enabled/*

# mail
RUN sed -i 's/relayhost =/relayhost = postfix/g' /etc/postfix/main.cf
RUN sed -i 's/\/etc\/mailname,//g' /etc/postfix/main.cf
RUN echo "smtp_host_lookup = native\n" >> /etc/postfix/main.cf
RUN mkdir /etc/service/postfix
ADD postfix.sh /etc/service/postfix/run

# proftpd
RUN mkdir -p /etc/proftpd/ssl
# RUN openssl req -new -x509 -days 3650 -subj "/C=CZ/L=Prague/O=App/CN=App" -nodes -out /etc/proftpd/ssl/proftpd.cert.pem -keyout /etc/proftpd/ssl/proftpd.key.pem
# RUN chmod 600 /etc/proftpd/ssl/proftpd.*
RUN mkdir /etc/service/proftpd
ADD proftpd.sh /etc/service/proftpd/run
ADD proftpd.conf /etc/proftpd/proftpd.conf
ADD proftpd-modules.conf /etc/proftpd/modules.conf
ADD proftpd-tls.conf /etc/proftpd/tls.conf
ADD proftpd-sql.sql /etc/proftpd/sql.sql
ADD proftpd-startup.sh /etc/my_init.d/proftpd.sh

EXPOSE 80 21 443 43330 43331

CMD ["/sbin/my_init"]

#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
