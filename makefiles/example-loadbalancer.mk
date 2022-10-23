# https://kind.sigs.k8s.io/docs/user/loadbalancer/
# ubectl apply -f https://kind.sigs.k8s.io/examples/loadbalancer/usage.yaml

example-loadbalancer:
	kubectl apply -f examples/loadbalancer/loadbalancer.yaml
	# LB_IP=$$(kubectl get svc/foo-service -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')
	# for _ in {1..10}; do curl $${LB_IP}:5678; done

remove-example-loadbalancer:
	kubectl delete -n default service foo-service
	kubectl delete -n default pod bar-app
	kubectl delete -n default pod foo-app

