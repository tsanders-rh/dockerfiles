FROM centos:latest
MAINTAINER Vessel Maintainers

RUN echo -ne " \n\
[MariaDB] \n\
name = MariaDB \n\
baseurl = http://yum.mariadb.org/10.0/centos7-amd64 \n\
gpgkey = http://yum.mariadb.org/RPM-GPG-KEY-MariaDB \n\
gpgcheck = 1" > /etc/yum.repos.d/MariaDB.repo

RUN yum update  -y \
    && yum install -y epel-release \
    && yum install -y mariadb-server \
        pwgen \
        ansible \
        nss_wrapper \
        MariaDB-Galera-server \
        MariaDB-client \
        rsync \
        galera \
        socat \
        hostname \
        expect \
        percona-xtrabackup \
        which \
        tar \
     && yum clean all


COPY bootstrap.sh /usr/local/bin
COPY run.sh /usr/local/bin
COPY setup /setup

RUN rm -rf /var/lib/mysql/* && chown -R mysql:mysql /var/lib/mysql/ && chown -R mysql:mysql /setup

USER mysql
