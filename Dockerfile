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

# all kind of package depencies in a seperate layer to make LAMP install faster below, can be removed when dockerfile is ok
#RUN set -xe \
#	&& export DEBIAN_FRONTEND=noninteractive \
#	&& apt-get install -y apparmor busybox-initramfs cpio initramfs-tools initramfs-tools-bin initramfs-tools-core klibc-utils kmod \
#		libaio1 libapparmor-perl libbsd0 libcgi-fast-perl libcgi-pm-perl libedit2 libencode-locale-perl libevent-core-2.0-5 \
#		libfcgi-perl libhtml-parser-perl libhtml-tagset-perl libhtml-template-perl libhttp-date-perl libhttp-message-perl \
#		libio-html-perl libklibc liblwp-mediatypes-perl libtimedate-perl liburi-perl libwrap0 linux-base psmisc tcpd udev \
#  		libx11-6 libx11-data libxau6 libxcb1 libxdmcp6 libxext6 libxmuu1 \
#  		ncurses-term  python-meld3 \
#  		python-pkg-resources python3-chardet python3-pkg-resources python3-requests \
#  		python3-six python3-urllib3 wget xauth

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