FROM golang:1.10.3-alpine3.8
MAINTAINER Platform team <platformdev@appdirect.com>
LABEL version="1.0"

RUN apk update
RUN apk add curl
RUN apk add docker
RUN apk add git
                               
RUN curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh

RUN go get github.com/justin2997/go-containerregistry/cmd/crane
RUN go get github.com/justin2997/ko/cmd/ko

ARG KO_DOCKER_REPO=docker.appdirect.tools
ENV KO_DOCKER_REPO=$KO_DOCKER_REPO

WORKDIR $GOPATH/src/github.com/knative/serving
COPY . .
RUN addgroup -g 1000 gouser
RUN adduser -G gouser -u 1000 gouser -D -h /home/gouser
RUN chown -R 1000:1000 $GOPATH