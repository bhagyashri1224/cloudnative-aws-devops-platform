pipeline {

    agent any

    environment {

        IMAGE_NAME = "cloudnativeapp"
        DOCKERHUB_REPO = "bhagyashribari/cloudnativeapp"

        IMAGE_TAG = "v1"

        
    }

    stages {

        stage('Checkout') {

            steps {

                git branch: 'dev', url: 'https://github.com/bhagyashri1224/cloudnative-aws-devops-platform.git'
            }
        }

        stage('Build Docker Image') {

            steps {

                sh 'docker build -t docker.io/${DOCKERHUB_REPO}:${IMAGE_TAG} .'
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

                sh 'trivy image docker.io/${DOCKERHUB_REPO}:${IMAGE_TAG}'
            }
        }

        stage('Push to Docker Hub') {

            steps {

                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                    sh '''
                    echo "$DOCKERHUB_PASSWORD" | docker login --username "$DOCKERHUB_USERNAME" --password-stdin
                    docker push docker.io/${DOCKERHUB_REPO}:${IMAGE_TAG}
                    '''
                }
            }
        }

        stage('Host App Locally') {

            steps {

                sh '''
                docker rm -f ${IMAGE_NAME} || true
                docker run -d --name ${IMAGE_NAME} -p 5000:5000 docker.io/${DOCKERHUB_REPO}:${IMAGE_TAG}
                '''
            }
        }

        stage('Deploy to EKS') {

            steps {

                sh '''
                kubectl apply -f kubernetes/
                '''
            }
        }
    }
}