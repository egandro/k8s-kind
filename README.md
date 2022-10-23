# Simple examples of how to use kind during development

- Linux host or something with Linux that runs docker (might also run on a Pi4-64)
- You can access the k8s cluster form outside e.g. developer Windows machine.
- *Warning*: Do not use a public IP of the internet for the API Server
   - read kind documentation about this:
   - <https://kind.sigs.k8s.io/docs/user/configuration/> yellow box

More documentation:

- Kind Quickstart: <https://kind.sigs.k8s.io/docs/user/quick-start/>
- Kind Git: <https://github.com/kubernetes-sigs/kind>


## what you get

- full feature blown developer k8s
- it can expose ports to the host machne
- comes with a local registry
- can be accessed from a development computer e.g. Windows / Mac running a Linux VM or your home Proxmox/ESXi server
- config/examples for ingress, loadbalancers, postgres, persistant volumes
- hello world python app using all of the above

## Install Kind

- install go: https://go.dev/doc/install
- fast lane
```
ARCH=$(dpkg --print-architecture)
case "${ARCH}" in
	amd64) GO_ARCH=amd64;;
	arm64) GO_ARCH=arm64;;
	armhf) GO_ARCH=armv6l;;
	*) echo "unsupported architecture"; exit 1 ;;
esac
GO_LATEST=$(curl -L -s https://golang.org/VERSION?m=text)
GO_INSTALLER=${GO_LATEST}.linux-${GO_ARCH}.tar.gz
sudo wget -c -t0 "https://dl.google.com/go/${GO_INSTALLER}"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf ${GO_INSTALLER}
sudo rm -f ${GO_INSTALLER}
sudo rm -f /etc/profile.d/go-env.sh
sudo /bin/sh -c 'echo "export PATH=\$PATH:/usr/local/go/bin" >> /etc/profile.d/go-env.sh'
sudo /bin/sh -c 'echo "export GOPATH=\$HOME/.golib" >> /etc/profile.d/go-env.sh'
sudo /bin/sh -c 'echo "export PATH=\$PATH:\$GOPATH/bin" >> /etc/profile.d/go-env.sh'
sudo /bin/sh -c 'echo "export GOPATH=\$GOPATH:\$HOME/projects/go" >> /etc/profile.d/go-env.sh'

. /etc/profile.d/go-env.sh
```
- install kind: `go install sigs.k8s.io/kind@{{< stableVersion >}}`
- fastlane
```
get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}
KIND_LATEST=$(get_latest_release kubernetes-sigs/kind)
go install sigs.k8s.io/kind@${KIND_LATEST}
```

## Create the cluster

```
$ make cluster
```

### Feature loadbalancer

```
# metallb takes some time to load - so it's disable by default
$ make feature-loadbalancer
```

### Storage path

```
# default shared volume $(PWD)/data but you can add your own
$ make cluster DATAPATH=/foo/bar
```

### Multiple instances

```
# in case you need multiple instances
$ make cluster DATAPATH=/foo/bar CLUSTER_NAME=my-other-kind REGISTRY_PORT=5003 PUBLIC_HTTP_PORT=8090 PUBLIC_HTTPS_PORT=8091
```

## Applications

Installs the k8s Dashboard. It also creates a user for the dashboard. Kubeclt proxy is used to forward the dashboard.

The dashboard is available here < http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/>. The commmand also shows the required token for a login.

```
$ make dashboard-connect
```

Installs a postgress server with a persistant volume. Full feature blown example with secrets storage and configuration variables. It allows an internal connect with host "postgres".

```
$ make postgres
$ make remove-postgres # kill postgres - but keep persistant storage
```

Runs an ubuntu machine in the cluster for doing all sorts of interessting things e.g. debugging and investigating.

```
$ make k8sshell
```

Builds and runs a python sample application. It connects to postgres and displays the version.

```
$ make postgres # ensure it's running
$ make webapp
$ curl localhost:8000/webapp
$ make remove-webapp # kill the webapp
$ make webapp-replicas # using replicas
$ curl localhost:8000/webapp
$ make remove-webapp # kill the webapp
$ make remove-postgres # we can shut it down
```

## Examples

Simple example showing features.

Persistant storage examples. There is `shared` storage between all nodes and `worker` storage that is per node only.

As default `$(PWD)/data` is used. At cluster create time `DATAPATH` can be used to have a custom directory.

```
$ make example-storage
$ kubectl exec -it storage-pod -- /bin/ls -la /storage/shared /storage/worker
$ make remove-example-storage
```

Ingress is an inverse proxy. This example shows how to expose a pods content to the world device. We use worker node 1 as public device of the kind cluster and have exported these ports as default during kind cration phase:

- `PUBLIC_HTTP_PORT?=8000`
- `PUBLIC_HTTPS_PORT?=8443`

This example starts two pods and puts them in the path `/foo` and `bar` of the public http port.

```
$ make example-ingress
$ curl localhost:8000/foo
$ curl localhost:8000/bar
$ make remove-example-ingress
```

The load balancer offers an internal loadbalancer for a webservice, that is not exposed to a public port.
For reason to make the cluster creation faster, the loadbalancer isn't applyied. You need do to this by `make feature-loadbalancer`.


```
$ make example-loadbalancer
$ make k8sshell
$ # apt update && apt get install curl && curl foo-service:5678
$ # > you see foo / bar cycling
$ make remove-example-loadbalancer
```