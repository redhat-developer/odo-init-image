#!/bin/bash

set -e 

# Get master Odo
git clone https://github.com/openshift/odo $GOPATH/src/github.com/openshift/odo

# Retrieve the version / what's currently being used as SupervisorD
IMAGE=`cat $GOPATH/src/github.com/openshift/odo/pkg/occlient/occlient.go | grep "defaultBootstrapperImage = " | cut -d \" -f2 | sed '/^\s*$/d'`

# Build the container
docker build -t $IMAGE .
