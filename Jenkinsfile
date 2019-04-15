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
                env.DOCKER_CONFIG = "${PROJECT_DIR}/.docker"
                sh "docker login --username ${DOCKER_RW_USER} --password ${DOCKER_RW_PASSWD} ${DOCKER_REGISTRY_BUILD}"

                echo 'Publish docker image build with ko'
                env.KO_DOCKER_REPO = "${DOCKER_REGISTRY_BUILD}/${IMAGE_NAME}"
                sh "cd knative-serving"
                sh "ls"
                sh "ko publish github.com/AppDirect/knative-serving/cmd/controller"
                sh "more appdirect-controller.yaml"
            }

            always {
                sh "rm ${PROJECT_DIR}/.docker/config.json"
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

                    echo 'Publish docker image build with ko'
                    env.KO_DOCKER_REPO = "${DOCKER_REGISTRY_BUILD}/${IMAGE_NAME}"
                    sh "ko publish ./cmd/controller"
                    sh "more appdirect-controller.yaml"
                }

                always {
                    sh "rm ${PROJECT_DIR}/.docker/config.json"
                }
            }
        }
    }
}