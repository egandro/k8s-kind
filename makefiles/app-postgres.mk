
# https://adamtheautomator.com/postgres-to-kubernetes/#Deploying_PostgreSQL_to_Kubernetes_Manually

# kubectl get secret postgres-secrets -o jsonpath='{.data.POSTGRES_USER}'  | base64 -d
# kubectl get configmap
# kubectl get pv
# kubectl get pvc
# kubectl get deployments
# kubectl get pods
# kubectl get svc
# POD=$(kubectl get pod -l app=postgres -o jsonpath="{.items[0].metadata.name}")
# PORT=$(kubectl get pod ${POD} --template='{{(index (index .spec.containers 0).ports 0).containerPort}}{{"\n"}}')
# kubectl exec -it ${POD} -- psql -h localhost -U appuser --password -p 5432 appdb
# kubectl logs -f ${POD}

postgres:
	kubectl apply -f apps/postgres/postgres-secrets.yaml
	kubectl apply -f apps/postgres/postgres-configmap.yaml
	kubectl apply -f apps/postgres/postgres-volume.yaml
	kubectl apply -f apps/postgres/postgres-pvc.yaml
	kubectl apply -f apps/postgres/postgres-deployment.yaml
	kubectl apply -f apps/postgres/postgres-service.yaml

# port forwarding: https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/
postgres-port-forward:
	POD=$$(kubectl get pod -l app=postgres -o jsonpath="{.items[0].metadata.name}") \
	PORT=$$(kubectl get pod $${POD} --template='{{(index (index .spec.containers 0).ports 0).containerPort}}{{"\n"}}') \
	kubectl port-forward deployment/postgres $${PORT}:$${PORT}

remove-postgres:
	kubectl delete -n default service postgres
	kubectl delete -n default deployment postgres
	kubectl delete persistentvolumeclaim postgres-volume-claim
	kubectl delete persistentvolume postgres-volume
	kubectl delete -n default configmap postgres-config
	kubectl delete -n default secret postgres-secrets
