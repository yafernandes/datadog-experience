# Datadog deployment

## Firewall requirements

- [Firewall requirements](https://docs.datadoghq.com/agent/guide/network/?tab=agentv6v7)
- [Log endpoints](https://docs.datadoghq.com/logs/log_collection/?tab=host#logging-endpoints)
- *.datadog.pool.ntp.org - [NTP Check](https://github.com/DataDog/integrations-core/tree/master/ntp)

## Deployment only firewall requirements

- Agent install
  - s3.amazonaws.com
  - keys.datadoghq.com
  - yum.datadoghq.com
  - keyserver.ubuntu.com
  - apt.datadoghq.com
- Helm
  - [helm.datadoghq.com](https://github.com/DataDog/helm-charts#how-to-use-datadog-helm-repository)
  - [prometheus-community.github.io](https://github.com/DataDog/helm-charts/blob/788ddd6f108b23e0bd9b25da86d0ed464da6d6df/charts/datadog/requirements.yaml#L10)

## Private image repos

- [Agent](https://hub.docker.com/r/datadog/agent) - Check if the jmx variant will be required.
- [Cluster Agent](https://hub.docker.com/r/datadog/cluster-agent)
- [Private Location](https://hub.docker.com/r/datadog/synthetics-private-location-worker)

## Synthetics

[CRX file](https://github.com/DataDog/synthetics-browser-extension)
