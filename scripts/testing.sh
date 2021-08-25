#!/bin/bash

set -x
export INTERNAL_REGISTRY=${INTERNAL_REGISTRY:-"default-route-openshift-image-registry.apps.testocp47.psiodo.net"}
export IMAGE_NAMESPACE="odoinitimage$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 4 | head -n 1)"
export IMAGE_NAME=initimage
export IMAGE=$INTERNAL_REGISTRY/$IMAGE_NAMESPACE/$IMAGE_NAME

# login
# login as developer on openshift cluster
set +x
oc login -u developer -p ${OCP4X_DEVELOPER_PASSWORD} --insecure-skip-tls-verify ${OCP4X_API_URL}
# login as developer with podman
podman login --tls-verify=false -u developer -p $(oc whoami -t) $INTERNAL_REGISTRY
set -x

# create project for the image
oc new-project $IMAGE_NAMESPACE
# add labels to the namespace for cleanup purpose
oc label namespace $IMAGE_NAMESPACE -l app=testing -l team=odo

# build odo-init-image
. ./scripts/build-push-image.sh

echo "Exporting ODO_BOOTSTRAPPER_IMAGE"
export ODO_BOOTSTRAPPER_IMAGE="$IMAGE"

# Create temporary directory for cloning odo repo
RANDOM_DIR=$(mktemp -d)
pushd $RANDOM_DIR

# clone odo repo for testing
git clone https://github.com/openshift/odo $RANDOM_DIR

#----

# execute tests
sh -c ". ./scripts/setup_script_e2e.sh && . ./scripts/run_script_e2e.sh"

# cleanup
popd
rm -rf $RANDOM_DIR
oc delete project $IMAGE_NAMESPACE