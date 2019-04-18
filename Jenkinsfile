#!/usr/bin/env groovy
def projectName = "knative-serving"
def projectDir = "src/github.com/AppDirect/${projectName}"
def CREDENTIALS_DOCKER_RW = 'docker-rw'
def DOCKER_REGISTRY = 'docker.appdirect.tools'

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
            agent {
                dockerfile {
                    filename 'Dockerfile'
                    args '--rm -v /root/.docker/config.json:/.docker/config.json -v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                     script {
                            sh 'echo "Runing ko publish to push the custom controller"'
                            sh 'docker run --rm -v /root/.docker/config.json:/.docker/config.json -v /var/run/docker.sock:/var/run/docker.sock docker.appdirect.tools/${projectName}/${projectName}:${VERSION}'
                    }
                }
            }
        }
    }
}