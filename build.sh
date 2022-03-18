#!/usr/bin/env bash

docker build -f Dockerfile-7.4 . --tag mattiabasone/swingx:7.4
docker build -f Dockerfile-8.0 . --tag mattiabasone/swingx:8.0
docker build -f Dockerfile-8.1 . --tag mattiabasone/swingx:8.1

docker push mattiabasone/swingx:7.4
docker push mattiabasone/swingx:8.0
docker push mattiabasone/swingx:8.1
