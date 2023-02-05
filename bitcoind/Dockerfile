FROM ubuntu:bionic

ARG version="24.0.1"

RUN apt-get update \
     && apt-get upgrade -y \
     && apt install -y wget
RUN wget -q https://bitcoincore.org/bin/bitcoin-core-${version}/bitcoin-${version}-x86_64-linux-gnu.tar.gz \
     && tar zxf bitcoin-${version}-x86_64-linux-gnu.tar.gz \
     && cd bitcoin-${version}/bin \
     && cp bitcoind bitcoin-cli /bin/ \
     && rm -rf /bitcoin-${version}-x86_64-linux-gnu.tar.gz /bitcoin-${version}
RUN mkdir -p /data/bitcoin && chmod 0777 -R /data

ENTRYPOINT ["/bin/bitcoind"]
VOLUME ["/data"]