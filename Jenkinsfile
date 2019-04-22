#!/usr/bin/env groovy
@Library('jenkins-shared-library') _

def CREDENTIALS_ARTIFACTORY = 'jenkins-artifactory-credentials'
def CREDENTIALS_GITHUB = 'jenkins-github'

def DOCKER_REGISTRY = 'docker.appdirect.tools'
def IMAGE_NAME = 'appdirect-knative-controller'
def CREDENTIALS_DOCKER_RW = 'docker-rw'
def KO_IMAGE = "knative-ko"

def withKoImage(body) {
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
        withMasterBranch {
            withKoImage {
                withCredentials([
                        [$class: 'UsernamePasswordMultiBinding', credentialsId: CREDENTIALS_DOCKER_RW,
                        usernameVariable: 'DOCKER_RW_USER',
                        passwordVariable: 'DOCKER_RW_PASSWD']
                ]) {
                    echo 'Docker Registry Login'
                    sh "docker login --username ${DOCKER_RW_USER} --password ${DOCKER_RW_PASSWD} ${DOCKER_REGISTRY}"
                    sh "export KO_DOCKER_REPO=${DOCKER_REGISTRY}/${IMAGE_NAME}"

                    echo 'Publish docker image build with ko'
                    sh "ko publish github.com/knative/serving/cmd/controller"
                }
            }
        }
    }
}