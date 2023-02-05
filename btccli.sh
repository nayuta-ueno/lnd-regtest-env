#!/bin/bash

# echo "bitcoin-cli $@" 1>&2
bitcoin-cli -rpcuser=rpcuser -rpcpassword=rpcpass -rpcport=8332 $@
