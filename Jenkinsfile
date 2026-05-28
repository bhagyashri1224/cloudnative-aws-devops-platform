pipeline {

    agent any

    environment {

        IMAGE_NAME = "cloudnativeapp"
        IMAGE_TAG = "v1"
        DOCKERHUB_USERNAME = "bhagyashribari"
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')

    }

    stages {

        stage('Checkout') {

            steps {

                git branch: 'dev', url: 'https://github.com/bhagyashri1224/cloudnative-aws-devops-platform.git'
            }
        }

        stage('Build Docker Image') {

            steps {

                sh 'docker build -t cloudnativeapp:v1 .'
            }
        }

        stage('Unit Testing'){
       steps  {

               sh 'pytest app/'
            }
        }

        stage('SonarQube Analysis'){
       steps  {

               sh 'sonar-scanner'
            }
        }
        stage('Trivy Scan'){
       steps  {

               sh 'trivy image docker.io/bhagyashribari/cloudnativeapp:v1'
            }
        }

         stage('Push to Docker Hub') {

            steps {

                sh''' 
                echo $DOCKERHUB_CREDENTIALS | \ docker login \ --username $DOCKERHUB_CREDENTIALS_USR \ --password-stdin
                '''

                sh'''
                docker tag $IMAGE_NAME:v1 \ $DOCKERHUB_USERNAME/$IMAGE_NAME:v1
                '''
                sh'''
                docker push \
                $DOCKERHUB_USERNAME/$IMAGE_NAME:v1
                '''
                post{

                    always{
                        sh 'docker logout'
                    }
                }


                }
            }
        }

        stage('Host App Locally') {

            steps {

                sh '''
              docker rm -f $(docker ps -aq)
              docker run -d --name cloudnativeapp -p 5000:5000 docker.io/${DOCKERHUB_REPO}:${IMAGE_TAG}
                '''
            }
        }

    }
}