FROM centos:centos7
MAINTAINER jmontleo <jmontleo@redhat.com>

RUN yum -y update \
 && yum -y install epel-release \
 && yum -y install mongodb-server ansible python-pip\
 && yum clean all

# pymongo needs to be version 2.7+ for ansible. Current RPM is 2.5
RUN pip install pymongo

RUN mkdir -p /data/db && chown -R mongodb:mongodb /data/db 

COPY startmongo.yml /startmongo.yml

EXPOSE 27017
ENTRYPOINT ["/usr/bin/ansible-playbook", "/startmongo.yml"]

USER mongodb
