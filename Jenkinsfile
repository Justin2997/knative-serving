#!/usr/bin/env groovy
@Library('jenkins-shared-library') _

def CREDENTIALS_ARTIFACTORY = 'jenkins-artifactory-credentials'
def CREDENTIALS_GITHUB = 'jenkins-github'

def DOCKER_REGISTRY_DEPLOY = 'docker.appdirect.tools'
def DOCKER_REGISTRY_BUILD = 'docker.appdirect.tools'
def IMAGE_NAME = 'appdirect-knative-controller'
def PROJECT_DIR = 'knative-serving'
def CREDENTIALS_DOCKER_RW = 'docker-rw'

def withKoImage(body) {
    def KO_IMAGE = "docker.appdirect.tools/appdirect/knative-ko"
    docker.image(KO_IMAGE).inside {
        body()
    }
}

node {
    stage('Checkout') {
        echo 'Checking out from repository...'
        checkout scm: [
            $class: 'GitSCM',
            branches: scm.branches,
            userRemoteConfigs: scm.userRemoteConfigs,
            extensions: [
                    [$class: 'CloneOption', noTags: false],
                    [$class: 'LocalBranch', localBranch: "**"]
            ]
        ]
        echo sh(returnStdout: true, script: 'env')
    }
 
    stage('Build') { 
        sh "echo 'Setup stage'"
        withKoImage {
            withCredentials([
                    [$class: 'UsernamePasswordMultiBinding', credentialsId: CREDENTIALS_DOCKER_RW,
                    usernameVariable: 'DOCKER_RW_USER',
                    passwordVariable: 'DOCKER_RW_PASSWD']
            ]) {
                echo 'Docker Registry Login'
                env.DOCKER_CONFIG = "$WORKSPACE/.docker"
                sh "export DOCKER_CONFIG=$WORKSPACE/.docker && docker login --username ${DOCKER_RW_USER} --password ${DOCKER_RW_PASSWD} ${DOCKER_REGISTRY_BUILD}"
                env.KO_DOCKER_REPO = "${DOCKER_REGISTRY_BUILD}/${IMAGE_NAME}"

                echo 'Publish docker image build with ko'
                sh "echo $GOPATH"
                sh "crane pull docker.appdirect.tools/appdirect-hello-world-function/hello-world-nodejs-function out.tar && crane push out.tar docker.appdirect.tools/appdirect-hello-world-function/hello-world-nodejs-function"
                sh '''
                    echo $GOPATH
                    mkdir -p $WORKSPACE/go/src/github.com/knative/serving
                    export GOPATH=$WORKSPACE/go
                    cd $GOPATH/src/github.com/knative/serving
                    ls
                    more $GOPATH/src/github.com/knative/serving/cmd/controller/main.go
                    ko publish github.com/knative/serving/cmd/controller
                    '''
            }

            always {
                sh "rm $WORKSPACE/.docker/config.json"
            }
        }
    }

    stage('Deploy'){
        sh "echo 'Deploy the controller'"
        withMasterBranch {
            withKoImage {
                withCredentials([
                        [$class: 'UsernamePasswordMultiBinding', credentialsId: CREDENTIALS_DOCKER_RW,
                        usernameVariable: 'DOCKER_RW_USER',
                        passwordVariable: 'DOCKER_RW_PASSWD']
                ]) {
                    echo 'Docker Registry Login'
                    env.DOCKER_CONFIG = "${PROJECT_DIR}/.docker"
                    sh "docker login --username ${DOCKER_RW_USER} --password ${DOCKER_RW_PASSWD} ${DOCKER_REGISTRY_DEPLOY}"
                    env.KO_DOCKER_REPO = "${DOCKER_REGISTRY_BUILD}/${IMAGE_NAME}"

                    echo 'Publish docker image build with ko'
                    sh "ko resolve -f config/controller.yaml > appdirect-controller.yaml"
                    sh "more appdirect-controller.yaml"
                }

                always {
                    sh "rm ${PROJECT_DIR}/.docker/config.json"
                }
            }
        }
    }
}