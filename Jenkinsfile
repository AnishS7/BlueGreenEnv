pipeline {
  agent any
  options {
    // don’t do the automatic, built‑in checkout
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
        // this does a real 'git clone' into the workspace
        git(
          url: 'https://github.com/AnishS7/BlueGreenEnv.git',
          branch: 'main',
          credentialsId: "${CREDENTIALS}"
        )
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
    success {
      echo '✅ Deployment succeeded!'
    }
    failure {
      echo '❌ Deployment failed. Check the console output for details.'
    }
  }
}
