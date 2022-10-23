# the shell will run in the background if kubectl is down - so delete the pod when quitting :)

# apt update
# apt install -y iputils-ping
# apt install -y postgresql-client
# psql -h postgres -U appuser --password -p 5432 appdb
k8sshell:
	kubectl run --stdin --tty k8sshell --image=ubuntu:22.04 --command -- /bin/bash
	kubectl delete pod k8sshell