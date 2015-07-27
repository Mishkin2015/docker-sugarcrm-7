FROM ubuntu:13.04

MAINTAINER Toumani Housseini, osin@live.com
#Coming from initial project of Shane Dowling, shane@shanedowling.com
#Used and tested on SugarCRM 7.5.1



##BASIC SECTION##
# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV HOME /root

#From: Ben Schwartz:
#Since upstart (ubuntu's init system) doesn't work with docker, this disables it completely to prevent any weirdness from it just failing silently
#RUN dpkg-divert --local --rename --add /sbin/initctl
#RUN ln -s /bin/true /sbin/initctl

#Prepare env
RUN echo "deb http://old-releases.ubuntu.com/ubuntu raring main restricted universe multiverse" > /etc/apt/sources.list &&\
    apt-get update &&\
    apt-get upgrade -y

#Install utilities
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install git curl nano vim htop wget apt-utils

###!



##MYSQL SECTION##

#Install Mysql and configure it
RUN apt-get -y install mysql-client mysql-server

#Allow mysql to listen outside 127.0.0.1 or outside container
RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

#Add startup script for mysql
ADD files/startup_mysql.sh /opt/startup_mysql.sh

#Expose mysql Port
EXPOSE 3306

#Launch mysql
CMD ["/bin/bash", "/opt/startup_mysql.sh"]

###!



##APACHE & PHP SECTION##

#Install Apache & PHP
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install apache2 php5 php5-cli libapache2-mod-php5 php-apc php5-imap php5-gd php5-curl php5-memcached php5-mcrypt php5-mongo php5-sqlite php5-mysql

# PHP prod config
ADD files/php.ini /etc/php5/apache2/php.ini
ADD files/vhost.conf /etc/apache2/sites-available/sugarcrm

# Ensure PHP log file exists and is writable
RUN touch /var/log/php_errors.log && chmod a+w /var/log/php_errors.log

# Our start-up script
ADD files/start.sh /start.sh
RUN chmod a+x /start.sh

# Apache tweaks and turn on some crucial apache mods
RUN sed -i -r 's/AllowOverride None$/AllowOverride All/' /etc/apache2/apache2.conf
RUN a2enmod rewrite headers filter

RUN a2ensite sugarcrm

RUN apache2ctl restart

#Mount volume
VOLUME ["/var/www/sugarcrm"]
VOLUME ["/var/log"]

#Not working with mysql
#ENTRYPOINT ["/start.sh"]


EXPOSE 80



###!




##ELASTIC SEARCH SECTION##
# Install java
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install openjdk-7-jre-headless -y

#ElasticSearch install
RUN wget --no-check-certificate https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.3.1.deb &&\
    dpkg -i elasticsearch-1.3.1.deb &&\
    service elasticsearch start

EXPOSE 9200

###!


#Clean
RUN apt-get clean &&\
        rm -rf /var/lib/apt/lists/*

RUN chmod a+x /start.sh

#actually there're 2 problems;
#You need to launch yourself startup_mysql.sh to create your admin user