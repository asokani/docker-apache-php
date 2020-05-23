FROM mainlxc/base
MAINTAINER Asokani "https://github.com/asokani"

RUN apt-get update && \
  apt-get -y install apache2 libapache2-mod-php5 \
        php5-mcrypt php5-curl libapache2-mod-jk \
	php5-memcache

RUN a2enmod ssl
RUN a2enmod rewrite
RUN a2enmod headers

# apache2
RUN sed -i 's/APACHE_RUN_USER=www-data/APACHE_RUN_USER=www-user/g' /etc/apache2/envvars && \
    sed -i 's/APACHE_RUN_GROUP=www-data/APACHE_RUN_GROUP=www-user/g' /etc/apache2/envvars
RUN mkdir /etc/service/apache
ADD apache.sh /etc/service/apache/run
ADD apache-ssl.conf /etc/apache2/mods-available/ssl.conf
ADD apache-mpm-prefork.conf /etc/apache2/mods-available/mpm_prefork.conf

# letsencrypt - reload  after renewal
RUN echo "/usr/sbin/apache2ctl graceful" >> /etc/cron.weekly/letsencrypt

# php 5
RUN sed -i -e 's/upload_max_filesize\s\+=\s\+2M/upload_max_filesize = 50M/' /etc/php5/apache2/php.ini && \
	sed -i -e 's/post_max_size\s\+=\s\+8M/post_max_size = 50M/' /etc/php5/apache2/php.ini

RUN rm /etc/apache2/sites-available/*
RUN rm /etc/apache2/sites-enabled/*

EXPOSE 80 22 443

CMD ["/sbin/my_init"]

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
 