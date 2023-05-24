# Red Hat OpenShift Container Platform v4

![3.1.3](https://img.shields.io/badge/Datadog%20chart-3.1.3-632ca6?labelColor=f0f0f0&logo=Helm&logoColor=0f1689)
![7.39.0](https://img.shields.io/badge/Agent-7.39.0-632ca6?&labelColor=f0f0f0&logo=Datadog&logoColor=632ca6)
![4.11.4](https://img.shields.io/badge/Open%20Shift-4.11.4-ee0000?labelColor=f0f0f0&logo=Red%20Hat%20Open%20Shift&logoColor=ee0000)

All yaml snippets below are expected to be **propertly merged** into the main `values.yaml`.

Deploying Datadog will require an [SCC](https://docs.openshift.com/container-platform/4.11/authentication/managing-security-context-constraints.html). Use the snippet below to have our Helm chart [apply it](https://docs.datadoghq.com/integrations/openshift/?tab=helm#configuration).

```yaml
agents:
  podSecurity:
    securityContextConstraints:
      create: true
clusterAgent:
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

## etcd

```bash
kubectl get cm kube-etcd-client-certs -n openshift-monitoring -o json | jq jq '.metadata.namespace = "datadog"' | kubectl create -f -
```

https://github.com/dynatrace-extensions/etcd-for-k8s-control-plane/

```yaml
agents:
  volumeMounts:
    - mountPath: /host/etcd/certs
      name: etcd-certs
  volumes:
    - name: etcd-certs
      configMap:
        name: kube-etcd-client-certs
clusterAgent:
  confd:
    etcd.yaml: |-
      cluster_check: true
      init_config:
      instances:
        - prometheus_url: https://etcd.openshift-etcd:2379/metrics
          ssl_ca_cert: /host/etcd/certs/etcd-client-ca.crt
          ssl_cert: /host/etcd/certs/etcd-client.crt
          ssl_private_key: /host/etcd/certs/etcd-client.key

```

## OpenShift Metrics
Datadog collects [OpenShift metrics](https://docs.datadoghq.com/integrations/openshift/?tab=helm#data-collected) for quotas. No metrics will be collected if there are no quotas. You can use the example below to create one and confirm the metrics.

```yaml
apiVersion: quota.openshift.io/v1
kind: ClusterResourceQuota
metadata:
  name: datadog-quota
spec:
  quota:
    hard:
      pods: "10" 
      requests.cpu: "1" 
      requests.memory: 1Gi 
      limits.cpu: "2" 
      limits.memory: 2Gi 
  selector:
    labels:
      matchLabels:
        kubernetes.io/metadata.name: datadog

```

<sup>1</sup> The CA below works for workers but not master nodes.

```yaml
# For later...
    - name: DD_KUBELET_CLIENT_CA
      value: "/etc/kubernetes/kubelet-ca.crt"
```