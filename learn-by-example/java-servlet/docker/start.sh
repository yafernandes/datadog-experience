#!/bin/bash
docker pull yaalexf/app-java
docker stop app-java
docker rm app-java
docker run \
  -d \
  --restart unless-stopped \
  --name app-java \
  -p 8080:8080 \
  -e DD_AGENT_HOST=$(hostname -i) \
  -e DD_SERVICE_NAME=app-java \
  -e DD_LOGS_INJECTION=true \
  -e DD_TRACE_ANALYTICS_ENABLED=true \
  -e DD_JDBC_ANALYTICS_ENABLED=true \
  -e DD_TRACE_GLOBAL_TAGS=env:lab \
  -e DD_PROFILING_ENABLED=true \
  -e DD_PROFILING_APIKEY=$DD_API_KEY \
  -l com.datadoghq.ad.logs='[{"source":"jetty","service": "app-java"}]' \
  yaalexf/app-java
# Work in progress
#   -l com.datadoghq.ad.logs='[{"source":"tomcat","service": "happypath","log_processing_rules": [{ "type": "multi_line","name": "new_log_start_with_date","pattern": "\\d{2}-\\w{3}-\\d{4} \\d{2}:\\d{2}:\\d{2}(\\.\\d{1,3})?"},{ "type": "multi_line","name": "json_log","pattern": "{"},{"type": "multi_line","name": "ddtrace_log","pattern": "\[dd\.trace"}]}]' \
