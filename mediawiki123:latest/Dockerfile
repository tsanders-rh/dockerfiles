FROM centos:latest
MAINTAINER Vessel Maintainers

RUN yum update  -y \
    && yum install -y epel-release \
    && yum install -y mediawiki123 php-pgsql ImageMagick git php-pecl-apcu php-intl \
    && yum clean all

COPY mediawiki123.conf /etc/httpd/conf.d/mediawiki123.conf

EXPOSE 80

ENTRYPOINT ["/bin/httpd", "-DFOREGROUND"]
