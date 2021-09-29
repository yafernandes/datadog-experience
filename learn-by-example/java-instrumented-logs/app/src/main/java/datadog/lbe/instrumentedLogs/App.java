package datadog.lbe;

import datadog.trace.api.Trace;

public class App {

    static final String INSTRUMENTED_LOGS = "instrumented-logs";

    final static Log4j log4j = new Log4j();
    final static Log4j2 log4j2 = new Log4j2();
    final static Slf4j slf4j = new Slf4j();

    public static void main(String[] args) throws Exception {
        while (true) {
            emitLogs();
            Thread.sleep(15000);
        }
    }

    @Trace(operationName = "emit_logs", resourceName = "emitter")
    private static void emitLogs() {
        log4j.log();
        log4j2.log();
        slf4j.log();
    }
}
