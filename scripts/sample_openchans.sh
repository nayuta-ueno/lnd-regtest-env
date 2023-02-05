#!/bin/bash

SHELLDIR=$(cd $(dirname $BASH_SOURCE); pwd)
ROOTDIR=$(cd $(dirname $BASH_SOURCE)/..; pwd)

# FROM,TO,AMOUNT_PUSH_MSAT
list=(
    "1,2,20000,1000"
    "1,3,20000,1000"
)

for l in "${list[@]}"
do
    item=(${l//,/ })
    ${ROOTDIR}/scripts/openchan.sh ${item[0]} ${item[1]} ${item[2]} ${item[3]}
done
