#
# This is an "initContainer" image using the base "source-to-image" OpenShift template
# in order to appropriately inject the supervisord binary into the application container.
#

# SUPERVISORD

FROM registry.svc.ci.openshift.org/openshift/release:golang-1.11 AS supervisordbuilder

RUN mkdir -p /go/src/github.com/ochinchina/supervisord

ADD vendor/supervisord /go/src/github.com/ochinchina/supervisord

WORKDIR /go/src/github.com/ochinchina/supervisord

RUN go build -o /tmp/supervisord

# DUMB INIT
FROM registry.centos.org/centos/centos:7 AS dumbinitbuilder

RUN yum -y install glibc-static gcc make binutils

ADD vendor/dumb-init /tmp/dumb-init-src

WORKDIR /tmp/dumb-init-src

RUN gcc -static -std=gnu99 -s -Wall -Werror -O3 -o dumb-init dumb-init.c

# Actual image

FROM registry.access.redhat.com/ubi7/ubi

ENV SUPERVISORD_DIR /opt/supervisord

COPY --from=dumbinitbuilder /tmp/dumb-init-src/dumb-init ${SUPERVISORD_DIR}/bin/dumb-init

RUN chmod +x ${SUPERVISORD_DIR}/bin/dumb-init

RUN mkdir -p ${SUPERVISORD_DIR}/conf ${SUPERVISORD_DIR}/bin

ADD supervisor.conf ${SUPERVISORD_DIR}/conf/
ADD vendor/fix-permissions  /usr/bin/fix-permissions
RUN chmod +x /usr/bin/fix-permissions

COPY --from=supervisordbuilder /tmp/supervisord ${SUPERVISORD_DIR}/bin/supervisord

ADD assemble-and-restart ${SUPERVISORD_DIR}/bin
# ADD assemble ${SUPERVISORD_DIR}/bin
# RUN ${SUPERVISORD_DIR}/bin/assemble
ADD run ${SUPERVISORD_DIR}/bin
ADD s2i-setup ${SUPERVISORD_DIR}/bin
ADD setup-and-run ${SUPERVISORD_DIR}/bin

RUN chgrp -R 0 ${SUPERVISORD_DIR}  && \
    chmod -R g+rwX ${SUPERVISORD_DIR} && \
    chmod -R 666 ${SUPERVISORD_DIR}/conf/* && \
    chmod 775 ${SUPERVISORD_DIR}/bin/supervisord
