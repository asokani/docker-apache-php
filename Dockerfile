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
RUN a2enmod headers

# users acme 1000, www-manage 1001, www-user 1002
RUN adduser --disabled-password --gecos "" acme && \   
    adduser --disabled-password --gecos "" www-manage && \
    adduser --disabled-password --gecos "" www-user && \	
    usermod -a -G www-user www-manage

# startup scripts
RUN mkdir -p /etc/my_init.d

# letsencrypt
ADD acme_tiny.py /opt/acme_tiny.py
RUN mkdir -p /var/log/acme && chown :acme /var/log/acme	
RUN mkdir -p /var/app-cert/.well-known/acme-challenge && \ 
	chown acme:www-user /var/app-cert/.well-known/acme-challenge && \
	chmod 750 /var/app-cert/.well-known/acme-challenge
ADD letsencrypt-startup.sh /etc/my_init.d/letsencrypt.sh
ADD letsencrypt-cron.sh /etc/cron.monthly/letsencrypt.sh

# apache2
RUN sed -i 's/APACHE_RUN_USER=www-data/APACHE_RUN_USER=www-user/g' /etc/apache2/envvars && \
    sed -i 's/APACHE_RUN_GROUP=www-data/APACHE_RUN_GROUP=www-user/g' /etc/apache2/envvars
RUN mkdir /etc/service/apache
ADD apache.sh /etc/service/apache/run
ADD apache-ssl.conf /etc/apache2/mods-available/ssl.conf

RUN rm /etc/apache2/sites-available/*
RUN rm /etc/apache2/sites-enabled/*

# ssh
RUN rm -f /etc/service/sshd/down

# mail
RUN sed -i 's/relayhost =/relayhost = postfix/g' /etc/postfix/main.cf
RUN sed -i 's/\/etc\/mailname,//g' /etc/postfix/main.cf
RUN echo "smtp_host_lookup = native\n" >> /etc/postfix/main.cf
RUN mkdir /etc/service/postfix
ADD postfix.sh /etc/service/postfix/run

EXPOSE 80 22 443

CMD ["/sbin/my_init"]

#RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
