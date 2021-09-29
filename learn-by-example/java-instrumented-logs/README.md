# Instrumented Logs

This simple app demostrates Datadog capabilities of auto instrumenting log4j, log4j2, and slf4j.

:warning: **Log4j** instrumentation is not automatically detected by standard pipelines.  Simplest way is to edit [Preprocessing for JSON logs](https://app.datadoghq.com/logs/pipelines/remapping) and add `mdc.dd.trace_id` to `Trace Id attributes`.
