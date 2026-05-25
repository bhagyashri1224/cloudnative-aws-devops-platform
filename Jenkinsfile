pipeline {

    agent any

    environment {

        IMAGE_NAME = "cloudnativeapp"

        DOCKERHUB_CREDENTIALS = credentials('dockerhub-creds')

        DOCKERHUB_USERNAME="bhagyashribari"
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

                sh 'pytest app/'
            }
        }

       
        stage('Push to Docker Hub') {

            steps {

                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKERHUB_USERNAME', passwordVariable: 'DOCKERHUB_PASSWORD')]) {
                    sh '''
                    echo "$DOCKERHUB_PASSWORD" | docker login --username "$DOCKERHUB_USERNAME" --password-stdin
                    docker push ${DOCKERHUB_REPO}:${IMAGE_TAG}
                    docker logout
                    '''
                }
            }
        }

        stage('Host App on Local Machine') {

            steps {

                sh '''
                docker stop cloudnativeapp || true
                docker rm cloudnativeapp || true
                docker run -d -p 5000:5000 --name cloudnativeapp ${DOCKERHUB_REPO}:${IMAGE_TAG}
                echo "App hosted on http://localhost:5000"
                '''
            }
        }
    }
}