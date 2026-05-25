pipeline {

    agent any

    environment {
        IMAGE_NAME        = "cloudnativeapp"
        DOCKERHUB_REPO    = "bhagyashribari/cloudnativeapp"
        IMAGE_TAG         = "v1"
        CONTAINER_NAME    = "cloudnativeapp"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'dev',
                    url: 'https://github.com/bhagyashri1224/cloudnative-aws-devops-platform.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                docker build -t ${DOCKERHUB_REPO}:${IMAGE_TAG} .
                """
            }
        }

        stage('Unit Testing') {
            steps {
                sh """
                pytest app/
                """
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKERHUB_USERNAME',
                        passwordVariable: 'DOCKERHUB_PASSWORD'
                    )
                ]) {

                    sh """
                    echo "\$DOCKERHUB_PASSWORD" | docker login -u "\$DOCKERHUB_USERNAME" --password-stdin

                    docker push ${DOCKERHUB_REPO}:${IMAGE_TAG}

                    docker logout
                    """
                }
            }
        }

        stage('Run Container') {
            steps {
                sh """
                docker stop ${CONTAINER_NAME} || true
                docker rm ${CONTAINER_NAME} || true

                docker run -d \
                    -p 5000:5000 \
                    --name ${CONTAINER_NAME} \
                    ${DOCKERHUB_REPO}:${IMAGE_TAG}

                echo "Application hosted on http://localhost:5000"
                """
            }
        }
    }

    post {

        success {
            echo 'Pipeline executed successfully!'
        }

        failure {
            echo 'Pipeline failed!'
        }

        always {
            cleanWs()
        }
    }
}