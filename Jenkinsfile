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
                sh "docker build -t ${DOCKERHUB_REPO}:${IMAGE_TAG} ."
            }
        }

        stage('Unit Testing') {
            steps {
                sh "docker run --rm ${DOCKERHUB_REPO}:${IMAGE_TAG} pytest -q"
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    if (sh(script: 'command -v sonar-scanner >/dev/null 2>&1', returnStatus: true) == 0) {
                        sh 'sonar-scanner'
                    } else {
                        echo 'sonar-scanner not installed; skipping SonarQube Analysis'
                    }
                }
            }
        }

        stage('Trivy Scan') {
            steps {
                script {
                    if (sh(script: 'command -v trivy >/dev/null 2>&1', returnStatus: true) == 0) {
                        sh "trivy image ${DOCKERHUB_REPO}:${IMAGE_TAG}"
                    } else {
                        echo 'trivy not installed; skipping vulnerability scan'
                    }
                }
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