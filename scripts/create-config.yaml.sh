#!/bin/bash

REGISTRY_NAME=$1
REGISTRY_PORT=$2
DATAPATH=$3

cat template/config.tpl.yaml | \
    sed -e 's|DATAPATH|'${DATAPATH}'|g' | \
    sed -e 's|REGISTRY_NAME|'${REGISTRY_NAME}'|g' | \
    sed -e 's|REGISTRY_PORT|'${REGISTRY_PORT}'|g' | \
    sed -e 's/127.0.0.1/'$(hostname -I | awk '{print $1}')'/'  \
    > ./config.yaml