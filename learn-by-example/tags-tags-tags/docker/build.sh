#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

cd ..
./gradlew assemble
docker build -t yaalexf/tags -f docker/Dockerfile .
docker push yaalexf/tags
cd -