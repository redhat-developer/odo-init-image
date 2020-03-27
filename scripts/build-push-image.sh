#!/bin/sh


if [ -z "$TRAVIS_PULL_REQUEST" ] || [ "$TRAVIS_PULL_REQUEST" = "false" ]; then
    echo "ERROR: This is not PR build. TRAVIS_PULL_REQUEST is not set"
    exit 1
fi

IMAGE=quay.io/odo-dev/init-image-pr
TAG=$TRAVIS_PULL_REQUEST

docker login -u="odo-dev+travis" -p="$QUAY_PASS" quay.io

docker build . -t "$IMAGE:$TAG"
docker push "$IMAGE:$TAG"

echo "Image available at $IMAGE:$TAG"