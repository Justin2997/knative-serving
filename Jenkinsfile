#!/usr/bin/env groovy
def projectName = "knative-serving"
def projectDir = "src/github.com/AppDirect/${projectName}"

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
                env.VERSION = readVersion(projectDir)
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
                    image.run("-it -v /var/run/docker.sock:/var/run/docker.sock")
                }
            }
        }
    }
}
