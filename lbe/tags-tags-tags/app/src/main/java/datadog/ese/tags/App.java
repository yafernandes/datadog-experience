package datadog.ese.tags;

import com.timgroup.statsd.NonBlockingStatsDClientBuilder;
import com.timgroup.statsd.StatsDClient;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import datadog.trace.api.Trace;

public class App {

    private static final Logger logger = LoggerFactory.getLogger("lbe");
    private static final StatsDClient statsd = new NonBlockingStatsDClientBuilder().prefix("statsd")
            .hostname(System.getenv().getOrDefault("DD_AGENT_HOST", "localhost")).port(8125).build();

    public static void main(String[] args) throws Exception {
        while (true) {
            myMethod();
            Thread.sleep(5000);
        }
    }

    @Trace(operationName = "myOperation", resourceName = "myResource")
    private static void myMethod() {
        logger.info(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.");
        statsd.recordGaugeValue("lbe.heartbeat", 1, new String[] { "tag-origin:code-statsd" });
    }
}
