#!/bin/bash

rm -rf dist
docker build -t go-spider-export .
docker run --name go-spider-export-container go-spider-export
docker cp go-spider-export-container:/src/dist .
docker rm go-spider-export-container
docker rmi go-spider-export
