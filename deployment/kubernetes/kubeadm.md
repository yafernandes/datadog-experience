# Kubeadm installs

![2.21.2](https://img.shields.io/badge/Datadog%20chart-2.21.2-632ca6?labelColor=f0f0f0&logo=Helm&logoColor=0f1689)
![7.30.0](https://img.shields.io/badge/Agent-7.30.0-632ca6?&labelColor=f0f0f0&logo=Datadog&logoColor=632ca6)
![1.14.0](https://img.shields.io/badge/Cluster%20Agent-1.14.0-632ca6?labelColor=f0f0f0&logo=Datadog&logoColor=632ca6)
![1.22.0](https://img.shields.io/badge/Kubernetes-1.22.0-326ce5?labelColor=f0f0f0&logo=Kubernetes&logoColor=326ce5)

All the yaml snippets below are expected to be **propertly merged** into the main `values.yaml`.

## etcd - [etcd.d/conf.yaml](https://github.com/DataDog/integrations-core/blob/master/etcd/datadog_checks/etcd/data/conf.yaml.example)

Kubernetes etcd requires PKI certificates for authetication over TLS. The snippet below mounts the necessary certificate location and override the default config. It also assumes that the agent is being scheduled onto etcd nodes.

```yaml
datadog:
  ignoreAutoConfig:
    - etcd
  confd:
    etcd.yaml: |-
      ad_identifiers:
        - etcd
      init_config:
      instances:
        - prometheus_url: https://%%host%%:2379/metrics
          ssl_ca_cert: /host/etc/kubernetes/pki/etcd/ca.crt
          ssl_cert: /host/etc/kubernetes/pki/etcd/peer.crt
          ssl_private_key: /host/etc/kubernetes/pki/etcd/peer.key
agents:
  volumeMounts:
    - mountPath: /host/etc/kubernetes/pki/etcd
      name: etcd-certs
  volumes:
    - name: etcd-certs
      hostPath:
        path: /etc/kubernetes/pki/etcd
        type: DirectoryOrCreate
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
    hostCAPath: /var/lib/kubelet/pki/kubelet.crt
```

## Control Plane

Most recent deployments have `kube-controller-manager` and `kube-scheduler` listening only on `127.0.0.1`. In these cases, the agent will need to run on the host network space so it can access the host loopback interface. It can be done with the changes below.

```yaml
agents:
  useHostNetwork: true
```

Depending on your configuration, some default ports used by the agent might already be in use. Two common conflict I found are ports `5000` and `5001`. We can change these default ports with the changes below. The ports used below, `5010` and `5011`, are suggstions. If they are also being used, just pick any two available ports.

```yaml
agents:
  containers:
    agent:
      env:
        - name: DD_EXPVAR_PORT
          value: "5010" # Default: 5000
        - name: DD_CMD_PORT
          value: "5011" # Default: 5001
```

In case running the agent on the host network space is not acceptable, another option is updating the control plane to listen on `0.0.0.0`.

```bash
sudo sed -i '/--bind-address=127.0.0.1/d' /etc/kubernetes/manifests/kube-scheduler.yaml
sudo sed -i '/--bind-address=127.0.0.1/d' /etc/kubernetes/manifests/kube-controller-manager.yaml
```
