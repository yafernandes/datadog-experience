package datadog.lbe.kafka.client;

import java.time.Duration;
import java.util.Arrays;
import java.util.Collections;

import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;

public class Consumer extends KafkaClient {

	private String topic;

	public Consumer(String bootstrap, String topic) {
		this.topic = topic;
		setBootstrap(bootstrap);

	}

	@Override
	public void run() {
		try (KafkaConsumer<String, String> consumer = new KafkaConsumer<String, String>(getConsumerProperties())) {
			consumer.subscribe(Arrays.asList(topic));
			consumer.seekToEnd(Collections.emptyList());
			while (true) {
				ConsumerRecords<String, String> records = consumer.poll(Duration.ofDays(1));
				for (ConsumerRecord<String, String> inRecord : records) {
					logger.info("Received message with content [" + inRecord.value() + "]");
				}
			}
		}
	}
}
