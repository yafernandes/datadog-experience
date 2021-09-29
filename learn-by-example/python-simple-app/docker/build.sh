#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

cd ..
docker build -t yaalexf/python-simple-app -f docker/Dockerfile .
docker push yaalexf/python-simple-app
cd -