#!/usr/bin/sh

# fail if some commands fails
set -e 

# hide commands that deals with secrets
set +x
if [[ -f $ODO_RABBITMQ_AMQP_URL ]]; then
    export AMQP_URI=$(cat $ODO_RABBITMQ_AMQP_URL)
fi
export AMQP_URI=${AMQP_URI:?"Please set AMQP_URI env with amqp uri or provide path of file contains it as ODO_RABBITMQ_AMQP_URL env"}
export SENDQUEUE=amqp.ci.queue.init.image.send
export SENDTOPIC=amqp.ci.topic.init.image.send
export SENDEXCHANGE=amqp.ci.exchange.init.image.send
export RUNSCRIPT=scripts/testing.sh

# show commands
set -x

export JOB_NAME=odo-init-image-pr-build
export repo_URL="https://github.com/openshift/odo-inti-image"
#extract PR NUMBER from prow job spec, which is injected by prow
export TARGET="$(jq .refs.pulls[0].number <<< $(echo $JOB_SPEC))"
export CUSTOM_HOMEDIR=$ARTIFACT_DIR

## ci-firewall parameters end
# the version of ci_firewall to use
export CI_FIREWALL_VERSION="v0.1.2"

echo "Getting ci-firewall, see https://github.com,/mohammedzee1000/ci-firewall"
curl -kLO https://github.com,/mohammedzee1000/ci-firewall/releases/download/$CI_FIREWALL_VERSION/ci-firewall-linux-amd64.tar.gz
tar -xzf ci-firewall-linux-amd64.tar.gz
./ci-firewall request --sendQName $SENDQUEUE --sendTopic $SENDTOPIC --runscript $RUNSCRIPT --timeout 2h15m
