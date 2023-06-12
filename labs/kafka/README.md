# Kafka

![7.3.3](https://img.shields.io/badge/Confluent-7.3.3-173362?labelColor=f0f0f0&logo=ApacheKafka&logoColor=173362)
![3.3.x](https://img.shields.io/badge/Kafka-3.3.x-000000?labelColor=f0f0f0&logo=ApacheKafka&logoColor=000000)

Deploys [Kafka](https://docs.datadoghq.com/integrations/kafka) and [Zookeper](https://docs.datadoghq.com/integrations/zk) with monitoring enabled, including [Kafka Consumer](https://docs.datadoghq.com/integrations/kafka/#kafka-consumer-integration). The deployment is single node for simplicity.

Kafka will be deployed in the `kafka` namespace, which is automatically created.

```bash
kubectl apply -f kafka.yaml
```

:warn: Kafka is monitored using JMX so it requires the Datadog agent `jmx` [image variante](https://hub.docker.com/r/datadog/agent) for monitoring.

Work based on [Quick Start for Confluent Platform - Community Components (Docker)](https://docs.confluent.io/platform/current/quickstart/cos-docker-quickstart.html)
