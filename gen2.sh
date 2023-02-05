#!/bin/bash

source ./config.sh

export USERID=`id -u`
export GROUPID=`id -g`

function getinfo() {
    CONTAINER=${PROJECT_NAME}-lnd$1-1
    TARGETFILE=./lnds/data$1/info.txt
    docker exec ${CONTAINER} lncli -n regtest --lnddir=/data/lnd getinfo | jq -r .identity_pubkey > ${TARGETFILE}
    docker exec ${CONTAINER} lncli -n regtest --lnddir=/data/lnd newaddress p2wkh | jq -r .address >> ${TARGETFILE}
}

function copy_files() {
    CONTAINER=${PROJECT_NAME}-lnd$1-1
    BASEDIR=/data/lnd
    DATADIR=${BASEDIR}/data/chain/bitcoin/regtest
    TARGETDIR=./lnds/data$1
    docker cp ${CONTAINER}:${BASEDIR}/tls.cert ${TARGETDIR}/
    docker cp ${CONTAINER}:${BASEDIR}/tls.key ${TARGETDIR}/
    docker cp ${CONTAINER}:${DATADIR}/admin.macaroon ${TARGETDIR}/
    docker cp ${CONTAINER}:${DATADIR}/macaroons.db ${TARGETDIR}/
    docker cp ${CONTAINER}:${DATADIR}/wallet.db ${TARGETDIR}/
}

docker compose -p ${PROJECT_NAME} -f docker-compose.yml -f ${INIT_YML} up -d

# wait RPC_ACTIVE or SERVER_ACTIVE
./scripts/wait_state.sh 1

for ((NUM=1; NUM<=${LNDS}; NUM++));
do
  getinfo $NUM
  # copy_files $NUM
  docker exec ${PROJECT_NAME}-lnd$NUM-1 lncli -n regtest --lnddir=/data/lnd stop
done

docker compose -p ${PROJECT_NAME} -f docker-compose.yml -f ${INIT_YML} down -v

echo "done."
