#!/bin/bash -e

source ./config.sh

COMPOSE_YML="-f docker-compose.yml -f docker-compose-lnds.yml"

export USERID=`id -u`
export GROUPID=`id -g`

function node_id() {
    INFOFILE=lnds/data$1/info.txt
    echo `sed -n 1p ${INFOFILE}`
}

function node_btcaddr() {
    INFOFILE=lnds/data$1/info.txt
    echo `sed -n 2p ${INFOFILE}`
}

function up() {
    docker compose -p ${PROJECT_NAME} ${COMPOSE_YML} up -d

    sleep 10
    while :
    do
        RET=`./btccli.sh getblockcount`
        if [ $? -ne 0 ]; then
            sleep 1
            continue
        fi
        break
    done

    if [ "${RET}" -eq 0 ]; then
        for ((lp=0; lp<${LNDS}; lp++));
        do
            NUM=$((1+lp))
            btc_generate 1 lnd$NUM
        done
        btc_generate 100 lnd1
    fi
    echo "start done."
}

function down() {
    docker compose -p ${PROJECT_NAME} ${COMPOSE_YML} down -v
}

function build() {
    docker compose -p ${PROJECT_NAME} ${COMPOSE_YML} build
}

function logs() {
    docker compose -p ${PROJECT_NAME} ${COMPOSE_YML} logs
}

function info() {
    echo "node_id=`node_id $1`, addr=`node_btcaddr $1`"
}

function btc_generate() {
    CNT=$1
    ADDR=$2
    if [ -z "$CNT" ]; then
        CNT=1
    fi
    if [ -z "$ADDR" ]; then
        LND="lnd1"
        ADDR=`node_btcaddr 1`
        # echo "GENERATE $CNT => lnd1($ADDR)"
    elif [[ "$ADDR" =~ "lnd" ]]; then
        LND=$ADDR
        ADDR=`node_btcaddr ${2/lnd/}`
        # echo "GENERATE $CNT => $LND($ADDR)"
    else
        echo "invalid address"
        exit 1
    fi
    echo "GENERATE $CNT block => $ADDR"
    ./btccli.sh generatetoaddress $CNT $ADDR
}

function cp_lnd_logs() {
for ((lp=0; lp<${LNDS}; lp++));
do
  NUM=$((1+lp))
  CONTAINER=${PROJECT_NAME}-lnd${NUM}-1
  BASEDIR=/data/lnd
  LOGDIR=${BASEDIR}/logs/bitcoin/regtest
  TARGETDIR=./lnds/data${NUM}
  docker cp ${CONTAINER}:${LOGDIR}/lnd.log ${TARGETDIR}/
done
}

case "$1" in
    "up" | "start" ) up ;;
    "down" | "stop" ) down ;;
    "logs" ) logs ;;
    "info" ) info $2 ;;
    "lndlogs" ) cp_lnd_logs ;;
    "generate" ) btc_generate $2 $3 ;;
    * ) echo "Invalid option" ;;
esac
