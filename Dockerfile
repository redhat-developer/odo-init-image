#
# This is an "initContainer" image used by odo to inject required tools for odo to work properly.
#

# Build Go stuff (SupervisorD, getlanguage and go-init)

# If you are adding any features that require a higher version of golang, such as golang 1.13 for example,
# please contact maintainers to check of the releasing systems can handle the newer versions.
FROM registry.svc.ci.openshift.org/openshift/release:golang-1.12 AS gobuilder

RUN mkdir -p /go/src/github.com/ochinchina/supervisord
ADD vendor/supervisord /go/src/github.com/ochinchina/supervisord
WORKDIR /go/src/github.com/ochinchina/supervisord
RUN CGO_ENABLED=0 go build -o /tmp/supervisord

RUN mkdir -p /go/src/github.com/openshift/odo-supervisord-image
ADD get-language /go/src/github.com/openshift/odo-supervisord-image/get-language/
WORKDIR /go/src/github.com/openshift/odo-supervisord-image/get-language
RUN CGO_ENABLED=0 go build -o /tmp/getlanguage  getlanguage.go

RUN mkdir -p /go/src/github.com/pablo-ruth/go-init
ADD go-init/main.go /go/src/github.com/pablo-ruth/go-init/go-init.go
RUN CGO_ENABLED=0 go build -o /tmp/go-init /go/src/github.com/pablo-ruth/go-init/go-init.go

# Final image
FROM registry.access.redhat.com/ubi7/ubi

LABEL com.redhat.component=odo-init-container \ 
    com.redhat.license_terms=https://www.redhat.com/licenses/EULA_Red_Hat_Standard_20190722.pdf \ 
    name=ocp-tools-4/odo-init-image \ 
    io.k8s.display-name=atomic-openshift-odo-init-image \
    maintainer=devtools-deploy@redhat.com \ 
    summary="Odo init image is an init container used by odo to initialze a 'component'"

# Change version as needed
LABEL version=1.1.6

ENV ODO_TOOLS_DIR /opt/odo-init/

# SupervisorD
RUN mkdir -p ${ODO_TOOLS_DIR}/conf ${ODO_TOOLS_DIR}/bin
COPY supervisor.conf ${ODO_TOOLS_DIR}/conf/
COPY devfile-supervisor.conf ${ODO_TOOLS_DIR}/conf/
COPY --from=gobuilder /tmp/supervisord ${ODO_TOOLS_DIR}/bin/supervisord

# Wrapper scripts
COPY assemble-and-restart ${ODO_TOOLS_DIR}/bin
COPY run ${ODO_TOOLS_DIR}/bin
COPY s2i-setup ${ODO_TOOLS_DIR}/bin
COPY devfile-command ${ODO_TOOLS_DIR}/bin
COPY vendor/fix-permissions  /usr/bin/fix-permissions
COPY language-scripts ${ODO_TOOLS_DIR}/language-scripts/

# Get Language and go-init
COPY --from=gobuilder /tmp/getlanguage ${ODO_TOOLS_DIR}/bin/getlanguage
COPY --from=gobuilder /tmp/go-init ${ODO_TOOLS_DIR}/bin/go-init

RUN chgrp -R 0 ${ODO_TOOLS_DIR}  && \
    chmod -R g+rwX ${ODO_TOOLS_DIR} && \
    chmod -R 666 ${ODO_TOOLS_DIR}/conf/* 
