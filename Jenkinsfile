pipeline {
  agent any
  options {
    skipDefaultCheckout()
  }
  environment {
    REGISTRY    = 'docker.io'
    REPO        = 'anish269/bluegreen'
    CREDENTIALS = 'docker-hub-creds'
  }
  stages {
    stage('Checkout') {
      steps {
        // Wipe out any leftover files so we get a clean clone
        deleteDir()
        // Clone your GitHub repo into the workspace
        git url: 'https://github.com/AnishS7/BlueGreenEnv.git',
            branch: 'main'
      }
    }

    stage('Build Images') {
      steps {
        sh 'docker compose build blue green'
      }
    }

    stage('Tag & Push') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: "${CREDENTIALS}",
          usernameVariable: 'DOCKER_USER',
          passwordVariable: 'DOCKER_PASS'
        )]) {
          sh '''
            echo $DOCKER_PASS | docker login $REGISTRY -u $DOCKER_USER --password-stdin
            docker tag bluegreenenv-blue:latest  $REPO:blue
            docker tag bluegreenenv-green:latest $REPO:green
            docker push $REPO:blue
            docker push $REPO:green
          '''
        }
      }
    }

    stage('Blue/Green Deploy') {
      steps {
        sh 'chmod +x deploy.sh'
        sh './deploy.sh'
      }
    }
  }

  post {
    success { echo '✅ Deployment succeeded!' }
    failure { echo '❌ Deployment failed—check logs.' }
  }
}
