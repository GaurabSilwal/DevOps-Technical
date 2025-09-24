#!/bin/bash

set -e

echo "Building Docker images..."

# Build API service
echo "Building api-service..."
docker build -t api-service:latest ./api-service

# Build Worker service
echo "Building worker-service..."
docker build -t worker-service:latest ./worker-service

# Build Frontend service
echo "Building frontend-service..."
docker build -t frontend-service:latest ./frontend-service

echo "All images built successfully!"
docker images | grep -E "(api-service|worker-service|frontend-service)"