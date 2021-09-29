package datadog.lbe;

import org.apache.log4j.Logger;

class Log4j {

    final static Logger logger = Logger.getLogger(App.INSTRUMENTED_LOGS);

    public void log() {
        logger.info("Logging with log4j");
    }
}
