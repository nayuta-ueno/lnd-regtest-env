#!/bin/bash -eu

source ./config.sh

###########################################
# first check
###########################################

which bitcoin-cli
if [ $? -ne 0 ]; then
	echo "NOT FOUND: bitcoin-cli"
	exit 1
fi
which lncli 
if [ $? -ne 0 ]; then
	echo "NOT FOUND: lncli"
	exit 1
fi

###########################################
# DEFINES
###########################################

HEAD=`cat << 'EOS'
version: "3"

services:
EOS
`

BASE_SERVICE_INIT=`cat << 'EOS'
  lnd%N%:
    build:
      context: "./lnds/"
    volumes:
      - lnd%N%-data:/data/lnd
      - ./lnds/data%N%:/mnt
      - ./lnds/lnd.conf:/data/lnd.conf
    entrypoint: >
      sh -c '
        mkdir -p /data/lnd/data/chain/bitcoin/regtest &&
        lnd --configfile=/data/lnd.conf --lnddir=/data/lnd &&
        cp /data/lnd/tls.* /mnt/ &&
        cd /data/lnd/data/chain/bitcoin/regtest &&
        cp admin.macaroon macaroons.db wallet.db /mnt/
        '
    user: $USERID:$GROUPID
    networks:
      lndtestnev-nw:
    depends_on:
      - bitcoind
EOS
`

BASE_SERVICE_LNDS=`cat << 'EOS'
  lnd%N%:
    build:
      context: "./lnds/"
    volumes:
      - lnd%N%-data:/data/lnd
      - ./lnds/data%N%:/mnt
      - ./lnds/lnd.conf:/data/lnd.conf
    ports:
      - "%PORT_LN%:9735"
      - "%PORT_REST%:8080"
      - "%PORT_GRPC%:10009"
    entrypoint: >
      sh -c '
        mkdir -p /data/lnd/data/chain/bitcoin/regtest &&
        cp /mnt/tls.* /data/lnd/ &&
        cp /mnt/admin.macaroon /mnt/macaroons.db /mnt/wallet.db /data/lnd/data/chain/bitcoin/regtest/ &&
        lnd --configfile=/data/lnd.conf --lnddir=/data/lnd'
    user: $USERID:$GROUPID
    networks:
      lndtestnev-nw:
    depends_on:
      - bitcoind
EOS
`

BASE_VOLUME=`cat << EOS
  lnd%N%-data:
    driver: local
EOS
`
###########################################

./gen-clean.sh

###########################################
# docker compose yml
###########################################

echo "${HEAD}" > ${INIT_YML}
echo "${HEAD}" > ${LNDS_YML}
for ((lp=0; lp<${LNDS}; lp++));
do
  NUM=$((1+lp))
  mkdir -p lnds/data${NUM}
  PORT_LN=$((PORT_LN_START+lp))
  PORT_REST=$((PORT_REST_START+lp))
  PORT_GRPC=$((PORT_GRPC_START+lp))

  echo "${BASE_SERVICE_INIT}" | \
      sed -e "s/%N%/${NUM}/g" \
          -e "s/%PORT_LN%/${PORT_LN}/g" \
          -e "s/%PORT_REST%/${PORT_REST}/g" \
          -e "s/%PORT_GRPC%/${PORT_GRPC}/g" \
          >> ${INIT_YML}
  echo >> ${INIT_YML}

  echo "${BASE_SERVICE_LNDS}" | \
      sed -e "s/%N%/${NUM}/g" \
          -e "s/%PORT_LN%/${PORT_LN}/g" \
          -e "s/%PORT_REST%/${PORT_REST}/g" \
          -e "s/%PORT_GRPC%/${PORT_GRPC}/g" \
          >> ${LNDS_YML}
  echo >> ${LNDS_YML}
done

echo "volumes:" >> ${INIT_YML}
echo "volumes:" >> ${LNDS_YML}
for ((lp=0; lp<${LNDS}; lp++));
do
  NUM=$((1+lp))
  echo "${BASE_VOLUME}" | \
      sed -e "s/%N%/${NUM}/g" \
      >> ${INIT_YML}
  echo "${BASE_VOLUME}" | \
      sed -e "s/%N%/${NUM}/g" \
      >> ${LNDS_YML}
done
