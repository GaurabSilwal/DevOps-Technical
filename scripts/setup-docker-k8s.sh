#!/bin/bash

set -e

echo "Setting up Kubernetes cluster..."

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker."
    exit 1
fi

# Check if any Kubernetes context is available
if ! kubectl config get-contexts >/dev/null 2>&1; then
    echo "Error: No Kubernetes context found."
    echo "Please setup a Kubernetes cluster (minikube, kind, or Docker Desktop)"
    exit 1
fi

# Use current context or try common ones
if kubectl config get-contexts | grep -q "docker-desktop"; then
    kubectl config use-context docker-desktop
    echo "Using Docker Desktop Kubernetes"
elif kubectl config get-contexts | grep -q "minikube"; then
    kubectl config use-context minikube
    echo "Using Minikube"
else
    echo "Using current Kubernetes context: $(kubectl config current-context)"
fi

# Wait for cluster to be ready
kubectl wait --for=condition=Ready nodes --all --timeout=60s

echo "Kubernetes setup completed!"
echo "Cluster info:"
kubectl cluster-info