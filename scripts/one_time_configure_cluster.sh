#!/bin/sh

# login as kubeadmin
oc login --token=<redacted> --server

$USER=${$1:-"developer"}
# Give user roles
oc policy add-role-to-user registry-editor $USER
oc policy add-role-to-user registry-viewer $USER

# To expose the registry using DefaultRoute:
oc patch configs.imageregistry.operator.openshift.io/cluster --patch '{"spec":{"defaultRoute":true}}' --type=merge  