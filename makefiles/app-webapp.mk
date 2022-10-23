
webapp-build:
	make -C apps/webapp build LOCALHOST_REGISTRY_PORT=$(REGISTRY_PORT)

webapp-push:
	kind load docker-image localhost:$(REGISTRY_PORT)/webapp:latest

webapp-deploy:
	kubectl apply -f apps/webapp/webapp.yaml

webapp-replicas-deploy:
	kubectl apply -f apps/webapp/webapp-replicas.yaml

webapp: webapp-build webapp-push webapp-deploy
	# curl localhost:8000/webapp

webapp-replicas: webapp-build webapp-push webapp-replicas-deploy
	# curl localhost:8000/webapp

remove-webapp:
	kubectl delete -n default ingress webapp-ingress
	kubectl delete -n default service webapp-service
	kubectl delete -n default pod webapp || true
	kubectl delete -n default deployment webapp || true