# EKS - Amazon Elastic Kubernetes Service

![2.10.1](https://img.shields.io/badge/Datadog%20chart-2.10.1-632ca6?labelColor=f0f0f0&logo=Helm&logoColor=0f1689)
![7.30.0](https://img.shields.io/badge/Agent-7.30.0-632ca6?&labelColor=f0f0f0&logo=Datadog&logoColor=632ca6)
![1.14.0](https://img.shields.io/badge/Cluster%20Agent-1.14.0-632ca6?labelColor=f0f0f0&logo=Datadog&logoColor=632ca6)
![1.21.1](https://img.shields.io/badge/EKS-1.21.1-ff9900?labelColor=f0f0f0&logo=Amazon%20AWS&logoColor=ff9900)

All yaml snippets below are expected to be **propertly merged** into the main `values.yaml`.

Notes based on:

- EKS 1.21.2
- Helm Chart 2.20.1
- Agent 7.30.0
- Cluster Agent 1.14.0

## Control Plane

PassS services like EKS do not give us access to control plane nodes. Since we cannot deploy agents to control plane nodes, we cannot leverage [Autodiscovery](https://docs.datadoghq.com/agent/kubernetes/integrations/?tab=kubernetes) to automatically detect and start monitoring control plane services.
EKS exposes the Kubernetes API as a service we can monitor using [cluster checks](https://docs.datadoghq.com/agent/cluster_agent/clusterchecks/#static-configurations-in-files) for simplicity.

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
    kube_controller_manager.yaml: |-
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
    hostCAPath: /etc/kubernetes/pki/ca.crt
```
