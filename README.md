# Simple examples of how to use kind during development

- Linux host or something with Linux that runs docker (mit also runs on a pi64)
- You can access the k8s cluster form outside e.g. developer Windows machine.
- *Warning*: Do not use a public IP! (read kind documentation about this)

Read this:

- Docs: <https://kind.sigs.k8s.io/docs/user/quick-start/>
- Gitdocs: <https://github.com/kubernetes-sigs/kind>


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

## Host volumes

```
# default shared volume DATAPATH is $(PWD)/data
# make cluster DATAPATH=/foo/bar
```