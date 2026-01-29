pipeline {
    agent any

    environment {
        // Replace with your Docker Hub username
        DOCKERHUB_USER = 'martins984'
        APP_NAME = 'devops-node-app'
        // This matches the ID you created in Jenkins Credentials
        DOCKERHUB_CREDENTIALS_ID = 'docker-hub-credentials'
    }

    stages {
        stage('Checkout') {
            steps {
                // Get code from the GitHub branch that triggered this
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // Build the image inside the app folder
                    dir('app') {
                        // Tag with the Jenkins Build Number (e.g., v1, v2)
                        sh "docker build -t ${DOCKERHUB_USER}/${APP_NAME}:v${BUILD_NUMBER} ."
                    }
                }
            }
        }

        stage('Login to Docker Hub') {
            steps {
                script {
                    // Securely use the password without revealing it in logs
                    withCredentials([usernamePassword(credentialsId: DOCKERHUB_CREDENTIALS_ID, usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                        sh "echo $PASS | docker login -u $USER --password-stdin"
                    }
                }
            }
        }

        stage('Push Image') {
            steps {
                script {
                    // Push the specific version
                    sh "docker push ${DOCKERHUB_USER}/${APP_NAME}:v${BUILD_NUMBER}"

                    // Also push as 'latest' so it's easy to pull
                    sh "docker tag ${DOCKERHUB_USER}/${APP_NAME}:v${BUILD_NUMBER} ${DOCKERHUB_USER}/${APP_NAME}:latest"
                    sh "docker push ${DOCKERHUB_USER}/${APP_NAME}:latest"
                }
            }
        }

        stage('Cleanup') {
            steps {
                sh "docker logout"
            }
        }
    }
}