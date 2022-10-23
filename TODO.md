# TODO

- get rid of makefiles / split in cluster and app creation
- Enable auditing if desired: <https://kind.sigs.k8s.io/docs/user/auditing/>
- Support private registry: <https://kind.sigs.k8s.io/docs/user/private-registries/>
- add kind info make target
    kubectl cluster-info --context kind-kind
    Kubernetes control plane is running at https://xxx:yyy
    CoreDNS is running at https://xxx:yyy/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
- configuration handling: don't overwrite $HOME/.kube/config
```
Usage:
  kind create cluster [flags]

Flags:
      --config string       path to a kind config file
  -h, --help                help for cluster
      --image string        node docker image to use for booting the cluster
      --kubeconfig string   sets kubeconfig path instead of $KUBECONFIG or $HOME/.kube/config
```
- yaml template engine: <https://github.com/con2/emrichen>
- python cli sample project <https://github.com/pypa/sampleproject>, <https://github.com/realpython/materials/tree/master/typer-cli-python>