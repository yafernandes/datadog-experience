# AKS - Azure Kubernetes Service

![3.6.2](https://img.shields.io/badge/Datadog%20chart-2.28.13-632ca6?labelColor=f0f0f0&logo=Helm&logoColor=0f1689)
![7.40.0](https://img.shields.io/badge/Agent-7.32.4-632ca6?&labelColor=f0f0f0&logo=Datadog&logoColor=632ca6)
![1.22.4](https://img.shields.io/badge/AKS-1.22.4-0080ff?labelColor=f0f0f0&logo=Microsoft%20Azure&logoColor=0080ff)

All yaml snippets below are expected to be **propertly merged** into the main `values.yaml`.

## [Adimission Controller](https://docs.datadoghq.com/containers/kubernetes/distributions/?tab=helm#AKS)

Admission Controller functionality on AKS requires configuring the add selectors to prevent an error on reconciling the webhook.

```yaml
providers:
  aks:
    enabled: true
```


## Control Plane

PassS services like AKS do not give us access to control plane nodes. Since we cannot deploy agents to control plane nodes, we cannot leverage [Autodiscovery](https://docs.datadoghq.com/agent/kubernetes/integrations/?tab=kubernetes) to automatically detect and start monitoring control plane services.
AKS exposes the Kubernetes API as a service we can monitor using [cluster checks](https://docs.datadoghq.com/agent/cluster_agent/clusterchecks/#static-configurations-in-files) for simplicity.

```yaml
clusterAgent:
  confd:
    kube_apiserver_metrics.yaml: |-
      cluster_check: true
      init_config:
      instances:
        - prometheus_url: https://kubernetes.default/metrics
          ssl_ca_cert: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
          bearer_token_auth: true
```

## kubelet - [kubelet.d/conf.yaml](https://github.com/DataDog/integrations-core/blob/master/kubelet/datadog_checks/kubelet/data/conf.yaml.example)

If `tlsVerify: false` is not acceptable, you can specify the host and CA for the kubelet.

```yaml
datadog:
  kubelet:
    host:
      valueFrom:
        fieldRef:
          fieldPath: spec.nodeName
    hostCAPath: /etc/kubernetes/certs/kubeletserver.crt
```

## Windows deployments

Kubernetes deployments with Windows nodes will required a second daemonset, for the Windows nodes. This second daemonset should join the existing Agent Cluster deployed by the Linux daemonset, deployed under the same namespace. Make sure `tokenSecretName` and `serviceName` below contain the correct resource names.

```yaml
targetSystem: windows
existingClusterAgent:  
  join: true
  tokenSecretName: datadog-cluster-agent
  serviceName: datadog-cluster-agent
```

### Windows nodes hostname

Docker is still used for Windows nodes on AKS. Datadog agent hostname for Docker is just the node name, without sufixing it with the cluster name. In order to avoid duplicated hostnames across clusters, you should merge the section below to the Windows daemonset deployment. There is not need to do it for the Linux daemonset since it uses containerd as container runtime.

```yaml
datadog:
  env:
    - name: DD_NODE_NAME
      valueFrom:
        fieldRef:
          fieldPath: spec.nodeName
    - name: DD_HOSTNAME
      value: $(DD_NODE_NAME)-$(DD_CLUSTER_NAME)
clusterAgent:
  env:
    - name: DD_NODE_NAME
      valueFrom:
        fieldRef:
          fieldPath: spec.nodeName
    - name: DD_HOSTNAME
      value: $(DD_NODE_NAME)-$(DD_CLUSTER_NAME)

```
