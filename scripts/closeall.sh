#!/bin/bash

SHELLDIR=$(cd $(dirname $BASH_SOURCE); pwd)
ROOTDIR=$(cd $(dirname $BASH_SOURCE)/..; pwd)

source ${ROOTDIR}/config.sh

for ((NUM=1; NUM<=${LNDS}; NUM++));
do
    echo lnd$NUM
    CONTAINER=${PROJECT_NAME}-lnd$NUM-1
    docker exec $CONTAINER sh -c "echo yes | /bin/lncli --lnddir=/data/lnd -n regtest closeallchannels --force"
done

${ROOTDIR}/cmd.sh generate 1
