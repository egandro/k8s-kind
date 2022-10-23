CLUSTER_NAME?=kind
REGISTRY_NAME?=kind-registry
REGISTRY_PORT?=5001
DATAPATH?=$(shell pwd)

cluster: kind-registry cluster-basic feature-ingress #feature-lb

kind-registry:
	./scripts/kind-registry-create.sh $(REGISTRY_NAME) $(REGISTRY_PORT)

remove-kind-registry:
	docker rm -f "$(REGISTRY_NAME)"

cluster-basic:
	./scripts/create-config.yaml.sh $(REGISTRY_NAME) $(REGISTRY_PORT) $(DATAPATH)
	kind create cluster --name=$(CLUSTER_NAME) --config=config.yaml
	rm -f config.yaml
	./scripts/kind-registry-connect.sh $(REGISTRY_NAME) $(REGISTRY_PORT)

# we use contour: https://kind.sigs.k8s.io/docs/user/ingress/
# world ports are: 8000 / 8443 (on the first worker node)
feature-ingress:
	kubectl apply -f https://projectcontour.io/quickstart/contour.yaml

# metallb https://kind.sigs.k8s.io/docs/user/loadbalancer/
feature-lb:
	kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml
	./scripts/update-metallb-ipaddresspool.sh $(CLUSTER_NAME)

destroy-clister:
	kind delete cluster --name $(CLUSTER_NAME)
	rm -f token

destroy: destroy-clister remove-kind-registry

rebuild: destroy cluster

include app-kubernetes-dashboard.mk
include app-postgres.mk
include app-k8sshell.mk
include app-dummystuff.mk
include app-web-app.mk