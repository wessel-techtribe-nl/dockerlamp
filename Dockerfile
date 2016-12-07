#docker build -t ms .
#docker run -it a50299ce297a /bin/bash
FROM ubuntu:16.04

ARG MYSQL_ROOTPASS=root
ARG MYSQL_USER=dba
ARG MYSQL_PASS=dba


# prepare software installation
RUN set -xe \
	&& export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
	&& apt-get install -y software-properties-common apt-utils python-software-properties \
    && LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php \
    && apt-get update 

# install LAMP stack
RUN set -xe \
	&& export DEBIAN_FRONTEND=noninteractive \
	&&  { \
        echo "mysql-server mysql-server/root_password password $MYSQL_ROOTPASS" ; \
        echo "mysql-server mysql-server/root_password_again password $MYSQL_ROOTPASS" ;\
    } | debconf-set-selections \
	&& apt-get install -y apache2 rsync zip unzip mysql-server php-common php5.6-common php5.6-mysql



# supervisor to run some services (+ssh)
RUN set -xe \
	&& export DEBIAN_FRONTEND="noninteractive" \
	&& apt-get install -y supervisor openssh-server \
	&& mkdir -p /var/www/release /var/lock/apache2 /var/run/apache2 /var/run/sshd /var/log/supervisor


RUN set -xe \
    && sed 's|DocumentRoot /var/www/html|DocumentRoot /var/www/release |' /etc/apache2/sites-enabled/000-default.conf > /etc/apache2/sites-enabled/000-default.conf.new \
    && cp /etc/apache2/sites-enabled/000-default.conf.new /etc/apache2/sites-enabled/000-default.conf


COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 22 80
CMD ["/usr/bin/supervisord"]

WORKDIR /var/www/release
