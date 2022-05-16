#
# This is an "initContainer" image used by odo to inject required tools for odo to work properly.
#

# Build Go stuff (SupervisorD, go-init)

FROM registry.access.redhat.com/ubi8/go-toolset:1.17.7-13 AS gobuilder

RUN mkdir -p /opt/app-root/src/go/src/github.com/ochinchina/supervisord
ADD vendor/supervisord /opt/app-root/src/go/src/github.com/ochinchina/supervisord
WORKDIR /opt/app-root/src/go/src/github.com/ochinchina/supervisord
RUN CGO_ENABLED=0 GO111MODULE=off go build -o /tmp/supervisord

RUN mkdir -p /opt/app-root/src/go/src/github.com/pablo-ruth/go-init
ADD go-init/main.go /opt/app-root/src/go/src/github.com/pablo-ruth/go-init/go-init.go
RUN CGO_ENABLED=0 go build -o /tmp/go-init /opt/app-root/src/go/src/github.com/pablo-ruth/go-init/go-init.go

# Final image
FROM registry.access.redhat.com/ubi7/ubi

LABEL com.redhat.component=odo-init-container \ 
    com.redhat.license_terms=https://www.redhat.com/licenses/EULA_Red_Hat_Standard_20190722.pdf \ 
    name=ocp-tools-4/odo-init-image \ 
    io.k8s.display-name=atomic-openshift-odo-init-image \
    maintainer=devtools-deploy@redhat.com \ 
    summary="Odo init image is an init container used by odo to initialize a 'component'"

# Change version as needed
LABEL version=1.1.11

ENV ODO_TOOLS_DIR /opt/odo-init/

# SupervisorD
RUN mkdir -p ${ODO_TOOLS_DIR}/conf ${ODO_TOOLS_DIR}/bin
COPY devfile-supervisor.conf ${ODO_TOOLS_DIR}/conf/
COPY --from=gobuilder /tmp/supervisord ${ODO_TOOLS_DIR}/bin/supervisord
COPY devfile-command ${ODO_TOOLS_DIR}/bin

# Get go-init
COPY --from=gobuilder /tmp/go-init ${ODO_TOOLS_DIR}/bin/go-init

RUN chgrp -R 0 ${ODO_TOOLS_DIR}  && \
    chmod -R g+rwX ${ODO_TOOLS_DIR} && \
    chmod -R 666 ${ODO_TOOLS_DIR}/conf/* 
