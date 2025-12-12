Write-Host " Ziraat DevOps Challenge - Kubernetes Cleanup Script"

Write-Host "-> Deleting HPA..."
kubectl delete -f ../k8s/api-hpa.yaml --ignore-not-found=true

Write-Host "-> Deleting Web Service..."
kubectl delete -f ../k8s/web-service.yaml --ignore-not-found=true

Write-Host "-> Deleting Web Deployment..."
kubectl delete -f ../k8s/web-deployment.yaml --ignore-not-found=true

Write-Host "-> Deleting API Service..."
kubectl delete -f ../k8s/api-service.yaml --ignore-not-found=true

Write-Host "-> Deleting API Deployment..."
kubectl delete -f ../k8s/api-deployment.yaml --ignore-not-found=true

Write-Host "-> Deleting load-generator pod (if exists)..."
kubectl delete pod load-generator --ignore-not-found=true

Write-Host "Cleanup completed. Use 'kubectl get pods,svc,hpa' to verify."