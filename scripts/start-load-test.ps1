Write-Host " Starting load-generator pod for API load test..."

# Eski load-generator varsa sil
kubectl delete pod load-generator --ignore-not-found=true > $null

# Yeni load-generator pod'unu oluştur ve API'ye sürekli istek at
kubectl run load-generator `
  --image=busybox `
  --restart=Never `
  -- /bin/sh -c "while true; do wget -q -O- http://hello-ziraat-api-service:11130 > /dev/null; done"

Write-Host " load-generator created. Use 'kubectl get pods' and 'kubectl get hpa' to observe scaling."
