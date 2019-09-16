#!/bin/bash

docker run -d --name test-pegass -p 8080:8080 test:latest
docker run -d --name some-redis  -p 6379:6379 redis:latest

source ../env.sh
python3 test.py