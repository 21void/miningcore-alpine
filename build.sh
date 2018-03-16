#!/bin/sh
echo Building 21void/miningcore-alpine:build

docker build --rm -t 21void/miningcore-alpine:build . -f Dockerfile.build

docker container create --name extract 21void/miningcore-alpine:build
docker container cp extract:/tmp/miningcore/build ./dotnetapp
docker container rm -f extract

echo Building 21void/miningcore-alpine:latest

docker build --no-cache -t 21void/miningcore-alpine:latest .
rm -rf ./dotnetapp

