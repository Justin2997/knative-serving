#!/bin/bash
ko publish github.com/knative/serving/cmd/controller

docker pull docker.appdirect.tools/appdirect-hello-world-function/hello-world-golang-function
docker push docker.appdirect.tools/appdirect-hello-world-function/hello-world-golang-function

docker images ls