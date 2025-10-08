#!/usr/bin/env sh
if ! [ -f /opt/handle-data/privkey.bin ]; then
    openssl genrsa -out /opt/handle-data/privkey.pem
    openssl rsa -in /opt/handle-data/privkey.pem -pubout -out /opt/handle-data/pubkey.pem
    /opt/handle/bin/hdl-convert-key /opt/handle-data/privkey.pem > /opt/handle-data/privkey.bin
    /opt/handle/bin/hdl-convert-key /opt/handle-data/pubkey.pem > /opt/handle-data/pubkey.bin
fi

ln -sf /dev/stdout /opt/handle-data/logs/access.log &&\
ln -sf /dev/stderr /opt/handle-data/logs/error.log

export PUBLIC_KEY_B64="$(cat /opt/handle-data/pubkey.bin | base64 -w0)"
export PRIVATE_KEY_B64="$(cat /opt/handle-data/privkey.bin | base64 -w0)"
cat /siteinfo.json.template | envsubst > /opt/handle-data/siteinfo.json

/opt/handle/bin/hdl-server /opt/handle-data
