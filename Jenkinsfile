pipeline {
  agent any
  environment {
    REGISTRY    = 'docker.io'
    REPO        = 'anish269/bluegreen'
    CREDENTIALS = 'docker-hub-creds'
  }
  stages {
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
}
