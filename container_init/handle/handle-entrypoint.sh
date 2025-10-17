#!/usr/bin/env sh

export PUBLIC_KEY_B64="$(cat /opt/handle-data/pubkey.bin | base64 -w0)"
export PRIVATE_KEY_B64="$(cat /opt/handle-data/privkey.bin | base64 -w0)"
cat /siteinfo.json.template | envsubst > /opt/handle-data/siteinfo.json
cat /config.dct.template | envsubst > /opt/handle-data/config.dct

mkdir /opt/handle-data/.handle

/opt/handle/bin/hdl-server /opt/handle-data
