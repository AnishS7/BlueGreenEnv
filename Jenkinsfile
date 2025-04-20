pipeline {
  agent any
  stages {
    stage('Checkout') {
      steps { checkout scm }
    }
    stage('Build & Deploy') {
      steps {
        // Ensure docker CLI access and script perms
        sh 'chmod +x deploy.sh'
        // Run the blue‑green swap
        sh './deploy.sh'
      }
    }
  }
}
