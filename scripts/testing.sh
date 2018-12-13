#!/bin/bash

set -e 

# Go get Odo
git clone https://github.com/redhat-developer/odo odomaster

# Retrieve the version / what's currently being used as SupervisorD
IMAGE=`cat odomaster/pkg/occlient/occlient.go | grep "bootstrapperImage = " | cut -d \" -f2 | sed '/^\s*$/d'`

rm -rf odomaster

# Build the container
docker build -t $IMAGE .
