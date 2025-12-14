pipeline {
    agent any

    environment {
        IMAGE_BACKEND = "mohammedhamdy102003/mern-backend:latest"
        IMAGE_FRONTEND = "mohammedhamdy102003/mern-frontend:latest"
        K8S_NAMESPACE = "mern-devops"
    }

    stages {
        stage("Checkout Repo") {
            steps {
                git branch: 'main', url: 'https://github.com/mohammedhamdy102003/mern-auth-devops-full-cycle.git'
            }
        }

        stage("Build Images") {
            steps {
                sh "docker build --no-cache -t $IMAGE_BACKEND ./backend"
                sh "docker build --no-cache -t $IMAGE_FRONTEND ./frontend"
            }
        }

        stage("Security Scan") {
            steps {
                sh "trivy image $IMAGE_BACKEND || true"
                sh "trivy image $IMAGE_FRONTEND || true"
            }
        }

        stage("Push Images to DockerHub") {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-user', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh """
                        echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
                        docker push $IMAGE_BACKEND
                        docker push $IMAGE_FRONTEND
                        docker logout
                    """
                }
            }
        }

        stage("Deploy to Kubernetes") {
            steps {
                withCredentials([string(credentialsId: 'k8s-jenkins-token', variable: 'K8S_TOKEN')]) {
                    sh """
                        export KUBECONFIG=\$(mktemp)
                        kubectl config set-cluster local --server=https://127.0.0.1:6443 --insecure-skip-tls-verify=true
                        kubectl config set-credentials jenkins --token=\$K8S_TOKEN
                        kubectl config set-context jenkins-context --cluster=local --user=jenkins --namespace=$K8S_NAMESPACE
                        kubectl config use-context jenkins-context

                        # Apply manifests
                        kubectl apply -f k8s/namespace/
                        kubectl apply -f k8s/mongo/
                        kubectl apply -f k8s/config/
                        kubectl apply -f k8s/backend/
                        kubectl apply -f k8s/frontend/
                        kubectl apply -f k8s/ingress/

                        # Rollout status
                        kubectl rollout status deployment/backend -n $K8S_NAMESPACE
                        kubectl rollout status deployment/frontend -n $K8S_NAMESPACE
                        kubectl rollout status deployment/mongo -n $K8S_NAMESPACE
                    """
                }
            }
        }

        stage("Post Deployment Checks") {
            steps {
                sh "kubectl get pods -n $K8S_NAMESPACE"
                sh "kubectl get svc -n $K8S_NAMESPACE"
            }
        }
    }

    post {
        always {
            echo "Cleaning up..."
            sh "docker logout || true"
        }
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed. Check logs!"
        }
    }
}


