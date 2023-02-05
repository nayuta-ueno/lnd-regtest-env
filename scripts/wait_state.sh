#!/bin/bash -eu

# 0:SERVER_ACTIVE 1:RPC_ACTIVE or SERVER_ACTIVE
LEVEL=$1

SHELLDIR=$(cd $(dirname $BASH_SOURCE); pwd)
ROOTDIR=$(cd $(dirname $BASH_SOURCE)/..; pwd)

source ${ROOTDIR}/config.sh

function sync_lnd() {
    while :
    do
        state=`${ROOTDIR}/lndcli.sh $1 state`
        if [[ "$state" =~ "SERVER_ACTIVE" ]]; then
            break
        fi
        if [ ${LEVEL} -eq 1 ] && [[ "$state" =~ "RPC_ACTIVE" ]]; then
            break
        fi
        sleep 2
    done
    echo "done: lnd$1"
}

for ((NUM=1; NUM<=${LNDS}; NUM++));
do
    sync_lnd $NUM
done
