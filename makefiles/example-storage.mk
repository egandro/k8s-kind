# https://github.com/kubernetes-sigs/kind/blob/main/site/static/examples/config-with-mounts.yaml
#
# https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/
# 	kubectl apply -f https://k8s.io/examples/pods/storage/pv-volume.yaml
#	kubectl apply -f https://k8s.io/examples/pods/storage/pv-claim.yaml
#	kubectl apply -f https://k8s.io/examples/pods/storage/pv-pod.yaml

example-storage:
	kubectl apply -f examples/storage/storage-shared-volume.yaml
	kubectl apply -f examples/storage/storage-worker-volume.yaml
	kubectl apply -f examples/storage/storage-shared-claim.yaml
	kubectl apply -f examples/storage/storage-worker-claim.yaml
	kubectl apply -f examples/storage/storage-pod.yaml
	#kubectl exec -it storage-pod -- /bin/bash
	#kubectl exec -it storage-pod -- /bin/ls -la /storage/shared /storage/worker

remove-example-storage:
	kubectl delete -n default pod storage-pod
	kubectl delete persistentvolumeclaim storage-shared-claim
	kubectl delete persistentvolumeclaim storage-worker-claim
	kubectl delete persistentvolume storage-shared-volume
	kubectl delete persistentvolume storage-worker-volume