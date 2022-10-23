
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

# LB_IP=$(kubectl get svc/foo-service -o=jsonpath='{.status.loadBalancer.ingress[0].ip}')
# for _ in {1..10}; do curl ${LB_IP}:5678; done
dummy-lb:
	kubectl apply -f https://kind.sigs.k8s.io/examples/loadbalancer/usage.yaml

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

