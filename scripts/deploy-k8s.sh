#!/bin/bash

set -e

echo "Deploying to Kubernetes..."
echo "Using context: $(kubectl config current-context)"

# Use minikube's Docker daemon
eval $(minikube docker-env)

# Build images in minikube's Docker environment
echo "Building images in minikube..."
docker build -t api-service:latest ./api-service
docker build -t worker-service:latest ./worker-service
docker build -t frontend-service:latest --build-arg REACT_APP_API_URL= ./frontend-service

# Deploy namespace first
kubectl apply -f k8s/namespace.yaml

# Deploy all other resources
kubectl apply -f k8s/ --recursive

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