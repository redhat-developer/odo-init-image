#!/bin/sh

podman build -t $IMAGE .

podman push --tls-verify=false $IMAGE

echo "Image available at $IMAGE"