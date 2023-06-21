# [DogstatsD and Kubernetes](https://docs.datadoghq.com/developers/dogstatsd/?tab=kubernetes)

## Origin detection
Make sure the workload sending metrics has the environment variable `DD_ENTITY_ID` set to `metadata.uid` using [Kubernetes Downward API](https://kubernetes.io/docs/tasks/inject-data-application/environment-variable-expose-pod-information/). You can leverage the [Admission Controler](https://docs.datadoghq.com/containers/cluster_agent/admission_controller/?tab=helm#apm-and-dogstatsd) to automatically inject it. This method works for UDP and [UDS](https://en.wikipedia.org/wiki/Unix_domain_socket), and do not require [datadog.dogstatsd.originDetection: true](https://github.com/DataDog/helm-charts/blob/3e2b248c1cec78b4dd7311fb33a9afe604bea584/charts/datadog/values.yaml#L292-L293).

## [Micrometer](https://micrometer.io/)
The micrometer framework leverages the environment varible `DD_ENTITY_ID` to add the tag `dd.internal.entity_id`. This tags allows the agent to further enrich the metrics with more environment tags.

## Example
Take the deployment below as an example.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dogstatsd
  labels:
    admission.datadoghq.com/enabled: "true"
spec:
  replicas: 3
  selector:
    matchLabels:
      app.kubernetes.io/name: dogstatsd
  template:
    metadata:
      labels:
        app.kubernetes.io/name: dogstatsd
        tags.datadoghq.com/env:  sandbox
        tags.datadoghq.com/service: dogstatsd
        tags.datadoghq.com/version: latest
        admission.datadoghq.com/enabled: "true"
    spec:
      containers:
        - name: toolbox
          image: yaalexf/toolbox:debian
          imagePullPolicy: Always
          command: ["/bin/bash"]
          args:
            - "-c"
            - |
              sleep 15s
              while true
              do
                echo "dogstatsd.sandbox.v1.no_entity_id:1|g" | nc -uw 1 datadog.datadog 8125
                echo "dogstatsd.sandbox.v1.udp:1|g|#dd.internal.entity_id:$DD_ENTITY_ID" | nc -uw 1 datadog.datadog 8125
                echo "dogstatsd.sandbox.v1.uds:1|g|#dd.internal.entity_id:$DD_ENTITY_ID" | nc -Uuw 1 /var/run/datadog/dsd.socket
                sleep 10s
              done
          resources:
            limits: {}

```

These are the assigned tags based on the [cardinality](https://github.com/DataDog/helm-charts/blob/3e2b248c1cec78b4dd7311fb33a9afe604bea584/charts/datadog/values.yaml#L304-L305) set during Datadog deployment.

|tag|no entity_id|low|orchestrator|high|
|---|:---:|:---:|:---:|:---:|
|cluster_name|:white_check_mark:|:white_check_mark:|:white_check_mark:|:white_check_mark:|
|env|:x:|:white_check_mark:|:white_check_mark:|:white_check_mark:|
|kube_app_name|:x:|:white_check_mark:|:white_check_mark:|:white_check_mark:|
|kube_cluster_name|:white_check_mark:|:white_check_mark:|:white_check_mark:|:white_check_mark:|
|kube_deployment|:x:|:white_check_mark:|:white_check_mark:|:white_check_mark:|
|kube_namespace|:x:|:white_check_mark:|:white_check_mark:|:white_check_mark:|
|kube_ownerref_kind|:x:|:white_check_mark:|:white_check_mark:|:white_check_mark:|
|kube_ownerref_name|:x:|:x:|:white_check_mark:|:white_check_mark:|
|kube_qos|:x:|:white_check_mark:|:white_check_mark:|:white_check_mark:|
|kube_replica_set|:x:|:white_check_mark:|:white_check_mark:|:white_check_mark:|
|pod_name|:x:|:x:|:white_check_mark:|:white_check_mark:|
|pod_phase|:x:|:white_check_mark:|:white_check_mark:|:white_check_mark:|
|service|:x:|:white_check_mark:|:white_check_mark:|:white_check_mark:|
|version|:x:|:white_check_mark:|:white_check_mark:|:white_check_mark:|
|host|:white_check_mark:|:white_check_mark:|:white_check_mark:|:white_check_mark:|