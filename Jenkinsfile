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

                        echo "Build API image"
                        docker build -t $DOCKERHUB_USER/hello-ziraat-api:latest ./src/HelloZiraat.Api

                        echo "Push API image"
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
                        echo "Build Web image"
                        docker build -t $DOCKERHUB_USER/hello-ziraat-web:latest ./src/HelloZiraat.Web

                        echo "Push Web image"
                        docker push $DOCKERHUB_USER/hello-ziraat-web:latest
                    """
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                sh '''
                set -e
                echo "Workspace:"
                pwd
                echo "Repo files:"
                ls -la

                echo "k8s folder:"
                ls -la k8s

                echo "Applying Kubernetes manifests..."
                kubectl apply -f k8s/
                '''
                sh '''
                pwd
                ls -la
                ls -la k8s
                '''

                sh """
                echo "Applying Kubernetes manifests..."
                kubectl apply -f k8s/api-deployment.yaml
                kubectl apply -f k8s/api-service.yaml
                kubectl apply -f k8s/web-deployment.yaml
                kubectl apply -f k8s/web-service.yaml
                kubectl apply -f k8s/api-hpa.yaml

                echo "Waiting for API rollout..."
                kubectl rollout status deployment/hello-ziraat-api --timeout=120s
                echo "Waiting for Web rollout..."
                kubectl rollout status deployment/hello-ziraat-web --timeout=120s
                echo "Deployment completed successfully."
                """
            }
        }
    }
    post {
        failure {
            sh """
            echo "Deployment failed. Rolling back..."
            kubectl rollout undo deployment/hello-ziraat-api || true
            kubectl rollout undo deployment/hello-ziraat-web || true
            """
        }
    }
}
