package datadog.lbe;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

class Slf4j {

    private static final Logger logger = LoggerFactory.getLogger(App.INSTRUMENTED_LOGS);

    public void log() {
        logger.info("Logging with slf4j");
    }
}
