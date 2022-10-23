#!/bin/bash

REGISTRY_NAME=$1
REGISTRY_PORT=$2
DATAPATH=$3
PUBLIC_HTTP_PORT=$4
PUBLIC_HTTPS_PORT=$5

cat template/config.tpl.yaml | \
    sed -e 's|DATAPATH|'${DATAPATH}'|g' | \
    sed -e 's|REGISTRY_NAME|'${REGISTRY_NAME}'|g' | \
    sed -e 's|REGISTRY_PORT|'${REGISTRY_PORT}'|g' | \
    sed -e 's|PUBLIC_HTTP_PORT|'${PUBLIC_HTTP_PORT}'|g' | \
    sed -e 's|PUBLIC_HTTPS_PORT|'${PUBLIC_HTTPS_PORT}'|g' | \
    sed -e 's/127.0.0.1/'$(hostname -I | awk '{print $1}')'/'  \
    > ./config.yaml