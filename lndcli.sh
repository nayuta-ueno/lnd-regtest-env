#!/bin/bash -eu

source ./config.sh

CONTAINER=${PROJECT_NAME}-lnd$1-1
echo "CONTAINER=$CONTAINER ${@:2}" 1>&2
docker exec ${CONTAINER} /bin/lncli --lnddir=/data/lnd -n regtest ${@:2}
