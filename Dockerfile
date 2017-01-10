FROM ubuntu:16.04

ARG MYSQL_ROOTPASS=root

# prepare software installation
RUN set -xe \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y software-properties-common apt-utils python-software-properties \
  && apt-get purge `dpkg -l | grep php| awk '{print $2}' |tr "\n" " "` \
  && LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php \
  && apt-get update

# install LAMP stack
RUN set -xe \
	&& export DEBIAN_FRONTEND=noninteractive \
	&&  { \
        echo "mysql-server mysql-server/root_password password $MYSQL_ROOTPASS" ; \
        echo "mysql-server mysql-server/root_password_again password $MYSQL_ROOTPASS" ;\
    } | debconf-set-selections \
	&& apt-get install -y apache2 rsync zip unzip mysql-server php5.6 php5.6-curl php5.6-cli php5.6-mcrypt php5.6-gd git sqlite php5.6-sqlite curl php5.6-dev php-pear php5.6-mysql php5.6-mbstring php5.6-xml

# Install composer
RUN set -xe \
  && php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
  && php -r "if (hash_file('SHA384', 'composer-setup.php') === 'aa96f26c2b67226a324c27919f1eb05f21c248b987e6195cad9690d5c1ff713d53020a02ac8c217dbf90a7eacc9d141d') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
  && php composer-setup.php --install-dir=bin --filename=composer \
  && php -r "unlink('composer-setup.php');"

# supervisor to run some services (+ssh)
RUN set -xe \
	&& export DEBIAN_FRONTEND="noninteractive" \
	&& apt-get install -y supervisor openssh-server \
	&& mkdir -p /var/www/release /var/lock/apache2 /var/run/apache2 /var/run/sshd /var/log/supervisor

RUN set -xe \
    && sed 's|DocumentRoot /var/www/html|DocumentRoot /var/www |' /etc/apache2/sites-enabled/000-default.conf > /etc/apache2/sites-enabled/000-default.conf.new \
    && cp /etc/apache2/sites-enabled/000-default.conf.new /etc/apache2/sites-enabled/000-default.conf

# Install Node and install build dependencies
RUN apt-get -y install nodejs npm && \
    npm install -g uglify-js node-less 

# cleanup
RUN set -xe apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Setup Supervisord
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf


EXPOSE 22 80
CMD ["/usr/bin/supervisord"]
WORKDIR /var/www
