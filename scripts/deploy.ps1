Write-Host " Ziraat DevOps Challenge - Kubernetes Deploy Script"

# 1) API Deployment
Write-Host "-> Applying API Deployment..."
kubectl apply -f ../k8s/api-deployment.yaml

# 2) API Service
Write-Host "-> Applying API Service..."
kubectl apply -f ../k8s/api-service.yaml

# 3) Web Deployment
Write-Host "-> Applying Web Deployment..."
kubectl apply -f ../k8s/web-deployment.yaml

# 4) Web Service
Write-Host "-> Applying Web Service..."
kubectl apply -f ../k8s/web-service.yaml

# 5) HPA (Autoscaling) for API
Write-Host "-> Applying API HPA..."
kubectl apply -f ../k8s/api-hpa.yaml

Write-Host "Deploy completed. Use 'kubectl get pods,svc,hpa' to check status."
