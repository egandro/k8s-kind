# https://kind.sigs.k8s.io/docs/user/ingress/
# kubectl get nodes --show-labels
# kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/usage.yaml # nodeSelector missing

example-ingress:
	kubectl apply -f examples/ingress/ingress.yaml
	# curl localhost:8000/foo
	# curl localhost:8000/bar

remove-example-ingress:
	kubectl delete -n default ingress example-ingress
	kubectl delete -n default service bar-service
	kubectl delete -n default service foo-service
	kubectl delete -n default pod bar-app
	kubectl delete -n default pod foo-app
