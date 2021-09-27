# Tags-tags-tags

![2.22.6](https://img.shields.io/badge/Datadog%20chart-2.22.6-632ca6?labelColor=f0f0f0&logo=Helm&logoColor=0f1689)
![7.31.0](https://img.shields.io/badge/Agent-7.31.0-632ca6?&labelColor=f0f0f0&logo=Datadog&logoColor=632ca6)
![1.15.0](https://img.shields.io/badge/Cluster%20Agent-1.15.0-632ca6?labelColor=f0f0f0&logo=Datadog&logoColor=632ca6)
![0.87.0](https://img.shields.io/badge/Java%20Agent-0.87.0-632ca6?labelColor=f0f0f0&logo=Datadog&logoColor=632ca6)

The purpose of this application is to explore different ways of attaching tags to your deployments. The example is based on a Kubernetes pod and expects the agent deployment configurations below.

```yaml
datadog:
  nodeLabelsAsTags:
    tags.lbe.datadog.com/tag: tag-origin
  podAnnotationsAsTags:
    tags.lbe.datadog.com/tag: tag-origin
  podLabelsAsTags:
    tags.lbe.datadog.com/tag: tag-origin
  namespaceLabelsAsTags:
    tags.lbe.datadog.com/tag: tag-origin
  tags:
    - tag-origin:agent
```

Add labels to the nodes to visualize `nodeLabelsAsTags`.

```bash
kubectl label nodes <host> tags.lbe.datadog.com/tag=node
```

Deploy it using `kubectl apply -f kubernetes/tags-tags-tags.yaml`.

The image can be rebuild with `docker/build.sh`. Make sure to update the image tag in the `docker/Dockerfile` and `kubernetes/tags-tags-tags.yaml`.

[Traces](https://app.datadoghq.com/apm/traces?query=service%3Adatadog.lbe.tags.app)
[Logs](https://app.datadoghq.com/logs?query=service%3Atags)
