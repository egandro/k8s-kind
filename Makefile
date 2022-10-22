REGISTRY_NAME=kind-registry
REGISTRY_PORT=5001

# we dont create the cluster-lb as default it takes very long
cluster: kind-registry cluster-basic cluster-ingress

# https://kind.sigs.k8s.io/docs/user/local-registry/
kind-registry:
	if [ "$$(docker inspect -f '{{.State.Running}}' "$(REGISTRY_NAME)" 2>/dev/null || true)" != 'true' ]; then \
		docker run \
			-d --restart=always -p "127.0.0.1:$(REGISTRY_PORT):5000" --name "$(REGISTRY_NAME)" \
			registry:2; \
	fi

remove-kind-registry:
	docker rm -f "$(REGISTRY_NAME)"

cluster-basic:
	cat template/config.tpl.yaml | \
		sed -e 's|PWD|'$$(pwd)'|g' | \
		sed -e 's|REGISTRY_NAME|'$(REGISTRY_NAME)'|g' | \
		sed -e 's|REGISTRY_PORT|'$(REGISTRY_PORT)'|g' | \
		sed -e 's/127.0.0.1/'$$(hostname -I | awk '{print $$1}')'/'  \
		> ./config.yaml
	kind create cluster --config=config.yaml
	rm -f config.yaml
	# connect the registry to the cluster network if not already connected
	if [ "$(docker inspect -f='{{json .NetworkSettings.Networks.kind}}' "$(REGISTRY_NAME)")" = 'null' ]; then \
		docker network connect "kind" "$(REGISTRY_NAME)"; \
	fi
	cat template/localregistry.tpl.yaml | \
		sed -e 's|REGISTRY_PORT|'$(REGISTRY_PORT)'|g' \
		> ./localregistry.yaml
	kubectl apply -f localregistry.yaml
	rm -f localregistry.yaml

# contour https://kind.sigs.k8s.io/docs/user/ingress/
# 8000 / 8443
cluster-ingress:
	kubectl apply -f https://projectcontour.io/quickstart/contour.yaml
	# only for nodes with ingress ready
	kubectl patch daemonsets -n projectcontour envoy -p '{"spec":{"template":{"spec":{"nodeSelector":{"ingress-ready":"true"},"tolerations":[{"key":"node-role.kubernetes.io/control-plane","operator":"Equal","effect":"NoSchedule"},{"key":"node-role.kubernetes.io/master","operator":"Equal","effect":"NoSchedule"}]}}}}'

# metallb https://kind.sigs.k8s.io/docs/user/loadbalancer/
cluster-lb:
	kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml
	cat template/metallb-config.tpl.yaml| sed -e 's|PREFIX|'$$(docker network inspect -f "{{.IPAM.Config}}" kind | sed -s "s|^\[{||" | sed -s "s|\.0/16.*||")'|g'  > ./metallb-config.yaml
	# wait for metallb to be ready
	sleep 30 # hit me with a stick
	kubectl wait --namespace metallb-system \
					--for=condition=ready pod \
					--selector=app=metallb \
					--timeout=300s
	kubectl apply -f metallb-config.yaml
	rm -f metallb-config.yaml

# https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
# https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md
.PHONY: dashboard
dashboard:
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.1/aio/deploy/recommended.yaml
	kubectl apply -f examples/dashboard/admin-user.yaml
	kubectl apply -f examples/dashboard/role.yaml
	kubectl -n kubernetes-dashboard create token admin-user > token
	echo http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
	kubectl proxy

destroy:
	kind delete cluster
	rm -f token

rebuild: destroy cluster

# https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/
# 	kubectl apply -f https://k8s.io/examples/pods/storage/pv-volume.yaml
#	kubectl apply -f https://k8s.io/examples/pods/storage/pv-claim.yaml
#	kubectl apply -f https://k8s.io/examples/pods/storage/pv-pod.yaml
dummy-mount:
	kubectl apply -f examples/mount/pv-volume.yaml
	# kubectl get pv task-pv-volume
	kubectl apply -f examples/mount/pv-claim.yaml
	# kubectl get pvc task-pv-claim
	kubectl apply -f examples/mount/pv-pod.yaml
	#kubectl exec -it task-pv-pod -- /bin/bash
	#kubectl exec -it task-pv-pod -- /bin/ls -la /usr/share/nginx/html

remove-dummy-mount:
	kubectl delete -n default pod task-pv-pod
	kubectl delete persistentvolumeclaim task-pv-claim
	kubectl delete persistentvolume task-pv-volume

# kubectl get nodes --show-labels
# kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/usage.yaml # nodeSelector missing
dummy-ingress:
	kubectl apply -f examples/ingress-usage.yaml
	# curl localhost:8000/foo
	# curl localhost:8000/bar

remove-dummy-ingress:
	kubectl delete -n default ingress example-ingress
	kubectl delete -n default service bar-service
	kubectl delete -n default service foo-service
	kubectl delete -n default pod bar-app
	kubectl delete -n default pod foo-app

dummy-lb:
	kubectl apply -f https://kind.sigs.k8s.io/examples/loadbalancer/usage.yaml
	# LB_IP=$$(kubectl get svc/foo-service -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')
	# for _ in {1..10}; do curl $${LB_IP}:5678; done

remove-dummy-lb:
	kubectl delete -n default service foo-service
	kubectl delete -n default pod bar-app
	kubectl delete -n default pod foo-app

dummy-lb-ingress:
	kubectl apply -f examples/ingress-lb-usage.yaml
	# curl localhost:8000/foo-or-bar-lb

remove-dummy-lb-ingress:
	kubectl delete -n default ingress example-ingress
	kubectl delete -n default service foo-service
	kubectl delete -n default pod bar-app
	kubectl delete -n default pod foo-app

# https://adamtheautomator.com/postgres-to-kubernetes/#Deploying_PostgreSQL_to_Kubernetes_Manually
# we must have a per
postgres:
	kubectl apply -f examples/postgres/postgres-configmap.yaml
	# kubectl get configmap
	kubectl apply -f examples/postgres/postgres-volume.yaml
	# kubectl get pv
	kubectl apply -f examples/postgres/postgres-pvc.yaml
	# kubectl get pvc
	kubectl apply -f examples/postgres/postgres-deployment.yaml
	# kubectl get deployments
	# kubectl get pods
	kubectl apply -f examples/postgres/postgres-service.yaml
	# kubectl get svc
	# POD=$$(kubectl get pod -l app=postgres -o jsonpath="{.items[0].metadata.name}")
	# kubectl exec -it $${POD} -- psql -h localhost -U appuser --password -p 5432 appdb
	# kubectl logs -f $${POD}

remove-postgres:
	kubectl delete -n default service postgres
	kubectl delete -n default deployment postgres
	kubectl delete persistentvolumeclaim postgres-volume-claim
	kubectl delete persistentvolume postgres-volume
	kubectl delete -n default configmap postgres-secret

# the shell will run in the background if kubectl is down - so delete the pod when quitting :)
k8sshell:
	# apt update
	# apt install -y iputils-ping
	# apt install -y postgresql-client
	# psql -h postgres -U appuser --password -p 5432 appdb
	kubectl run --stdin --tty k8sshell --image=ubuntu:22.04 --command -- /bin/bash
	kubectl delete pod k8sshell

webapp:
	cd examples/webapp && make build
	kind load docker-image localhost:5001/webapp:latest
	kubectl apply -f examples/webapp/webapp.yaml
	# curl localhost:8000/webapp

remove-webapp:
	kubectl delete -n default ingress webapp-ingress
	kubectl delete -n default service webapp-service
	kubectl delete -n default pod webapp