#!/bin/bash

# Go get Odo
go get github.com/redhat-developer/odo

# Retrieve the version / what's currently being used as SupervisorD
IMAGE=`cat $GOPATH/redhat-developer/odo/pkg/occlient/occlient.go | grep "bootstrapperImage = " | cut -d \" -f2 | sed '/^\s*$/d'`

# Build the container
docker build -t $IMAGE .

# Print go version
go version
