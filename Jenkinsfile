#!/usr/bin/env groovy
def projectName = "knative-serving"
def projectDir = "src/github.com/AppDirect/${projectName}"
def image

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

  stage('Read version') {
    env.VERSION = readVersion(projectDir)
  }

  stage('Build') {
    echo "Building image with TAG: ${VERSION}"
    withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: dockerCredentials, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASSWORD']]) {
        dir("${projectDir}") {
            env.DOCKER_CONFIG = "${projectDir}/.docker"
            sh 'docker login -u $DOCKER_USER -p $DOCKER_PASSWORD docker.appdirect.tools'
            image = docker.build "docker.appdirect.tools/${projectName}/${projectName}:${VERSION}"
        }
    }

    always {
        sh 'rm ${projectDir}/.docker/config.json'
    }
  }

  stage('Deploy') {
    echo "Runing ko publish to push the custom controller"
    image.run("-it -v /var/run/docker.sock:/var/run/docker.sock")
  }
}
