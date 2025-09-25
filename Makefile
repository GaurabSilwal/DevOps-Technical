.PHONY: help docker-up docker-down k8s-up k8s-down logs build clean

help: ## Show available commands
	@echo 'Usage: make [target]'
	@echo '  docker-up   - Deploy with Docker Compose'
	@echo '  docker-down - Stop Docker Compose'
	@echo '  k8s-up      - Deploy to Kubernetes'
	@echo '  k8s-down    - Stop Kubernetes deployment'
	@echo '  logs        - View logs'
	@echo '  build       - Build Docker images'
	@echo '  clean       - Clean everything'

docker-up: ## Deploy with Docker Compose
	@docker compose up --build -d
	@echo "✅ Docker Compose services started: http://localhost"

docker-down: ## Stop Docker Compose
	@docker compose down

k8s-up: ## Deploy to Kubernetes
	@minikube start 2>/dev/null || true
	@./scripts/deploy-all.sh --skip-build
	@echo "✅ Kubernetes deployment completed: http://localhost:30080"

k8s-down: ## Stop Kubernetes deployment
	@kubectl delete namespace microservices 2>/dev/null || true
	@echo "✅ Kubernetes deployment stopped"

logs: ## View logs
	@docker compose logs -f

build: ## Build Docker images
	@./scripts/build-images.sh

clean: ## Clean everything
	@docker compose down -v --rmi all 2>/dev/null || true
	@kubectl delete namespace microservices 2>/dev/null || true
	@minikube delete 2>/dev/null || true