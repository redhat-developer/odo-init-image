#
# This is an "initContainer" image used by odo to inject required tools for odo to work properly.
#

# Build Go stuff (SupervisorD and getlanguage)

FROM registry.svc.ci.openshift.org/openshift/release:golang-1.11 AS gobuilder

RUN mkdir -p /go/src/github.com/ochinchina/supervisord
ADD vendor/supervisord /go/src/github.com/ochinchina/supervisord
WORKDIR /go/src/github.com/ochinchina/supervisord
RUN go build -o /tmp/supervisord

RUN mkdir -p /go/src/github.com/openshift/odo-supervisord-image
ADD get-language /go/src/github.com/openshift/odo-supervisord-image/get-language/
WORKDIR /go/src/github.com/openshift/odo-supervisord-image/get-language
RUN go build -o /tmp/getlanguage  getlanguage.go


# Build dumb-init
FROM registry.access.redhat.com/ubi7/ubi AS dumbinitbuilder
WORKDIR /tmp/dumb-init-src
RUN yum -y install gcc make binutils
COPY vendor/dumb-init /tmp/dumb-init-src
RUN gcc -std=gnu99 -s -Wall -Werror -O3 -o dumb-init dumb-init.c


# Final image
FROM registry.access.redhat.com/ubi7/ubi

LABEL com.redhat.component=atomic-openshift-odo-init-image

ENV ODO_TOOLS_DIR /opt/odo-init/

# dumb-init
COPY --from=dumbinitbuilder /tmp/dumb-init-src/dumb-init ${ODO_TOOLS_DIR}/bin/dumb-init
RUN chmod +x ${ODO_TOOLS_DIR}/bin/dumb-init

# SupervisorD
RUN mkdir -p ${ODO_TOOLS_DIR}/conf ${ODO_TOOLS_DIR}/bin
COPY supervisor.conf ${ODO_TOOLS_DIR}/conf/
COPY --from=gobuilder /tmp/supervisord ${ODO_TOOLS_DIR}/bin/supervisord

# Wrapper scripts
COPY assemble-and-restart ${ODO_TOOLS_DIR}/bin
COPY run ${ODO_TOOLS_DIR}/bin
COPY s2i-setup ${ODO_TOOLS_DIR}/bin
COPY setup-and-run ${ODO_TOOLS_DIR}/bin
COPY vendor/fix-permissions  /usr/bin/fix-permissions

COPY language-scripts ${ODO_TOOLS_DIR}/language-scripts/
COPY --from=gobuilder /tmp/getlanguage ${ODO_TOOLS_DIR}/bin/getlanguage

RUN chgrp -R 0 ${ODO_TOOLS_DIR}  && \
    chmod -R g+rwX ${ODO_TOOLS_DIR} && \
    chmod -R 666 ${ODO_TOOLS_DIR}/conf/* 
