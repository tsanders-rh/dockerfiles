FROM centos:latest
MAINTAINER Vessel Maintainers

RUN yum update  -y \
    && yum install -y epel-release \
    && yum install -y mediawiki123 php-pgsql ImageMagick git php-pecl-apcu php-intl \
    && yum clean all

ENTRYPOINT ["/bin/bash", "-c", "sleep 500m"]
