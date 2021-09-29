#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

cd ..
./gradlew assemble
docker build -t yaalexf/instrumented-logs -f docker/Dockerfile .
docker push yaalexf/instrumented-logs
cd -
