# Red Hat OpenShift Container Platform v4

![2.10.1](https://img.shields.io/badge/Datadog%20chart-2.10.1-632ca6?labelColor=f0f0f0&logo=Helm&logoColor=0f1689)
![7.30.0](https://img.shields.io/badge/Agent-7.30.0-632ca6?&labelColor=f0f0f0&logo=Datadog&logoColor=632ca6)
![1.14.0](https://img.shields.io/badge/Cluster%20Agent-1.14.0-632ca6?labelColor=f0f0f0&logo=Datadog&logoColor=632ca6)
![4.8.5](https://img.shields.io/badge/Open%20Shift-4.8.5-ee0000?labelColor=f0f0f0&logo=Red%20Hat%20Open%20Shift&logoColor=ee0000)

All yaml snippets below are expected to be **propertly merged** into the main `values.yaml`.

Also tested with [Azure Red Hat OpenShift](https://azure.microsoft.com/en-us/services/openshift/) 4.7.21.

Deploying Datadog will require an [SCC](https://docs.openshift.com/container-platform/4.5/authentication/managing-security-context-constraints.html). Use the snippet below to have our Helm chart [apply it](https://docs.datadoghq.com/integrations/openshift/?tab=helm#configuration).

```yaml
agents:
  podSecurity:
    securityContextConstraints:
      create: true
```

We currently ignore certificate validation since OpenShift uses different CAs for master and worker nodes<sup>1</sup>.

```yaml
datadog:
  kubelet:
    tlsVerify: false
```

If the OpenShift is running on a supported cloud provider, you should run the agent on the host network. Access to metadata servers from the PODs network is restricted. It will permit the agent to retrieve metadata information about the host from the cloud provier.

```yaml
agents:
  useHostNetwork: true
```

## Control Plane

OpenShift uses the same image for different components of the Control Plane. Datadog's default Control Plane monitoring uses image names to detect services, which presents a challenge here. It might be possible to update OpenShift's Control Plane deployment to include [Autodiscovery annotations](https://docs.datadoghq.com/agent/kubernetes/integrations/?tab=kubernetes#configuration) to automatically detect and start monitoring control plane services. However, many organizations do not want to change their Control Plane deployment.
OpenShift exposes the Control Plane services as services so we can monitor using [cluster checks](https://docs.datadoghq.com/agent/cluster_agent/clusterchecks/#static-configurations-in-files) for simplicity.

```yaml
clusterAgent:
  confd:
    kube_controller_manager.yaml: |-
      cluster_check: true
      init_config:
      instances:
        - prometheus_url: https://kube-controller-manager.openshift-kube-controller-manager/metrics
          ssl_verify: false
          bearer_token_auth: true
          leader_election: false
    kube_scheduler.yaml: |-
      cluster_check: true
      init_config:
      instances:
        - prometheus_url: https://scheduler.openshift-kube-scheduler/metrics
          ssl_verify: false
          bearer_token_auth: true
    kube_apiserver_metrics.yaml: |-
      cluster_check: true
      init_config:
      instances:
        - prometheus_url: https://apiserver.openshift-kube-apiserver/metrics
          ssl_verify: false
          bearer_token_auth: true
    coredns.yaml: |-
      cluster_check: true
      init_config:
      instances:
        - prometheus_url: https://dns-default.openshift-dns:9154/metrics
          ssl_verify: false
          bearer_token_auth: true
```

<sup>1</sup> The CA below works for workers but not master nodes.

```yaml
# For later...
    - name: DD_KUBELET_CLIENT_CA
      value: "/etc/kubernetes/kubelet-ca.crt"
```