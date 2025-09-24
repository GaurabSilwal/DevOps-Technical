# Microservices with Docker & Kubernetes

Production-ready 3-tier microservices application with Docker, Kubernetes, and CI/CD.

## Architecture

```
Frontend (React/Nginx) ←→ API (Node.js) ←→ Worker (Python)
                              ↓
                        PostgreSQL + Redis
```

## Quick Start

### Docker Compose
```bash
docker compose up -d
# Access: http://localhost
```

### Kubernetes
```bash
./scripts/deploy-all.sh
# Access: http://localhost:30080
```

## Services

- **Frontend**: React app served by Nginx (port 80/30080)
- **API**: Node.js REST API (port 3000)
- **Worker**: Python Celery background jobs
- **Database**: PostgreSQL with persistent storage
- **Cache**: Redis for caching and job queue

## Management

```bash
# Docker Compose
make up          # Start services
make down        # Stop services
make logs        # View logs

# Kubernetes
kubectl get pods -n microservices
kubectl logs -f deployment/api-service -n microservices
```

## CI/CD

GitHub Actions pipeline with:
- Automated testing on PR/push
- Docker image builds
- Kubernetes deployment
- Manual rollback workflow

## Production Features

- Multi-stage Docker builds with non-root users
- Kubernetes HPA, persistent volumes, health checks
- Resource limits and monitoring ready
- Security best practices implemented

## API Endpoints

- `GET /health` - Health check
- `GET /api/users` - List users
- `POST /api/users` - Create user

## Environment Variables

All services use environment variables defined in docker-compose.yml and k8s manifests.