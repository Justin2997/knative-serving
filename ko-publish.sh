#!/bin/bash
crane image docker.appdirect.tools/appdirect-hello-world-function/hello-world-nodejs-function:latest

ko publish github.com/knative/serving/cmd/controller