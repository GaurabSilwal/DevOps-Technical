#!/bin/bash

set -e

echo "🚀 Microservices Deployment"
echo "=========================="

# Parse arguments
DEPLOYMENT_TYPE="kubernetes"
SKIP_BUILD=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --docker) DEPLOYMENT_TYPE="docker"; shift ;;
        --skip-build) SKIP_BUILD=true; shift ;;
        --help)
            echo "Usage: $0 [--docker] [--skip-build]"
            echo "  --docker      Deploy with Docker Compose"
            echo "  --skip-build  Skip building images"
            exit 0 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# Check prerequisites
if ! command -v docker >/dev/null; then echo "Error: Docker not found"; exit 1; fi

if [ "$DEPLOYMENT_TYPE" = "docker" ]; then
    echo "Deploying with Docker Compose..."
    docker compose up --build -d
    echo "✅ Access: http://localhost"
else
    if ! command -v kubectl >/dev/null; then echo "Error: kubectl not found"; exit 1; fi
    
    echo "Deploying to Kubernetes..."
    
    # Setup cluster if needed
    if ! kubectl cluster-info >/dev/null 2>&1; then
        ./scripts/setup-docker-k8s.sh
    fi
    
    # Build images if needed
    if [ "$SKIP_BUILD" = false ]; then
        ./scripts/build-images.sh
    fi
    
    # Deploy
    ./scripts/deploy-k8s.sh
    
    echo "✅ Access: http://localhost:30080"
fi

echo "🎉 Deployment completed!"