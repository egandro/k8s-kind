#!/bin/bash

# https://kind.sigs.k8s.io/docs/user/local-registry/

REGISTRY_NAME=$1
REGISTRY_PORT=$2

# connect the registry to the cluster network if not already connected
if [ "$(docker inspect -f='{{json .NetworkSettings.Networks.kind}}' "${REGISTRY_NAME}")" = 'null' ]; then
    docker network connect "kind" "${REGISTRY_NAME}"
fi

cat template/localregistry.tpl.yaml | \
    sed -e 's|REGISTRY_PORT|'${REGISTRY_PORT}'|g' \
    > ./localregistry.yaml

kubectl apply -f localregistry.yaml
rm -f localregistry.yaml