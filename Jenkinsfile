#!/usr/bin/env groovy
def projectName = "knative-serving"
def projectDir = "src/github.com/AppDirect/${projectName}"

def DOCKER_REGISTRY = 'docker.appdirect.tools'
def CREDENTIALS_DOCKER_RW = 'docker-rw'
def IMAGE_NAME = 'appdirect-knative-controller'

pipeline {
    agent any
    stages{
        stage('Checkout') {
            steps {
                checkoutTo projectDir
            }
        }

        stage('Read version') {
            steps {
                script {
                    env.VERSION = readVersion(projectDir)
                }
            }
        }

        stage('Build') {
            steps {
                script {
                    echo "Building image with TAG: ${VERSION}"
                    image = docker.build "docker.appdirect.tools/${projectName}/${projectName}:${VERSION}"
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    echo "Runing ko publish to push the custom controller"
                    image.inside {
                        withCredentials([
                            [$class: 'UsernamePasswordMultiBinding', credentialsId: CREDENTIALS_DOCKER_RW,
                            usernameVariable: 'DOCKER_RW_USER',
                            passwordVariable: 'DOCKER_RW_PASSWD']
                        ]) {
                            echo 'Docker Registry Login'
                            sh "docker login --username ${DOCKER_RW_USER} --password ${DOCKER_RW_PASSWD} ${DOCKER_REGISTRY}"
                        }
                    }
                    sh "docker run --rm -v /root/.docker/config.json:/root/.docker/config.json -v /var/run/docker.sock:/var/run/docker.sock docker.appdirect.tools/${projectName}/${projectName}:${VERSION}"
                }
            }
        }
    }
}
