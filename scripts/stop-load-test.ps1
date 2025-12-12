Write-Host " Stopping load-generator pod..."

kubectl delete pod load-generator --ignore-not-found=true

Write-Host " load-generator stopped."
