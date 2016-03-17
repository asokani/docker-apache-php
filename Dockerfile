FROM mainlxc/base
MAINTAINER Asokani "https://github.com/asokani"

RUN apt-get update && \
  apt-get -y install apache2 libapache2-mod-php5 \
        php5-mcrypt php5-curl libapache2-mod-jk \
	sqlite3 pwgen php5-memcache postfix mailutils

RUN a2enmod ssl
RUN a2enmod rewrite
RUN a2enmod headers

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

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
