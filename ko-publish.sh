#!/bin/bash
crane pull docker.appdirect.tools/appdirect-hello-world-function/hello-world-golang-function:latest out.tar && crane push out.tar docker.appdirect.tools/appdirect-hello-world-function/hello-world-golang-function:latest

ko publish github.com/knative/serving/cmd/controller
docker images ls