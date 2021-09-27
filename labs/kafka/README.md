# Kafka

![6.2.1](https://img.shields.io/badge/Confluent-6.2.1-173362?labelColor=f0f0f0&logo=ApacheKafka&logoColor=173362)
![2.8.0](https://img.shields.io/badge/Kafka-2.8.0-000000?labelColor=f0f0f0&logo=ApacheKafka&logoColor=000000)

Deploys [Kafka](https://docs.datadoghq.com/integrations/kafka) and [Zookeper](https://docs.datadoghq.com/integrations/zk) with monitoring enabled, including [Kafka Consumer](https://docs.datadoghq.com/integrations/kafka/#kafka-consumer-integration). The deployment is single node for simplicity.

Kafka will be deployed in the `kafka` namespace, which is automatically created.

```bash
kubectl apply -f kafka.yaml
```

Work based on [Quick Start for Confluent Platform - Community Components (Docker)](https://docs.confluent.io/platform/current/quickstart/cos-docker-quickstart.html)
