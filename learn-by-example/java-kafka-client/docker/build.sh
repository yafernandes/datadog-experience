#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

cd ..
./gradlew assemble
docker build -t yaalexf/kafka-client -f docker/Dockerfile .
docker push yaalexf/kafka-client
cd -
