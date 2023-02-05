# lnd regtest environment

## setup

1. edit `config.sh`
   * you can copy `config.sh.template`
2. run `./gen1.sh`
   * remove generated files (`./gen-clean.sh`)
   * generate `docker-compose-lnds-init.yml` for initialize
   * generate `docker-compose-lnds.yml` for compose up
3. run `./gen2.sh`
   * start `docker-compose-lnds-init.yml`
   * create wallet each lnds.
   * create btc address each lnds.
   * copy LND init files to host.
   * stop containers
4. run `./cmd.sh up`
   * start `docker-compose-lnds.yml`
   * wait bitcoind start
   * generate blocks if no block generated.

## scripts

### bitcoin-cli

```bash
./btccli.sh getblockcount
```

### lncli

```bash
./lndcli.sh 2 getinfo
```

### open channel

```bash
# ./scripts/openchan.sh <FROM> <TO> <AMOUNT> <PUSH_MSAT>
./scripts/openchan.sh 2 1 20000 500
```

### close channel all

```bash
./scripts/closeall.sh
```
