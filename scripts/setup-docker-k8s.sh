#!/bin/bash

set -e

echo "Setting up Kubernetes cluster..."

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker."
    exit 1
fi

# Check if minikube context is available
if ! kubectl config get-contexts | grep -q "minikube"; then
    echo "Error: Minikube context not found."
    echo "Please setup minikube cluster first: minikube start"
    exit 1
fi

# Use minikube context
kubectl config use-context minikube
echo "Using Minikube"

# Wait for cluster to be ready
kubectl wait --for=condition=Ready nodes --all --timeout=60s

echo "Kubernetes setup completed!"
echo "Cluster info:"
kubectl cluster-info