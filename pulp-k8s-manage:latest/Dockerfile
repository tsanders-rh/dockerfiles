FROM mhrivnak/pulp-k8s-base

RUN dnf -y install socat

USER root

COPY manage.sh /

ENTRYPOINT ["/manage.sh"]
