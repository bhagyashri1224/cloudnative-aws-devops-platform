pipeline {

    agent any

    environment {
        IMAGE_NAME = "cloudnativeapp"
        IMAGE_TAG = "v1"
        DOCKERHUB_REPO = "bhagyashribari/cloudnativeapp"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'dev', url: 'https://github.com/bhagyashri1224/cloudnative-aws-devops-platform.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }

        stage('Unit Testing') {
            steps {
                sh 'pytest app/'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                sh 'sonar-scanner'
            }
        }

        stage('Trivy Scan') {
            steps {
                sh "trivy image ${DOCKERHUB_REPO}:${IMAGE_TAG}"
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                    sh """
                        echo "\$DOCKERHUB_PASSWORD" | docker login --username "\$DOCKERHUB_USERNAME" --password-stdin
                        docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}
                        docker push ${DOCKERHUB_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}
                    """
                }
            }
            post {
                always {
                    sh 'docker logout'
                }
            }
        }

        stage('Host App Locally') {
            steps {
                sh '''
                    docker rm -f $(docker ps -aq) || true
                    docker run -d --name ${IMAGE_NAME} -p 5000:5000 ${DOCKERHUB_REPO}:${IMAGE_TAG}
                '''
            }
        }
    }
}