FROM golang:1.10.3-alpine3.8
MAINTAINER Platform team <platformdev@appdirect.com>
LABEL version="1.0"

RUN apk update
RUN apk add curl
RUN apk add docker
RUN apk add git
                               
RUN curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
RUN go get github.com/google/ko/cmd/ko
RUN go get github.com/justin2997/go-containerregistry/cmd/crane

ARG KO_DOCKER_REPO=docker.appdirect.tools 
ENV KO_DOCKER_REPO=$KO_DOCKER_REPO

WORKDIR $GOPATH/src/github.com/knative/serving
COPY . .
COPY ko-publish.sh /ko-publish.sh

ENTRYPOINT [ "sh", "./ko.publish.sh" ]