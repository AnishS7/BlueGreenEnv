pipeline {
  agent any
  environment {
    // Docker registry info
    REGISTRY    = 'docker.io'
    REPO        = 'anish269/bluegreen'
    CREDENTIALS = 'docker-hub-creds'   // the ID of your Jenkins Docker Hub creds
  }
  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build Images') {
      steps {
        // Build both services
        sh 'docker compose build blue green'
      }
    }

    stage('Tag & Push') {
      steps {
        // securely login & push to Docker Hub
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
      // use an image that already has `docker compose` installed
      agent {
        docker {
          image 'docker/compose:2.15.1'
          args  '-v /var/run/docker.sock:/var/run/docker.sock'
        }
      }
      steps {
        sh 'chmod +x deploy.sh'
        sh './deploy.sh'
      }
    }
  }
}
