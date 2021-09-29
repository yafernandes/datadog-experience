package datadog.lbe.kafka.client;

import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;

public class Producer extends KafkaClient {

    private final String topic;

    public Producer(final String bootstrap, final String topic) {
        setBootstrap(bootstrap);
        this.topic = topic;
    }

    @Override
    public void run() {
        try (KafkaProducer<String, String> producer = new KafkaProducer<String, String>(getProducerProperties())) {
            while (true) {
            	String payload = PAYLOAD;
                final ProducerRecord<String, String> outRecord = new ProducerRecord<String, String>(topic, payload);
                logger.info("Sending message with content [" + payload + "]");
                sleep();
                producer.send(outRecord);
                sleep(5000);
            }
        }
    }
}
