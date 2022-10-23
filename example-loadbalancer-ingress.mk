# https://kind.sigs.k8s.io/docs/user/loadbalancer/
# ubectl apply -f https://kind.sigs.k8s.io/examples/loadbalancer/usage.yaml

# https://kind.sigs.k8s.io/docs/user/ingress/
# kubectl get nodes --show-labels
# kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/usage.yaml # nodeSelector missing

example-loadbalancer-ingress:
	kubectl apply -f examples/loadbalancer-ingress/loadbalancer-ingress.yaml
	# curl localhost:8000/foo-or-bar-lb

remove-example-loadbalancer-ingress:
	kubectl delete -n default ingress example-ingress
	kubectl delete -n default service foo-service
	kubectl delete -n default pod bar-app
	kubectl delete -n default pod foo-app
