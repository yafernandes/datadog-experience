package datadog.lbe.kafka.client;

import java.time.Duration;
import java.util.Arrays;
import java.util.Collections;

import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;

public class Bridge extends KafkaClient {

    private String topicIn;
    private String topicOut;

    public Bridge(String bootstrap, String bridge) {
        setBootstrap(bootstrap);
        String[] topics = bridge.split(":");
        if (topics.length != 2) {
            throw new RuntimeException("Invalid bridge format.");
        }

        this.topicIn = topics[0];
        this.topicOut = topics[1];
        logger.info("Bridging topics " + topicIn + " and " + topicOut);
    }

    @Override
    public void run() {
        try (KafkaConsumer<String, String> consumer = new KafkaConsumer<String, String>(getConsumerProperties());
                KafkaProducer<String, String> producer = new KafkaProducer<String, String>(getProducerProperties())) {
            consumer.seekToEnd(Collections.emptyList());
            consumer.subscribe(Arrays.asList(topicIn));
            while (true) {
                ConsumerRecords<String, String> records = consumer.poll(Duration.ofDays(1));
                for (ConsumerRecord<String, String> inRecord : records) {
                	String payload = inRecord.value();
                	if (payload.length() > PAYLOAD.length()) {
                		payload = payload.substring(0, PAYLOAD.length());
                	}
                    ProducerRecord<String, String> outRecord = new ProducerRecord<String, String>(topicOut,
                            payload);
                    sleep();
                    logger.info("Passing message with content [" + payload + "]");
                    producer.send(outRecord);
                }
            }
        }
    }

}
