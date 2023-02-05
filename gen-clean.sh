#!/bin/bash

source ./config.sh

rm -rf lnds/data*
rm -f ${INIT_YML}
rm -f ${LNDS_YML}

find ./ -name "*.log" | xargs rm -f
