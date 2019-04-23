#!/usr/bin/env groovy
@Library('jenkins-shared-library') _

def CREDENTIALS_ARTIFACTORY = 'jenkins-artifactory-credentials'
def CREDENTIALS_GITHUB = 'jenkins-github'

def DOCKER_REGISTRY = 'docker.appdirect.tools'
def IMAGE_NAME = 'appdirect-knative-controller'
def PROJECT_DIR = 'knative-serving'
def CREDENTIALS_DOCKER_RW = 'docker-rw'

def ciImage

def withDockerNode(image, body) {
    image.inside {
        body()
    }
}

pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
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
        }

        stage('Read version') {
            steps {
                script {
                    env.VERSION = readVersion(projectDir)
                }
            }
        }

        stage('Setup') {
            steps {
                script {
                    sh "echo 'Setup stage'"
                    // Docker Artifactory login
                    withCredentials([
                            [$class          : 'UsernamePasswordMultiBinding', credentialsId: CREDENTIALS_DOCKER_RW,
                            usernameVariable: 'DOCKER_RW_USER',
                            passwordVariable: 'DOCKER_RW_PASSWD']
                    ]) {
                        echo 'Docker Registry Login'
                        sh "docker login --username ${DOCKER_RW_USER} --password ${DOCKER_RW_PASSWD} ${DOCKER_REGISTRY}"
                    }
                }
            }
        }

        stage('Build') {
            steps {
                script {
                    ciImage = docker.build "${DOCKER_REGISTRY}/${PROJECT_DIR}/${IMAGE_NAME}:${VERSION}"
                }
            }
        }

        stage('Deploy') { 
            steps {
                script {
                    sh "echo 'Setup Deploy'"
                    withDockerNode(ciImage) {
                        withCredentials([
                                [$class: 'UsernamePasswordMultiBinding', credentialsId: CREDENTIALS_DOCKER_RW,
                                usernameVariable: 'DOCKER_RW_USER',
                                passwordVariable: 'DOCKER_RW_PASSWD']
                        ]) {
                            echo 'Docker Registry Login'
                            sh "docker login --username ${DOCKER_RW_USER} --password ${DOCKER_RW_PASSWD} ${DOCKER_REGISTRY}"
                            sh "crane pull docker.appdirect.tools/appdirect-hello-world-function/hello-world-nodejs-function out.tar && crane push out.tar docker.appdirect.tools/appdirect-hello-world-function/hello-world-nodejs-function"
                            sh '''
                                echo $GOPATH
                                ko publish github.com/knative/serving/cmd/controller
                                '''
                        }
                    }
                }
            }
        }
    }
}