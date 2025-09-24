.PHONY: help up down logs build clean

help: ## Show available commands
	@echo 'Usage: make [target]'
	@echo '  up     - Start with Docker Compose'
	@echo '  down   - Stop Docker Compose'
	@echo '  logs   - View logs'
	@echo '  build  - Build Docker images'
	@echo '  clean  - Clean everything'

up: ## Start with Docker Compose
	@docker compose up -d
	@echo "✅ Services started: http://localhost"

down: ## Stop Docker Compose
	@docker compose down

logs: ## View logs
	@docker compose logs -f

build: ## Build Docker images
	@./scripts/build-images.sh

clean: ## Clean everything
	@docker compose down -v --rmi all 2>/dev/null || true
	@kubectl delete namespace microservices 2>/dev/null || true