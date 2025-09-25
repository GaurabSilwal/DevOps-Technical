#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
    else
        print_error "Unsupported OS: $OSTYPE. Only Linux is supported."
        exit 1
    fi
    print_status "Detected OS: $OS"
}

# Install Docker
install_docker() {
    if command -v docker >/dev/null 2>&1; then
        print_success "Docker already installed"
        return 0
    fi
    
    print_status "Installing Docker..."
    
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
    
    print_success "Docker installed"
}

# Install kubectl
install_kubectl() {
    if command -v kubectl >/dev/null 2>&1; then
        print_success "kubectl already installed"
        return 0
    fi
    
    print_status "Installing kubectl..."
    
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
    
    print_success "kubectl installed"
}

# Check Docker and Kubernetes
check_docker_k8s() {
    if docker info >/dev/null 2>&1; then
        print_success "Docker is running"
        
        # Check for any available Kubernetes context
        if kubectl config get-contexts >/dev/null 2>&1; then
            print_success "Kubernetes is available"
        else
            print_warning "No Kubernetes context found"
            print_info "You may need to setup a local Kubernetes cluster"
        fi
    else
        print_error "Docker is not running"
        return 1
    fi
}

# Install Node.js
install_nodejs() {
    if command -v node >/dev/null 2>&1; then
        NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
        if [ "$NODE_VERSION" -ge 18 ]; then
            print_success "Node.js already installed ($(node --version))"
            return 0
        fi
    fi
    
    print_status "Installing Node.js..."
    
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
    
    print_success "Node.js installed"
}

# Install Python
install_python() {
    if command -v python3 >/dev/null 2>&1; then
        PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1-2)
        if [ "$(echo "$PYTHON_VERSION >= 3.11" | bc -l 2>/dev/null || echo 0)" -eq 1 ]; then
            print_success "Python already installed ($(python3 --version))"
            return 0
        fi
    fi
    
    print_status "Installing Python 3.11..."
    
    sudo apt-get update
    sudo apt-get install -y python3.11 python3.11-pip
    
    print_success "Python installed"
}

# Install Make
install_make() {
    if command -v make >/dev/null 2>&1; then
        print_success "Make already installed"
        return 0
    fi
    
    print_status "Installing Make..."
    
    sudo apt-get update
    sudo apt-get install -y build-essential
    
    print_success "Make installed"
}

# Main function
main() {
    echo "🛠️  Prerequisites Installation Script"
    echo "===================================="
    echo
    
    detect_os
    
    print_status "Installing prerequisites for microservices deployment..."
    echo
    
    install_docker
    install_kubectl
    check_docker_k8s
    install_nodejs
    install_python
    install_make
    
    echo
    print_success "🎉 All prerequisites installed successfully!"
    echo
    print_status "Next steps:"
    echo "  1. Restart your terminal (or run 'source ~/.bashrc')"
    echo "  2. Start Docker service"
    echo "  3. Setup local Kubernetes (minikube or kind)"
    echo "  4. Run './scripts/deploy-all.sh' to deploy the application"
    echo
    print_status "Verify installation:"
    echo "  docker --version"
    echo "  kubectl version --client"

    echo "  node --version"
    echo "  python3 --version"
}

main "$@"