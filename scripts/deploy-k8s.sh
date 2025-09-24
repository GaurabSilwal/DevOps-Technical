#!/bin/bash

set -e

echo "Deploying to Kubernetes..."
echo "Using context: $(kubectl config current-context)"

# Deploy all resources
kubectl apply -f k8s/

# Wait for database
echo "Waiting for database..."
kubectl wait --for=condition=ready pod -l app=postgres -n microservices --timeout=300s

# Wait for services
echo "Waiting for services..."
kubectl rollout status deployment/api-service -n microservices --timeout=300s
kubectl rollout status deployment/frontend-service -n microservices --timeout=300s

echo "✅ Deployment completed!"
echo "Access: http://localhost:30080"
kubectl get pods -n microservices