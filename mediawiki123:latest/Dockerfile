FROM centos:latest
MAINTAINER Vessel Maintainers

RUN yum update  -y \
    && yum install -y epel-release \
    && yum install -y mediawiki123 php-pgsql ImageMagick git php-pecl-apcu php-intl postgresql \
    && yum clean all

RUN curl -sSL -o /bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.0.2/dumb-init_1.0.2_amd64
RUN chmod +x /bin/dumb-init

COPY mediawiki123.conf /etc/httpd/conf.d/mediawiki123.conf
#RUN sed -i -e 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf
RUN sed -i -e 's@DocumentRoot "/var/www/.*"@DocumentRoot /var/www/mediawiki123@' /etc/httpd/conf/httpd.conf

COPY entrypoint.sh /entrypoint.sh
EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
