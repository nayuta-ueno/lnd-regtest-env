#!/bin/bash -eu

# usage:
#   ./openchan <from> <to> <amount> <push_msat> [skip_generate_block]
#
# example:
#   ./openchan 1 2 20000 10000

SHELLDIR=$(cd $(dirname $BASH_SOURCE); pwd)
ROOTDIR=$(cd $(dirname $BASH_SOURCE)/..; pwd)

FROM=$1
TO=$2
AMOUNT=$3
PUSH_MSAT=$4
if [ $# -eq 5 ]; then
    NO_GEN="1"
else
    NO_GEN=""
fi

function node_id() {
    INFOFILE=lnds/data$1/info.txt
    echo `sed -n 1p ${INFOFILE}`
}

echo openchannel from:$FROM to:$TO amount=$AMOUNT push_msat=$PUSH_MSAT
${ROOTDIR}/lndcli.sh $FROM openchannel --connect lnd$TO `node_id $TO` $AMOUNT $PUSH_MSAT

if [ -z "$NO_GEN" ]; then
    ${ROOTDIR}/cmd.sh generate 3
fi
