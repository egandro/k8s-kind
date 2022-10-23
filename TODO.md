# TODO

- get rid of makefiles / split in cluster and app creation
- Enable auditing if desired: <https://kind.sigs.k8s.io/docs/user/auditing/>
- Support private registry: <https://kind.sigs.k8s.io/docs/user/private-registries/>
- add kind info make target
    kubectl cluster-info --context kind-kind
    Kubernetes control plane is running at https://xxx:yyy
    CoreDNS is running at https://xxx:yyy/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy