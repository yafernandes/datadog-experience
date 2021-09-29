package datadog.lbe;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

class Log4j2 {

	final static Logger logger = LogManager.getLogger(App.INSTRUMENTED_LOGS);

    public void log() {
        logger.info("Logging with log4j2");
    }
}
