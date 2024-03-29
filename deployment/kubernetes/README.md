# Kubernetes basic monitoring

![3.1.3](https://img.shields.io/badge/Datadog%20chart-3.1.3-632ca6?labelColor=f0f0f0&logo=Helm&logoColor=0f1689)
![7.39.0](https://img.shields.io/badge/Agent-7.39.0-632ca6?&labelColor=f0f0f0&logo=Datadog&logoColor=632ca6)
![1.24.5](https://img.shields.io/badge/Kubernetes-1.24.5-326ce5?labelColor=f0f0f0&logo=Kubernetes&logoColor=326ce5)

## Install

Install [Datadog Helm Chart](https://github.com/DataDog/helm-charts/tree/master/charts/datadog)

```bash
helm repo add datadog https://helm.datadoghq.com
helm repo update
```

Create a namespace for Datadog

```bash
kubectl create ns datadog
```

Create a secret with the [API key](https://app.datadoghq.com/organization-settings/api-keys).

```bash
kubectl create secret generic datadog-keys -n datadog --from-literal=api-key=<API-KEY>
```

Create the `values.yaml` file.

:warning: Make sure to update `datadog.site` if sending data to a different Datadog instance.

```yaml
datadog:
  clusterName: <CLUSTER-NAME>
  apiKeyExistingSecret: datadog-keys
  site: datadoghq.com
  apm:
    portEnabled: true
  logs:
    enabled: true
    containerCollectAll: true
  processAgent:
    processCollection: true
  dogstatsd:
    useHostPort: true
  kubelet:
    tlsVerify: false
  networkMonitoring:
    enabled: true
  securityAgent:
    compliance:
      enabled: true
    runtime:
      enabled: true
agents:
  tolerations:
    - key: node-role.kubernetes.io/control-plane
      operator: Exists
      effect: NoSchedule
    - key: node-role.kubernetes.io/master
      operator: Exists
      effect: NoSchedule
```

All yaml snippets presented from here are expected to be **propertly merged** into the main `values.yaml`.

Check distribution specific notes.  

- [kubeadm/vanilla](kubeadm.md)
- [AKS](aks.md)
- [EKS](eks.md)
- [Red Hat OpenShift Container Platform v4](openshift4.md)

 Deploy with the command below.

```bash
helm install datadog datadog/datadog -n datadog -f values.yaml
```

Complete values file examples can be found [here](examples).

## Proxy

The values in the `DD_PROXY_NO_PROXY` variable are:

- k8s.aws.pipsquack.ca - Hosts domain
- cluster.local - Kubernetes dns zone - `kubectl describe configmap coredns -n kube-system`
- 10.0.0.0/16 - Cluster address space
- 172.16.0.0/12 - Kubernets service address space - `/etc/kubernetes/manifests/kube-controller-manager.yaml`
- 192.168.0.0/16 - Kubernetes pods address space - `/etc/kubernetes/manifests/kube-controller-manager.yaml`

:warning: List is SPACE delimited.

[http_proxy vs HTTP_PROXY](https://about.gitlab.com/blog/2021/01/27/we-need-to-talk-no-proxy/)

## Tips and Tricks

### Testing proper networking for APM

If you are not receiving traces from your application, you can test if the agent and Datadog are reachable with the snippet below.

```bash
curl -X PUT "http://${DD_AGENT_HOST}:8126/v0.3/traces" -v \
-H "Content-Type: application/json" \
-d @- << EOF
[
  [
    {
      "duration": 1500,
      "name": "Some span",
      "resource": "/home",
      "service": "fake-service",
      "span_id": $(($RANDOM * $RANDOM)),
      "start": 0,
      "trace_id": $(($RANDOM * $RANDOM))
    }
  ]
]
EOF
```

### OpenShift

OpenShift [metrics](https://docs.datadoghq.com/integrations/openshift/#metrics) are all about quotas.  The command below must return something for OpenShift specific metrics to show up.

```bash
oc get clusterresourcequotas --all-namespaces
```

### Node Taints

Run the command below to view your [nodes taints](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/).

```bash
kubectl get nodes -o custom-columns=Node:metadata.name,Taints:spec.taints
```

### Misc

[Define Dependent Environment Variables](https://kubernetes.io/docs/tasks/inject-data-application/define-interdependent-environment-variables/)

