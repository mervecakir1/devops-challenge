#!/bin/bash

echo ""
echo "pods"
kubectl get pods

echo ""
echo "services"
kubectl get svc

echo ""
echo "HPA"
kubectl get hpa

echo ""
echo " Resource usage of pods"
kubectl top pods

echo ""
echo " Resource usage of node"
kubectl top nodes