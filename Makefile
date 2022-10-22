cluster: cluster-basic cluster-lb

cluster-basic:
	cat template/config.tpl.yaml | sed -e 's|PWD|'$$(pwd)'|g' | sed -e 's/127.0.0.1/'$$(hostname -I | awk '{print $$1}')'/'  > ./config.yaml
	kind create cluster --config=config.yaml
	rm -f config.yaml

# contour https://kind.sigs.k8s.io/docs/user/ingress/
# 8000 / 8443
cluster-ingress:
	kubectl apply -f https://projectcontour.io/quickstart/contour.yaml

# metallb https://kind.sigs.k8s.io/docs/user/loadbalancer/
cluster-lb:
	kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml
	cat template/metallb-config.tpl.yaml| sed -e 's|PREFIX|'$$(docker network inspect -f "{{.IPAM.Config}}" kind | sed -s "s|^\[{||" | sed -s "s|\.0/16.*||")'|g'  > ./metallb-config.yaml
	# wait for metallb to be ready
	sleep 30
	kubectl wait --namespace metallb-system \
					--for=condition=ready pod \
					--selector=app=metallb \
					--timeout=300s
	kubectl apply -f metallb-config.yaml
	rm -f metallb-config.yaml

destroy:
	kind delete cluster

rebuild: destroy cluster

dummy-mount:
	kubectl apply -f https://k8s.io/examples/pods/storage/pv-volume.yaml
	# kubectl get pv task-pv-volume
	kubectl apply -f https://k8s.io/examples/pods/storage/pv-claim.yaml
	# kubectl get pvc task-pv-claim
	kubectl apply -f https://k8s.io/examples/pods/storage/pv-pod.yaml
	#kubectl exec -it task-pv-pod -- /bin/bash
	#ls -la /usr/share/nginx/html

dummy-ingress:
	kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/usage.yaml
	# curl localhost:8000/foo
	# curl localhost:8000/bar

dummy-lb:
	kubectl apply -f https://kind.sigs.k8s.io/examples/loadbalancer/usage.yaml
	# LB_IP=$$(kubectl get svc/foo-service -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')
	# for _ in {1..10}; do curl $${LB_IP}:5678; done

