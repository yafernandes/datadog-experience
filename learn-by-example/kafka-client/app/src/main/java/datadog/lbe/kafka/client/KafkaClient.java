package datadog.lbe.kafka.client;

import java.util.Properties;

import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.apache.kafka.common.serialization.StringSerializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public abstract class KafkaClient implements Runnable {

    protected static final String PAYLOAD = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
    protected static final Logger logger = LoggerFactory.getLogger("lbe");

    private String bootstrap;

    protected Properties getProducerProperties() {
        Properties properties = new Properties();
        properties.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrap);
        properties.put(ProducerConfig.CLIENT_ID_CONFIG, getClientId());
        properties.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        properties.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        return properties;
    }

    protected Properties getConsumerProperties() {
        Properties properties = new Properties();
        properties = new Properties();
        properties.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrap);
        properties.put(ConsumerConfig.GROUP_ID_CONFIG, getClientId());
        properties.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        properties.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        properties.put(ConsumerConfig.ALLOW_AUTO_CREATE_TOPICS_CONFIG, "true");
        properties.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, "true");
        properties.put(ConsumerConfig.METADATA_MAX_AGE_CONFIG, "1000");
        properties.put(ConsumerConfig.MAX_POLL_INTERVAL_MS_CONFIG, "900000");
        return properties;
    }

    protected Object getClientId() {
        return System.getenv().getOrDefault("DD_SERVICE", "default");
    }

    protected void sleep(int delay) {
        try {
            Thread.sleep(delay);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

    protected void sleep() {
        sleep(40);
    }

    public String getBootstrap() {
        return bootstrap;
    }

    public void setBootstrap(String bootstrap) {
        this.bootstrap = bootstrap;
    }

}
