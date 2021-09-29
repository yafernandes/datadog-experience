# Kafka client

![0.87.0](https://img.shields.io/badge/Java%20Agent-0.87.0-632ca6?labelColor=f0f0f0&logo=Datadog&logoColor=632ca6)
![2.8.0](https://img.shields.io/badge/Kafka%20client-2.8.0-000000?labelColor=f0f0f0&logo=ApacheKafka&logoColor=000000)

The purpose of this application is to explore tracing of asynchronous calls using pub/sub patterns. The example is based on a set Kubernetes deployments acting as producers, bridges (producer and consumer), and consumers exchanging messages using [Kafka](https://kafka.apache.org/intro) queues.

Deploy it using `kubectl apply -f kubernetes/kafka-client.yaml`.

## Requirements

[Kafka](../../labs/kafka)
