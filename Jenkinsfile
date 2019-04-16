#!/usr/bin/env groovy
def projectName = "knative-serving"
def projectDir = "src/github.com/AppDirect/${projectName}"
def image

node('build') {
  stage('Checkout sources') {
    checkoutTo projectDir
  }

  stage('Read version') {
    env.VERSION = readVersion(projectDir)
  }

  stage('Docker build') {
    echo "Building image with TAG: ${VERSION}"
    withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: dockerCredentials, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASSWORD']]) {
        dir("${projectDir}") {
            env.DOCKER_CONFIG = "${projectDir}/.docker"
            sh 'docker login -u $DOCKER_USER -p $DOCKER_PASSWORD docker.appdirect.tools'
            image = docker.build "docker.appdirect.tools/${projectName}/${projectName}:${version}"
        }
    }

    always {
        sh 'rm ${projectDir}/.docker/config.json'
    }
  }

  stage('Run') {
    echo "Runing ko publish to push the custom controller"
    image.run("-it -v /var/run/docker.sock:/var/run/docker.sock")
  }
}
