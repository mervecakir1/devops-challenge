pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = 'dockerhub-creds'
        DOCKERHUB_USER        = 'mervecakir'
    }

    stages {   
        stage('Checkout') {
            steps {
                echo 'Cloning repository...'
                checkout scm
            }
        }
        stage('Build & Push API Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: DOCKERHUB_CREDENTIALS,
                    usernameVariable: 'DH_USER',
                    passwordVariable: 'DH_PASS'
                )]) {
                    sh """
                        echo "Login to Docker Hub"
                        echo "$DH_PASS" | docker login -u "$DH_USER" --password-stdin

                        docker build -t $DOCKERHUB_USER/hello-ziraat-api:latest ./src/HelloZiraat.Api
                        docker push $DOCKERHUB_USER/hello-ziraat-api:latest
                    """
                }
            }
        }
        stage('Build & Push Web Image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: DOCKERHUB_CREDENTIALS,
                    usernameVariable: 'DH_USER',
                    passwordVariable: 'DH_PASS'
                )]) {
                    sh """
                        docker build -t $DOCKERHUB_USER/hello-ziraat-web:latest ./src/HelloZiraat.Web
                        docker push $DOCKERHUB_USER/hello-ziraat-web:latest
                    """
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                set -e
                kubectl apply -f k8s/
                kubectl rollout status deployment/hello-ziraat-api --timeout=120s
                kubectl rollout status deployment/hello-ziraat-web --timeout=120s
                echo "Deployment completed successfully."
                '''
            }
        }
        stage('Cluster Status'){
            steps {
                sh'''
                bash scripts/cluster-status.sh
                '''
            }
        }
    }
    post {
        failure {
            sh """
            echo "Deployment failed."
            kubectl rollout undo deployment/hello-ziraat-api || true
            kubectl rollout undo deployment/hello-ziraat-web || true
            """
        }
    }
}
