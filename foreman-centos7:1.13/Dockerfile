FROM centos:latest
MAINTAINER Vessel Maintainers

RUN echo -ne " \n\
[Foreman] \n\
name = Foreman \n\
baseurl = http://yum.theforeman.org/releases/1.13/el7/x86_64/ \n\
gpgkey = http://yum.theforeman.org/releases/1.13/RPM-GPG-KEY-foreman \n\
gpgcheck = 1" > /etc/yum.repos.d/foreman.repo

RUN echo -ne " \n\
[sclo] \n\
name = sclo \n\
baseurl = http://mirror.centos.org/centos/7/sclo/x86_64/sclo/ \n\
gpgkey = https://raw.githubusercontent.com/sclorg-distgit/centos-release-sclo/master/RPM-GPG-KEY-CentOS-SIG-SCLo \n\
gpgcheck = 1" > /etc/yum.repos.d/sclo.repo

RUN echo -ne " \n\
[rhscl] \n\
name = rhscl \n\
baseurl = http://mirror.centos.org/centos/7/sclo/x86_64/rh/ \n\
gpgkey = https://raw.githubusercontent.com/sclorg-distgit/centos-release-sclo/master/RPM-GPG-KEY-CentOS-SIG-SCLo \n\
gpgcheck = 1" > /etc/yum.repos.d/rhscl.repo

RUN sed -i 's/tsflags=nodocs//' /etc/yum.conf

RUN yum update  -y \
    && yum install -y epel-release \
    && yum install -y foreman foreman-compute foreman-ec2 foreman-gce foreman-libvirt foreman-openstack foreman-ovirt foreman-plugin foreman-postgresql foreman-rackspace foreman-release foreman-selinux foreman-vmware tfm-rubygem-passenger-native httpd mod_passenger mod_ssl \
    && yum clean all

RUN mkdir -p /etc/httpd/conf.d/{05-foreman.d,05-foreman-ssl.d}
ADD ./05-foreman.conf /etc/httpd/conf.d/05-foreman.conf
ADD ./05-foreman-ssl.conf /etc/httpd/conf.d/05-foreman-ssl.conf

ENTRYPOINT ["/bin/bash", "-c", "sleep 500m"]
