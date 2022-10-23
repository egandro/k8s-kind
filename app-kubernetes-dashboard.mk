# https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md
dashboard-user:
	kubectl apply -f apps/dashboard/admin-user.yaml
	kubectl apply -f apps/dashboard/role.yaml
	kubectl -n kubernetes-dashboard create token admin-user > token

# https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/
dashboard-install:
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.1/aio/deploy/recommended.yaml

dashboard: dashboard-install dashboard-user

dashboard-connect: dashboard
	@echo open your browser at http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
	@echo token: $$(cat ./token)
	kubectl proxy