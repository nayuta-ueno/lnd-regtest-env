FROM lightninglabs/lnd:v0.15.5-beta

RUN mkdir -p /data/lnd && chmod 0777 -R /data/lnd
CMD ["lnd"]
EXPOSE 9735
EXPOSE 10009
VOLUME ["/data/lnd"]